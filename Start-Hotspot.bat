@echo off
:: =============================================================================
:: Start-Hotspot.bat
:: Launcher script for Toggle-Hotspot.ps1
:: 
:: This script runs the PowerShell hotspot toggle script with administrator
:: privileges and hidden window for seamless execution.
::
:: Usage:
::   Double-click to toggle hotspot, or run from Task Scheduler
::
:: Author: Automation Engineer
:: Updated: 2026-01-04
:: =============================================================================

:: Run PowerShell script with bypass execution policy and hidden window
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0scripts\Toggle-Hotspot.ps1" -Action Start
