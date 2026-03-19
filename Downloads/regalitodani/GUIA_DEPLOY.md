# 🎀 Guía de deploy — regalitodani

## Antes de empezar, necesitas tener:
- ✅ Cuenta en **Supabase** (ya la tienes)
- ✅ Cuenta en **Vercel** (gratis en vercel.com)
- ✅ Cuenta en **Resend** (gratis en resend.com)
- ✅ **Node.js** instalado en tu computador (descárgalo en nodejs.org si no lo tienes)
- ✅ **Git** instalado (git-scm.com)

---

## PASO 1 — Configurar Supabase (5 min)

1. Ve a **supabase.com** → entra a tu proyecto `regalitodani`
2. En el menú izquierdo haz clic en **SQL Editor**
3. Haz clic en **New query**
4. Copia y pega todo el contenido del archivo `supabase_schema.sql`
5. Haz clic en **Run** (el botón verde)
6. Deberías ver: `Success. No rows returned` ✅

---

## PASO 2 — Crear cuenta en Resend y obtener API Key (5 min)

1. Ve a **resend.com** y haz clic en **Get started for free**
2. Regístrate con tu correo (vale.roserom23@gmail.com)
3. Confirma tu correo
4. Una vez dentro, ve al menú **API Keys** (barra izquierda)
5. Haz clic en **Create API Key**
   - Name: `regalitodani`
   - Permission: **Full access**
   - Haz clic en **Add**
6. ¡Copia la clave! Empieza por `re_...` — **guárdala, solo se muestra una vez**

> ⚠️ Con el plan gratis de Resend solo puedes enviar a emails verificados.
> Ve a **Domains** → **Add Domain** y agrega tu dominio, O bien:
> Ve a **Emails** → necesitas verificar `vale.roserom23@gmail.com` como destinatario.
> La forma más fácil es en **Contacts** → verificar tu propio email como destinatario.

---

## PASO 3 — Subir el proyecto a GitHub (5 min)

1. Ve a **github.com** → crea una cuenta si no tienes
2. Haz clic en **New repository**
   - Nombre: `regalitodani`
   - Privado ✅ (para que nadie más lo vea)
   - Haz clic en **Create repository**
3. Abre una terminal en tu computador y navega hasta la carpeta del proyecto:
   ```bash
   cd regalitodani
   ```
4. Ejecuta estos comandos uno por uno:
   ```bash
   git init
   git add .
   git commit -m "Regalo para Danilo 💌"
   git branch -M main
   git remote add origin https://github.com/TU_USUARIO/regalitodani.git
   git push -u origin main
   ```
   *(Reemplaza `TU_USUARIO` con tu usuario de GitHub)*

---

## PASO 4 — Deploy en Vercel (5 min)

1. Ve a **vercel.com** → regístrate con tu cuenta de GitHub
2. Haz clic en **Add New → Project**
3. Importa el repositorio `regalitodani`
4. Antes de hacer clic en Deploy, haz clic en **Environment Variables** y agrega estas una por una:

   | Nombre | Valor |
   |--------|-------|
   | `NEXT_PUBLIC_SUPABASE_URL` | `https://hwkgqjojmpbnrdhsudqv.supabase.co` |
   | `NEXT_PUBLIC_SUPABASE_ANON_KEY` | `sb_publishable_HN4MTwdUj_KFVXHIdqNMxA_bKZwGVJr` |
   | `RESEND_API_KEY` | `re_XXXXXXXX` *(la que copiaste en el paso 2)* |
   | `NOTIFY_EMAIL` | `vale.roserom23@gmail.com` |
   | `NEXT_PUBLIC_ACCESS_PASSWORD` | `terroncito` *(o la contraseña que quieras)* |

5. Haz clic en **Deploy** 🚀
6. Espera 2-3 minutos mientras construye
7. ¡Listo! Te dará una URL tipo `regalitodani.vercel.app`

---

## PASO 5 — Cambiar la contraseña (opcional)

Si quieres usar otra contraseña diferente a `terroncito`:
- En Vercel → tu proyecto → **Settings → Environment Variables**
- Edita `NEXT_PUBLIC_ACCESS_PASSWORD` con la contraseña que quieras
- Ve a **Deployments** → haz clic en los tres puntos del último deploy → **Redeploy**

---

## PASO 6 — Dominio personalizado (opcional pero bonito 💕)

Si quieres una URL más bonita como `paramiamorcito.com`:
1. Compra el dominio en **namecheap.com** o **porkbun.com** (~$10/año)
2. En Vercel → tu proyecto → **Settings → Domains**
3. Agrega tu dominio y sigue las instrucciones para apuntar los DNS

---

## ¿Algo salió mal?

| Problema | Solución |
|----------|----------|
| `Error: RESEND_API_KEY not set` | Revisa que agregaste las variables de entorno en Vercel |
| El email no llega | Verifica tu email en Resend (Contacts) |
| La base de datos no guarda | Revisa que ejecutaste el SQL en Supabase correctamente |
| La contraseña no funciona | Confirma el valor de `NEXT_PUBLIC_ACCESS_PASSWORD` en Vercel |

---

## Resultado final 🎀

Danilo podrá entrar a tu web con la contraseña, explorar todos sus sobrecitos y vales, y cada vez que abra o canjee uno, ¡tú recibirás un email bonito en vale.roserom23@gmail.com! 💌

