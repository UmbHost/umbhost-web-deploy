
 $msdeploy = "C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy.exe";

 $source = $args[0]
 $recycleApp = $args[1]
 $computerName = $args[2]
 $username = $args[3]
 $password = $args[4]
 $paramFile = $args[5]
 $fileName = $args[6]
 
 $computerNameArgument = $computerName + '/MsDeploy.axd?site=' + $recycleApp
 
 $directory = Split-Path -Path (Get-Location) -Parent
 $baseName = (Get-Item $directory).BaseName
 $contentPath = Join-Path(Join-Path $directory $baseName) $source

 $remoteArguments = "computerName='${computerNameArgument}',userName='${username}',password='${password}',authType='Basic',"

 [string[]] $arguments = 
 "-verb:sync",
 "-source:package=${contentPath}\${fileName}",
 "-dest:auto,$($remoteArguments)includeAcls='False'",
 "-allowUntrusted",
 "-enableRule:AppOffline",
 "-setParam:'IIS Web Application Name'='${recycleApp}'",
 "-setParamFile:${contentPath}\${paramFile}",
 "-enableRule:DoNotDeleteRule"
 
  $fullCommand = """$msdeploy"" $arguments"
 Write-Host $fullCommand
 
 $result = cmd.exe /c "$fullCommand"
 
 Write-Host $result