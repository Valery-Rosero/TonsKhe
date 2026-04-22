# 🗄️ Modelo de Base de Datos — PostgreSQL / Supabase

## Diagrama de Relaciones (Texto)

```
users
  └──< story_members >──┐
                        stories
                          └──< categories
                                  └──< plans
                                        └── outings
                                              ├── expenses (1:1)
                                              ├──< outing_photos
                                              └── outing_notes (1:1)
```

---

## Tablas

### 👤 users
> Manejada principalmente por Supabase Auth. Se extiende con una tabla `profiles`.

```sql
-- Esta tabla la gestiona Supabase Auth internamente (auth.users)
-- Solo extendemos con profiles para datos adicionales
```

---

### 👤 profiles

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `uuid` | PK, FK → auth.users(id) | ID del usuario (mismo que Supabase Auth) |
| `username` | `text` | NOT NULL | Nombre visible del usuario |
| `avatar_url` | `text` | NULLABLE | URL de la foto de perfil en Supabase Storage |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT now() | Fecha de creación del perfil |
| `updated_at` | `timestamptz` | NOT NULL, DEFAULT now() | Última actualización |

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT NOT NULL,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

### 🌍 stories

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | ID único de la Historia |
| `name` | `text` | NOT NULL | Nombre de la Historia |
| `cover_url` | `text` | NULLABLE | URL de la foto de portada |
| `invite_code` | `text` | NOT NULL, UNIQUE | Código único de invitación (6 caracteres) |
| `created_by` | `uuid` | NOT NULL, FK → profiles(id) | Usuario que creó la Historia |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT now() | Fecha de creación |
| `updated_at` | `timestamptz` | NOT NULL, DEFAULT now() | Última actualización |

```sql
CREATE TABLE stories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  cover_url TEXT,
  invite_code TEXT NOT NULL UNIQUE,
  created_by UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

### 🤝 story_members
> Tabla pivote que vincula exactamente dos usuarios por Historia.

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | ID del registro |
| `story_id` | `uuid` | NOT NULL, FK → stories(id) | Historia a la que pertenece |
| `user_id` | `uuid` | NOT NULL, FK → profiles(id) | Usuario miembro |
| `joined_at` | `timestamptz` | NOT NULL, DEFAULT now() | Fecha en que se unió |

```sql
CREATE TABLE story_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  story_id UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (story_id, user_id) -- Un usuario no puede estar dos veces en la misma Historia
);

-- Restricción: máximo 2 miembros por Historia (se valida en Edge Function)
```

---

### 🗂️ categories

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | ID de la categoría |
| `story_id` | `uuid` | NOT NULL, FK → stories(id) | Historia a la que pertenece |
| `name` | `text` | NOT NULL | Nombre de la categoría |
| `icon` | `text` | NULLABLE | Emoji o nombre de ícono |
| `color` | `text` | NULLABLE | Color en HEX (ej: #FF5733) |
| `created_by` | `uuid` | NOT NULL, FK → profiles(id) | Usuario que la creó |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT now() | Fecha de creación |
| `updated_at` | `timestamptz` | NOT NULL, DEFAULT now() | Última actualización |

```sql
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  story_id UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  icon TEXT,
  color TEXT,
  created_by UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

### 📌 plans

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | ID del plan |
| `category_id` | `uuid` | NOT NULL, FK → categories(id) | Categoría a la que pertenece |
| `story_id` | `uuid` | NOT NULL, FK → stories(id) | Historia a la que pertenece (desnormalizado para queries rápidas) |
| `name` | `text` | NOT NULL | Nombre del plan |
| `status` | `text` | NOT NULL, DEFAULT 'pending' | Estado: `pending` o `done` |
| `created_by` | `uuid` | NOT NULL, FK → profiles(id) | Usuario que lo creó |
| `completed_at` | `timestamptz` | NULLABLE | Fecha y hora en que se marcó como realizado |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT now() | Fecha de creación |
| `updated_at` | `timestamptz` | NOT NULL, DEFAULT now() | Última actualización |

