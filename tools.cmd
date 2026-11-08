
@echo off
title VM Setup Downloader

cd /d "%~dp0"

set "VMTOOLS_ISO=%~dp0VMware-tools-windows-13.1.5-25544008.iso"

echo Downloading VMware Tools...
curl.exe -fL -o "%VMTOOLS_ISO%" "https://packages-prod.broadcom.com/tools/releases/latest/windows/VMware-tools-windows-13.1.5-25544008.iso"
if errorlevel 1 goto error

echo.
echo Mounting VMware Tools ISO...

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $img = Mount-DiskImage -ImagePath $env:VMTOOLS_ISO -PassThru; $img | Get-Volume | Select-Object DriveLetter, FileSystemLabel"

if errorlevel 1 goto error

echo.
echo VMware Tools ISO mounted successfully!

echo.
echo Downloading Xtreme Download Manager...

curl.exe -fL -o "xdm-9.0.8-x64.msi" "https://github.com/subhra74/xdm/releases/download/9.0.8/xdm-9.0.8-x64.msi"
if errorlevel 1 goto error

echo.
echo Installing Xtreme Download Manager...

msiexec.exe /i "xdm-9.0.8-x64.msi" /passive /norestart

echo.
echo Downloading RustDesk...

curl.exe -fL -o "rustdesk-1.5.1-x86_64.exe" "https://github.com/rustdesk/rustdesk/releases/download/1.5.1/rustdesk-1.5.1-x86_64.exe"
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
