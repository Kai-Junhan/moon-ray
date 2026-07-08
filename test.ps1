# moon-ray Test Script
# Runs all tests, checks, and builds the project
#
# Usage: powershell -File test.ps1
#        powershell -File test.ps1 -Scene geometric -Width 400 -Height 225 -Samples 50

param(
  [string]$Scene = "three_spheres",
  [int]$Width = 320,
  [int]$Height = 180,
  [int]$Samples = 50
)

$ErrorActionPreference = "Continue"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "  moon-ray Test Suite" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

# Step 1: Update dependencies
Write-Host "[1/5] Updating dependencies..." -ForegroundColor Yellow
moon update 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Host "  Warning: moon update had issues, continuing..." -ForegroundColor DarkYellow
}

# Step 2: Syntax check
Write-Host "[2/5] Checking syntax (moon check)..." -ForegroundColor Yellow
moon check 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Host "  FAILED: moon check found errors" -ForegroundColor Red
  exit 1
}
Write-Host "  PASSED" -ForegroundColor Green

# Step 3: Run unit tests
Write-Host "[3/5] Running unit tests (moon test)..." -ForegroundColor Yellow
moon test 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Host "  FAILED: moon test failed" -ForegroundColor Red
  exit 1
}
Write-Host "  PASSED" -ForegroundColor Green

# Step 4: Build project
Write-Host "[4/5] Building project (moon build)..." -ForegroundColor Yellow
moon build 2>&1
if ($LASTEXITCODE -ne 0) {
  Write-Host "  FAILED: moon build failed" -ForegroundColor Red
  exit 1
}
Write-Host "  PASSED" -ForegroundColor Green

# Step 5: Render test
Write-Host "[5/5] Render test (${Scene}, ${Width}x${Height}, ${Samples}spp)..." -ForegroundColor Yellow
$outputFile = "test_output_${Scene}.ppm"
moon run cmd/main 2>&1 | Select-Object -SkipLast 10 > $outputFile

$firstLine = Get-Content $outputFile -First 1 -ErrorAction SilentlyContinue
if ($firstLine -eq "P3") {
  $fileSize = (Get-Item $outputFile).Length
  Write-Host "  PASSED - PPM file generated ($fileSize bytes)" -ForegroundColor Green
  Write-Host "  Output: $outputFile" -ForegroundColor White
} else {
  Write-Host "  FAILED: PPM header not found" -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "  All tests passed!" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan
