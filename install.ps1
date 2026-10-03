# One-line installer for presenters on Windows, from the latest GitHub release.
#
#   irm https://raw.githubusercontent.com/tschinz/presenters/main/install.ps1 | iex
#
# Downloads the portable zip (x64), extracts it to %LOCALAPPDATA%\Programs\presenters,
# and creates a Start Menu shortcut.
$ErrorActionPreference = 'Stop'

$repo = 'tschinz/presenters'
$url  = "https://github.com/$repo/releases/latest/download/presenters-windows-x64.zip"
$dest = Join-Path $env:LOCALAPPDATA 'Programs\presenters'
$zip  = Join-Path $env:TEMP 'presenters.zip'

Write-Host "Downloading presenters for Windows (x64)…"
Invoke-WebRequest -Uri $url -OutFile $zip

Write-Host "Installing to $dest…"
if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
Expand-Archive -Path $zip -DestinationPath $dest -Force
Remove-Item $zip

# The zip contains a top-level 'presenters' folder (presenters.exe + pdfium.dll).
$exe = Join-Path $dest 'presenters\presenters.exe'

$startMenu = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
$shortcut  = (New-Object -ComObject WScript.Shell).CreateShortcut((Join-Path $startMenu 'Presenters.lnk'))
$shortcut.TargetPath = $exe
$shortcut.Save()

Write-Host "✓ Installed. Launch 'Presenters' from the Start Menu, or run:"
Write-Host "    $exe"
