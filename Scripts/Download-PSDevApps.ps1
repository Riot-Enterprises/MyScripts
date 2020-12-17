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
    @{Repo = 'git-for-windows/git'; Regex = 'Git-\d*\.\d*\.\d*.\d*-64-bit\.exe' }#,
    #@{Repo ='microsoft/terminal'; Regex = 'Microsoft.WindowsTerminal_\d*\.\d*\.\d*.\d*_.*\.msixbundle$'},
    #@{Repo = 'PowerShell/PowerShell'; Regex = '^PowerShell-\d*\.\d*\.\d*-win-x64\.msi$'},
    #@{Repo = 'Microsoft/vscode'; Regex = '.*'}
)
function DownloadFile ($URI) { 
    $fileName = ([uri]$URI).Segments | Select-Object -Last 1
    $destination = Join-Path (Get-DownloadFolderPath) $fileName
    Invoke-WebRequest -Uri $URI -PassThru -OutFile $destination -UseBasicParsing
    #$fileName = $Response.BaseResponse.ResponseUri.Segments | Select-Object -Last 1
    #$destination = Join-Path (Get-DownloadFolderPath) $fileName
    #Move-Item $temp $destination -Force
    return (Get-ChildItem $destination)
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
    If ($Response.StatusCode -eq 200) {
        $asset = $RestResponse.assets | Where-Object { $_.Name -match $Repository.Regex }
        Write-Host $asset.name
        DownloadFile($asset.browser_download_url)
    }
}
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

