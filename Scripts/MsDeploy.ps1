# Shared by the other scripts. Runs Web Deploy without going through cmd.exe, which would expand %NAME% in a value, and
# without printing the command, which holds the password.

# msdeploy reads the quotes itself and has no way to escape one, so a value cannot contain either kind.
function Format-MsDeployValue([string]$name, [string]$value) {
    if ([string]::IsNullOrWhiteSpace($value)) { throw "$name is required." }
    if ($value -match '["''\r\n]') { throw "$name cannot contain a quote or a line break." }
    return '"' + $value + '"'
}

function Get-MsDeployDestination {
    $site = Format-MsDeployValue 'website-name' $env:WEB_DEPLOY_SITE
    $computer = Format-MsDeployValue 'server-computer-name' ($env:WEB_DEPLOY_COMPUTER + '/MsDeploy.axd?site=' + $env:WEB_DEPLOY_SITE)
    $user = Format-MsDeployValue 'server-username' $env:WEB_DEPLOY_USERNAME
    $password = Format-MsDeployValue 'server-password' $env:WEB_DEPLOY_PASSWORD

    # Hides it in the log even when it did not come from a secret.
    Write-Host "::add-mask::$env:WEB_DEPLOY_PASSWORD"

    return [pscustomobject]@{
        Site       = $site
        Connection = "computerName=$computer,userName=$user,password=$password,authType=`"Basic`""
    }
}

# Returns msdeploy's exit code. Its output goes straight to the log.
function Invoke-MsDeploy([string[]]$arguments) {
    $msdeploy = 'C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy.exe'
    if (-not (Test-Path -LiteralPath $msdeploy)) { throw 'Web Deploy is not installed on this runner. Use a Windows runner.' }

    $start = [Diagnostics.ProcessStartInfo]::new($msdeploy, ($arguments -join ' '))
    $start.UseShellExecute = $false
    $process = [Diagnostics.Process]::Start($start)
    $process.WaitForExit()
    return $process.ExitCode
}
