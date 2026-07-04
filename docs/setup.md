# Cómo correr el proyecto

## Requisitos

- Flutter 3.44+ / Dart 3.12+ (el proyecto fija `sdk: ^3.11.5` en `pubspec.yaml`).
- Un proyecto de Supabase ya creado, con el esquema de [`database/schema.sql`](database/schema.sql) y las correcciones de [`database/security_fixes.sql`](database/security_fixes.sql) ejecutadas (en ese orden), más la migración [`database/003_story_covers_public_bucket.sql`](database/003_story_covers_public_bucket.sql).
- Las Edge Functions `generate-invite-code` y `join-story` desplegadas en ese mismo proyecto de Supabase (el código de esas funciones no vive en este repositorio — ver [`architecture.md`](architecture.md#edge-functions-viven-fuera-de-este-repo) para el contrato que el cliente espera).

## Variables de entorno

Copiar `.env.example` a `.env` (en la raíz del proyecto, junto a `pubspec.yaml`) y completar:

```
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key
```

`.env` está en `.gitignore` — nunca se commitea. `.env` es un asset declarado en `pubspec.yaml` (`flutter: assets: - .env`), así que si falta el archivo la app no compila/arranca.

## Primer arranque

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # genera los *.g.dart de Riverpod
flutter run
```

Hay que volver a correr `build_runner` cada vez que se edite un archivo `*_provider.dart` o `app_router.dart` (cualquier cosa anotada con `@riverpod`/`@Riverpod`).

## Verificar que todo esté sano

```bash
flutter analyze
flutter test
```

Ambos deberían salir limpios antes de dar por terminado cualquier cambio.

## Notas de la configuración de Supabase Auth

- **Email provider**: habilitado, longitud mínima de contraseña recomendada: 8 (la validación del cliente ya exige 8+, mayúscula y número — un mínimo del servidor más bajo, como 6, no rompe nada, simplemente es más permisivo del lado del servidor que del cliente).
- **Google/OAuth**: no se usa. No hace falta configurar ningún provider externo.
- **Phone provider**: debe estar habilitado para que funcionen el registro por teléfono y la recuperación de contraseña por OTP/SMS.
