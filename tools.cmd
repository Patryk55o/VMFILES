
@echo off
title VM Setup Downloader

echo Downloading VMware Tools...
curl.exe -fL -O "https://packages-prod.broadcom.com/tools/releases/latest/windows/VMware-tools-windows-13.1.5-25544008.iso"
if errorlevel 1 goto error

echo.
echo Downloading Xtreme Download Manager...
curl.exe -fL -O "https://github.com/subhra74/xdm/releases/download/9.0.8/xdm-9.0.8-x64.msi"
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
echo VMware Tools ISO is ready to mount.
echo RustDesk installer is ready to run.
echo Tools Have Been Downloaded/Installed
pause >nul

:error
echo.
echo ERROR: A download failed!
pause
exit /b 1
