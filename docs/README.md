# Documentación de TonsKhe

- [`architecture.md`](architecture.md) — Clean Architecture, convenciones de Riverpod, router y guardas de sesión, manejo de errores, contrato de las Edge Functions.
- [`progress.md`](progress.md) — qué módulos están implementados, cuáles son solo scaffold, y decisiones tomadas durante el desarrollo (y por qué).
- [`design-system.md`](design-system.md) — paleta "Toxic Pulse", tipografía, formas, componentes compartidos.
- [`setup.md`](setup.md) — cómo correr el proyecto localmente (variables de entorno, Supabase, comandos).
- [`gitflow.md`](gitflow.md) — flujo de ramas (Git Flow): `main`, `develop`, `feature/*`, `release/*`, `hotfix/*`.
- [`database/`](database/) — esquema SQL, políticas RLS, Storage, y migraciones, en orden: `schema.sql` → `security_fixes.sql` → `003_story_covers_public_bucket.sql`.
