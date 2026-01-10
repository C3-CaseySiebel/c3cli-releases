# C3.ai CLI

A fast, native command-line tool for syncing C3.ai projects and managing environments.

> **Warning: Development Release**
>
> This tool is under active development. Before using:
> - **Do not use on production environments** unless you know how to recover them
> - Test on non-critical environments first
> - Report issues at the project repository

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/C3-CaseySiebel/c3cli-releases/master/install.sh | sh
```

Verify the installation:

```bash
c3 --version
```

## Quick Start

```bash
# Just sync - authentication is automatic if you're logged into C3 in Chrome
cd /path/to/workspace
c3 sync -s https://your-env.c3.ai

# Watch for changes continuously
c3 sync -s https://your-env.c3.ai -w
```

If you're already logged into the C3 server in Chrome, the CLI will automatically use your browser session. No token needed!

### Authentication Methods

The CLI tries these authentication methods in order:

1. **CLI argument** (`-t <token>`) - Explicit token on command line
2. **Environment variable** (`C3_AUTH_TOKEN`) - Token from env var
3. **Cached token** - Previously saved token for this workspace/server
4. **Browser cookie** (macOS + Chrome only) - Extracts token from Chrome if you're logged in
5. **Browser login** (macOS + Chrome only) - Opens Chrome for login, polls for cookie
6. **OAuth flow** - Custom OIDC endpoint (with `-o` flag)
7. **Manual entry** - Prompts you to paste a token from the console

For most users on macOS with Chrome, the CLI will either use your existing Chrome session or open the browser for you to log in - no token needed!

### Manual Token Entry

If automatic auth doesn't work, get a token from your browser console:
```javascript
User.mySessionToken().signedToken
```

Then either:
```bash
# Pass token directly
c3 sync -s https://your-env.c3.ai -t <your-token>

# Or cache it for future use
c3 auth -s https://your-env.c3.ai -t <your-token>
c3 sync -s https://your-env.c3.ai  # Uses cached token
```

### OAuth Support

For servers with OAuth configured, use the `-o` flag to authenticate via browser:
```bash
c3 sync -s https://your-env.c3.ai -o
```

## Commands

### sync

Sync files to a C3 server. Uses current directory if no workspace is specified.

```bash
c3 sync [WORKSPACE] [OPTIONS]
```

| Flag | Description |
|------|-------------|
| `-s, --server <URL>` | C3 server URL |
| `-t, --token <TOKEN>` | Auth token |
| `-w, --watch` | Watch for changes continuously |
| `-f, --force` | Force upload all files |
| `-g, --git` | Use git for change detection |
| `-n, --dry-run` | Show what would be synced without uploading |
| `-p, --path <PATH>` | Filter to specific path |
| `-v, --verbose` | Show all files (no truncation) |
| `-l, --log [FILE]` | Enable file logging |
| `-o, --oauth` | Use OAuth browser flow for authentication |
| `-e, --build-errors` | Show build errors after sync |
| `--build-errors-level <LEVEL>` | Error severity: error, warn, info, debug (default: warn) |

### auth

Manage authentication and cached tokens.

```bash
c3 auth [OPTIONS]
```

| Flag | Description |
|------|-------------|
| `-s, --server <URL>` | C3 server URL |
| `-t, --token <TOKEN>` | Cache a token directly |
| `-o, --oauth` | Authenticate via OAuth browser flow |
| `-p, --oauth-port <PORT>` | OAuth callback port (default: 3737) |
| `-k, --workspace <PATH>` | Workspace for token scoping |
| `--list` | List cached tokens |
| `--clear` | Clear cached tokens |

Tokens are stored in `~/.c3cli/tokens.json` and scoped per workspace/server.

### exec

Execute JavaScript or TypeScript code on a C3 server.

```bash
c3 exec <CODE> [-- ARGS...]
```

| Flag | Description |
|------|-------------|
| `-s, --server <URL>` | C3 server URL |
| `-t, --token <TOKEN>` | Auth token |
| `--ts` | Execute as TypeScript (for inline code) |

Examples:
```bash
# Inline JavaScript
c3 exec "1 + 1"
c3 exec "Surfboard.ping()"

# Inline TypeScript
c3 exec --ts "const x: number = 42; x"

# From file (auto-detects .ts)
c3 exec script.js
c3 exec script.ts

