# Release Handoff

This repository is the Homebrew distribution layer for `amberframework/amber_cli`.

## Purpose

The tap exists to make the Amber v2 install path real and testable before broader package distribution work begins.

The path we care about is:

```bash
brew tap amberframework/amber_cli
brew install amber_cli
brew test amber_cli
amber new my_app
```

## Responsibilities

This repo is responsible for:

- updating `Formula/amber_cli.rb` after a CLI release
- keeping macOS and Ubuntu install smoke tests green
- documenting any packaging decisions that affect users

## PR Expectations

Any PR that touches the formula or workflows should explain:

- why the tap behavior is changing
- whether coordination with `amberframework/amber_cli` is required
- how the change was verified

Use the repository PR template so this context is captured in review.

## Release Verification

After a CLI release:

1. confirm the formula version and checksums updated
2. confirm `Validate Install` passed on macOS
3. confirm `Validate Install` passed on Ubuntu
4. if the update fails, patch the formula manually and rerun the smoke workflow
