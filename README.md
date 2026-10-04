# Homebrew Tap for Amber CLI

This is the Homebrew distribution layer for the standalone
[Amber CLI](https://github.com/amberframework/amber_cli), `amber-lsp`, and
[Minecart](https://github.com/crimson-knight/shards). The formulas target Amber
V2. They conflict with the old `amber` formula.

## Install

Follow the [versioned installation guide](https://amberframework.org/docs/v2/getting-started/installation/)
for the audited tap commit and complete commands. The sequence begins with
`brew trust --tap amberframework/amber_cli`, checks out and verifies that exact
commit, and ends with the one Amber install command
`HOMEBREW_NO_AUTO_UPDATE=1 brew install amberframework/amber_cli/amber_cli`.
Run the complete sequence from the guide; installing from the moving tip of
the tap leaves the formula revision unpinned.

The formula installs Amber CLI 2.0.7, `amber-lsp`, Minecart 2025.11.25.7,
Crystal, and the required SQLite, OpenSSL, PostgreSQL, and MySQL libraries.
Its two release source archives have exact versions and SHA-256 checksums.
Minecart verifies every CLI Crystal dependency against `shard.lock` before
compilation. The Homebrew core dependencies are resolved by Homebrew and are
**not** fixed to exact versions by this tap. `brew trust` authorizes loading
the tap; it does not freeze the tap. The commit checkout and
`HOMEBREW_NO_AUTO_UPDATE=1` guard the formula used for the install.

These source archives are release candidates until both upstream assets are
published at the URLs in `Formula/`. The current public Amber CLI release is
2.0.6. Do not claim the new install works until the release assets and tap
commit are available and the install smoke passes.

## Verify with a web app

```bash
amber --version
test -x "$(command -v amber-lsp)"
minecart --version
amber new amber_beta_smoke --type web -y
cd amber_beta_smoke
minecart install --frozen --skip-ai-docs
crystal spec
crystal build src/amber_beta_smoke.cr -o bin/amber_beta_smoke
amber watch
```

`amber new` writes exact root dependency versions, `.minecart-policy.yml`, a
`shard.lock` with Git tree checksums, and `.claude/` assistant setup. Commit the
lockfile with the app. `--no-deps` intentionally skips Minecart installation
and assistant setup; run those commands before using the app.

## Updates and troubleshooting

Review a new tap commit and both formula checksums before moving the checkout.
Then run `HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade amberframework/amber_cli/amber_cli`.
To inspect a conflicting executable, run `type -a amber` and
`brew list --versions amber_cli`. Report formula problems at
<https://github.com/amberframework/homebrew-amber_cli/issues> with the OS,
architecture, `brew config`, `amber --version`, and complete error output.
