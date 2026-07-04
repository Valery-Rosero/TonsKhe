# Avances

Última actualización: 2026-07-03.

## Estado por módulo

| Módulo | Estado | Notas |
|---|---|---|
| **Auth** | ✅ Completo y funcional | Registro (correo o teléfono), login, recuperación de contraseña (correo + OTP por teléfono), persistencia de sesión con `flutter_secure_storage`, guardas de navegación por sesión. Sin Google/OAuth (se decidió no incluirlo). |
| **Historias** | ✅ Completo y funcional | Crear, unirse por código (Edge Functions), listar en tiempo real, hub con bottom nav de 4 tabs. |
| **Categorías** | 🕳️ Solo scaffold | Carpetas y archivos vacíos nombrados (`categories_entity.dart`, `categories_model.dart`, etc.), sin lógica. |
| **Planes** | 🕳️ Solo scaffold | Igual que arriba. |
| **Salidas (outings)** | 🕳️ Solo scaffold | Corresponde a la tab "Historial" del hub. |
| **Gastos (expenses)** | 🕳️ Solo scaffold | |
| **Fotos (photos)** | 🕳️ Solo scaffold | Corresponde a la tab "Álbum". |
| **Ruleta (roulette)** | 🕳️ Solo scaffold | |

"Solo scaffold" significa: la estructura de carpetas por capa existe (`domain/entities/<módulo>`, `domain/usecases/<módulo>`, etc.) con archivos vacíos ya nombrados correctamente, pero sin ninguna clase implementada todavía. Es el punto de partida para implementar cada módulo sin tener que decidir de nuevo la estructura de archivos.

## Detalle: Auth

- `sign_in_usecase.dart`, `sign_up_usecase.dart`, `sign_out_usecase.dart`, `recover_password_usecase.dart`.
- Validaciones en `core/utils/validators.dart`: email, teléfono colombiano (`+57XXXXXXXXXX`), contraseña (8+ caracteres, mayúscula, número).
- 4 pantallas: `splash_page.dart` (ahora es la pantalla de bienvenida real, no solo un loader), `login_page.dart`, `register_page.dart` (con checkbox de términos), `recover_password_page.dart` (flujo de 2 pasos para teléfono: pedir OTP → verificar OTP + nueva contraseña).
- Pendiente/fuera de alcance: no hay pantalla de "editar perfil" todavía (el prototipo la define como pantalla 23, "Perfil & Configuración", no implementada).

## Detalle: Historias

- `create_story_usecase.dart`, `join_story_usecase.dart`, `get_stories_usecase.dart`, `update_story_usecase.dart`.
- 4 pantallas: `home_page.dart` (lista + estado vacío + FAB), `create_story_page.dart` (nombre + portada opcional + código generado), `join_story_page.dart` (código de 6 caracteres), `story_detail_page.dart` (hub con bottom nav).
- Las 4 tabs del hub (`categorías`, `historial`, `álbum`, `ruleta`) están enrutadas y navegables, pero su contenido es un placeholder ("— próximamente"). Implementarlas es lo que corresponde a los módulos Categorías/Planes/Salidas/Gastos/Fotos/Ruleta de la tabla de arriba.
- Depende de dos Edge Functions desplegadas en Supabase (fuera de este repo): `generate-invite-code` y `join-story`. Ver [`architecture.md`](architecture.md#edge-functions-viven-fuera-de-este-repo) para el contrato exacto.

## Decisiones tomadas durante el desarrollo (y por qué)

- **Sin Google Sign-In.** Se implementó y luego se quitó a pedido explícito ("mucha vuelta"). Login/registro son solo correo o teléfono.
- **Colombia / COP / +57, no Perú / PEN / +51.** El prototipo visual usa "S/" y "+51" como placeholders del diseñador; se confirmó explícitamente mantener la lógica ya implementada para Colombia.
- **`story-covers` es un bucket público de Storage**, a diferencia de `avatars` y `outing-photos` (privados). Es necesario para poder usar `getPublicUrl()` + `CachedNetworkImage` sin firmar URLs; el acceso real sigue estando controlado por RLS en la tabla `stories`, no por el bucket. Ver la migración `docs/database/003_story_covers_public_bucket.sql`.
- **Las Edge Functions no viven en este repositorio.** Se generaron aquí en un primer momento y se removieron a pedido explícito: el contrato de datos quedó documentado en `architecture.md`, pero el código Deno/TypeScript se administra directamente en el proyecto de Supabase.
- **`StatefulShellRoute` no se usó todavía** para las tabs del hub (ver `architecture.md`) — se prefirieron 4 rutas planas mientras las tabs sean placeholders.

## Siguientes pasos sugeridos

1. Implementar el módulo **Categorías** (probablemente el siguiente, ya que Planes depende de él).
2. Implementar **Planes** (usecases de crear/editar/marcar como realizado — esto ya dispara el trigger `handle_plan_completed` que crea el `outing` automáticamente, ver `schema.sql`).
3. Implementar **Salidas/Historial** y **Gastos** (1:1 con `outings`).
4. Implementar **Fotos/Álbum**.
5. Implementar **Ruleta**.
6. Evaluar migrar el hub a `StatefulShellRoute` si alguna tab necesita su propia sub-navegación.
