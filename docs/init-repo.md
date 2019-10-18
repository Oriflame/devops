# init-repo.ps1
Repository initialization.

Input parameters:
* **$AzureDevOpsCollection**: url to Azure DevOps, e.g. https://dev.azure.com/oriflame/ (optional)
* **$DevOpsProject**: name of the project in Azure DevOps, e.g. http://dev.azure.com/oriflame/{THIS}
* **$RepositoryName**: name of the project in Azure DevOps, e.g. http://dev.azure.com/oriflame/something/_git/{THIS}

It does following:

* check & install prerequisities: 
  * in case GIT command is missing it installs [chocolatey](https://chocolatey.org/) and [git](https://chocolatey.org/packages/git.install)
  * in case TF tool is missing (C:\Program Files (x86)\Microsoft Visual Studio\2019\TeamExplorer\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\tf.exe is searched) it installst [Team Explorer](https://chocolatey.org/packages/visualstudio2017teamexplorer)
* it checks, if we are in GIT repo and if not, it clones the repo locally from provided project and repository name
* it switches to **master** branch
* if **develop** branch is not yet created it is
* it updates proper rights in the repo

**How to call it:**

Start powershell.exe with elevated user rights in any writeable directory and copy/paste following:

```
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Oriflame/devops/master/scripts/init-repo.ps1'))
```