# With arguments (passed to function)
c3 exec "(a, b) => a + b" -- 3 4
c3 exec multiply.js -- 6 7
```

### env

Manage C3 environments on a cluster.

```bash
c3 env <COMMAND> [OPTIONS]
```

| Command | Description |
|---------|-------------|
| `create <NAME>` | Create a new environment |
| `list` | List all environments |
| `status <NAME>` | Get environment status |
| `start <NAME>` | Start a stopped environment |
| `stop <NAME>` | Stop an environment |
| `terminate <NAME>` | Delete an environment permanently |
| `upgrade <NAME>` | Upgrade server version |
| `versions` | List available server versions |

Common flags for env commands:

| Flag | Description |
|------|-------------|
| `-s, --server <URL>` | C3 cluster URL |
| `-t, --token <TOKEN>` | Auth token |
| `-W, --wait` | Wait for operation to complete |
| `--oauth-port <PORT>` | OAuth callback port (default: 3737) |

### app

Manage C3 applications in an environment.

```bash
c3 app <COMMAND> [OPTIONS]
```

| Command | Description |
|---------|-------------|
| `create` | Create a new application |
| `list` | List applications |
| `status <NAME>` | Get application status |
| `start <NAME>` | Start a stopped application |
| `stop <NAME>` | Stop an application |
| `terminate <NAME>` | Delete an application permanently |
| `upgrade <NAME>` | Upgrade application |

Common flags for app commands:

| Flag | Description |
|------|-------------|
| `-s, --server <URL>` | C3 server URL |
| `-t, --token <TOKEN>` | Auth token |
| `--env <NAME>` | Environment name (required if server URL is cluster-level) |
| `-W, --wait` | Wait for operation to complete |
| `--oauth-port <PORT>` | OAuth callback port (default: 3737) |

### info

Show workspace info and discovered packages.

```bash
c3 info
```

### seed

Upsert all seed data from packages into the database. Seed data files are typically located in `packages/<pkg>/seed/` directories.

```bash
c3 seed [OPTIONS]
```

| Flag | Description |
|------|-------------|
| `-s, --server <URL>` | C3 server URL (dev URL or app URL) |
| `-t, --token <TOKEN>` | Auth token |
| `-a, --app <APP>` | App name (required if multiple apps, auto-detected otherwise) |
| `-k, --workspace <DIR>` | Workspace directory for auto-detecting app |

**Examples:**
```bash
# Auto-detect app from workspace packages
c3 seed -s https://cluster/env/dev

# Explicit app name
c3 seed -s https://cluster/env/dev --app myapp

# Direct app URL
c3 seed -s https://cluster/env/myapp
```

### update

Update the CLI to the latest version.

```bash
c3 update
```

## Global Options

These options can be used with any command:

| Flag | Description |
|------|-------------|
| `-k, --workspace, --wk <DIR>` | Workspace directory (defaults to current directory) |
| `-s, --server <URL>` | C3 server URL (or use `C3_SERVER_URL` env var) |
| `-t, --token <TOKEN>` | Auth token (or use `C3_AUTH_TOKEN` env var) |
| `-v, --verbose` | Enable verbose logging |

## Environment Variables

| Variable | Description |
|----------|-------------|
| `C3_SERVER_URL` | Default server URL |
| `C3_AUTH_TOKEN` | Auth token |

## Examples

### Daily Workflow

```bash
# Log into C3 in Chrome, then just sync - no token needed!
cd ~/projects/my-app
c3 sync -s https://dev.c3.ai -w

# Or with explicit token if browser auth doesn't work
c3 sync -s https://dev.c3.ai -t <token> -w

# End of day: clear cached tokens (optional, tokens auto-expire)
c3 auth --clear
```

### Sync Specific Directory

```bash
c3 sync -s https://dev.c3.ai -t <token> -p src/transforms
```

### Force Re-sync

```bash
c3 sync -s https://dev.c3.ai -t <token> --force
```

### Git-based Sync

```bash
c3 sync -s https://dev.c3.ai -t <token> --git
```

## Troubleshooting

### Files not syncing

```bash
# Force re-sync everything
c3 sync -s https://server.c3.ai -t <token> --force
```

### Token expired

Get a fresh token from your browser console:
```javascript
User.mySessionToken().signedToken
```

## File Types

The following extensions are synced:

`.c3typ`, `.js`, `.py`, `.c3ml`, `.json`, `.html`, `.css`, `.map`, `.svg`, `.png`, `.jpg`, `.jpeg`, `.gif`, `.ico`, `.webp`

## Security

- Tokens are stored in `~/.c3cli/tokens.json` with restricted permissions (0600)
- Tokens are scoped per workspace and server URL
- Expired tokens are automatically detected and skipped
- Clear tokens with `c3 auth --clear` if needed
- Never share or commit tokens
- Use environment variables in CI/CD

### Browser Cookie Extraction (macOS + Chrome)

When using automatic browser authentication, the CLI extracts your C3 session cookie from Chrome. Chrome stores cookies encrypted, and the decryption key is stored in the macOS Keychain. When `c3` accesses this key, you'll see a system prompt:

> "c3" wants to use your confidential information stored in "Chrome Safe Storage" in your keychain.

You have two options:

| Option | Behavior |
|--------|----------|
| **Allow** | One-time access. You'll be prompted every time `c3` needs to read the cookie. |
| **Always Allow** | Permanent access for `c3`. No future prompts - the CLI can silently extract cookies. |

**Notes:**
- This feature only works on **macOS with Google Chrome**
- Safari, Firefox, and other browsers are not supported
- If you choose "Deny", the CLI will fall back to other auth methods (browser login, manual entry)
- To revoke "Always Allow", open Keychain Access, find "Chrome Safe Storage", and remove `c3` from the access list

## License

Copyright (c) C3.ai. All rights reserved.
