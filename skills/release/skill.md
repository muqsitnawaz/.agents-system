---
name: release
description: >-
  Publish packages to registries (npm, PyPI, crates.io, Docker, etc.). 
  Auto-detects project type or defers to project-specific instructions.
  Handles versioning, changelog, tests, publish, and git tags.
  Supports environment targets (preprod, prod).
  Triggers on: release, publish, ship, cut a release, deploy to prod.
user-invocable: true
version: 2.0.0
---

# Release

Publish packages to their registries. Supports npm, PyPI, Cargo, Docker, Helm, and custom workflows.

## Arguments

`$ARGUMENTS` may contain:
- Version: `1.2.3`, `1.2.3-alpha.1`, `patch`, `minor`, `major`
- Environment: `preprod`, `prod`, `staging` (default: `prod` for registry publishes)
- Package path (monorepos): `packages/core`, `crates/parser`
- Flags: `--skip-tests`, `--skip-build`, `--force`, `--type <npm|pypi|cargo|docker|helm>`

---

## Principles

### Secrets belong in a secret manager, not env files

**Never** store API keys, deploy tokens, or registry credentials in:
- `.env` files (even `.env.prod`) — these end up in git history
- Hardcoded in scripts
- Plaintext config files

**Use a proper secret manager:**

| Tool | Load command | Notes |
|------|--------------|-------|
| `agents secrets` | `eval "$(agents secrets export bundle)"` | Built into agents-cli, uses macOS Keychain |
| 1Password CLI | `op read "op://vault/item/field"` | If your team already uses 1Password |
| CI secrets | `${{ secrets.NPM_TOKEN }}` | GitHub Actions, GitLab CI, etc. |

The skill detects which is available and guides setup accordingly. Default recommendation is `agents secrets` since it's zero-config for agents-cli users.

### Environment separation

Projects with deployment targets should have explicit environments:
- **preprod** — staging/preview, safe to deploy frequently
- **prod** — production, requires explicit `--env prod` or `--confirm`

Scripts should default to preprod (safe) and require explicit confirmation for prod.

### Scripts are the source of truth

Once `scripts/build.sh` and `scripts/release.sh` exist, the skill uses them. It doesn't bypass or duplicate their logic. The scripts encode the project's release process; the skill orchestrates.

---

## Phase 1: Find Release Instructions

The skill defers to project-specific knowledge before imposing its own patterns.

### 1.1 Project-level release skill (highest priority)

```bash
if [[ -d ".agents/skills/release" ]]; then
  echo "DEFER: Project has .agents/skills/release/"
  cat .agents/skills/release/skill.md
fi
```

If found, **stop here** and follow those instructions completely.

### 1.2 Existing release script

```bash
for script in scripts/release.sh release.sh scripts/deploy.sh; do
  if [[ -x "$script" ]]; then
    echo "FOUND: $script"
    head -100 "$script"
  fi
done
```

If found, read it to understand:
- Dry-run flag (`--dry-run`, `--apply`, `--confirm`)
- Environment support (`--env preprod`, `--env prod`)
- What it publishes to
- Whether it runs tests

Then execute with appropriate flags. Don't reinvent.

### 1.3 Release instructions in docs

```bash
grep -l -i "release\|publish\|deploy" README.md AGENTS.md CLAUDE.md CONTRIBUTING.md docs/*.md 2>/dev/null | while read -r f; do
  echo "=== $f ==="
  grep -A 20 -i "^#.*release\|^#.*publish\|^#.*deploy" "$f" 2>/dev/null | head -30
done
```

If docs describe a release process, follow those instructions.

### 1.4 Fall through to detection

Only if none of the above exist, proceed to Phase 2.

---

## Phase 2: Detect Project Type

### 2.1 Identify manifest files

