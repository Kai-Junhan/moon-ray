# test.ps1 - Run a quick test render and save to test_output.ppm
# Usage: powershell -File test.ps1

$env:Path = "$env:USERPROFILE\.moon\bin;$env:Path"
$output = "test_output.ppm"

Write-Host "Building moon-ray..."
moon check --quiet 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!"
    exit 1
}

Write-Host "Rendering test scene (200x112, 50 samples)..."
moon run cmd/main > $output

if ($LASTEXITCODE -eq 0) {
    $size = (Get-Item $output).Length
    Write-Host "Done! Output: $output ($size bytes)"
    Write-Host "Open with any image viewer that supports PPM (e.g. IrfanView, GIMP)"
    Write-Host "Or convert: ffmpeg -i $output test_output.png"
    Write-Host "Run 'powershell -File clean.ps1' to delete test files"
} else {
    Write-Host "Render failed!"
}
