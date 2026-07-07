# test.ps1 - Run a quick test render, convert to BMP, and clean up PPM
# Usage: powershell -File test.ps1

$env:Path = "$env:USERPROFILE\.moon\bin;$env:Path"

Write-Host "Building moon-ray..."
moon check 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "Build failed!"; exit 1 }

Write-Host "Rendering (400x225, 100 samples)..."
moon run cmd/main > test_output.ppm 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "Render failed!"; exit 1 }

Write-Host "Converting to BMP..."
powershell -File ppm2bmp.ps1

Write-Host "Done! Open test_output.bmp to view."
Write-Host "Run 'powershell -File clean.ps1' to delete test files."
