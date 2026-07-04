# Sistema de diseño — "Toxic Pulse"

Basado en el prototipo `TonsKhe Prototype (standalone).html` (23 pantallas). Los tokens viven en `lib/core/theme/app_colors.dart` y `lib/core/theme/app_theme.dart` — este documento explica el porqué, no repite el código.

## Paleta

| Token | Hex | Uso |
|---|---|---|
| `background` | `#0A0C10` | Fondo base (poco usado directamente; la mayoría de pantallas usan el gradiente) |
| `backgroundGradient` | `#1D2331 → #12161F` | Fondo de casi todas las pantallas (login, registro, home, hub, etc.) |
| `primaryAccent` | `#8B53FE` (violeta) | Acento principal: botones primarios, elementos activos |
| `secondaryAccent` | `#8EFF01` (lima) | Acento secundario: links, códigos de invitación, estados positivos |
| `surface` | `#1D2331` | Fondo de tarjetas e inputs |
| `border` | `#2B3345` | Bordes de inputs y separadores |
| `textPrimary` | `#F5F5F0` | Texto principal (blanco hueso, **no** `#FFFFFF` puro) |
| `textSecondary` | `#9A9AA8` | Subtítulos, labels |
| `textMuted` | `#8A8A9E` | Texto terciario (menos jerarquía que secondary) |
| `textPlaceholder` | `#5C5C6B` | Placeholders dentro de inputs |
| `textBody` | `#B4B4C2` | Cuerpo de texto largo (descripciones) |
| `primaryContainer` / `primaryContainerAlt` | `#241A3D` / `#1C1430` | Fondo de pills/badges violeta (dos tonos ligeramente distintos, usados según el contexto en el prototipo) |
| `secondaryContainer` | `#1C2410` | Fondo de pills/badges lima |
| `error` | `#FF5252` | Bordes/mensajes de error (no viene del prototipo — es una adición razonable, el prototipo no muestra estados de error) |

`AppColors.welcomeGradient` es un gradiente especial (lima → violeta oscuro → gris azulado → violeta) usado **solo** en la pantalla de bienvenida (splash) y en la de resultado de la ruleta — son las dos pantallas "hero" del prototipo, todo lo demás usa `backgroundGradient`.

## Tipografía

- **Space Grotesk** — títulos de pantalla, el wordmark "TonsKhe", labels de botones. Se accede vía `AppTextStyles.heading(fontSize:, fontWeight:, color:)` en `app_theme.dart`, no escribiendo `GoogleFonts.spaceGrotesk(...)` suelto en cada pantalla.
- **Manrope** — todo lo demás (cuerpo, labels de formulario, texto secundario). Es la fuente **por defecto del tema** (`AppTheme.darkTheme.textTheme`), así que cualquier `Text(style: TextStyle(fontSize: ..., color: ...))` sin `fontFamily` explícito ya sale en Manrope automáticamente — no hace falta tocarlo pantalla por pantalla.

> El brief inicial pedía Inter. El prototipo real usa Space Grotesk + Manrope — se priorizó el prototipo por ser la fuente de verdad más reciente y explícita.

## Formas

- **Botones**: siempre píldora (`StadiumBorder()`), nunca esquinas redondeadas parciales. Ver `AppPrimaryButton`/`AppSecondaryButton` en `presentation/widgets/common/custom_button.dart`.
- **Inputs**: esquinas de 14px, borde de 2px (no 1px — es el valor exacto del prototipo, un borde de 1px se ve notablemente más débil sobre el fondo oscuro).
- **Tarjetas** (stories, listas): esquinas de 18–20px, con sombra suave (`boxShadow` con `alpha: 0.14`, no elevación de Material por defecto).
- **Pills/badges** (estado, categoría, código): `borderRadius: 999` (círculo completo en los extremos).

## Componentes compartidos

Todo widget reutilizable vive en `presentation/widgets/common/`:

- `AppPrimaryButton` / `AppSecondaryButton` — botones píldora con estado de carga incorporado (`isLoading` reemplaza el label por un spinner, no lo pone al lado).
- `AppTextField` — input con label flotante, ícono opcional, alternar visibilidad de contraseña, `inputFormatters`/`maxLength` opcionales.
- `AppLoadingIndicator` — spinner en `primaryAccent`.
- `AppSnackBar` (+ extensión `context.showErrorSnackBar` / `context.showSuccessSnackBar` en `core/utils/extensions.dart`) — snackbar con estilo consistente; nunca se usa `ScaffoldMessenger` directo en una pantalla.

Y específicos de Historias en `presentation/widgets/stories/`: `StoryCard`, `InviteCodeWidget`.

**Regla seguida en todo el código**: cero valores hexadecimales sueltos fuera de `app_colors.dart`. Cualquier color en una pantalla se referencia como `AppColors.algo`. Esto es lo que permitió que, al actualizar la paleta completa para igualar el prototipo, ninguna pantalla necesitara tocarse por color — solo cambió `app_colors.dart` y todo se propagó solo.

## Decisiones de UX que se alejan del prototipo (y por qué)

- **Splash como gate + bienvenida, no solo bienvenida.** El prototipo muestra la pantalla de bienvenida como estática. En la app real, `/` primero resuelve si hay sesión activa (muestra un spinner brevemente) y solo si no hay sesión se ve el contenido de bienvenida — necesario porque un usuario que vuelve a abrir la app no debería ver "Crear cuenta" de nuevo.
- **Código de invitación se muestra después de crear, no antes.** El prototipo muestra el código dentro del mismo formulario de creación (como si ya existiera antes de guardar). En la implementación real el código lo genera el backend (Edge Function `generate-invite-code`) recién cuando se confirma la creación, así que se muestra en una pantalla de éxito posterior — generar y mostrar un código "de prueba" antes de guardar crearía códigos huérfanos si el usuario abandona el formulario.
- **Botón "Compartir" del código no implementado**, solo "Copiar" — requeriría agregar el paquete `share_plus`, que no estaba en el alcance pedido.
