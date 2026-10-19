# Import Blizzard's Classic Era tiled rock background for WoW 1.12.
# Downloads only a PNG from Gethe/wow-ui-textures and converts it locally.
# This is needed even if Import-Art.ps1 was run: that script imports metal art.
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Drawing
$dir = Join-Path $PSScriptRoot 'Textures'
New-Item -ItemType Directory -Path $dir -Force | Out-Null
$png = Join-Path $dir 'UI-Background-Rock-Classic.PNG'
$tga = Join-Path $dir 'UI-Background-Rock-Classic.tga'
$url = 'https://raw.githubusercontent.com/Gethe/wow-ui-textures/classic/FrameGeneral/UI-Background-Rock.PNG'
if (Test-Path $tga) {
    Write-Host "Already present: $tga"
    exit 0
}
Write-Host 'Downloading Blizzard Classic Era UI-Background-Rock art...'
Invoke-WebRequest -Uri $url -OutFile $png -UseBasicParsing
$img = New-Object System.Drawing.Bitmap($png)
try {
    if ($img.Width -ne 256 -or $img.Height -ne 256) {
        throw "Expected 256x256 Classic Era rock texture, received $($img.Width)x$($img.Height). No file was installed."
    }
    $rect = New-Object System.Drawing.Rectangle(0, 0, $img.Width, $img.Height)
    $argb = $img.Clone($rect, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        $file = [System.IO.File]::Open($tga, [System.IO.FileMode]::Create)
        try {
            $writer = New-Object System.IO.BinaryWriter($file)
            try {
                $header = New-Object byte[] 18
                $header[2] = 2
                $header[12] = [byte]($argb.Width -band 255)
                $header[13] = [byte](($argb.Width -shr 8) -band 255)
                $header[14] = [byte]($argb.Height -band 255)
                $header[15] = [byte](($argb.Height -shr 8) -band 255)
                $header[16] = 32
                $header[17] = 40
                $writer.Write($header)
                $data = $argb.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
                try {
                    $stride = $argb.Width * 4
                    $line = New-Object byte[] $stride
                    for ($y = 0; $y -lt $argb.Height; $y++) {
                        $ptr = [IntPtr]::Add($data.Scan0, $y * $data.Stride)
                        [Runtime.InteropServices.Marshal]::Copy($ptr, $line, 0, $stride)
                        $writer.Write($line)
                    }
                } finally { $argb.UnlockBits($data) }
            } finally { $writer.Dispose() }
        } finally { $file.Dispose() }
    } finally { $argb.Dispose() }
} finally { $img.Dispose() }
Write-Host "Installed Classic Era Blizzard rock texture: $tga"
Write-Host 'Restart the game client if textures do not load after /reload.'
