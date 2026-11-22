@echo off
title VM Setup Downloader

cd /d "%~dp0"

if /i "%~1"=="-w" goto windows_install
if /i "%~1"=="--windows-install" goto windows_install

set "VMTOOLS_ISO=%~dp0VMware-tools-windows-13.1.5-25544008.iso"

echo Downloading VMware Tools...
call :download "https://packages.vmware.com/tools/esx/latest/windows/VMware-tools-windows-13.1.5-25544008.iso" "%VMTOOLS_ISO%"
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
echo Downloading RustDesk 1.5.3 MSI...

call :download "https://github.com/rustdesk/rustdesk/releases/download/1.5.3/rustdesk-1.5.3-x86_64.msi" "rustdesk-1.5.3-x86_64.msi"
if errorlevel 1 goto error

echo.
echo Launching RustDesk MSI installer...
msiexec.exe /i "rustdesk-1.5.3-x86_64.msi"

echo.
echo Downloads complete!
echo VMware Tools ISO is mounted.
echo RustDesk installation launched.
echo XDM installation launched.

pause
exit /b 0

:windows_install
set "WINDOWS_ISO=%~dp0Windows-IoT-Enterprise-LTSC-Eval.iso"
echo Windows IoT Enterprise LTSC Evaluation ISO download selected.
echo This is a large download. Make sure you have enough disk space.
call :download "https://software-static.download.prss.microsoft.com/dbazure/998969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_CLIENT_IOT_LTSC_EVAL_x64FRE_en-us.iso" "%WINDOWS_ISO%"
if errorlevel 1 goto error

echo.
echo Mounting Windows ISO...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $img = Mount-DiskImage -ImagePath $env:WINDOWS_ISO -PassThru; $img | Get-Volume | Select-Object DriveLetter, FileSystemLabel"
if errorlevel 1 goto error

echo.
echo Windows ISO downloaded and mounted successfully!
echo ISO location:
echo %WINDOWS_ISO%
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
    if errorlevel 1 exit /b 1
    exit /b 0
)

echo curl.exe not found. Using PowerShell Invoke-WebRequest...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; try { Invoke-WebRequest -UseBasicParsing -Uri $env:DOWNLOAD_URL -OutFile $env:DOWNLOAD_FILE } catch { Write-Error $_; exit 1 }"
exit /b %errorlevel%