```bash
echo "=== Manifest Detection ==="

[[ -f "package.json" ]] && echo "npm: package.json"
[[ -f "pyproject.toml" ]] && echo "pypi: pyproject.toml"
[[ -f "setup.py" ]] && echo "pypi: setup.py"
[[ -f "Cargo.toml" ]] && echo "cargo: Cargo.toml"
[[ -f "Dockerfile" ]] && echo "docker: Dockerfile"
[[ -f "Chart.yaml" ]] && echo "helm: Chart.yaml"
[[ -f "go.mod" ]] && echo "go: go.mod (tag-based)"

# Monorepo detection
[[ -f "pnpm-workspace.yaml" ]] && echo "monorepo: pnpm"
jq -e '.workspaces' package.json 2>/dev/null && echo "monorepo: npm/bun workspaces"
grep -q '\[workspace\]' Cargo.toml 2>/dev/null && echo "monorepo: cargo workspace"
```

### 2.2 Resolve ambiguity

If multiple types exist:
1. Check `$ARGUMENTS` for `--type <type>`
2. Infer from structure (Dockerfile copying from `dist/` → npm primary)
3. Use `AskUserQuestion` with detected options

### 2.3 Monorepo: identify target package

If `$ARGUMENTS` specifies a package path, use it. Otherwise list publishable packages and ask.

---

## Phase 3: Check Secrets

Before any publish attempt, verify credentials are available.

### 3.1 Required secrets by type

| Type | Env var | Where to get it |
|------|---------|-----------------|
| npm | `NPM_TOKEN` | npmjs.com/settings/tokens |
| PyPI | `PYPI_TOKEN` | pypi.org/manage/account/token |
| Cargo | `CARGO_REGISTRY_TOKEN` | crates.io/settings/tokens |
| Docker Hub | `DOCKER_TOKEN` | hub.docker.com/settings/security |
| GHCR | `GHCR_TOKEN` | github.com/settings/tokens |

### 3.2 Check secrets

```bash
check_secret() {
  local var_name="$1"
  local bundle="$2"
  
  # Try 1Password if available
  if command -v op &>/dev/null; then
    op read "op://Private/$bundle/$var_name" 2>/dev/null && return 0
  fi
  
  # Try agents secrets (default)
  if command -v agents &>/dev/null; then
    agents secrets export "$bundle" --plaintext 2>/dev/null | grep -q "^$var_name=" && return 0
  fi
  
  return 1
}

# Check required secret
if ! check_secret "NPM_TOKEN" "npmjs.com"; then
  echo "MISSING: NPM_TOKEN"
  echo ""
  echo "Set it up:"
  echo "  agents secrets create npmjs.com"
  echo "  agents secrets add npmjs.com NPM_TOKEN"
  echo ""
  echo "Or with 1Password:"
  echo "  op item create --category=login --title=npmjs.com --vault=Private"
  echo "  # then add NPM_TOKEN field"
fi
```

If secrets are missing, this is **blocking**. Do not proceed until configured.

### 3.3 Environment-specific secrets

For deploy targets with multiple environments:

```bash
# Check preprod secrets
check_secret "DEPLOY_KEY" "myapp.preprod" && echo "preprod: OK"

# Check prod secrets  
check_secret "DEPLOY_KEY" "myapp.prod" && echo "prod: OK"
```

Convention: `<service>.<env>` bundles (e.g., `vercel.prod`, `fly.preprod`).

---

## Phase 4: Type-Specific Release

Each type follows: preflight → version → changelog → publish → verify → tag.

### 4.1 npm

**Preflight:**
```bash
PKG_NAME=$(jq -r '.name' package.json)
CURRENT=$(npm view "$PKG_NAME" version 2>/dev/null || echo "0.0.0")
echo "Package: $PKG_NAME"
echo "Published: $CURRENT"

check_secrets "npmjs.com" "NPM_TOKEN"
```

**Publish:**
```bash
eval "$(agents secrets export npmjs.com)"
echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > .npmrc.release
trap 'rm -f .npmrc.release' EXIT

npm version "$VERSION" --no-git-tag-version
npm publish --access public --userconfig .npmrc.release
```

