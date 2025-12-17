# C3.ai CLI

A fast, native command-line tool for syncing C3.ai projects and managing environments.

> **Warning: Development Release**
>
> This tool is under active development. Before using:
> - **Do not use on production environments** unless you know how to recover them
> - Test on non-critical environments first
> - **Clear tokens daily**: Run `c3 auth --clear` at the end of each session
> - Report issues at the project repository

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/C3-CaseySiebel/c3cli-releases/main/install.sh | sh
```

Verify the installation:

```bash
c3 --version
```

## Quick Start

```bash
# cd to your project and sync with a token (most common)
cd /path/to/workspace
c3 sync -s https://your-env.c3.ai -t <your-token>

# Or specify workspace explicitly
c3 sync /path/to/workspace -s https://your-env.c3.ai -t <token>

# Watch for changes and sync continuously
c3 sync -s https://your-env.c3.ai -t <token> -w
```

### Getting Your Token

In your browser console on the C3 server:
```javascript
User.mySessionToken().signedToken
```

### OAuth Support

For C3 servers that support OAuth, you can authenticate without a token:
```bash
c3 sync -s https://your-env.c3.ai
```
This will open a browser for authentication.

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
| `-p, --path <PATH>` | Filter to specific path |
| `-v, --verbose` | Show all files (no truncation) |
| `-l, --log [FILE]` | Enable file logging |
| `-e, --build-errors` | Show build errors after sync |

### auth

Manage cached tokens.

```bash
c3 auth [OPTIONS]
```

| Flag | Description |
|------|-------------|
| `-s, --server <URL>` | C3 server URL |
| `-t, --token <TOKEN>` | Cache a token directly |
| `--list` | List cached tokens |
| `--clear` | Clear cached tokens |

Tokens are stored in `~/.c3cli/tokens.json`.

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

### info

Show workspace info and discovered packages.

```bash
c3 info
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `C3_SERVER_URL` | Default server URL |
| `C3_AUTH_TOKEN` | Auth token |

## Examples

### Daily Workflow

```bash
# Get token from browser console: User.mySessionToken().signedToken

# cd to your project and watch for changes
cd ~/projects/my-app
c3 sync -s https://dev.c3.ai -t <token> -w

# End of day: clear cached tokens
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

- Tokens are stored in `~/.c3cli/tokens.json`
- **Clear tokens regularly** with `c3 auth --clear`
- Never share or commit tokens
- Use environment variables in CI/CD

## License

Copyright (c) C3.ai. All rights reserved.
