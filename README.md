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

## Contributing

This tap is maintained by d3mlabs. Formulas point at tagged releases from their respective source repos.
