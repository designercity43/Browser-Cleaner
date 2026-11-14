@echo off
setlocal EnableExtensions EnableDelayedExpansion

title System and Browser Cleaner
color 0A

:: Automatically request Administrator privileges if not already running as Admin
net session >nul 2>&1
if not "%ERRORLEVEL%"=="0" (
    echo Requesting Administrator privileges...
    powershell -NoProfile -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

if not defined LocalAppData if defined USERPROFILE set "LocalAppData=%USERPROFILE%\AppData\Local"

echo ==================================================
echo      Cleaning junk files and browser cache...
echo ==================================================
echo.

:: Clean system and user temp folders
call :CleanDirectory "%TEMP%"
call :CleanDirectory "%SystemRoot%\Temp"
call :CleanDirectory "%SystemRoot%\Prefetch"

:: Clean Google Chrome cache (without clearing saved passwords or bookmarks)
echo [+] Cleaning Google Chrome cache...
taskkill /F /IM chrome.exe >nul 2>&1
call :CleanDirectory "%LocalAppData%\Google\Chrome\User Data\Default\Cache"
call :CleanDirectory "%LocalAppData%\Google\Chrome\User Data\Default\Code Cache"

:: Clean Microsoft Edge cache
echo [+] Cleaning Microsoft Edge cache...
taskkill /F /IM msedge.exe >nul 2>&1
call :CleanDirectory "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache"
call :CleanDirectory "%LocalAppData%\Microsoft\Edge\User Data\Default\Code Cache"

:: Flush DNS and empty Recycle Bin
echo [+] Flushing DNS cache and emptying Recycle Bin...
ipconfig /flushdns >nul 2>&1
if exist "%SystemDrive%\$Recycle.Bin" rd /s /q "%SystemDrive%\$Recycle.Bin" >nul 2>&1

echo.
echo ==================================================
echo      Cleanup completed successfully!
echo ==================================================
pause
exit /b

:CleanDirectory
set "dir=%~1"
if exist "%dir%" (
    del /f /s /q "%dir%\*.*" >nul 2>&1
    for /d %%D in ("%dir%\*") do rd /s /q "%%~fD" >nul 2>&1
)
exit /b
