# init-repo.ps1
Repository initialization.

Input parameters:
* **AzureDevOpsCollection**: Url of Azure DevOps organization, e.g. 'https://dev.azure.com/oriflame/' (optional)
* **DevOpsProject**: Name of the project in Azure DevOps, like the part of the url http://dev.azure.com/oriflame/{DevOpsProject}, e.g. 'MyProject'
* **RepositoryName**: name of the project in Azure DevOps, e.g. http://dev.azure.com/oriflame/something/_git/{THIS}
* **dependenciesRepositoryUrl**: Url of dependend scripts and resources, e.g. url from GitHub 'https://raw.githubusercontent.com/Oriflame/devops/master/scripts/init-repo/' (which is default value), or your local repo path (optional)

It does following:

* check & install prerequisities: 
  * in case GIT command is missing it installs [chocolatey](https://chocolatey.org/) and [git](https://chocolatey.org/packages/git.install)
  * in case TF tool is missing (C:\Program Files (x86)\Microsoft Visual Studio\2019\TeamExplorer\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\tf.exe is searched) it installst [Team Explorer](https://chocolatey.org/packages/visualstudio2017teamexplorer)
* it checks, if we are in GIT repo and if not, it clones the repo locally from provided project and repository name
* it switches to **master** branch
* if **develop** branch is not yet created it is
* it updates proper rights in the repo


## how to test it locally

Before any commit it is recommended to test the script locally. Navigate to an empty directory and run

 ```
 # tested on windows 10
 $repoSrc = "$env:USERPROFILE/source/repos/devops/scripts"
 . "$repoSrc/init-repo.ps1" -DevOpsProject XXX -RepositoryName XXX -dependenciesRepositoryUrl "$repoSrc/init-repo/"
 ```

 Please note: expected location of GIT repositories is in your profile. You need also to replace XXX with valid project name and repository name etc.

**How to call it:**

Start powershell.exe with elevated user rights in any writeable directory and copy/paste following:

```
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Oriflame/devops/master/scripts/init-repo.ps1'))
```
