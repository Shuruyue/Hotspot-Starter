@echo off
:: =============================================================================
:: Start-Hotspot.bat
:: Launcher script for Toggle-Hotspot.ps1
:: 
:: This script runs the PowerShell hotspot script in start mode with a
:: hidden window for seamless execution.
::
:: Usage:
::   Double-click to start hotspot, or run from Task Scheduler
::
:: Author: Automation Engineer
:: Updated: 2026-01-04
:: =============================================================================

:: Run PowerShell script with bypass execution policy and hidden window
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0scripts\Toggle-Hotspot.ps1" -Action Start