### 4.2 PyPI

**Preflight:**
```bash
PKG_NAME=$(grep -E '^name\s*=' pyproject.toml | head -1 | cut -d'"' -f2)
CURRENT=$(pip index versions "$PKG_NAME" 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "0.0.0")

check_secrets "pypi.org" "PYPI_TOKEN"
```

**Publish:**
```bash
sed -i '' "s/^version = .*/version = \"$VERSION\"/" pyproject.toml
uv build || python -m build

eval "$(agents secrets export pypi.org)"
uv publish --token "$PYPI_TOKEN" || twine upload dist/* -u __token__ -p "$PYPI_TOKEN"
```

### 4.3 Cargo

**Preflight:**
```bash
PKG_NAME=$(grep -E '^name\s*=' Cargo.toml | head -1 | cut -d'"' -f2)
CURRENT=$(cargo search "$PKG_NAME" --limit 1 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "0.0.0")

check_secrets "crates.io" "CARGO_REGISTRY_TOKEN"
```

**Publish:**
```bash
sed -i '' "s/^version = .*/version = \"$VERSION\"/" Cargo.toml
eval "$(agents secrets export crates.io)"
cargo publish
```

### 4.4 Docker

**Preflight:**
```bash
REGISTRY="${DOCKER_REGISTRY:-docker.io}"
IMAGE_NAME=$(basename "$(pwd)")

# Determine which secret bundle based on registry
case "$REGISTRY" in
  *ghcr.io*) check_secrets "ghcr.io" "GHCR_TOKEN" ;;
  *)         check_secrets "docker.io" "DOCKER_TOKEN" ;;
esac
```

**Publish:**
```bash
eval "$(agents secrets export docker.io)"
echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USERNAME" --password-stdin

docker build -t "$REGISTRY/$IMAGE_NAME:$VERSION" -t "$REGISTRY/$IMAGE_NAME:latest" .
docker push "$REGISTRY/$IMAGE_NAME:$VERSION"
docker push "$REGISTRY/$IMAGE_NAME:latest"
```

### 4.5 Go modules

Tag-based, no registry upload:
```bash
git tag "v$VERSION"
git push origin "v$VERSION"
```

### 4.6 Helm

```bash
CHART_NAME=$(grep '^name:' Chart.yaml | cut -d: -f2 | tr -d ' ')
sed -i '' "s/^version:.*/version: $VERSION/" Chart.yaml

helm package .
helm push "$CHART_NAME-$VERSION.tgz" oci://$HELM_REGISTRY/charts
```

---

## Phase 5: Environment-Aware Deploys

For services (not just packages), handle environment targeting.

### 5.1 Detect environment from arguments

```bash
ENV="preprod"  # Safe default
for arg in $ARGUMENTS; do
  case "$arg" in
    preprod|staging) ENV="preprod" ;;
    prod|production) ENV="prod" ;;
    --env) shift; ENV="$1" ;;
  esac
done
```

### 5.2 Require confirmation for prod

```bash
if [[ "$ENV" == "prod" ]]; then
  if [[ "$ARGUMENTS" != *"--confirm"* && "$ARGUMENTS" != *"--apply"* ]]; then
    echo ""
    echo "============================================"
    echo "  PRODUCTION DEPLOY"
    echo "  "
    echo "  Target: $ENV"
    echo "  Version: $VERSION"
    echo "  "
    echo "  To proceed, add --confirm:"
    echo "    /release $VERSION prod --confirm"
    echo "============================================"
    exit 0
  fi
fi
```

### 5.3 Load environment-specific secrets

```bash
# Load base secrets
eval "$(agents secrets export $SERVICE_NAME)"

# Override with environment-specific if they exist
if agents secrets list 2>/dev/null | grep -q "^${SERVICE_NAME}.${ENV}$"; then
  eval "$(agents secrets export ${SERVICE_NAME}.${ENV})"
fi
```

