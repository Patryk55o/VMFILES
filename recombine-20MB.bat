@echo off
setlocal

if "%~1"=="" (
    echo Usage: %~nx0 part001 part002 [part003 ...]
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& { $parts = @($args); if ($parts.Count -eq 0) { throw 'No part files supplied.' }; foreach ($part in $parts) { if (-not (Test-Path -LiteralPath $part -PathType Leaf)) { throw ('Part file not found: ' + $part) } }; $first = [IO.Path]::GetFullPath($parts[0]); $baseName = [IO.Path]::GetFileName($first) -replace '\.\d{3}\.part$',''; $output = Join-Path (Get-Location).Path ([IO.Path]::GetFileNameWithoutExtension($baseName) + '-recombined' + [IO.Path]::GetExtension($baseName)); $outStream = [IO.File]::Create($output); try { foreach ($part in $parts) { $inStream = [IO.File]::OpenRead($part); try { $inStream.CopyTo($outStream) } finally { $inStream.Dispose() } } } finally { $outStream.Dispose() }; Write-Host ('Created: ' + $output) }" %*

if errorlevel 1 (
    echo Recombining failed.
    exit /b 1
)

endlocal
