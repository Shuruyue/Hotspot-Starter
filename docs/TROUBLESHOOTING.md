# Troubleshooting Guide

Quick solutions for common issues with Hotspot-Starter.

## Quick Diagnostics

```powershell
# Check status
.\scripts\Toggle-Hotspot.ps1 -Action Status

# View recent logs
Get-Content .\logs\hotspot.log -Tail 30
```

---

## Common Issues

### 1. "No internet connection profile found"

| Cause | Solution |
|-------|----------|
| No active connection | Connect to WiFi or Ethernet first |
| Adapter disabled | Enable network adapter in Device Manager |

```powershell
# Check active adapters
Get-NetAdapter | Where-Object Status -eq 'Up'
```

---

### 2. "Access Denied" or Permission Errors

| Cause | Solution |
|-------|----------|
| Not running as Admin | Right-click PowerShell, select "Run as administrator" |
| Execution policy | Run: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| UAC blocking | Allow in UAC prompt |

---

### 3. Hotspot Does Not Start at Login

**Check scheduled task:**
```powershell
Get-ScheduledTask -TaskName "Hotspot-Starter" | Get-ScheduledTaskInfo
```

**Solutions:**

| Issue | Fix |
|-------|-----|
| Task missing | Run `.\Install-ScheduledTask.ps1` again |
| Network slow | Increase delay in Task Scheduler |
| Task disabled | Enable in Task Scheduler |

**Reinstall task:**
```powershell
.\Install-ScheduledTask.ps1 -Uninstall
.\Install-ScheduledTask.ps1
```

---

### 4. "Mobile Hotspot can not be set up"

**Check hardware support:**
```powershell
netsh wlan show drivers | Select-String "Hosted network supported"
```
Result should be **Yes**

**Solutions:**

| Cause | Solution |
|-------|----------|
| Unsupported hardware | Use a compatible USB WiFi adapter |
| Driver issue | Update network driver |
| Adapter busy | Disable and re-enable WiFi adapter |

```powershell
# Restart WiFi adapter
Disable-NetAdapter -Name "Wi-Fi" -Confirm:$false
Start-Sleep 5
Enable-NetAdapter -Name "Wi-Fi"
```

---

### 5. Logs Not Being Created

**Check:**
```powershell
# Does logs folder exist?
Test-Path .\logs

# Create if missing
New-Item -ItemType Directory -Path ".\logs" -Force
```

---

## Log File Reference

**Format:** `YYYY-MM-DD HH:MM:SS [LEVEL] Message`

| Level | Meaning |
|-------|---------|
| `INFO` | Normal operation |
| `WARN` | Non-critical warning |
| `ERROR` | Operation failed |
| `DEBUG` | Diagnostic info |

---

## Getting Help

**Collect diagnostic info:**
```powershell
# System info
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion

# Network adapters
Get-NetAdapter | Format-Table Name, Status, InterfaceDescription

# Logs
Get-Content .\logs\hotspot.log
```

**Open an issue** with:
- Windows version
- Error messages
- Log file contents
- Steps to reproduce
