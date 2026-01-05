<#
.SYNOPSIS
    Toggle Windows Mobile Hotspot on or off.

.DESCRIPTION
    This script automatically enables or disables the Windows Mobile Hotspot
    using the Windows Runtime (WinRT) NetworkOperatorTetheringManager API.
    It includes robust error handling and logging capabilities.

.NOTES
    Author  : Sh. (Original), Refactored by Automation Engineer
    Created : 2025-08-07
    Updated : 2026-01-04
    Requires: Administrator privileges, Windows 10/11

.EXAMPLE
    .\Toggle-Hotspot.ps1
    Toggles the hotspot state (on→off or off→on)

.EXAMPLE
    .\Toggle-Hotspot.ps1 -Action Start
    Forces the hotspot to start

.EXAMPLE
    .\Toggle-Hotspot.ps1 -Action Stop
    Forces the hotspot to stop
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("Toggle", "Start", "Stop", "Status")]
    [string]$Action = "Toggle"
)

#region Configuration
$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot
$LogDir = Join-Path (Split-Path $ScriptRoot -Parent) "logs"
$LogFile = Join-Path $LogDir "hotspot.log"
$MaxLogAgeDays = 7
#endregion

#region Logging Functions
function Write-Log {
    <#
    .SYNOPSIS
        Writes a timestamped log entry to the log file and optionally to console.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")]
        [string]$Level,
        
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    
    # Ensure log directory exists
    if (-not (Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Level] $Message"
    
    # Write to log file
    Add-Content -Path $LogFile -Value $logEntry -Encoding UTF8
    
    # Write to console with color coding
    switch ($Level) {
        "INFO"  { Write-Host $logEntry -ForegroundColor Green }
        "WARN"  { Write-Host $logEntry -ForegroundColor Yellow }
        "ERROR" { Write-Host $logEntry -ForegroundColor Red }
        "DEBUG" { Write-Host $logEntry -ForegroundColor Cyan }
    }
}

function Clear-OldLogs {
    <#
    .SYNOPSIS
        Removes log entries older than the specified retention period.
    #>
    if (Test-Path $LogFile) {
        $cutoffDate = (Get-Date).AddDays(-$MaxLogAgeDays)
        $content = Get-Content $LogFile -Encoding UTF8
        $filteredContent = $content | Where-Object {
            if ($_ -match '^\d{4}-\d{2}-\d{2}') {
                $dateStr = $_.Substring(0, 10)
                try {
                    $logDate = [DateTime]::ParseExact($dateStr, "yyyy-MM-dd", $null)
                    return $logDate -ge $cutoffDate
                } catch {
                    return $true
                }
            }
            return $true
        }
        $filteredContent | Set-Content $LogFile -Encoding UTF8
    }
}
#endregion

#region WinRT Async Helpers
function Initialize-WinRT {
    <#
    .SYNOPSIS
        Loads required Windows Runtime assemblies and types.
    #>
    try {
        [Windows.System.UserProfile.LockScreen, Windows.System.UserProfile, ContentType=WindowsRuntime] | Out-Null
        Add-Type -AssemblyName System.Runtime.WindowsRuntime
        Write-Log -Level "DEBUG" -Message "WinRT assemblies loaded successfully"
    } catch {
        Write-Log -Level "ERROR" -Message "Failed to load WinRT assemblies: $($_.Exception.Message)"
        throw
    }
}

function Invoke-Await {
    <#
    .SYNOPSIS
        Awaits a WinRT IAsyncOperation and returns the result.
    #>
    param(
        [Parameter(Mandatory = $true)]
        $WinRtTask,
        
        [Parameter(Mandatory = $true)]
        [Type]$ResultType
    )
    
    $asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | 
        Where-Object { 
            $_.Name -eq 'AsTask' -and 
            $_.GetParameters().Count -eq 1 -and 
            $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' 
        })[0]
    
    $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
    $netTask = $asTask.Invoke($null, @($WinRtTask))
    $netTask.Wait(-1) | Out-Null
    return $netTask.Result
}

function Invoke-AwaitAction {
    <#
    .SYNOPSIS
        Awaits a WinRT IAsyncAction (no return value).
    #>
    param(
        [Parameter(Mandatory = $true)]
        $WinRtAction
    )
    
    $asTask = ([System.WindowsRuntimeSystemExtensions].GetMethods() | 
        Where-Object { 
            $_.Name -eq 'AsTask' -and 
            $_.GetParameters().Count -eq 1 -and 
            -not $_.IsGenericMethod 
        })[0]
    
    $netTask = $asTask.Invoke($null, @($WinRtAction))
    $netTask.Wait(-1) | Out-Null
}
#endregion

