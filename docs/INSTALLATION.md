# Installation Guide

This guide provides step-by-step instructions for setting up Hotspot-Starter.

## Prerequisites

| Requirement | Version |
|-------------|---------|
| Operating System | Windows 10 (1803+) or Windows 11 |
| PowerShell | 5.1 or later |
| Privileges | Administrator access |
| Network | Active internet connection |

## Installation Steps

### Step 1: Download or Clone

```powershell
git clone https://github.com/Shuruyue/Hotspot-Starter.git
```

**Recommended locations:**
- `C:\Tools\Hotspot-Starter`
- `%USERPROFILE%\Scripts\Hotspot-Starter`

> **Important:** Avoid placing in Downloads or temporary directories.

### Step 2: Verify Execution Policy

Open PowerShell as **Administrator**:

```powershell
Get-ExecutionPolicy
```

If `Restricted`, run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Step 3: Test the Script

```powershell
cd "C:\Path\To\Hotspot-Starter"
.\scripts\Toggle-Hotspot.ps1 -Action Status
```

**Expected output:**
```
2026-01-04 14:30:00 [INFO] ========== Hotspot Script Started ==========
2026-01-04 14:30:00 [INFO] Current hotspot state: Off
Hotspot is currently: Off
2026-01-04 14:30:00 [INFO] ========== Hotspot Script Completed ==========
```

### Step 4: Configure Auto-Startup (Optional)

Run as **Administrator**:

```powershell
.\Install-ScheduledTask.ps1
```

**What this does:**

| Setting | Value |
|---------|-------|
| Task Name | Hotspot-Starter |
| Trigger | At user logon (30s delay) |
| Privileges | Highest |

### Step 5: Verify Installation

1. Open Task Scheduler (`Win + R` then type `taskschd.msc`)
2. Find **Hotspot-Starter** in Task Scheduler Library
3. Verify settings match the table above

## Uninstallation

```powershell
# Remove scheduled task
.\Install-ScheduledTask.ps1 -Uninstall

# Delete the folder
Remove-Item -Path "C:\Path\To\Hotspot-Starter" -Recurse
```

## Post-Installation Verification

After restarting your computer:

1. Wait **30+ seconds** after logging in
2. Check hotspot status:
   - Settings > Network & Internet > Mobile hotspot
3. Review logs:
   ```powershell
   Get-Content .\logs\hotspot.log -Tail 20
   ```

## Next Steps

- [Troubleshooting Guide](TROUBLESHOOTING.md) - If you encounter issues
