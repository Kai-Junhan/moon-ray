# clean.ps1 - Remove test output files

Remove-Item -Force test_output.ppm -ErrorAction SilentlyContinue
Remove-Item -Force test_output.bmp -ErrorAction SilentlyContinue
Remove-Item -Force test_output.png -ErrorAction SilentlyContinue
Write-Host "Test output files removed."
