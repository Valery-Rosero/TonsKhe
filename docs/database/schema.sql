-- ============================================================
-- TonsKhe — Script SQL completo para Supabase
-- Ejecutar en el SQL Editor de Supabase en este orden
-- ============================================================

-- ============================================================
-- 0. EXTENSIONES
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- ============================================================
-- 1. TIPOS PERSONALIZADOS
-- ============================================================
CREATE TYPE plan_status AS ENUM ('pending', 'done');


-- ============================================================
-- 2. TABLA: profiles
-- Extiende auth.users con datos adicionales del usuario
-- ============================================================
CREATE TABLE profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username    TEXT NOT NULL,
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Trigger para crear perfil automáticamente al registrarse
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, username)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();


-- ============================================================
-- 3. TABLA: stories
-- Espacios compartidos entre dos personas
-- ============================================================
CREATE TABLE stories (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT NOT NULL,
  cover_url    TEXT,
  invite_code  TEXT NOT NULL UNIQUE,
  created_by   UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ============================================================
-- 4. TABLA: story_members
-- Vincula exactamente 2 usuarios por Historia
-- ============================================================
CREATE TABLE story_members (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  story_id    UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  joined_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (story_id, user_id)
);

-- Restricción: máximo 2 miembros por Historia
CREATE OR REPLACE FUNCTION check_story_members_limit()
RETURNS TRIGGER AS $$
BEGIN
  IF (
    SELECT COUNT(*) FROM story_members WHERE story_id = NEW.story_id
  ) >= 2 THEN
    RAISE EXCEPTION 'Una Historia no puede tener más de 2 miembros';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_story_members_limit
  BEFORE INSERT ON story_members
  FOR EACH ROW EXECUTE FUNCTION check_story_members_limit();


-- ============================================================
-- 5. TABLA: categories
-- Categorías personalizadas dentro de cada Historia
-- ============================================================
CREATE TABLE categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  story_id    UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  icon        TEXT,
  color       TEXT,
  created_by  UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ============================================================
-- 6. TABLA: plans
-- Planes dentro de cada categoría
-- ============================================================
CREATE TABLE plans (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id   UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  story_id      UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
  name          TEXT NOT NULL,
  status        plan_status NOT NULL DEFAULT 'pending',
  created_by    UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  completed_at  TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ============================================================
-- 7. TABLA: outings
-- Se crea cuando un plan se marca como realizado
-- ============================================================
CREATE TABLE outings (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id      UUID NOT NULL UNIQUE REFERENCES plans(id) ON DELETE CASCADE,
  story_id     UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
  outing_date  TIMESTAMPTZ NOT NULL,
  notes        TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Trigger: al marcar un plan como done, crea automáticamente el outing
CREATE OR REPLACE FUNCTION handle_plan_completed()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'done' AND OLD.status = 'pending' THEN
    NEW.completed_at = now();
    INSERT INTO outings (plan_id, story_id, outing_date)
    VALUES (NEW.id, NEW.story_id, now());
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_plan_completed
  BEFORE UPDATE ON plans
  FOR EACH ROW EXECUTE FUNCTION handle_plan_completed();


-- ============================================================
-- 8. TABLA: expenses
-- Gasto total por salida (relación 1:1 con outings)
-- ============================================================
CREATE TABLE expenses (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  outing_id       UUID NOT NULL UNIQUE REFERENCES outings(id) ON DELETE CASCADE,
  story_id        UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
  total_amount    NUMERIC(12,2) NOT NULL CHECK (total_amount > 0),
  currency        TEXT NOT NULL DEFAULT 'COP',
  registered_by   UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ============================================================
-- 9. TABLA: outing_photos
-- Fotos asociadas a cada salida
-- ============================================================
CREATE TABLE outing_photos (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  outing_id     UUID NOT NULL REFERENCES outings(id) ON DELETE CASCADE,
  story_id      UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
  storage_path  TEXT NOT NULL,
  uploaded_by   UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ============================================================
-- 10. ÍNDICES
-- ============================================================
CREATE INDEX idx_story_members_user_id     ON story_members(user_id);
CREATE INDEX idx_story_members_story_id    ON story_members(story_id);
CREATE INDEX idx_categories_story_id       ON categories(story_id);
CREATE INDEX idx_plans_story_id            ON plans(story_id);
CREATE INDEX idx_plans_category_id         ON plans(category_id);
CREATE INDEX idx_plans_status              ON plans(status);
CREATE INDEX idx_outings_story_id          ON outings(story_id);
CREATE INDEX idx_outings_outing_date       ON outings(outing_date DESC);
CREATE INDEX idx_expenses_story_id         ON expenses(story_id);
CREATE INDEX idx_outing_photos_story_id    ON outing_photos(story_id);
CREATE INDEX idx_outing_photos_outing_id   ON outing_photos(outing_id);


-- ============================================================
-- 11. ROW LEVEL SECURITY (RLS)
-- Patrón base: solo los miembros de una Historia acceden a sus datos
-- ============================================================

-- Helper function reutilizable
CREATE OR REPLACE FUNCTION is_story_member(p_story_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM story_members
    WHERE story_id = p_story_id AND user_id = auth.uid()
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
  ON profiles FOR SELECT USING (id = auth.uid());

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE USING (id = auth.uid());

-- stories
ALTER TABLE stories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view their stories"
  ON stories FOR SELECT USING (is_story_member(id));

CREATE POLICY "Authenticated users can create stories"
  ON stories FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Members can update their stories"
  ON stories FOR UPDATE USING (is_story_member(id));

-- story_members
ALTER TABLE story_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view story members"
  ON story_members FOR SELECT USING (is_story_member(story_id));

CREATE POLICY "Authenticated users can join stories"
  ON story_members FOR INSERT WITH CHECK (auth.uid() = user_id);

-- categories
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view categories"
  ON categories FOR SELECT USING (is_story_member(story_id));

CREATE POLICY "Members can insert categories"
  ON categories FOR INSERT WITH CHECK (is_story_member(story_id));

CREATE POLICY "Members can update categories"
  ON categories FOR UPDATE USING (is_story_member(story_id));

CREATE POLICY "Members can delete categories"
  ON categories FOR DELETE USING (is_story_member(story_id));

-- plans
ALTER TABLE plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view plans"
  ON plans FOR SELECT USING (is_story_member(story_id));

CREATE POLICY "Members can insert plans"
  ON plans FOR INSERT WITH CHECK (is_story_member(story_id));

CREATE POLICY "Members can update plans"
  ON plans FOR UPDATE USING (is_story_member(story_id));

CREATE POLICY "Members can delete plans"
  ON plans FOR DELETE USING (is_story_member(story_id));

-- outings
ALTER TABLE outings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view outings"
  ON outings FOR SELECT USING (is_story_member(story_id));

CREATE POLICY "Members can update outings"
  ON outings FOR UPDATE USING (is_story_member(story_id));

-- expenses
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view expenses"
  ON expenses FOR SELECT USING (is_story_member(story_id));

CREATE POLICY "Members can insert expenses"
  ON expenses FOR INSERT WITH CHECK (is_story_member(story_id));

CREATE POLICY "Members can update expenses"
  ON expenses FOR UPDATE USING (is_story_member(story_id));

CREATE POLICY "Members can delete expenses"
  ON expenses FOR DELETE USING (is_story_member(story_id));

-- outing_photos
ALTER TABLE outing_photos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view photos"
  ON outing_photos FOR SELECT USING (is_story_member(story_id));

CREATE POLICY "Members can insert photos"
  ON outing_photos FOR INSERT WITH CHECK (is_story_member(story_id));

CREATE POLICY "Members can delete photos"
  ON outing_photos FOR DELETE USING (is_story_member(story_id));


-- ============================================================
-- 12. REALTIME
-- Habilitar sincronización en tiempo real por tabla
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE categories;
ALTER PUBLICATION supabase_realtime ADD TABLE plans;
ALTER PUBLICATION supabase_realtime ADD TABLE outings;
ALTER PUBLICATION supabase_realtime ADD TABLE expenses;
ALTER PUBLICATION supabase_realtime ADD TABLE outing_photos;
ALTER PUBLICATION supabase_realtime ADD TABLE stories;
ALTER PUBLICATION supabase_realtime ADD TABLE story_members;


-- ============================================================
-- 13. STORAGE
-- Crear buckets para fotos y avatares
-- ============================================================
-- story-covers is public: the app stores a plain getPublicUrl() in
-- stories.cover_url and renders it with CachedNetworkImage. Access to the
-- underlying story row is still gated by RLS on `stories`/`story_members`.
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('avatars', 'avatars', false),
  ('story-covers', 'story-covers', true),
  ('outing-photos', 'outing-photos', false);

-- Políticas de Storage: solo miembros acceden a sus archivos
CREATE POLICY "Users can upload their own avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can view their own avatar"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Members can upload outing photos"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'outing-photos');

CREATE POLICY "Members can view outing photos"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'outing-photos');

CREATE POLICY "Members can delete outing photos"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'outing-photos');

CREATE POLICY "Members can upload story covers"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'story-covers');

CREATE POLICY "Members can view story covers"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'story-covers');
