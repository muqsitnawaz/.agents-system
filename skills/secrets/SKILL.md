---
name: secrets
description: "Manage named bundles of environment variables backed by macOS Keychain. Create bundles, add secrets, and inject them into agent runs. Use this skill when working with credentials, API keys, or sensitive configuration."
argument-hint: "[list|view|create|add|remove|import|export]"
allowed-tools: Bash(agents secrets*)
user-invocable: true
---

# Secrets Skill

Manage named bundles of environment variables backed by macOS Keychain. This skill teaches you how to use the `agents secrets` CLI.

## Concepts

- **Bundle** — A named container for secrets (e.g., "production", "staging", "stripe")
- **Secret** — A key-value pair inside a bundle
- **Keychain** — Secrets are stored in macOS Keychain by default (never touch disk in plaintext)

## Quick Start

```bash
# List bundles
agents secrets list

# Create a bundle
agents secrets create production

# Add a secret
agents secrets add production STRIPE_API_KEY
# Enter value when prompted (stored in Keychain)

# Use in an agent run
agents run --secrets production
```

## Commands

| Command | Description | Example |
|---------|-------------|---------|
| `list` | List bundles | `agents secrets list` |
| `view` | Show a bundle | `agents secrets view production` |
| `create` | Create empty bundle | `agents secrets create staging` |
| `delete` | Delete a bundle | `agents secrets delete staging` |
| `add` | Add a secret | `agents secrets add staging API_KEY` |
| `remove` | Remove a secret | `agents secrets remove staging API_KEY` |
| `import` | Import from .env or 1Password | `agents secrets import .env production` |
| `export` | Export to file or 1Password | `agents secrets export production .env` |

## Adding Secrets

```bash
# Keychain-backed (default)
agents secrets add production STRIPE_API_KEY
# Prompts for value, stores in Keychain

# Literal value
agents secrets add production DEBUG true --value

# From environment variable
agents secrets add production PATH --env

# From file
agents secrets add production CERT --file /path/to/cert.pem

# From command output
agents secrets add production TOKEN --exec "cat /tmp/token"
```

## Viewing Secrets

```bash
# Masked (default)
agents secrets view production

# Revealed (be careful)
agents secrets view production --reveal
```

## 1Password Integration

```bash
# Import from 1Password vault
agents secrets import 1password:MyVault production

# Export to 1Password vault
agents secrets export production 1password:MyVault
```

Requires the `op` CLI signed in.

## Security

- Keychain-backed values never touch disk in plaintext
- Use `--reveal` sparingly and only when necessary
- Delete bundles when no longer needed
- Use separate bundles for different environments (dev, staging, production)
