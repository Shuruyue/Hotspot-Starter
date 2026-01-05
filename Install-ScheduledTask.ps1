<#
.SYNOPSIS
    Installs a scheduled task to automatically start the mobile hotspot at user logon.

.DESCRIPTION
    This script creates a Windows Task Scheduler task that runs the Toggle-Hotspot.ps1
    script with "Start" action when the current user logs on. The task is configured
    with a 30-second delay to ensure network connectivity is established.

.NOTES
    Author  : Automation Engineer
    Created : 2026-01-04
    Requires: Administrator privileges

.EXAMPLE
    .\Install-ScheduledTask.ps1
    Creates the scheduled task with default settings

.EXAMPLE
    .\Install-ScheduledTask.ps1 -Uninstall
    Removes the scheduled task
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$Uninstall
)

$TaskName = "Hotspot-Starter"
$TaskDescription = "Automatically starts the mobile hotspot when user logs on"
$ScriptPath = Join-Path $PSScriptRoot "scripts\Toggle-Hotspot.ps1"

function Write-Status {
    param([string]$Message, [string]$Type = "INFO")
    $color = switch ($Type) {
        "INFO" { "Green" }
        "WARN" { "Yellow" }
        "ERROR" { "Red" }
        "SUCCESS" { "Cyan" }
        default { "White" }
    }
    Write-Host "[$Type] $Message" -ForegroundColor $color
}

# Check for administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Status "This script requires administrator privileges. Please run as Administrator." -Type "ERROR"
    exit 1
}

if ($Uninstall) {
    # Remove existing task
    Write-Status "Removing scheduled task '$TaskName'..."
    
    try {
        $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($existingTask) {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
            Write-Status "Scheduled task '$TaskName' has been removed successfully." -Type "SUCCESS"
        }
        else {
            Write-Status "Scheduled task '$TaskName' does not exist." -Type "WARN"
        }
    }
    catch {
        Write-Status "Failed to remove scheduled task: $($_.Exception.Message)" -Type "ERROR"
        exit 1
    }
}
else {
    # Verify script exists
    if (-not (Test-Path $ScriptPath)) {
        Write-Status "Script not found at: $ScriptPath" -Type "ERROR"
        exit 1
    }

    Write-Status "Creating scheduled task '$TaskName'..."
    
    try {
        # Remove existing task if present
        $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($existingTask) {
            Write-Status "Removing existing task..." -Type "WARN"
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        }

        # Create trigger: At logon with 30-second delay
        $trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
        $trigger.Delay = "PT30S"  # 30 second delay

        # Create action: Run PowerShell script
        $action = New-ScheduledTaskAction `
            -Execute "powershell.exe" `
            -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`" -Action Start" `
            -WorkingDirectory $PSScriptRoot

        # Create principal: Run with highest privileges
        $principal = New-ScheduledTaskPrincipal `
            -UserId $env:USERNAME `
            -RunLevel Highest `
            -LogonType Interactive

        # Create settings
        $settings = New-ScheduledTaskSettingsSet `
            -AllowStartIfOnBatteries `
            -DontStopIfGoingOnBatteries `
            -StartWhenAvailable `
            -ExecutionTimeLimit (New-TimeSpan -Minutes 5)

        # Register the task
        Register-ScheduledTask `
            -TaskName $TaskName `
            -Description $TaskDescription `
            -Trigger $trigger `
            -Action $action `
            -Principal $principal `
            -Settings $settings `
            -Force | Out-Null

        Write-Status "Scheduled task '$TaskName' created successfully!" -Type "SUCCESS"
        Write-Status ""
        Write-Status "Configuration Summary:" -Type "INFO"
        Write-Status "  - Task Name    : $TaskName"
        Write-Status "  - Trigger      : At user logon (30s delay)"
        Write-Status "  - Privileges   : Run with highest privileges"
        Write-Status "  - Script       : $ScriptPath"
        Write-Status ""
        Write-Status "The hotspot will automatically start when you log in." -Type "SUCCESS"

    }
    catch {
        Write-Status "Failed to create scheduled task: $($_.Exception.Message)" -Type "ERROR"
        exit 1
    }
}
