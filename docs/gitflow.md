# Flujo de trabajo con Git (Git Flow)

Este proyecto usa el modelo Git Flow con git normal (sin la extensión CLI `git-flow`, no hace falta instalarla).

## Ramas permanentes

- **`main`** — siempre desplegable/estable. Nunca se trabaja directo aquí; solo recibe merges desde `release/*` o `hotfix/*`.
- **`develop`** — integración. Todo el trabajo terminado de las features vive aquí antes de convertirse en una versión.

## Ramas temporales

| Tipo | Sale de | Se mezcla en | Cuándo usarla |
|---|---|---|---|
| `feature/<nombre>` | `develop` | `develop` | Para cualquier módulo o funcionalidad nueva (ej: `feature/categorias`, `feature/planes`) |
| `release/x.y.z` | `develop` | `main` **y** `develop` | Cuando `develop` ya tiene lo suficiente para una versión — solo se permiten fixes menores en esta rama, no features nuevas |
| `hotfix/<nombre>` | `main` | `main` **y** `develop` | Bug urgente en producción que no puede esperar al próximo release |

## Comandos — feature

```bash
git checkout develop
git pull
git checkout -b feature/categorias

# ... trabajar, commitear normal ...

git push -u origin feature/categorias
# abrir Pull Request feature/categorias -> develop en GitHub
```

Al aprobarse el PR: mergear a `develop` y borrar la rama `feature/categorias` (local y remota).

## Comandos — release

```bash
git checkout develop
git pull
git checkout -b release/1.1.0

# solo fixes menores / bump de versión en pubspec.yaml aquí

git checkout main
git merge --no-ff release/1.1.0
git tag -a v1.1.0 -m "Versión 1.1.0"
git push origin main --tags

git checkout develop
git merge --no-ff release/1.1.0
git push origin develop

git branch -d release/1.1.0
git push origin --delete release/1.1.0
```

## Comandos — hotfix

```bash
git checkout main
git pull
git checkout -b hotfix/nombre-del-bug

# ... arreglar, commitear ...

git checkout main
git merge --no-ff hotfix/nombre-del-bug
git tag -a v1.0.1 -m "Hotfix 1.0.1"
git push origin main --tags

git checkout develop
git merge --no-ff hotfix/nombre-del-bug
git push origin develop

git branch -d hotfix/nombre-del-bug
git push origin --delete hotfix/nombre-del-bug
```

## Reglas prácticas

- Nunca `git push --force` a `main` o `develop`.
- Nunca commitear directo a `main` — ni siquiera un fix de un typo. Todo pasa por una rama temporal, aunque sea de un solo commit.
- Nombrar las features por módulo cuando sea posible, para que coincidan con [`progress.md`](progress.md): `feature/categorias`, `feature/planes`, `feature/salidas`, `feature/gastos`, `feature/album`, `feature/ruleta`.
- Antes de abrir un PR: `flutter analyze` y `flutter test` deben salir limpios (ver [`setup.md`](setup.md)).
- Recomendado (no configurado todavía porque requiere acceso al panel de GitHub): activar **branch protection** en `main` y `develop` para bloquear push directo y exigir PR — Settings → Branches → Add rule, en github.com/Valery-Rosero/TonsKhe.
