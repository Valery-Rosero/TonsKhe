-- ============================================================
-- TonsKhe — Arreglo de advertencias del Security Advisor de Supabase
-- Resuelve:
--   * function_search_path_mutable (0011)
--   * anon/authenticated_security_definer_function_executable (0028/0029)
--
-- Ejecutar UNA VEZ en el SQL Editor de Supabase, después de schema.sql.
-- Después, vuelve a correr el Security Advisor para confirmar que
-- las advertencias desaparecieron.
-- ============================================================


-- ============================================================
-- 1. Esquema privado (NO expuesto por la API REST)
--    Las funciones aquí no serán llamables como /rest/v1/rpc/...
-- ============================================================
CREATE SCHEMA IF NOT EXISTS private;

-- Los roles necesitan USAGE en el esquema para que las políticas RLS
-- puedan invocar la función de ayuda que vive aquí.
GRANT USAGE ON SCHEMA private TO anon, authenticated;


-- ============================================================
-- 2. Mover las funciones fuera del esquema public (expuesto)
--    Los triggers y las políticas RLS siguen funcionando: Postgres
--    las referencia por identidad interna, no por nombre.
-- ============================================================
ALTER FUNCTION public.handle_new_user()             SET SCHEMA private;
ALTER FUNCTION public.check_story_members_limit()   SET SCHEMA private;
ALTER FUNCTION public.handle_plan_completed()       SET SCHEMA private;
ALTER FUNCTION public.is_story_member(uuid)         SET SCHEMA private;


-- ============================================================
-- 3. Recrear cada función con search_path fijo ('') y tablas
--    escritas con su esquema completo (public.*, auth.*).
--    CREATE OR REPLACE conserva la identidad, así que triggers
--    y políticas quedan intactos.
-- ============================================================

-- 3.1 Crea el perfil al registrarse un usuario
CREATE OR REPLACE FUNCTION private.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.profiles (id, username)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$;

-- 3.2 Máximo 2 miembros por Historia
CREATE OR REPLACE FUNCTION private.check_story_members_limit()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  IF (
    SELECT COUNT(*) FROM public.story_members WHERE story_id = NEW.story_id
  ) >= 2 THEN
    RAISE EXCEPTION 'Una Historia no puede tener más de 2 miembros';
  END IF;
  RETURN NEW;
END;
$$;

-- 3.3 Al marcar un plan como "done", crea el outing automáticamente
CREATE OR REPLACE FUNCTION private.handle_plan_completed()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF NEW.status = 'done' AND OLD.status = 'pending' THEN
    NEW.completed_at = now();
    INSERT INTO public.outings (plan_id, story_id, outing_date)
    VALUES (NEW.id, NEW.story_id, now());
  END IF;
  RETURN NEW;
END;
$$;

-- 3.4 Función de ayuda usada en TODAS las políticas RLS
CREATE OR REPLACE FUNCTION private.is_story_member(p_story_id uuid)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.story_members
    WHERE story_id = p_story_id AND user_id = auth.uid()
  );
$$;


-- ============================================================
-- 4. is_story_member se llama dentro de las políticas RLS, así que
--    los roles que consultan deben poder ejecutarla.
--    (Sigue sin estar expuesta por la API: private no es un esquema
--    publicado por PostgREST.)
-- ============================================================
GRANT EXECUTE ON FUNCTION private.is_story_member(uuid) TO anon, authenticated;
