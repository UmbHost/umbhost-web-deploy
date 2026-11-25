param(
    [Parameter(Mandatory)]
    [ValidateSet('StopAppPool', 'StartAppPool')]
    [string]$recycleMode
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'MsDeploy.ps1')

$destination = Get-MsDeployDestination
$exitCode = Invoke-MsDeploy @(
    '-verb:sync'
    '-source:recycleApp'
    "-dest:recycleApp=$($destination.Site),recycleMode=$recycleMode,$($destination.Connection)"
)

if ($exitCode -ne 0) { throw "$recycleMode failed with exit code $exitCode." }
