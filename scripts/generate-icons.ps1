Add-Type -AssemblyName System.Drawing

function Create-CineplexMasterIcon {
    param([int]$size = 1024)

    $bmp = [System.Drawing.Bitmap]::new($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    $g.Clear([System.Drawing.Color]::Transparent)

    # 1. Base Squircle / Rounded Rectangle
    $margin = [int]($size * 0.04)
    $badgeSize = $size - ($margin * 2)
    $radius = [int]($size * 0.22)

    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $rect = [System.Drawing.Rectangle]::new($margin, $margin, $badgeSize, $badgeSize)
    $d = $radius * 2

    $path.AddArc($rect.X, $rect.Y, $d, $d, [float]180, [float]90)
    $path.AddArc($rect.Right - $d, $rect.Y, $d, $d, [float]270, [float]90)
    $path.AddArc($rect.Right - $d, $rect.Bottom - $d, $d, $d, [float]0, [float]90)
    $path.AddArc($rect.X, $rect.Bottom - $d, $d, $d, [float]90, [float]90)
    $path.CloseFigure()

    # Dark Cinema Charcoal Background (#14141B -> #08080B)
    $bgBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        [System.Drawing.PointF]::new(0, 0),
        [System.Drawing.PointF]::new($size, $size),
        [System.Drawing.Color]::FromArgb(255, 20, 20, 28),
        [System.Drawing.Color]::FromArgb(255, 10, 10, 14)
    )
    $g.FillPath($bgBrush, $path)
    $bgBrush.Dispose()

    # Outer Subtle Sheen / Rim
    $borderPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(50, 255, 255, 255), [float]($size * 0.012))
    $g.DrawPath($borderPen, $path)
    $borderPen.Dispose()

    # Center Coordinates - perfectly centered
    $cx = [float]($size * 0.5)
    $cy = [float]($size * 0.5)

    # Ambient Cinema Red Glow
    $glowPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $glowRect = [System.Drawing.RectangleF]::new(($cx - $size * 0.38), ($cy - $size * 0.38), ($size * 0.76), ($size * 0.76))
    $glowPath.AddEllipse($glowRect)
    $pbr = [System.Drawing.Drawing2D.PathGradientBrush]::new($glowPath)
    $pbr.CenterColor = [System.Drawing.Color]::FromArgb(110, 229, 9, 20) # Rich Cinema Red Glow
    $pbr.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
    $g.FillPath($pbr, $glowPath)
    $pbr.Dispose()
    $glowPath.Dispose()

    # 2. Main Cinema "C" Arc (Bold & Centered)
    $cRadius = [float]($size * 0.25)
    $cThickness = [float]($size * 0.125)
    $cRect = [System.Drawing.RectangleF]::new(($cx - $cRadius), ($cy - $cRadius), ($cRadius * 2), ($cRadius * 2))

    # Drop Shadow for "C"
    $cShadowPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(180, 0, 0, 0), $cThickness)
    $cShadowPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $cShadowPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $cShadowRect = [System.Drawing.RectangleF]::new(($cx - $cRadius), ($cy - $cRadius + $size * 0.022), ($cRadius * 2), ($cRadius * 2))
    $g.DrawArc($cShadowPen, $cShadowRect, [float]42, [float]276)
    $cShadowPen.Dispose()

    # Rich Cinema Red Gradient Pen for "C" (#FF334B -> #B00510)
    $cGradBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        [System.Drawing.PointF]::new(($cx - $cRadius), ($cy - $cRadius)),
        [System.Drawing.PointF]::new(($cx + $cRadius), ($cy + $cRadius)),
        [System.Drawing.Color]::FromArgb(255, 255, 45, 60),  # Bright Cinema Red
        [System.Drawing.Color]::FromArgb(255, 175, 5, 15)    # Deep Crimson
    )
    $cPen = [System.Drawing.Pen]::new($cGradBrush, $cThickness)
    $cPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $cPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawArc($cPen, $cRect, [float]42, [float]276)
    $cPen.Dispose()
    $cGradBrush.Dispose()

    # Subtle inner highlight arc for 3D glass / metallic reflection
    $highlightPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(90, 255, 255, 255), [float]($size * 0.016))
    $highlightPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $highlightPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $hRadius = $cRadius + ($cThickness * 0.28)
    $hRect = [System.Drawing.RectangleF]::new(($cx - $hRadius), ($cy - $hRadius), ($hRadius * 2), ($hRadius * 2))
    $g.DrawArc($highlightPen, $hRect, [float]135, [float]90)
    $highlightPen.Dispose()

    # 3. Cinema Film Perforations (5 clean sprocket dots along the curve)
    $perfAngles = @(110, 145, 180, 215, 250)
    $perfRadius = [float]($size * 0.02)
    $perfBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 14, 14, 20))
    $perfPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(100, 255, 255, 255), [float]($size * 0.0035))

    foreach ($ang in $perfAngles) {
        $rad = $ang * [Math]::PI / 180.0
        $px = $cx + ($cRadius * [Math]::Cos($rad))
        $py = $cy + ($cRadius * [Math]::Sin($rad))
        $pRect = [System.Drawing.RectangleF]::new(($px - $perfRadius), ($py - $perfRadius), ($perfRadius * 2), ($perfRadius * 2))
        $g.FillEllipse($perfBrush, $pRect)
        $g.DrawEllipse($perfPen, $pRect)
    }
    $perfBrush.Dispose()
    $perfPen.Dispose()

    # 4. Cinema Play Button Triangle (▶) nestled right at the center opening
    # Popcorn Gold / Amber (#FFC800 -> #E58E26)
    $playX = $cx + [float]($size * 0.04)
    $playY = $cy
    $playW = [float]($size * 0.14)
    $playH = [float]($size * 0.15)

    $playPts = @(
        [System.Drawing.PointF]::new(($playX - $playW * 0.45), ($playY - $playH * 0.5)),
        [System.Drawing.PointF]::new(($playX + $playW * 0.65), $playY),
        [System.Drawing.PointF]::new(($playX - $playW * 0.45), ($playY + $playH * 0.5))
    )

    # Play Shadow
    $pshPts = @(
        [System.Drawing.PointF]::new(($playX - $playW * 0.45 + 4), ($playY - $playH * 0.5 + 7)),
        [System.Drawing.PointF]::new(($playX + $playW * 0.65 + 4), ($playY + 7)),
        [System.Drawing.PointF]::new(($playX - $playW * 0.45 + 4), ($playY + $playH * 0.5 + 7))
    )
    $pshBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(150, 0, 0, 0))
    $g.FillPolygon($pshBrush, $pshPts)
    $pshBrush.Dispose()

    # Play Gold Linear Gradient (#FFE043 -> #E58E26)
    $goldBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        [System.Drawing.PointF]::new(($playX - $playW * 0.45), ($playY - $playH * 0.5)),
        [System.Drawing.PointF]::new(($playX + $playW * 0.65), ($playY + $playH * 0.5)),
        [System.Drawing.Color]::FromArgb(255, 255, 222, 60),  # Bright Gold
        [System.Drawing.Color]::FromArgb(255, 229, 142, 38)   # Popcorn Amber (#E58E26)
    )
    $g.FillPolygon($goldBrush, $playPts)
    $goldBrush.Dispose()

    # Play Border Highlight
    $goldPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(220, 255, 255, 255), [float]($size * 0.005))
    $g.DrawPolygon($goldPen, $playPts)
    $goldPen.Dispose()

    # Cleanup
    $path.Dispose()
    $g.Dispose()

    return $bmp
}

