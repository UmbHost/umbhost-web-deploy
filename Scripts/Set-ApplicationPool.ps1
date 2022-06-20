
$msdeploy = "C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy.exe";

param
(
  [string]$recycleMode,
  [string]$recycleApp,
  [string]$computerName,
  [string]$username,
  [string]$password
)

$computerNameArgument = $computerName + '/MsDeploy.axd?site=' + $recycleApp

$msdeployArguments = 
    "-verb:sync",
    "-allowUntrusted",
    "-source:recycleApp",
    ("-dest:" + 
        "recycleApp=${recycleApp}," +
        "recycleMode=${recycleMode}," +
        "computerName=${computerNameArgument}," + 
        "username=${username}," +
        "password=${password}," +
        "AuthType='Basic'"
    )

& $msdeploy $msdeployArguments