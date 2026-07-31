#!/usr/bin/env bash
set -euo pipefail

grep -F 'brew tap amberframework/amber_cli' README.md
grep -F 'brew install amber_cli' README.md
grep -F 'depends_on "openssl@3"' .github/workflows/update-formula.yml
grep -F 'version: 2.0.0-beta.2' .github/workflows/update-formula.yml
grep -F 'VERSION: ${{ steps.release.outputs.version }}' .github/workflows/update-formula.yml
grep -F 'gh workflow run validate-install.yml --ref main' .github/workflows/update-formula.yml
grep -F "grep -F 'version: 2.0.0-beta.2'" .github/workflows/validate-install.yml
grep -F "grep -F 'template: ecr'" .github/workflows/validate-install.yml
grep -F "grep -F 'openssl@1.1'" .github/workflows/validate-install.yml

if grep -Ein 'amberframework/amber-cli|brew install amber-cli|brew install amber$|brew upgrade amber$|brew uninstall amber$' README.md docs/*.md; then
  echo "Homebrew beta docs contain a stale tap or formula name" >&2
  exit 1
fi

echo "Homebrew Amber CLI beta contract checks passed"