#region Hotspot Management
function Get-TetheringManager {
    <#
    .SYNOPSIS
        Creates and returns a NetworkOperatorTetheringManager instance.
    #>
    try {
        $connectionProfile = [Windows.Networking.Connectivity.NetworkInformation, Windows.Networking.Connectivity, ContentType=WindowsRuntime]::GetInternetConnectionProfile()
        
        if ($null -eq $connectionProfile) {
            Write-Log -Level "ERROR" -Message "No internet connection profile found. Ensure you have an active internet connection."
            throw "No internet connection available"
        }
        
        $tetheringManager = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager, Windows.Networking.NetworkOperators, ContentType=WindowsRuntime]::CreateFromConnectionProfile($connectionProfile)
        
        Write-Log -Level "DEBUG" -Message "TetheringManager created successfully"
        return $tetheringManager
    } catch {
        Write-Log -Level "ERROR" -Message "Failed to create TetheringManager: $($_.Exception.Message)"
        throw
    }
}

function Get-HotspotState {
    <#
    .SYNOPSIS
        Returns the current operational state of the mobile hotspot.
    .OUTPUTS
        String: "On", "Off", or "Unknown"
    #>
    param(
        [Parameter(Mandatory = $true)]
        $TetheringManager
    )
    
    $state = $TetheringManager.TetheringOperationalState
    switch ($state) {
        0 { return "Unknown" }
        1 { return "On" }
        2 { return "Off" }
        3 { return "InTransition" }
        default { return "Unknown ($state)" }
    }
}

function Start-MobileHotspot {
    <#
    .SYNOPSIS
        Starts the mobile hotspot.
    #>
    param(
        [Parameter(Mandatory = $true)]
        $TetheringManager
    )
    
    Write-Log -Level "INFO" -Message "Starting mobile hotspot..."
    
    try {
        $result = Invoke-Await -WinRtTask ($TetheringManager.StartTetheringAsync()) -ResultType ([Windows.Networking.NetworkOperators.NetworkOperatorTetheringOperationResult])
        
        if ($result.Status -eq 0) {
            Write-Log -Level "INFO" -Message "Mobile hotspot started successfully"
            return $true
        } else {
            Write-Log -Level "ERROR" -Message "Failed to start hotspot. Status: $($result.Status)"
            return $false
        }
    } catch {
        Write-Log -Level "ERROR" -Message "Exception while starting hotspot: $($_.Exception.Message)"
        throw
    }
}

function Stop-MobileHotspot {
    <#
    .SYNOPSIS
        Stops the mobile hotspot.
    #>
    param(
        [Parameter(Mandatory = $true)]
        $TetheringManager
    )
    
    Write-Log -Level "INFO" -Message "Stopping mobile hotspot..."
    
    try {
        $result = Invoke-Await -WinRtTask ($TetheringManager.StopTetheringAsync()) -ResultType ([Windows.Networking.NetworkOperators.NetworkOperatorTetheringOperationResult])
        
        if ($result.Status -eq 0) {
            Write-Log -Level "INFO" -Message "Mobile hotspot stopped successfully"
            return $true
        } else {
            Write-Log -Level "ERROR" -Message "Failed to stop hotspot. Status: $($result.Status)"
            return $false
        }
    } catch {
        Write-Log -Level "ERROR" -Message "Exception while stopping hotspot: $($_.Exception.Message)"
        throw
    }
}
#endregion

#region Main Execution
try {
    Write-Log -Level "INFO" -Message "========== Hotspot Script Started =========="
    Write-Log -Level "INFO" -Message "Action requested: $Action"
    
    # Clean up old logs
    Clear-OldLogs
    
    # Initialize WinRT
    Initialize-WinRT
    
    # Get tethering manager
    $tetheringManager = Get-TetheringManager
    $currentState = Get-HotspotState -TetheringManager $tetheringManager
    Write-Log -Level "INFO" -Message "Current hotspot state: $currentState"
    
    # Execute requested action
    switch ($Action) {
        "Status" {
            Write-Log -Level "INFO" -Message "Hotspot status check complete"
            Write-Output "Hotspot is currently: $currentState"
        }
        "Start" {
            if ($currentState -eq "On") {
                Write-Log -Level "WARN" -Message "Hotspot is already on"
                Write-Output "Hotspot is already running"
            } else {
                Start-MobileHotspot -TetheringManager $tetheringManager
            }
        }
        "Stop" {
            if ($currentState -eq "Off") {
                Write-Log -Level "WARN" -Message "Hotspot is already off"
                Write-Output "Hotspot is already stopped"
            } else {
                Stop-MobileHotspot -TetheringManager $tetheringManager
            }
        }
        "Toggle" {
            if ($currentState -eq "On") {
                Stop-MobileHotspot -TetheringManager $tetheringManager
            } else {
                Start-MobileHotspot -TetheringManager $tetheringManager
            }
        }
    }
    
    Write-Log -Level "INFO" -Message "========== Hotspot Script Completed =========="
    exit 0
    
} catch {
    Write-Log -Level "ERROR" -Message "Unhandled exception: $($_.Exception.Message)"
    Write-Log -Level "ERROR" -Message "Stack trace: $($_.ScriptStackTrace)"
    Write-Log -Level "INFO" -Message "========== Hotspot Script Failed =========="
    exit 1
}
#endregion
