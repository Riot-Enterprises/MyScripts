if ($PSVersionTable.PSVersion.Major -le 5){
    # Download install-powershell.ps1
    Invoke-RestMethod https://aka.ms/install-powershell.ps1 -OutFile .\install-powershell.ps1
    $FullName = (GCI .\install-powershell.ps1).FullName
    Start-Process -Verb RunAs -Wait powershell -ArgumentList '-ExecutionPolicy Bypass',"-File ""$FullName"" -UseMSI -quiet" 
    $ScriptBlock = {iex (new-object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/RamblingCookieMonster/PSDepend/master/Examples/Install-PSDepend.ps1')}
    Start-Process pwsh -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass","-NoExit","-Command $ScriptBlock"
} else { 
    Write-Host -ForegroundColor Red  "Running in core"
    Install-Script "Install-Git","Install-Hub","Install-VSCode" -Force
    Install-Git.ps1
    #Start-Process -Verb RunAs -Wait pwsh -ArgumentList "-ExecutionPolicy Bypass","-NoExit","-File ~\Documents\Powershell\Scripts\Install-Hub.ps1"
    Install-VSCode -AdditionalExtensions 'vivaxy.vscode-conventional-commits','eamodio.gitlens','donjayamanne.githistory','dotjoshjohnson.xml' -EnableContextMenus
    Install-Module Posh-Git -Scope CurrentUser
    Add-PoshGitToProfile -AllHosts
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue
}
