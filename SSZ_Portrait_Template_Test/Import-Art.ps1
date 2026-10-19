# Downloads the verified modern Blizzard UI artwork from Gethe's extracted
# World of Warcraft texture archive and converts PNG -> uncompressed 32-bit TGA
# for use in WoW 1.12. This downloads only art; no remote code is executed.
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Drawing

$base = 'https://raw.githubusercontent.com/Gethe/wow-ui-textures/live/FrameGeneral/'
$out = Join-Path $PSScriptRoot 'Textures'
New-Item -ItemType Directory -Path $out -Force | Out-Null
$files = @(
  'UI-Frame',
  '!UI-Frame'
)

function Convert-PngToTga([string]$source, [string]$destination) {
  $original = New-Object System.Drawing.Bitmap($source)
  try {
    $rect = New-Object System.Drawing.Rectangle(0, 0, $original.Width, $original.Height)
    $argb = $original.Clone($rect, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
      $fs = [System.IO.File]::Open($destination, [System.IO.FileMode]::Create)
      try {
        $bw = New-Object System.IO.BinaryWriter($fs)
        try {
          $header = New-Object byte[] 18
          $header[2] = 2  # Uncompressed true-color TGA.
          $header[12] = [byte]($argb.Width -band 255)
          $header[13] = [byte](($argb.Width -shr 8) -band 255)
          $header[14] = [byte]($argb.Height -band 255)
          $header[15] = [byte](($argb.Height -shr 8) -band 255)
          $header[16] = 32 # BGRA pixels, eight alpha bits.
          $header[17] = 40 # Top-left origin and 8-bit alpha channel.
          $bw.Write($header)
          $data = $argb.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
          try {
            $bytesPerRow = $argb.Width * 4
            $line = New-Object byte[] $bytesPerRow
            for ($y = 0; $y -lt $argb.Height; $y++) {
              $ptr = [IntPtr]::Add($data.Scan0, $y * $data.Stride)
              [Runtime.InteropServices.Marshal]::Copy($ptr, $line, 0, $bytesPerRow)
              $bw.Write($line)
            }
          } finally {
            $argb.UnlockBits($data)
          }
        } finally { $bw.Dispose() }
      } finally { $fs.Dispose() }
    } finally { $argb.Dispose() }
  } finally { $original.Dispose() }
}

foreach ($name in $files) {
  $png = Join-Path $out ($name + '.PNG')
  $tga = Join-Path $out ($name + '.tga')
  $url = $base + [Uri]::EscapeDataString($name) + '.PNG' # Case-sensitive extension in Gethe archive.
  if (Test-Path $tga) { Write-Host "Already installed: $tga"; continue }
  Write-Host "Fetching $name from the Blizzard UI artwork mirror..."
  Invoke-WebRequest -Uri $url -OutFile $png -UseBasicParsing
  Convert-PngToTga $png $tga
  Write-Host "Created: $tga"
}
Write-Host ''
Write-Host 'Done. Restart Turtle WoW (or /reload), then /sszframe.'
Write-Host 'This did not change your Compendium.'
