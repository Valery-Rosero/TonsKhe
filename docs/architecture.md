# Arquitectura

TonsKhe sigue **Clean Architecture** con tres capas (`domain`, `data`, `presentation`) sobre un backend Supabase. El objetivo de la separación es que `domain` no sepa que Supabase existe, y que `presentation` no sepa cómo se guardan los datos.

```
lib/
├── core/            # Config, tema, router, utils, errores — transversal a todo
├── domain/          # Entidades, contratos de repositorio (abstract), casos de uso
├── data/             # Modelos (JSON), datasources (Supabase), implementaciones de repositorio
└── presentation/     # Providers (Riverpod), páginas, widgets
```

## Flujo de una operación (ejemplo: crear una Historia)

```
CreateStoryPage
  → ref.read(createStoryUseCaseProvider).call(...)   [presentation/providers]
    → CreateStoryUseCase.call(...)                    [domain/usecases]
      → StoriesRepository.createStory(...)            [domain/repositories — contrato abstracto]
        → StoriesRepositoryImpl.createStory(...)      [data/repositories — implementación real]
          → StoriesRemoteDataSource.*                 [data/datasources — llamadas Supabase/Edge Functions]
```

Cada capa solo conoce la inmediatamente inferior. `domain` define **interfaces** (`abstract class XRepository`); `data` las implementa. Esto permite, en teoría, cambiar Supabase por otro backend sin tocar `domain` ni `presentation`.

## Por qué estas decisiones

- **Modelos extienden entidades** (`class UserModel extends UserEntity`) en vez de tener un mapper aparte. Menos boilerplate para un proyecto de este tamaño; el modelo solo añade `fromJson`/`toJson`.
- **Los repositorios traducen errores.** Nada en `presentation` debería hacer `catch (PostgrestException)`. Cada `*RepositoryImpl` tiene un `_mapError` que convierte excepciones de Supabase (`AuthException`, `PostgrestException`, `StorageException`, `FunctionException`) en `AppException(String message)` con un mensaje ya listo para mostrar en un `SnackBar`.
- **Los datasources no traducen errores** — solo hacen la llamada cruda y dejan que la excepción de Supabase suba. La traducción vive en el repositorio, no duplicada en cada datasource.
- **Streams para tiempo real, no polling.** `StoriesRepositoryImpl.userStories` combina el stream de `stories` y el de `story_members` (dos señales de "algo cambió") y ante cualquiera de los dos vuelve a pedir la lista completa con el conteo de miembros embebido. Ver el comentario en el propio archivo para el porqué de no usar `.select()` con embeds dentro de `.stream()` (Supabase no lo soporta).

## Riverpod: convención de código generado

Todos los providers usan `riverpod_annotation` (`@riverpod` / `@Riverpod(keepAlive: true)`), no la sintaxis manual (`Provider((ref) => ...)`). Tras editar cualquier archivo `*_provider.dart` hay que regenerar:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Reglas usadas en este proyecto:
- `keepAlive: true` en todo lo que sea sesión/estado de app (auth, stories, router). Sin esto, Riverpod destruye el provider en cuanto la última pantalla que lo observa se cierra, y se perdería el stream de sesión.
- El nombre del provider generado para una clase `XNotifier` es `xProvider`, **no** `xNotifierProvider` (riverpod_generator recorta el sufijo `Notifier`). Ver `authProvider` en `lib/presentation/providers/auth/auth_provider.dart`.
- `Ref` es un tipo único y genérico en Riverpod 3 (ya no hay `AuthRepositoryRef` por-provider como en Riverpod 2).

## Router (go_router) y guardas de sesión

`app_router.dart` expone `appRouterProvider`, no una instancia estática. El `redirect` centraliza toda la lógica de sesión:

- Mientras `authProvider` está en `AsyncLoading` → se queda en `/` (splash).
- Sin sesión → puede quedarse en `/`, `/login`, `/register`, `/recover-password`; cualquier otra ruta lo manda a `/login`.
- Con sesión → si está en `/`, `/login`, etc., lo manda a `/home`.

El truco para que `go_router` vuelva a evaluar `redirect` exactamente cuando cambia la sesión (y no antes/después por una carrera entre streams) es `_RouterRefreshNotifier`: un `ChangeNotifier` que hace `ref.listen(authProvider, ...)` — es decir, escucha el **mismo** provider que el `redirect` lee con `ref.read`, no un stream derivado por separado.

### Rutas anidadas de una Historia

Las 4 tabs del hub de una Historia (`categorías`, `historial`, `álbum`, `ruleta`) son 4 `GoRoute` planos que comparten el patrón `/story/:id/<tab>`, todos apuntando al mismo widget `StoryDetailPage(storyId, tabIndex)`. Se evaluó `StatefulShellRoute.indexedStack` (el patrón "correcto" para bottom nav con navegación anidada por tab), pero se descartó por ahora: como las 4 tabs son placeholders sin navegación interna propia, el beneficio de `StatefulShellRoute` (preservar el stack de navegación de cada tab) no aplica todavía. Si en el futuro alguna tab gana su propia sub-navegación, ese es el momento de migrar.

## Manejo de errores de usuario

`AppException` (en `core/errors/app_exception.dart`) es la única excepción que `presentation` conoce. Regla seguida en los repositorios de auth:

- Errores de login con credenciales incorrectas → mensaje genérico ("Correo o contraseña incorrectos"), **sin decir cuál campo falló** (evita revelar si un correo existe).
- Errores de registro con correo/teléfono ya usado → mensaje específico y claro.

## Persistencia de sesión

Supabase por defecto persiste la sesión con `SharedPreferences`. Este proyecto la reemplaza por `SecureLocalStorage` (`core/config/secure_local_storage.dart`), que implementa la interfaz `LocalStorage` de `supabase_flutter` usando `flutter_secure_storage` (Keystore/Keychain), no shared prefs en texto plano.

## Edge Functions (viven fuera de este repo)

`generate-invite-code` y `join-story` corren en el proyecto de Supabase (dashboard/CLI), **no** en este repositorio — se decidió así explícitamente para no mezclar código de infraestructura Supabase con el cliente Flutter. El contrato que el cliente Flutter espera de cada una:

| Función | Body | Respuesta OK | Por qué existe como Edge Function y no como insert directo desde el cliente |
|---|---|---|---|
| `generate-invite-code` | `{ name, cover_url? }` | `{ story_id, invite_code, name, created_at }` | Crea la Historia **y** agrega al creador a `story_members` en una sola llamada server-side; además necesita permisos elevados para verificar que el código generado sea único contra *todas* las Historias (RLS le ocultaría las de otros usuarios a una consulta normal). |
| `join-story` | `{ invite_code }` | `{ story_id, name, cover_url, created_at, message }` | Para buscar una Historia por código, un usuario que todavía no es miembro necesita saltarse RLS (que exige ya ser miembro para hacer `SELECT` sobre `stories`) — solo el service role puede hacer esa búsqueda. También valida el límite de 2 miembros. |

`StoriesRemoteDataSource` solo llama estas funciones y luego re-hidrata con `getStoryById` (un `SELECT` normal, ya con RLS a favor una vez el usuario es miembro) para obtener una fila consistente con el resto del código (incluye `updated_at` y el conteo de miembros).

## Ver también

- [`progress.md`](progress.md) — qué módulos están implementados y cuáles son solo scaffold.
- [`design-system.md`](design-system.md) — paleta, tipografía y convenciones de UI.
- [`setup.md`](setup.md) — cómo correr el proyecto localmente.
- [`database/schema.sql`](database/schema.sql) — esquema completo de Postgres/RLS/Storage.
