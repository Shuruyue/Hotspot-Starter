# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.x     | Yes |

## Security Considerations

### Required Privileges

This application requires **Administrator privileges** to control the Windows Mobile Hotspot. This is a necessary requirement of the Windows Runtime API.

### What the Scripts Access

| Resource | Purpose | Risk Level |
|----------|---------|------------|
| Network Adapter | Hotspot control | Low |
| Windows Registry | None | None |
| File System | Logging only | Low |
| Internet | None | None |

### Security Best Practices

1. **Official Sources Only**
   
   Download only from the official GitHub repository.

2. **Verify Script Integrity**
   ```powershell
   Get-FileHash .\scripts\Toggle-Hotspot.ps1 -Algorithm SHA256
   ```

3. **Review Before Running**
   ```powershell
   Get-Content .\scripts\Toggle-Hotspot.ps1 | Out-Host -Paging
   ```

4. **Execution Policy**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

## Data Privacy

| Aspect | Status |
|--------|--------|
| Data Collection | None |
| Data Transmission | None |
| External Requests | None |
| Local Logs | `logs/` folder only |

## Reporting Vulnerabilities

If you discover a security vulnerability:

1. **DO NOT** open a public issue
2. Open a private [Security Advisory](../../security/advisories/new) on GitHub
3. Or email the maintainers directly

We will respond within **48 hours**.

## Audit History

| Date | Scope | Result |
|------|-------|--------|
| 2026-01-04 | Full code review | Passed |

**Audit Findings:**
- No hardcoded credentials
- No hardcoded user paths (uses `$PSScriptRoot`)
- Proper error handling
- No external dependencies
- No data exfiltration risks
