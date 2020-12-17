function Get-DownloadFolderPath {
    # Define known folder GUIDs
    $KnownFolders = @{
        'Downloads'             = '374DE290-123F-4565-9164-39C4925E467B';
        'PublicDownloads'       = '3D644C9B-1FB8-4f30-9B45-F670235F79C0';
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
Get-DownloadFolderPath
