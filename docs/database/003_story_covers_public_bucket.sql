-- ============================================================
-- TonsKhe — hace público el bucket de portadas de Historias
--
-- El módulo de Historias sube la portada a Storage y guarda una
-- URL pública (getPublicUrl) en stories.cover_url para poder
-- mostrarla con CachedNetworkImage sin firmar URLs. Esto solo
-- funciona si el bucket es público; la tabla `stories` y sus
-- políticas RLS siguen restringiendo quién puede ver el registro
-- que referencia esa URL.
--
-- Ejecutar UNA VEZ en el SQL Editor de Supabase.
-- ============================================================

UPDATE storage.buckets SET public = true WHERE id = 'story-covers';
