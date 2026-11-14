@echo off
setlocal EnableExtensions

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
set "LOG_DIR=%LocalAppData%\Browser-Cleaner"
set "LOG_FILE=%LOG_DIR%\Cleaner.log"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1

call :Log "=================================================="
call :Log "Cleanup started"

echo ==================================================
echo      Cleaning junk files and browser cache...
echo      Log: "%LOG_FILE%"
echo ==================================================
echo.

:: Clean system and user temp folders
echo [+] Cleaning Temp and Prefetch folders...
call :CleanDirectory "%TEMP%"
call :CleanDirectory "%SystemRoot%\Temp"
call :CleanDirectory "%SystemRoot%\Prefetch"

:: Clean Google Chrome cache (without clearing saved passwords or bookmarks)
echo [+] Cleaning Google Chrome cache...
call :Log "Closing Google Chrome, if running"
taskkill /F /IM chrome.exe >nul 2>&1
call :CleanDirectory "%LocalAppData%\Google\Chrome\User Data\Default\Cache"
call :CleanDirectory "%LocalAppData%\Google\Chrome\User Data\Default\Code Cache"

:: Clean Microsoft Edge cache
echo [+] Cleaning Microsoft Edge cache...
call :Log "Closing Microsoft Edge, if running"
taskkill /F /IM msedge.exe >nul 2>&1
call :CleanDirectory "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache"
call :CleanDirectory "%LocalAppData%\Microsoft\Edge\User Data\Default\Code Cache"

:: Clean Mozilla Firefox cache across all discovered profiles
echo [+] Cleaning Mozilla Firefox cache...
call :Log "Closing Mozilla Firefox, if running"
taskkill /F /IM firefox.exe >nul 2>&1
for /d %%P in ("%APPDATA%\Mozilla\Firefox\Profiles\*") do call :CleanDirectory "%%~fP\cache2"

:: Clean Brave cache across all discovered profiles
echo [+] Cleaning Brave cache...
call :Log "Closing Brave, if running"
taskkill /F /IM brave.exe >nul 2>&1
for /d %%P in ("%LocalAppData%\BraveSoftware\Brave-Browser\User Data\*") do (
    call :CleanDirectory "%%~fP\Cache"
    call :CleanDirectory "%%~fP\Code Cache"
)

:: Flush DNS and empty Recycle Bin
echo [+] Flushing DNS cache and emptying Recycle Bin...
call :Log "Flushing DNS cache"
ipconfig /flushdns >nul 2>&1
if errorlevel 1 (call :Log "DNS cache flush failed") else (call :Log "DNS cache flush completed")
if exist "%SystemDrive%\$Recycle.Bin" (
    call :Log "Emptying Recycle Bin"
    rd /s /q "%SystemDrive%\$Recycle.Bin" >nul 2>&1
    if errorlevel 1 (call :Log "Recycle Bin cleanup failed or was incomplete") else (call :Log "Recycle Bin cleanup completed")
) else (
    call :Log "Recycle Bin folder not found; skipped"
)

echo.
echo ==================================================
echo      Cleanup completed. See the log for details.
echo ==================================================
call :Log "Cleanup finished; locked or inaccessible files may have been skipped"
pause
exit /b

:CleanDirectory
if exist "%~1" (
    del /f /s /q "%~1\*.*" >nul 2>&1
    for /d %%D in ("%~1\*") do rd /s /q "%%~fD" >nul 2>&1
    call :Log "Directory cleanup attempted; locked or inaccessible files may remain"
) else (
    call :Log "Cache or temporary directory not found; skipped"
)
exit /b

:Log
echo [%date% %time%] %~1>>"%LOG_FILE%"
exit /b
