@echo off
title VM Setup Downloader

cd /d "%~dp0"

set "SKIP_VMWARE="
set "SKIP_XDM="
set "SKIP_RUSTDESK="

:parse_args
if "%~1"=="" goto main
if /i "%~1"=="-w" goto windows_install
if /i "%~1"=="--windows-install" goto windows_install
if /i "%~1"=="-ac" goto activate
if /i "%~1"=="--activate" goto activate
if /i "%~1"=="--skip-vmware" set "SKIP_VMWARE=1"
if /i "%~1"=="--skip-xdm" set "SKIP_XDM=1"
if /i "%~1"=="--skip-rustdesk" set "SKIP_RUSTDESK=1"
shift
goto parse_args

:main
set "VMTOOLS_ISO=%~dp0VMware-tools-windows-13.1.5-25544008.iso"

if defined SKIP_VMWARE (
    echo Skipping VMware Tools stage.
) else (
    echo Downloading VMware Tools...
    call :download "https://packages.vmware.com/tools/esx/latest/windows/VMware-tools-windows-13.1.5-25544008.iso" "%VMTOOLS_ISO%"
    if errorlevel 1 goto error
    
    echo.
    echo Mounting VMware Tools ISO...
    
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $img = Mount-DiskImage -ImagePath $env:VMTOOLS_ISO -PassThru; $img | Get-Volume | Select-Object DriveLetter, FileSystemLabel"
    
    if errorlevel 1 goto error
    
    echo.
    echo VMware Tools ISO mounted successfully!
)

if defined SKIP_XDM (
    echo Skipping XDM stage.
) else (
    echo.
    echo Downloading Xtreme Download Manager...
    
    call :download "https://github.com/subhra74/xdm/releases/download/9.0.8/xdm-9.0.8-x64.msi" "xdm-9.0.8-x64.msi"
    if errorlevel 1 goto error
    
    echo.
    echo Installing Xtreme Download Manager...
    
    msiexec.exe /i "xdm-9.0.8-x64.msi" /passive /norestart
)

if defined SKIP_RUSTDESK (
    echo Skipping RustDesk stage.
) else (
    echo.
    echo Downloading RustDesk 1.5.3 MSI...
    
    call :download "https://github.com/rustdesk/rustdesk/releases/download/1.5.3/rustdesk-1.5.3-x86_64.msi" "rustdesk-1.5.3-x86_64.msi"
    if errorlevel 1 goto error
    
    echo.
    echo Installing RustDesk...
    msiexec.exe /i "rustdesk-1.5.3-x86_64.msi" /passive /norestart
)

echo.
echo Downloads complete!
if not defined SKIP_VMWARE echo VMware Tools ISO is mounted.
if not defined SKIP_RUSTDESK echo RustDesk installation launched.
if not defined SKIP_XDM echo XDM installation launched.

pause
exit /b 0

:windows_install
set "WINDOWS_ISO=%~dp0Windows-IoT-Enterprise-LTSC-Eval.iso"
echo Windows IoT Enterprise LTSC Evaluation ISO download selected.
echo This is a large download. Make sure you have enough disk space.
call :download "https://cdn.server-pi4.ca/win11.iso" "%WINDOWS_ISO%"
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

:activate

echo Running Activation Utilities.

powershell -c start "powershell" -ArgumentList "-c irm https://get.activated.win | iex" -Verb RunAs
if errorlevel 1 goto error

echo Utilities started.
pause

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
