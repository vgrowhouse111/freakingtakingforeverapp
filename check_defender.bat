@echo off
echo Checking Windows Defender status...
powershell -Command "Get-MpPreference | Select-Object DisableRealtimeMonitoring, DisableBehaviorMonitoring, DisableBlockAtFirstSeen, DisableIOAVProtection | Format-List"
echo.
echo If any of these are set to 'False', Windows Defender might be blocking Node.js
pause
