@echo off
title System and Browser Cleaner
color 0A

:: Automatically request Administrator privileges if not already running as Admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo ==================================================
echo      Cleaning junk files and browser cache...
echo ==================================================
echo.

:: 1. Clean system and user Temp and Prefetch folders
echo [+] Cleaning Temp and Prefetch folders...
del /s /f /q "%temp%\*.*" >nul 2>&1
for /d %%p in ("%temp%\*.*") do rmdir "%%p" /s /q >nul 2>&1

del /s /f /q "C:\Windows\Temp\*.*" >nul 2>&1
for /d %%p in ("C:\Windows\Temp\*.*") do rmdir "%%p" /s /q >nul 2>&1

del /s /f /q "C:\Windows\Prefetch\*.*" >nul 2>&1

:: 2. Clean Google Chrome cache (without clearing saved passwords or bookmarks)
echo [+] Cleaning Google Chrome cache...
taskkill /F /IM chrome.exe >nul 2>&1
del /s /f /q "%LocalAppData%\Google\Chrome\User Data\Default\Cache\*.*" >nul 2>&1
del /s /f /q "%LocalAppData%\Google\Chrome\User Data\Default\Code Cache\*.*" >nul 2>&1

:: 3. Clean Microsoft Edge cache
echo [+] Cleaning Microsoft Edge cache...
taskkill /F /IM msedge.exe >nul 2>&1
del /s /f /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache\*.*" >nul 2>&1
del /s /f /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Code Cache\*.*" >nul 2>&1

:: 4. Flush DNS and empty Recycle Bin
echo [+] Flushing DNS cache and emptying Recycle Bin...
ipconfig /flushdns >nul 2>&1
rd /s /q %systemdrive%\$Recycle.Bin >nul 2>&1

echo.
echo ==================================================
echo      Cleanup completed successfully!
echo ==================================================
pause