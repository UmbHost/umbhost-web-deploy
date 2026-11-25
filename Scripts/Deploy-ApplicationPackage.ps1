$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'MsDeploy.ps1')
. (Join-Path $PSScriptRoot 'DeploymentFiles.ps1')

$files = Get-DeploymentFiles
$destination = Get-MsDeployDestination

$arguments = @(
    '-verb:sync'
    "-source:package=$(Format-MsDeployValue 'source-fileName' $files.Package)"
    "-dest:auto,$($destination.Connection),includeAcls=`"False`""
    '-enableRule:AppOffline'
    "-setParam:'IIS Web Application Name'=$($destination.Site)"
    '-enableRule:DoNotDeleteRule'
)
if ($files.Parameters) { $arguments += "-setParamFile:$(Format-MsDeployValue 'source-paramFile' $files.Parameters)" }

# Safe to repeat: only what still differs is copied.
$attempts = 3
for ($attempt = 1; $attempt -le $attempts; $attempt++) {
    $exitCode = Invoke-MsDeploy $arguments
    if ($exitCode -eq 0) { return }
    Write-Host "Attempt $attempt of $attempts failed with exit code $exitCode."
    if ($attempt -lt $attempts) { Start-Sleep -Seconds 10 }
}

throw 'Deployment incomplete, so the site has been stopped to avoid running a mix of old and new files. Re-run the deployment.'
