# Homebrew Tap for Amber CLI

This is the official Homebrew distribution layer for the standalone
[Amber CLI](https://github.com/amberframework/amber_cli).

## Supported beta platforms

| Platform | Archive |
|---|---|
| Apple Silicon macOS | `amber_cli-darwin-arm64.tar.gz` |
| x86_64 Linux | `amber_cli-linux-x86_64.tar.gz` |

Intel macOS and Linux ARM64 are not release-gated for this beta.

## Install

The tap and formula are named `amber_cli`; the executable is named `amber`:

```bash
brew tap amberframework/amber_cli
brew install amber_cli
amber --version
```

This installs `amber` and `amber-lsp`, plus the Crystal and runtime libraries
needed by the release binary.

## Verify with a web app

```bash
amber new amber_beta_smoke --type web
cd amber_beta_smoke
crystal spec
crystal build src/amber_beta_smoke.cr -o bin/amber_beta_smoke
amber watch
```

Open <http://127.0.0.1:3000> and
<http://127.0.0.1:3000/css/app.css>. The generated app pins
`amberframework/amber` at `2.0.0-beta.2` and uses ECR.

## Update

```bash
brew update
brew upgrade amber_cli
amber --version
```

## Uninstall

```bash
brew uninstall amber_cli
brew untap amberframework/amber_cli
```

## Troubleshooting

If the wrong executable runs:

```bash
type -a amber
brew list --versions amber_cli
```

Remove or rename an older Amber V1 executable, or place Homebrew earlier in
`PATH`. On macOS, a beta binary must not require `openssl@1.1`; include
`otool -L "$(command -v amber)"` in a formula issue.

Report formula problems at
<https://github.com/amberframework/homebrew-amber_cli/issues> with the OS,
architecture, `brew config`, `amber --version`, and complete error output.
