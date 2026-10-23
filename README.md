# homebrew-d3mlabs

Official Homebrew tap for d3mlabs developer tooling.

## Installation

```bash
brew tap d3mlabs/d3mlabs
```

## Available formulas

- **`dev`** — Global CLI that discovers `dev.yml` in your git repos and runs commands like `dev up`, `dev build`, `dev test`.

  ```bash
  brew install d3mlabs/d3mlabs/dev
  ```

  See [d3mlabs/dev](https://github.com/d3mlabs/dev) for usage and the `dev.yml` convention.

- **`axslcc`** — Axmol shader compiler (used by Cellbound and other axmol-based projects).

  ```bash
  brew install d3mlabs/d3mlabs/axslcc
  ```

- **`powershell@7.4.0`** — PowerShell (pwsh) 7.4.0 for Linux. macOS users typically install the cask instead.

  ```bash
  brew install d3mlabs/d3mlabs/powershell@7.4.0
  ```

- **`clang-format@18.1.8`** — Pinned standalone clang-format, so CI and every dev machine format identically. One ~4 MB binary (lifted from the [ssciwr clang-format wheel](https://github.com/ssciwr/clang-format-wheel), built from official LLVM in public CI), not all of LLVM. Linux x86_64 + macOS arm64/Intel.

  ```bash
  brew install d3mlabs/d3mlabs/clang-format@18.1.8
  ```

## What this tap admits

The rule, decided in [plans#50](https://github.com/d3mlabs/plans/issues/50) and recorded as dev's [ADR-0010](https://github.com/d3mlabs/dev/blob/HEAD/docs/DECISIONS.md#adr-0010--the-verb-follows-the-channel): a dependency is consumed from its upstream channel through the dev DSL verb for that channel, and a formula lands here only when that is not possible. Consumer-facing guidance, with the decision flowchart, is [dev's deps-channels.md](https://github.com/d3mlabs/dev/blob/HEAD/docs/deps-channels.md).

A formula is admitted when it is one of:

1. **Software d3mlabs authors** — `dev`, `wwise-cli`. This is the tap's reason to exist.
2. **A repackage under one of three triggers**, named in the formula's `desc` or a comment:
   - **no binary channel exists** — Ruby and Python (ruby-build compiles 2–3 minutes per host and the prebuilt rubies that exist are not relocatable; [dev#269](https://github.com/d3mlabs/dev/issues/269) adds `ruby@4.0` and `python@3.12` here);
   - **a channel exists but fails dev's admission test** (immutable versions, verifiable integrity, no root, per-host probe) — Wine via apt ([#5](https://github.com/d3mlabs/homebrew-d3mlabs/issues/5));
   - **we change the bytes** — patches, relocation.
   Brew is the right own-channel when the package has transitive runtime dependencies to declare (`depends_on` installs the closure a bare tree cannot). A self-contained tree, something large, or something licensed goes to a GitHub release in a repo we own and is consumed with dev's `gh` verb instead.
3. **A thin lift as a stopgap** — re-hosting an artifact a channel dev supports already carries, without changing the bytes, because the consuming project cannot yet reach that channel. A thin lift names its retirement condition. The three in the tap today — `clang-format@18.1.8` (a PyPI wheel), `powershell@7.4.0` (a GitHub release `.deb`), `axslcc` (GitHub release tarballs) — were right when written and retire under [#6](https://github.com/d3mlabs/homebrew-d3mlabs/issues/6) once dev puts `gh` trees on PATH.

Conventions for what is admitted:

- **Bottled for arm64 macOS and x86_64 Linux.** Today this tap's CI audits, installs and tests but does not bottle, so every formula here builds from source on the installing host (dev's lock records `format: source` and names it at `dev deps update`). Bottling CI lands with the first formula that cannot afford a source build on every host — `ruby@4.0` under dev#269.
- **`name@exact`** (`ruby@4.0`, `clang-format@18.1.8`) when two projects on one machine plausibly lock different versions; a plain `name` otherwise. dev activates the locked keg per project regardless of which keg brew linked, so the suffix is about brew's view, not dev's.
- **A bump is two steps**: the formula bump here, then `dev deps update` in each consumer, which moves its `tap_commit` pin (dev's ADR-0005).

Not admitted: a formula for something `homebrew/core` carries at the version needed; a formula that wraps a `gem`, `pip` or `luarocks` package (those have their own verbs); OS state (users, daemons, kernel modules — provisioning, not a dependency).

## Contributing

This tap is maintained by d3mlabs. Formulas point at tagged releases from their respective source repos.
