# Contributing Guide

Thanks for helping improve Hotspot-Starter.

## Development Setup

1. Fork the repository.
2. Clone your fork:
   ```powershell
   git clone https://github.com/<your-username>/Hotspot-Starter.git
   cd Hotspot-Starter
   ```
3. Create a feature branch:
   ```powershell
   git checkout -b feature/your-change
   ```

## Coding Standards

- Keep scripts compatible with Windows PowerShell 5.1 and newer.
- Prefer clear, descriptive log and error messages.
- Use `$PSScriptRoot` and relative paths when possible.
- Keep changes focused and avoid unrelated formatting-only edits.

## Submitting Changes

1. Commit your changes with a clear message.
2. Push to your fork.
3. Open a pull request that includes:
   - What changed
   - Why it changed
   - How you tested it

## Reporting Issues

When reporting a bug, include:

- Windows version
- PowerShell version (`$PSVersionTable.PSVersion`)
- Reproduction steps
- Relevant log lines from `logs/hotspot.log`
