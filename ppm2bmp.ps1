# ppm2bmp.ps1 - Fast PPM P3 to BMP converter using .NET streams
param($ppmFile = "test_output.ppm", $bmpFile = "test_output.bmp")

$reader = [System.IO.StreamReader]::new($ppmFile)
$magic = $reader.ReadLine()
if ($magic -ne "P3") { $reader.Close(); Write-Host "Not P3 format"; exit 1 }

# Skip comments
do { $line = $reader.ReadLine() } while ($line.StartsWith("#"))
$dims = $line -split '\s+' | Where-Object { $_ -ne '' }
$width = [int]$dims[0]; $height = [int]$dims[1]
$maxval = [int]$reader.ReadLine()
Write-Host "PPM: ${width}x${height}"

# Read all pixel values as integers
$values = [System.Collections.Generic.List[int]]::new($width * $height * 3)
while (($line = $reader.ReadLine()) -ne $null) {
    foreach ($token in ($line -split '\s+' | Where-Object { $_ -ne '' })) {
        $values.Add([int]$token)
    }
}
$reader.Close()
Write-Host "Pixels read: $($values.Count)"

# Write BMP binary
$rowSize = ($width * 3 + 3) -band -4
$pixelDataSize = $rowSize * $height
$fileSize = 54 + $pixelDataSize
$fs = [System.IO.FileStream]::new($bmpFile, [System.IO.FileMode]::Create)
$bw = [System.IO.BinaryWriter]::new($fs)

# BMP File Header (14 bytes)
$bw.Write([byte]0x42); $bw.Write([byte]0x4D)
$bw.Write([int]$fileSize); $bw.Write([int]0); $bw.Write([int]54)

# DIB Header (40 bytes)
$bw.Write([int]40); $bw.Write([int]$width); $bw.Write([int]$height)
$bw.Write([int16]1); $bw.Write([int16]24); $bw.Write([int]0)
$bw.Write([int]$pixelDataSize); $bw.Write([int]2835); $bw.Write([int]2835)
$bw.Write([int]0); $bw.Write([int]0)

# Pixels (bottom-up, BGR)
for ($y = $height - 1; $y -ge 0; $y--) {
    for ($x = 0; $x -lt $width; $x++) {
        $i = ($y * $width + $x) * 3
        $bw.Write([byte]$values[$i + 2])
        $bw.Write([byte]$values[$i + 1])
        $bw.Write([byte]$values[$i])
    }
    for ($p = $rowSize - $width * 3; $p -gt 0; $p--) { $bw.Write([byte]0) }
}

$bw.Close(); $fs.Close()
Write-Host "BMP: $bmpFile — double-click to open"
