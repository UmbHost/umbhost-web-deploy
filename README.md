## UmbHost Web Deploy
Automatically deploy your projects to UmbHost.net with Web Deploy using this GitHub action. 

This action utilizes Microsoft’s own `Web Deploy 3.0+` executable, which you can read everything about [here](https://docs.microsoft.com/en-us/aspnet/web-forms/overview/deployment/web-deployment-in-the-enterprise/deploying-web-packages). Further documentation of the rules and parameters can also be seen [here](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-r2-and-2008/dd568992(v=ws.10)).

---

### Example
Place the following in your action `/.github/workflows/main.yml`
```yml
      - name: Deploy to UmbHost
        uses: UmbHost/umbhost-web-deploy@v1.0.3
          with:
            website-name: ${{ secrets.WEBSITE_NAME }}
            server-computer-name: ${{ secrets.SERVER_COMPUTER_NAME }}
            server-username: ${{ secrets.USERNAME }}
            server-password: ${{ secrets.PASSWORD }}
            source-path: '_build'
            source-fileName: Umbraco.Web.zip
```

---

### Requirements
- Access to the SolidCP account for the hosting package, to download the WebDeploy publishing profile.

---

### Setup
1. Locate the repository you want to automate UmbHost web deployment in.
2. Select the `Actions` tab.
3. Select `Set up a workflow yourself`.
4. Copy paste one of the examples into your .yml workflow file and commit the file.
5. All the examples takes advantage of `Secrets`, so make sure you have added the required secrets to your repository. Instructions on this can be found in the [settings](#settings) section.
6. Once you have added your secrets, your new workflow should be running on every push to the branch.

---

### Settings
These settings can be either be added directly to your .yml config file or referenced from your GitHub repository `Secrets`. I strongly recommend storing any private values like `server-username` and `server-password` in `Secrets`, regardless of if the repository is private or not.

To add a secret to your repository go to the `Settings` tab, followed by `Secrets`. Here you can add your secrets and reference to them in your .yml file.

You can find the access credentials for WebDeploy by accessing your `SolidCP account` -> `Web Sites` -> `WEBSITENAME` -> `Web Publishing` -> if you have previously set a password click `Download Publishing Profile for this web site` and open the downloaded file with Notepad, if you have not previously set a password or you cannot see the `Download Publishing Profile for this web site` button, enter a `Password` and `Confirmation password` and then click `Enable`, and then you will be able to click the `Download Publishing Profile for this web site` button

| Setting | Required | Example | Default Value | Description |
|-|-|-|-|-|
| `website-name`          | Yes | `example.com` | | Website name as found in SolidCP |
| `server-computer-name`  | Yes | `https://webdeploy.umbhost.net:8172` or `https://webdeploy.us.umbhost.net:8172` | | Computer name, including the port|
| `server-username`       | Yes | `username`        | | Your UmbHost Web Publishing username |
| `server-password`       | Yes | `password`        | | Your UmbHost Web Publishing password |
| `source-fileName`       | Yes | `Umbraco.Web.zip`        | `Umbraco.Web.zip` | The location of the SetParameters.xml file |
| `solution-name`       | Yes | `ExampleSolution`        |  | The name of the .NET solution containing the Umbraco project to be deployed |
| `source-path`       | No | `_build`        | `_build`  | The source directory for payload |
| `source-paramFile`       | No | `_build`        |  | The location of the SetParameters.xml file |
---

# Common examples
#### Build and publish .NET Framework

```yml
name: Build, publish and deploy project to UmbHost

on:
  push:
    branches: [ main ]
env:
    SolutionName: ${{ secrets.SOLUTION_NAME }}
    BuildPlatform: Any CPU
    BuildConfiguration: Release

jobs:
  build:

    runs-on: windows-latest
    
    steps:
        - name: Checkout
          uses: actions/checkout@v3.0.0
    
        - name: Setup MSBuild
          uses: microsoft/setup-msbuild@v1
          
        - name: Setup NuGet.exe for use with actions
          uses: NuGet/setup-nuget@v1.2.0

        - name: Create Build Directory
          run: mkdir _build

        - name: Restore Packages
          run: nuget restore ${{env.SolutionName}}
      
        - name: Build Solution
          run: | 
            msbuild.exe ${{env.SolutionName}} /nologo /nr:false /p:DeployOnBuild=true /p:DeployDefaultTarget=WebPublish /p:WebPublishMethod=Package /p:PackageAsSingleFile=true /p:DeleteExistingFiles=True /p:SkipInvalidConfigurations=true /p:IncludeSetAclProviderOnDestination=False /p:AutoParameterizationWebConfigConnectionStrings=False /p:platform="${{env.BuildPlatform}}" /p:configuration="${{env.BuildConfiguration}}" /p:PackageLocation="../_build"
            
        - name: Deploy to UmbHost
          uses: UmbHost/umbhost-web-deploy@v1.0.3
          with:
            website-name: ${{ secrets.WEBSITE_NAME }}
            server-computer-name: ${{ secrets.SERVER_COMPUTER_NAME }}
            server-username: ${{ secrets.USERNAME }}
            server-password: ${{ secrets.PASSWORD }}
            source-path: '_build'
            source-fileName: Umbraco.Web.zip

```

#### Build and publish .NET Core / .NET 5.0+

```yml

name: Build, publish and deploy project to UmbHost

on:
  push:
    branches: [ main ]
env:
    SolutionName: ${{ secrets.SOLUTION_NAME }}
    BuildPlatform: Any CPU
    BuildConfiguration: Release

jobs:
  build:

    runs-on: windows-latest
    
    steps:
        - name: Checkout
          uses: actions/checkout@v3.0.0

        - name: Create Build Directory
          run: mkdir _build

        - name: Build Solution
          run: | 
            dotnet build ${{env.SolutionName}} /nologo /nr:false /p:DeployOnBuild=true /p:DeployDefaultTarget=WebPublish /p:WebPublishMethod=Package /p:PackageAsSingleFile=true /p:DeleteExistingFiles=True /p:SkipInvalidConfigurations=true /p:IncludeSetAclProviderOnDestination=False /p:AutoParameterizationWebConfigConnectionStrings=False /p:platform="${{env.BuildPlatform}}" /p:configuration="${{env.BuildConfiguration}}" /p:PackageLocation="../_build"
            
        - name: Deploy to UmbHost
          uses: UmbHost/umbhost-web-deploy@v1.0.3
          with:
            website-name: ${{ secrets.WEBSITE_NAME }}
            server-computer-name: ${{ secrets.SERVER_COMPUTER_NAME }}
            server-username: ${{ secrets.USERNAME }}
            server-password: ${{ secrets.PASSWORD }}
            source-path: '_build'
            source-fileName: Umbraco.Web.zip
```
