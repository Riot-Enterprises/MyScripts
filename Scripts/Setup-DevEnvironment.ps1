
<#PSScriptInfo

.VERSION 1.0

.GUID 6de5c050-465f-4874-a54a-e57fce86e731

.AUTHOR MarkEvans <mark@madspaniels.co.uk>

.COMPANYNAME Riot Enterprises Ltd

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Script to setup Win10 for powershell dev 

#> 

[cmdletbinding()]
param()

# --------------------------- User Defined Variables --------------------------
#                         Edit these variables as needed

#
# <- VARIABLES HERE ->
#

###############################################################################
#                       DO NOT MODIFY BEYOND THIS POINT!                      #
###############################################################################

# Track running time.
$StopWatch = [ordered]@{
    Total = [System.Diagnostics.Stopwatch]::StartNew()
}

# ------------------------------ Static Variables -----------------------------

#
# <- VARIABLES HERE ->
#

# ------------------------------ Helper Functions -----------------------------

# Track step time.
$StopWatch.LoadFunctions = [System.Diagnostics.Stopwatch]::StartNew()

#
# <- FUNCTIONS HERE ->
#

# Stop step timer.
$StopWatch.LoadFunctions.Stop()

# ------------------------------- Script Logic --------------------------------

# Track step time.
$StopWatch.ScriptLogic = [System.Diagnostics.Stopwatch]::StartNew()

#
$StopWatch.InstallPWSH = [System.Diagnostics.Stopwatch]::StartNew()
#$ScriptBlock = [Scriptblock]::Create("$(Invoke-RestMethod https://aka.ms/install-powershell.ps1)")
Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -Quiet"
$StopWatch.InstallPWSH.Stop()
$StopWatch.InstallVSCode = [System.Diagnostics.Stopwatch]::StartNew()
Invoke-Expression "& { $(Invoke-RestMethod https://raw.githubusercontent.com/PowerShell/vscode-powershell/master/scripts/Install-VSCode.ps1) } -EnableContextMenus -AdditionalExtensions 'vivaxy.vscode-conventional-commits','eamodio.gitlens','donjayamanne.githistory','dotjoshjohnson.xml'"
$StopWatch.InstallVSCode.Stop()
$StopWatch.InstallGit = [System.Diagnostics.Stopwatch]::StartNew()
Invoke-Expression "& { $(Invoke-RestMethod https://raw.githubusercontent.com/tomlarse/Install-Git/master/Install-Git/Install-Git.ps1) }"
$StopWatch.InstallGit.Stop()
#

# Stop step timer.
$StopWatch.ScriptLogic.Stop()

# Compute and display elapsed run time (Verbose stream.)
$StopWatch.Total.Stop()
$StepTimes = @(
    $StopWatch.Keys | Where-Object { $_ -ne 'Total' } | ForEach-Object { [pscustomobject]@{ Step = $_ ; ElapsedTime = $StopWatch.Item($_).Elapsed.ToString()} }
)
$StepTimes | Out-String -Stream | Where-Object { $_ -ne "" } | Write-Verbose
Write-Verbose ""
Write-Verbose "TOTAL $($Stopwatch.Total.Elapsed.ToString())"