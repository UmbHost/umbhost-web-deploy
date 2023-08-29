param
 (
   [string]$source,
   [string]$recycleApp,
   [string]$computerName,
   [string]$username,
   [string]$password,
   [string]$paramFile,
   [string]$fileName
 )

 $msdeploy = "C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy.exe";

 $computerNameArgument = $computerName + '/MsDeploy.axd?site=' + $recycleApp
 
 $directory = Split-Path -Path (Get-Location) -Parent
 $baseName = (Get-Item $directory).BaseName
 $contentPath = Join-Path(Join-Path $directory $baseName) $source

 $remoteArguments = "computerName=`"${computerNameArgument}`",userName=`"${username}`",password=`"${password}`",authType=`"Basic`","

 [string[]] $arguments = 
 "-verb:sync",
 "-source:package=${contentPath}\${fileName}",
 "-dest:auto,$($remoteArguments)includeAcls=`"False`"",
 "-allowUntrusted",
 "-enableRule:AppOffline",
 "-setParam:'IIS Web Application Name'=`"${recycleApp}`"",
 "-enableRule:DoNotDeleteRule"

 if ($paramFile){
    $arguments += "-setParamFile:${contentPath}\${paramFile}"
 }
 
  $fullCommand = """$msdeploy"" $arguments"
 Write-Host $fullCommand
 
 $result = cmd.exe /c "$fullCommand"
 
 Write-Host $result