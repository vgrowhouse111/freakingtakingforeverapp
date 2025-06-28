@echo off
echo Resetting Windows network stack...
echo.

:: Reset TCP/IP stack
netsh int ip reset resetlog.txt

:: Reset Winsock
netsh winsock reset

:: Flush DNS
ipconfig /flushdns

:: Reset network adapters
netsh interface ipv4 reset
netsh interface ipv6 reset

echo.
echo Network stack reset complete.
echo Please restart your computer to apply all changes.
pause
