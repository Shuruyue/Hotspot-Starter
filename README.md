<div align="center">

# Hotspot-Starter

**Automatically enable Windows Mobile Hotspot at system startup**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?logo=windows)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white)](https://docs.microsoft.com/powershell/)

[Features](#features) •
[Quick Start](#quick-start) •
[Installation](#installation) •
[Documentation](#documentation) •
[Contributing](#contributing)

</div>

---

## Features

| Feature | Description |
|---------|-------------|
| Toggle Control | Start, stop, or toggle hotspot with a single command |
| Auto Startup | Automatically start hotspot at user logon |
| Logging | Timestamped logs for troubleshooting |
| Error Handling | Comprehensive error handling with descriptive messages |
| Modern API | Uses Windows Runtime (WinRT), fully compatible with Windows 10/11 |

## Quick Start

```powershell
# Clone the repository
git clone https://github.com/Shuruyue/Hotspot-Starter.git
cd Hotspot-Starter

# Toggle hotspot (on to off or off to on)
.\scripts\Toggle-Hotspot.ps1

# Or use specific actions
.\scripts\Toggle-Hotspot.ps1 -Action Start    # Force start
.\scripts\Toggle-Hotspot.ps1 -Action Stop     # Force stop
.\scripts\Toggle-Hotspot.ps1 -Action Status   # Check status
```

## Installation

### Prerequisites

| Requirement | Version |
|-------------|---------|
| Operating System | Windows 10 (1803+) or Windows 11 |
| PowerShell | 5.1 or later |
| Privileges | Administrator |
| Network | Active internet connection |

### Setup Automatic Startup

Run as **Administrator**:

```powershell
.\Install-ScheduledTask.ps1
```

This creates a scheduled task that starts the hotspot **30 seconds after user logon**.

To remove:

```powershell
.\Install-ScheduledTask.ps1 -Uninstall
```

## Project Structure

```
Hotspot-Starter/
├── scripts/
│   └── Toggle-Hotspot.ps1       # Main hotspot control script
├── docs/
│   ├── INSTALLATION.md          # Detailed setup guide
│   └── TROUBLESHOOTING.md       # Common issues and solutions
├── logs/                        # Runtime logs (auto-created)
├── Start-Hotspot.bat            # Quick launcher (double-click)
├── Install-ScheduledTask.ps1    # Task Scheduler setup
├── SECURITY.md                  # Security policy
├── CONTRIBUTING.md              # Contribution guidelines
└── LICENSE                      # MIT License
```

## Documentation

| Document | Description |
|----------|-------------|
| [Installation Guide](docs/INSTALLATION.md) | Step-by-step setup instructions |
| [Troubleshooting](docs/TROUBLESHOOTING.md) | Common issues and solutions |
| [Security Policy](SECURITY.md) | Security considerations |
| [Contributing](CONTRIBUTING.md) | How to contribute |

## Security

This project has been audited for security concerns:

- No hardcoded credentials or user paths
- Uses relative paths (`$PSScriptRoot`)
- No external network dependencies
- No data collection or transmission

See [SECURITY.md](SECURITY.md) for full details.

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Original concept by **Sh.**
- Uses Windows Runtime (WinRT) `NetworkOperatorTetheringManager` API
- Inspired by the community need for reliable hotspot automation

---

<div align="center">

**[Back to Top](#hotspot-starter)**

</div>