---

## Phase 6: Common Steps

### 6.1 Pre-flight checks

```bash
# Git state
[[ -n "$(git status --porcelain)" ]] && echo "BLOCKING: Uncommitted changes"

# Branch check
BRANCH=$(git rev-parse --abbrev-ref HEAD)
[[ "$BRANCH" != "main" && "$BRANCH" != "master" ]] && echo "WARNING: Not on main branch"

# Version not already tagged
git tag -l "v$VERSION" | grep -q . && echo "BLOCKING: Tag v$VERSION already exists"
```

### 6.2 Run tests

Unless `--skip-tests`:

```bash
if [[ -x "scripts/build.sh" ]]; then
  ./scripts/build.sh
elif [[ -f "package.json" ]]; then
  npm test || bun test
elif [[ -f "pyproject.toml" ]]; then
  uv run pytest || pytest
elif [[ -f "Cargo.toml" ]]; then
  cargo test
elif [[ -f "go.mod" ]]; then
  go test ./...
fi
```

If tests fail, **stop**.

### 6.3 Changelog

```bash
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [[ -n "$LAST_TAG" ]]; then
  echo "## [$VERSION] - $(date +%Y-%m-%d)"
  echo ""
  git log "$LAST_TAG"..HEAD --oneline --no-merges
fi
```

### 6.4 Git tag (after successful publish)

```bash
git add -A
git commit -m "chore(release): $VERSION"
git tag "v$VERSION"
git push origin "$(git rev-parse --abbrev-ref HEAD)"
git push origin "v$VERSION"
```

---

## Phase 7: Scaffold (Greenfield Only)

Only if no release process exists and user confirms.

### 7.1 Offer to scaffold

Use `AskUserQuestion`:
```
No release process found. Set up standard release infrastructure?

This creates:
- scripts/build.sh — lint, test, build (type-checked, test-gated)
- scripts/release.sh — version, publish, tag (dry-run default, secrets via keychain)

Secrets will use `agents secrets` (macOS Keychain), not .env files.

Options: "Create scripts", "Show me what they'd contain", "Skip"
```

### 7.2 Scaffolded build.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

SKIP_TESTS=false
for arg in "$@"; do
  [[ "$arg" == "--skip-tests" ]] && SKIP_TESTS=true
done

echo "==> Type checking..."
# Type check based on detected project type
{{TYPE_CHECK_COMMAND}}

echo "==> Linting..."
{{LINT_COMMAND}}

if [[ "$SKIP_TESTS" != "true" ]]; then
  echo "==> Running tests..."
  {{TEST_COMMAND}}
else
  echo ""
  echo "WARNING: Skipping tests. Fix failing tests instead of bypassing them."
  echo ""
fi

echo "==> Building..."
{{BUILD_COMMAND}}

