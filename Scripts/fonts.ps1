
$FONTS = 0x14
Expand-Archive "C:\Users\User\Downloads\CascadiaCode-2009.22.zip" $env:TEMP\
$objShell = New-Object -ComObject Shell.Application
$objFolder = $objShell.Namespace($FONTS)
$Fontdir = Get-ChildItem $env:Temp\* -Include '*.TTF' -Recurse
foreach ($File in $Fontdir) {

    $try = $true
    $installedFonts = @(Get-ChildItem c:\windows\fonts | Where-Object { $_.PSIsContainer -eq $false } | Select-Object basename)
    $name = $File.baseName

    foreach ($font in $installedFonts) {
        $font = $font -replace "_", ""
        $name = $name -replace "_", ""
        if ($font -match $name) {
            $try = $false
        }
    }
    if ($try) {
        $objFolder.CopyHere($File.fullname)
    }

}

$objShell = New-Object -ComObject Shell.Application
$objFolder = $objShell.Namespace($FONTS)

# This will list all installed windows fonts
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
$installedFonts = (New-Object System.Drawing.Text.InstalledFontCollection).Families

$ttfFiles = Get-ChildItem $env:Temp\ttf\* -Include '*.TTF'
$fontCollection = new-object System.Drawing.Text.PrivateFontCollection
$ttfFiles | ForEach-Object {
    $fontCollection.AddFontFile($_.fullname)
    $fontCollection.Families[-1].Name
    if ($installedFonts -contains $fontCollection.Families[-1].Name) { $objFolder.CopyHere($_.FullName, 0x14) }
}