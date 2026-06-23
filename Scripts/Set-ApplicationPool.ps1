[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'password', Justification = 'msdeploy requires the password as plaintext in its -dest: argument; it arrives from a GitHub Actions masked secret and is passed straight through.')]
param
(
  [string]$recycleMode,
  [string]$recycleApp,
  [string]$computerName,
  [string]$username,
  [string]$password
)

$msdeploy = "C:\Program Files (x86)\IIS\Microsoft Web Deploy V3\msdeploy.exe";

$computerNameArgument = $computerName + '/MsDeploy.axd?site=' + $recycleApp

[string[]] $msdeployArguments =
    "-verb:sync",
    "-allowUntrusted",
    "-source:recycleApp",
    ("-dest:" +
        "recycleApp=${recycleApp}," +
        "recycleMode=${recycleMode}," +
        "computerName=${computerNameArgument}," +
        "username=`"${username}`"," +
        "password=`"${password}`"," +
        "AuthType=`"Basic`""
    )

$fullCommand = """$msdeploy"" $msdeployArguments"
Write-Output $fullCommand

$result = cmd.exe /c "$fullCommand"

Write-Output $result