echo "==> Build complete"
```

### 7.3 Scaffolded release.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-}"
ENV="${2:-preprod}"
APPLY=false
SKIP_BUILD=false
SKIP_TESTS=false

for arg in "$@"; do
  case "$arg" in
    --apply|--confirm) APPLY=true ;;
    --skip-build) SKIP_BUILD=true ;;
    --skip-tests) SKIP_TESTS=true ;;
    preprod|staging) ENV="preprod" ;;
    prod|production) ENV="prod" ;;
  esac
done

die() { echo "ERROR: $1" >&2; exit 1; }

[[ -z "$VERSION" ]] && die "Usage: scripts/release.sh <version> [preprod|prod] [--apply]"

# Validate semver
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]] || die "Invalid version: $VERSION"

# Pre-flight
echo "==> Pre-flight checks"
[[ -n "$(git status --porcelain)" ]] && die "Uncommitted changes"

# Secrets check — NEVER use plaintext .env files for credentials
echo "==> Checking secrets"

load_secrets() {
  local bundle="$1"
  
  # Try 1Password first if available
  if command -v op &>/dev/null && op account list &>/dev/null 2>&1; then
    echo "   Loading from 1Password..."
    # 1Password integration would go here
    return 0
  fi
  
  # Default: agents secrets (macOS Keychain)
  if command -v agents &>/dev/null; then
    echo "   Loading from agents secrets..."
    eval "$(agents secrets export "$bundle" 2>/dev/null)" && return 0
  fi
  
  return 1
}

load_secrets "{{BUNDLE}}" || die "Missing secrets. Run: agents secrets create {{BUNDLE}}"

{{SECRETS_CHECK}}

# Build
if [[ "$SKIP_BUILD" != "true" ]]; then
  echo "==> Building"
  BUILD_FLAGS=""
  [[ "$SKIP_TESTS" == "true" ]] && BUILD_FLAGS="--skip-tests"
  ./scripts/build.sh $BUILD_FLAGS || die "Build failed"
fi

# Dry-run gate
if [[ "$APPLY" != "true" ]]; then
  echo ""
  echo "============================================"
  echo "  DRY-RUN COMPLETE"
  echo "  "
  echo "  Environment: $ENV"
  echo "  Version: $VERSION"
  echo "  "
  echo "  To publish, run:"
  echo "    scripts/release.sh $VERSION $ENV --apply"
  echo "============================================"
  exit 0
fi

# Prod confirmation
if [[ "$ENV" == "prod" ]]; then
  echo ""
  echo "  DEPLOYING TO PRODUCTION"
  echo "  Version: $VERSION"
  echo ""
  read -p "  Type 'yes' to confirm: " confirm
  [[ "$confirm" != "yes" ]] && die "Aborted"
fi

# Load secrets from keychain
echo "==> Loading secrets"
{{SECRETS_LOAD}}

# Publish
echo "==> Publishing to $ENV"
{{PUBLISH_COMMAND}}

# Verify
echo "==> Verifying"
{{VERIFY_COMMAND}}

# Git tag (after successful publish)
echo "==> Tagging"
git add {{VERSION_FILES}}
git commit -m "chore(release): $VERSION"
git tag "v$VERSION"
git push origin "$(git rev-parse --abbrev-ref HEAD)"
git push origin "v$VERSION"

echo ""
echo "============================================"
echo "  RELEASED $VERSION to $ENV"
echo "============================================"
```

### 7.4 Guide secrets setup

After scaffolding, remind:

```
Scripts created. Next: set up secrets.

For {{REGISTRY}}:
  agents secrets create {{BUNDLE_NAME}}
  agents secrets add {{BUNDLE_NAME}} {{TOKEN_VAR}}

Get your token from: {{TOKEN_URL}}

Then run:
  scripts/release.sh $VERSION --apply
```

---

## Error Recovery

### Missing secrets
```
Missing {{REGISTRY}} authentication.

Set up with agents secrets (stored in macOS Keychain):
  agents secrets create {{BUNDLE}}
  agents secrets add {{BUNDLE}} {{KEY}}

Get your token: {{URL}}

Do NOT put tokens in .env files — they end up in git history.
```

### Tests failed
```
Tests failed. Fix them before releasing.

  {{TEST_COMMAND}}

Bypass (discouraged): /release $VERSION --skip-tests
```

### Version collision
```
Version $VERSION already published.

Options:
1. Bump: /release {{NEXT}}
2. Prerelease: /release $VERSION-rc.1
3. Force (dangerous): /release $VERSION --force
```

---

## Flags Reference

| Flag | Effect |
|------|--------|
| `--skip-tests` | Skip test suite (prints warning) |
| `--skip-build` | Skip build step |
| `--force` | Skip version validation |
| `--type <t>` | Override detection: npm, pypi, cargo, docker, helm, go |
| `--env <e>` | Target environment: preprod (default), prod |
| `--dry-run` | Show plan without executing (default) |
| `--apply` / `--confirm` | Execute the release |