function Resize-Bitmap {
    param(
        [System.Drawing.Bitmap]$source,
        [int]$width,
        [int]$height
    )
    $target = [System.Drawing.Bitmap]::new($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($target)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawImage($source, 0, 0, $width, $height)
    $g.Dispose()
    return $target
}

# 1. Generate Master Icon (1024x1024)
Write-Host "Rendering 1024x1024 master icon (symbol only, text removed)..."
$master = Create-CineplexMasterIcon -size 1024

$assetsDir = "D:\UTE\LTDDNC\mobile\assets\images"
if (!(Test-Path $assetsDir)) { New-Item -ItemType Directory -Path $assetsDir -Force }
$master.Save("$assetsDir\app_icon.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "Master icon saved to $assetsDir\app_icon.png"

# 2. Android Mipmap Densities
$androidResDir = "D:\UTE\LTDDNC\mobile\android\app\src\main\res"
$androidDensities = @{
    "mipmap-mdpi"    = 48
    "mipmap-hdpi"    = 72
    "mipmap-xhdpi"   = 96
    "mipmap-xxhdpi"  = 144
    "mipmap-xxxhdpi" = 192
}

foreach ($folder in $androidDensities.Keys) {
    $dim = $androidDensities[$folder]
    $destPath = "$androidResDir\$folder\ic_launcher.png"
    $resized = Resize-Bitmap -source $master -width $dim -height $dim
    $resized.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $resized.Dispose()
    Write-Host "Generated Android icon ($dim x $dim): $destPath"
}

# 3. iOS AppIcon set if present
$iosIconDir = "D:\UTE\LTDDNC\mobile\ios\Runner\Assets.xcassets\AppIcon.appiconset"
if (Test-Path $iosIconDir) {
    $iosFiles = Get-ChildItem -Path $iosIconDir -Filter "*.png"
    foreach ($file in $iosFiles) {
        try {
            $img = [System.Drawing.Image]::FromFile($file.FullName)
            $w = $img.Width
            $h = $img.Height
            $img.Dispose()

            $resized = Resize-Bitmap -source $master -width $w -height $h
            $resized.Save($file.FullName, [System.Drawing.Imaging.ImageFormat]::Png)
            $resized.Dispose()
            Write-Host "Updated iOS icon ($w x $h): $($file.Name)"
        } catch {
            Write-Warning "Could not update iOS icon $($file.Name): $_"
        }
    }
}

$master.Dispose()
Write-Host "All launcher icons updated successfully without text!"
