@echo off
title VM Setup Downloader

cd /d "%~dp0"

set "VMTOOLS_ISO=%~dp0VMware-tools-windows-13.1.5-25544008.iso"

echo Downloading VMware Tools...
call :download "https://packages-prod.broadcom.com/tools/releases/latest/windows/VMware-tools-windows-13.1.5-25544008.iso" "%VMTOOLS_ISO%"
if errorlevel 1 goto error

echo.
echo Mounting VMware Tools ISO...

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $img = Mount-DiskImage -ImagePath $env:VMTOOLS_ISO -PassThru; $img | Get-Volume | Select-Object DriveLetter, FileSystemLabel"

if errorlevel 1 goto error

echo.
echo VMware Tools ISO mounted successfully!

echo.
echo Downloading Xtreme Download Manager...

call :download "https://github.com/subhra74/xdm/releases/download/9.0.8/xdm-9.0.8-x64.msi" "xdm-9.0.8-x64.msi"
if errorlevel 1 goto error

echo.
echo Installing Xtreme Download Manager...

msiexec.exe /i "xdm-9.0.8-x64.msi" /passive /norestart

echo.
echo Downloading RustDesk...

call :download "https://github.com/rustdesk/rustdesk/releases/download/1.5.1/rustdesk-1.5.1-x86_64.exe" "rustdesk-1.5.1-x86_64.exe"
if errorlevel 1 goto error

echo.
echo Downloads complete!
echo VMware Tools ISO is mounted.
echo RustDesk installer is ready.
echo XDM installation launched.

pause
exit /b 0

:error
echo.
echo ERROR: Something failed!
pause
exit /b 1

:download
set "DOWNLOAD_URL=%~1"
set "DOWNLOAD_FILE=%~2"

where.exe curl.exe >nul 2>&1
if not errorlevel 1 (
    echo Using curl...
    curl.exe -fL -o "%DOWNLOAD_FILE%" "%DOWNLOAD_URL%"
    exit /b %errorlevel%
)

echo curl.exe not found. Using PowerShell Invoke-WebRequest...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; try { Invoke-WebRequest -UseBasicParsing -Uri $env:DOWNLOAD_URL -OutFile $env:DOWNLOAD_FILE } catch { Write-Error $_; exit 1 }"
exit /b %errorlevel%
