# ADR 0001: Keep Amber CLI Distribution In A Dedicated Tap During The Release-Candidate Phase

## Context

Amber v2 needs a trustworthy install path before the public announcement goes out. The immediate requirement is to verify the exact commands users will run:

```bash
brew tap amberframework/amber_cli
brew install amber_cli
amber new my_app
```

The CLI release process is still evolving, and the team wants to keep the tap formula, checksum updates, and smoke tests under direct control before pursuing `homebrew/core`.

## Decision

During the Amber v2 release-candidate phase:

- the tap formula will point at released Amber CLI assets from `amberframework/amber_cli`
- the tap will update itself from the CLI release workflow
- tap CI will verify both `brew test amber_cli` and a scaffold smoke test on macOS and Ubuntu

## Consequences

### Positive

- the actual end-user install path is under CI coverage
- release regressions are caught before announcement posts go live
- the tap can evolve quickly while the CLI and docs stabilize

### Tradeoffs

- the tap is one more repository to keep aligned
- this is a stepping stone, not the final `homebrew/core` story

### Follow-up

Once the release process and scaffold stabilize, evaluate a source-built formula path for `homebrew/core`.