```sql
CREATE TYPE plan_status AS ENUM ('pending', 'done');

CREATE TABLE plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  story_id UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  status plan_status NOT NULL DEFAULT 'pending',
  created_by UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

### 🗓️ outings
> Se crea automáticamente cuando un plan se marca como `done`.

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | ID de la salida |
| `plan_id` | `uuid` | NOT NULL, UNIQUE, FK → plans(id) | Plan asociado (1:1) |
| `story_id` | `uuid` | NOT NULL, FK → stories(id) | Historia a la que pertenece |
| `outing_date` | `timestamptz` | NOT NULL | Fecha y hora en que ocurrió la salida |
| `notes` | `text` | NULLABLE | Descripción/nota de recuerdo opcional |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT now() | Fecha de creación del registro |
| `updated_at` | `timestamptz` | NOT NULL, DEFAULT now() | Última actualización |

```sql
CREATE TABLE outings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID NOT NULL UNIQUE REFERENCES plans(id) ON DELETE CASCADE,
  story_id UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
  outing_date TIMESTAMPTZ NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

### 💸 expenses
> Una salida puede tener un único registro de gasto (1:1).

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | ID del gasto |
| `outing_id` | `uuid` | NOT NULL, UNIQUE, FK → outings(id) | Salida asociada (1:1) |
| `story_id` | `uuid` | NOT NULL, FK → stories(id) | Historia a la que pertenece |
| `total_amount` | `numeric(12,2)` | NOT NULL, CHECK > 0 | Monto total gastado en la salida |
| `currency` | `text` | NOT NULL, DEFAULT 'COP' | Moneda (ej: COP, USD) |
| `registered_by` | `uuid` | NOT NULL, FK → profiles(id) | Usuario que registró el gasto |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT now() | Fecha de registro |
| `updated_at` | `timestamptz` | NOT NULL, DEFAULT now() | Última actualización |

```sql
CREATE TABLE expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  outing_id UUID NOT NULL UNIQUE REFERENCES outings(id) ON DELETE CASCADE,
  story_id UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
  total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount > 0),
  currency TEXT NOT NULL DEFAULT 'COP',
  registered_by UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

### 📸 outing_photos

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| `id` | `uuid` | PK, DEFAULT gen_random_uuid() | ID de la foto |
| `outing_id` | `uuid` | NOT NULL, FK → outings(id) | Salida a la que pertenece |
| `story_id` | `uuid` | NOT NULL, FK → stories(id) | Historia a la que pertenece |
| `storage_path` | `text` | NOT NULL | Ruta del archivo en Supabase Storage |
| `uploaded_by` | `uuid` | NOT NULL, FK → profiles(id) | Usuario que subió la foto |
| `created_at` | `timestamptz` | NOT NULL, DEFAULT now() | Fecha de subida |

```sql
CREATE TABLE outing_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  outing_id UUID NOT NULL REFERENCES outings(id) ON DELETE CASCADE,
  story_id UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
  storage_path TEXT NOT NULL,
  uploaded_by UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

## 🔒 Row Level Security (RLS)

Todas las tablas deben tener RLS habilitado. La regla base para todas es:

> **Un usuario solo puede ver y modificar datos de las Historias a las que pertenece.**

```sql
-- Ejemplo para la tabla plans:
ALTER TABLE plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view plans of their stories"
  ON plans FOR SELECT
  USING (
    story_id IN (
      SELECT story_id FROM story_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Members can insert plans in their stories"
  ON plans FOR INSERT
  WITH CHECK (
    story_id IN (
      SELECT story_id FROM story_members WHERE user_id = auth.uid()
    )
  );

-- Aplicar el mismo patrón a: categories, outings, expenses, outing_photos
```

---

## ⚡ Edge Functions necesarias

| Función | Propósito |
|---------|-----------|
| `generate-invite-code` | Genera un código único de 6 caracteres y valida que no exista en la tabla `stories` |
| `join-story` | Valida el código, verifica que la Historia tenga menos de 2 miembros e inserta en `story_members` |
| `mark-plan-done` | Marca el plan como `done`, registra `completed_at` y crea automáticamente el registro en `outings` |
| `get-story-total-expense` | Suma todos los `total_amount` de `expenses` filtrados por `story_id` |

---

## 📊 Índices recomendados

```sql
-- Búsquedas frecuentes por story_id
CREATE INDEX idx_categories_story_id ON categories(story_id);
CREATE INDEX idx_plans_story_id ON plans(story_id);
CREATE INDEX idx_plans_category_id ON plans(category_id);
CREATE INDEX idx_plans_status ON plans(status);
CREATE INDEX idx_outings_story_id ON outings(story_id);
CREATE INDEX idx_outings_outing_date ON outings(outing_date DESC);
CREATE INDEX idx_outing_photos_story_id ON outing_photos(story_id);
CREATE INDEX idx_outing_photos_outing_id ON outing_photos(outing_id);
CREATE INDEX idx_expenses_story_id ON expenses(story_id);
CREATE INDEX idx_story_members_user_id ON story_members(user_id);
```
