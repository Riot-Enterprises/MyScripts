function Get-DownloadFolderPath {
    # Define known folder GUIDs
    $KnownFolders = @{
        'Downloads'       = '374DE290-123F-4565-9164-39C4925E467B';
        'PublicDownloads' = '3D644C9B-1FB8-4f30-9B45-F670235F79C0';
    }
    $GetSignature = @'
    [DllImport("shell32.dll", CharSet = CharSet.Unicode)]public extern static int SHGetKnownFolderPath(
    ref Guid folderId,
    uint flags,
    IntPtr token,
    out IntPtr pszProfilePath);
'@
    $GetType = Add-Type -MemberDefinition $GetSignature -Name 'GetKnownFolders' -Namespace 'SHGetKnownFolderPath' -Using "System.Text" -PassThru
    $ptr = [intptr]::Zero
    [void]$GetType::SHGetKnownFolderPath([ref]$KnownFolders['Downloads'], 0, 0, [ref]$ptr)
    [System.Runtime.InteropServices.Marshal]::PtrToStringUni($ptr)
    [System.Runtime.InteropServices.Marshal]::FreeCoTaskMem($ptr)
}

$Repositories = @(
    @{Repo = 'git-for-windows/git'; Regex = 'Git-\d*\.\d*\.\d*.\d*-64-bit\.exe' , '/VERYSILENT /NORESTART' },
    @{Repo = 'microsoft/terminal'; Regex = 'Microsoft.WindowsTerminal_\d*\.\d*\.\d*.\d*_.*\.msixbundle$' },
    #Add-AppxPackage Bundle
    @{Repo = 'PowerShell/PowerShell'; Regex = '^PowerShell-\d*\.\d*\.\d*-win-x64\.msi$' }#,
    #$ArgumentList=@("/i", $packagePath, "/quiet","ENABLE_PSREMOTING=1","ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1")
    #Start-Process msiexec -ArgumentList $ArgumentList -Wait -PassThru
    #@{Repo = 'Microsoft/vscode'; Regex = '.*' }
    , @{Repo = 'microsoft/cascadia-code'; Regex = 'CascadiaCode-\d*\.\d*\.zip' }
)

<#
        $MSIArguments = @()
        if($AddExplorerContextMenu) {
            $MSIArguments += "ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1"
        }
        if($EnablePSRemoting) {
            $MSIArguments += "ENABLE_PSREMOTING=1"
        }
******************************************************8
            if ($UseMSI -and $Quiet) {
                Write-Verbose "Performing quiet install"
                $ArgumentList=@("/i", $packagePath, "/quiet","ENABLE_PSREMOTING=1","ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1")
                if($MSIArguments) {
                    $ArgumentList+=$MSIArguments
                }
                $process = Start-Process msiexec -ArgumentList $ArgumentList -Wait -PassThru
#>
function DownloadFile ($URI) {
    $fileName = ([uri]$URI).Segments | Select-Object -Last 1
    $destination = Join-Path (Get-DownloadFolderPath) $fileName
    if (-not (Test-Path $destination)) {
        Invoke-WebRequest -Uri $URI -OutFile $destination -UseBasicParsing
    }
    #$fileName = $Response.BaseResponse.ResponseUri.Segments | Select-Object -Last 1
    #$destination = Join-Path (Get-DownloadFolderPath) $fileName
    #Move-Item $temp $destination -Force
    return (Get-ChildItem $destination)
}
(Invoke-WebRequest -Method HEAD -Uri https://vscode-update.azurewebsites.net/latest/win32-x64/stable).Header

<#
        # On Windows
        'exe' {
            $exeArgs = '/verysilent /tasks=addtopath'
            if ($EnableContextMenus) {
                $exeArgs = '/verysilent /tasks=addcontextmenufiles,addcontextmenufolders,addtopath'
            }

            if (-not $PSCmdlet.ShouldProcess("$installerPath $exeArgs", 'Start-Process -Wait')) {
                break
            }

            Start-Process -Wait $installerPath -ArgumentList $exeArgs
            break
        }
#>

<#
$FONTS = 0x14
$Path=".\fonts-to-be-installed"
$objShell = New-Object -ComObject Shell.Application
$objFolder = $objShell.Namespace($FONTS)
$Fontdir = dir $Path
foreach($File in $Fontdir) {
if(!($file.name -match "pfb$"))
{
$try = $true
$installedFonts = @(Get-ChildItem c:\windows\fonts | Where-Object {$_.PSIsContainer -eq $false} | Select-Object basename)
$name = $File.baseName

foreach($font in $installedFonts)
{
$font = $font -replace "_", ""
$name = $name -replace "_", ""
if($font -match $name)
{
$try = $false
}
}
if($try)
{
$objFolder.CopyHere($File.fullname)
}
}
}
#>
function DownloadFileRedirect ($URI) {
    ((Invoke-WebRequest -Method HEAD -Uri $URI).Headers.'Content-Disposition')[0] -match '".*"'
    $fileName = $Matches[0].Replace('"', '')
    $destination = Join-Path (Get-DownloadFolderPath) $fileName
    if (-not (Test-Path $destination)) {
        Invoke-WebRequest -Uri $URI -OutFile $destination -UseBasicParsing
    }
    #Invoke-WebRequest -Uri $URI -OutFile $destination -UseBasicParsing
    #$fileName = $Response.BaseResponse.ResponseUri.Segments | Select-Object -Last 1
    #$destination = Join-Path (Get-DownloadFolderPath) $fileName
    #Move-Item $temp $destination -Force
}
foreach ($Repository in $Repositories) {
    Write-Warning -Message $Repository.Repo
    try {
        $Response = Invoke-WebRequest -Uri "https://api.github.com/repos/$($Repository.Repo)/releases/latest"
        $RestResponse = $Response.Content | ConvertFrom-Json
    }
    catch {
        $Failure = $_.Exception.Response
    }
    If ($Failure) { Write-Output "Error" }
    If ($Response.StatusCode -eq 200) {
        $asset = $RestResponse.assets | Where-Object { $_.Name -match $Repository.Regex }
        Write-Output $asset.name
        DownloadFile($asset.browser_download_url)
    }
}

DownloadFileRedirect('https://vscode-update.azurewebsites.net/latest/win32-x64/stable')


#$Response.InputFields | Where-Object {
#    $_.name -like "* Value*"
#} | Select-Object Name, Value

<#
    foreach ($asset in (Invoke-RestMethod "https://api.github.com/repos/$($Repository.Repo)/releases/latest").assets)
    {
        sleep -Seconds 5
        if ($asset.name -match $Repository.Regex){
            $asset.name
        } elseif ($Repository.Repo.EndsWith('vscode')) {
            $asset.name
        }
        <#
        if ($asset.name.EndsWith('.zip') -or $asset.name.EndsWith('.exe') -or $asset.name.EndsWith('.msi') -or $asset.name.EndsWith('.msixbundle')){
            $asset.name
        } else {
            #$asset.name
        }
        #>
<#
        if ($asset.name -match 'Git-\d*\.\d*\.\d*.\d*-64-bit\.exe')
        {
            $dlurl = $asset.browser_download_url
            $newver = $asset.name
        } #>
#}

#} #>

