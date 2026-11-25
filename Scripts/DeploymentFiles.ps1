# Finds the files to deploy, and fails if one is missing.
function Get-DeploymentFiles {
    $folder = Join-Path (Get-Location) $env:WEB_DEPLOY_SOURCE

    $package = Join-Path $folder $env:WEB_DEPLOY_PACKAGE
    if (-not (Test-Path -LiteralPath $package -PathType Leaf)) { throw "The package was not found: $package" }

    # The default is a pair of quotes, meaning none.
    $name = "$env:WEB_DEPLOY_PARAMETERS".Trim('"', ' ')
    $parameters = $null
    if ($name) {
        $parameters = Join-Path $folder $name
        if (-not (Test-Path -LiteralPath $parameters -PathType Leaf)) { throw "The parameters file was not found: $parameters" }
    }

    return [pscustomobject]@{ Package = $package; Parameters = $parameters }
}
