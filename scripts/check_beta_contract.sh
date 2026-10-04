#!/usr/bin/env bash
set -euo pipefail

grep -F 'brew trust --tap amberframework/amber_cli' README.md .github/workflows/validate-install.yml
grep -F 'brew install amberframework/amber_cli/amber_cli' README.md .github/workflows/validate-install.yml
grep -F 'depends_on "minecart"' Formula/amber_cli.rb
grep -F 'depends_on "crystal"' Formula/amber_cli.rb Formula/minecart.rb
grep -F 'conflicts_with "amber"' Formula/amber_cli.rb
grep -F 'minecart install --frozen' README.md .github/workflows/validate-install.yml
grep -F 'amber database migrate' .github/workflows/validate-install.yml
grep -F 'env AMBER_ENV=test amber database migrate' .github/workflows/validate-install.yml
grep -F 'ubuntu-24.04-arm' .github/workflows/validate-install.yml

test ! -e .github/workflows/update-formula.yml
test "$(grep -c 'sha256 "[0-9a-f]\{64\}"' Formula/amber_cli.rb)" -eq 1
test "$(grep -c 'sha256 "[0-9a-f]\{64\}"' Formula/minecart.rb)" -eq 1

echo "Homebrew Amber CLI beta contract checks passed"
