# moon-ray GUI Launcher
# Starts the Python GUI server for visual scene rendering
#
# Usage: powershell -File gui.ps1 [-Port 8088]

param(
  [int]$Port = 8088
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$guiDir = Join-Path $scriptDir "gui"
$serverScript = Join-Path $guiDir "server.py"

Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "  moon-ray GUI Launcher" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""
Write-Host "Starting GUI server on port $Port..." -ForegroundColor Yellow
Write-Host "Open http://localhost:$Port in your browser" -ForegroundColor Green
Write-Host ""

python $serverScript 2>&1
