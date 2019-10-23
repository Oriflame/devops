#######################################
# this should init any GIT repository #
#######################################
[cmdletbinding()]
param
(
    [string]
    $AzureDevOpsCollection = "https://dev.azure.com/oriflame/",

    [string]
    $DevOpsProject,

    [string]
    $RepositoryName
)
$ErrorActionPreference='Stop';

####################################################
# functions                                        #
####################################################

function PromptUserYN
{
    [cmdletbinding()]
    param
    (
        [string]
        $Message,

        [string]
        $Question
    )
    if ($script:PromptUserAlwaysYes)
    {
        return $true;
    }

    $choices  = '&Yes', '&No', 'Yes to &all';
    $decision = $Host.UI.PromptForChoice($Message, $Question, $choices, 1);
    if ($decision -eq 1)
    {
        return $false;
    }
    if ($decision -eq 2)
    {
        $script:PromptUserAlwaysYes = $true;
    }
    return $true;
}

function Install-Choco
{
    if ((Get-Command -Name choco -ErrorAction SilentlyContinue) -eq $null)
    {
        Set-ExecutionPolicy Bypass -Scope Process -Force;
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
        if ((Get-Command -Name choco -ErrorAction SilentlyContinue) -eq $null)
        {
            Write-Warning 'Unable to find [choco] command. Try restarting the powershell console and run again the whole script.'
            return;
        }
    }
}

#function Uninstall-AllModules {
#  param(
#    [Parameter(Mandatory=$true)]
#    [string]$TargetModule,

#    [Parameter(Mandatory=$true)]
#    [string]$Version,

#    [switch]$Force,

#    [switch]$WhatIf
#  )
#  #MS code, see https://docs.microsoft.com/cs-cz/powershell/azure/uninstall-az-ps?view=azps-2.8.0#uninstall-the-azurerm-module
  
#  $AllModules = @()
  
#  'Creating list of dependencies...'
#  $target = Find-Module $TargetModule -RequiredVersion $version
#  $target.Dependencies | ForEach-Object {
#    if ($_.PSObject.Properties.Name -contains 'requiredVersion') {
#      $AllModules += New-Object -TypeName psobject -Property @{name=$_.name; version=$_.requiredVersion}
#    }
#    else { # Assume minimum version
#      # Minimum version actually reports the installed dependency
#      # which is used, not the actual "minimum dependency." Check to
#      # see if the requested version was installed as a dependency earlier.
#      $candidate = Get-InstalledModule $_.name -RequiredVersion $version -ErrorAction Ignore
#      if ($candidate) {
#        $AllModules += New-Object -TypeName psobject -Property @{name=$_.name; version=$version}
#      }
#      else {
#        $availableModules = Get-InstalledModule $_.name -AllVersions
#        Write-Warning ("Could not find uninstall candidate for {0}:{1} - module may require manual uninstall. Available versions are: {2}" -f $_.name,$version,($availableModules.Version -join ', '))
#      }
#    }
#  }
#  $AllModules += New-Object -TypeName psobject -Property @{name=$TargetModule; version=$Version}

#  foreach ($module in $AllModules) {
#    Write-Output ('Uninstalling {0} version {1}...' -f $module.name,$module.version)
#    try {
#      Uninstall-Module -Name $module.name -RequiredVersion $module.version -Force:$Force -ErrorAction Stop -WhatIf:$WhatIf
#    } catch {
#      Write-Output ("`t" + $_.Exception.Message)
#    }
#  }
#}

####################################################
# INTRO                                            #
####################################################

Write-Output '************ INIT REPO SCRIPT ************';
Write-Output 'Author: jan.vilimek@oriflame.com'
Write-Output 'Downloaded from: https://github.com/Oriflame/devops'
Write-Output '******************************************';
Write-Output '';

if ([string]::IsNullOrEmpty($DevOpsProject))
{
    $DevOpsProject = Read-Host -Prompt "Please specify Azure DevOps Project, e.g. http://dev.azure.com/oriflame/{THIS}"
}

if ([string]::IsNullOrEmpty($RepositoryName))
{
    $RepositoryName = Read-Host -Prompt "Please specify GIT Repository Name, e.g. http://dev.azure.com/oriflame/something/_git/{THIS}"
}

####################################################
# prerequisities - check                           #
####################################################


Write-Output 'Prerequisities check...';
# check for WMF 5.0 +
if ((Get-Command -Name Get-PackageProvider -ErrorAction SilentlyContinue) -eq $null)
{
    Write-Warning "Unable to find Get-PackageProvider... do you have WMF 5.0 installed?"
    return;
}
Write-Output '... WMF 5.0 found.';

#check for GIT
if ((Get-Command -Name git -ErrorAction SilentlyContinue) -eq $null)
{
    $message  = "Unable to find GIT";
    $LASTEXITCODE = 0;
    $question = 'We need to install GIT (via Chocolatey). Is this OK?';
    if (!(PromptUserYN -Message $message -Question $question))
    {
        return;
    }
    Install-Choco;
    choco install git.install --force --force-dependencies -y;
    if ((Get-Command -Name git -ErrorAction SilentlyContinue) -eq $null)
    {
        Write-Warning 'Unable to find [git] command. Try restarting the powershell console and run again the whole script.'
        return;
    }
}

#check for TF
$tfExe = "C:\Program Files (x86)\Microsoft Visual Studio\2019\TeamExplorer\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\tf.exe"
if (!(Test-Path -Path $tfExe))
{
    $message  = "Unable to find TF";
    $LASTEXITCODE = 0;
    $question = 'We need to install Team Explorer = TF.EXE (via Chocolatey). Is this OK?';
    if (!(PromptUserYN -Message $message -Question $question))
    {
        return;
    }
    Install-Choco;
    choco install visualstudio2019teamexplorer --force --force-dependencies --package-parameters "--passive --locale en-US" -y;
    if (!(Test-Path -Path $tfExe))
    {
        Write-Warning 'Unable to find [tf] command. Try restarting the powershell console and run again the whole script.'
        return;
    }
}

#check for AZ CLI
if ((Get-Command -Name AZ -ErrorAction SilentlyContinue) -eq $null)
{
    $message  = "Unable to find AZ CLI";
    $LASTEXITCODE = 0;
    $question = 'We need to install AZ CLI. Is this OK?';
    if (!(PromptUserYN -Message $message -Question $question))
    {
        return;
    }   
    Write-Output '... installing Az CLI';
    $tmpFile = [System.Io.Path]::Combine([System.Io.Path]::GetTempPath(), 'AzureCLI.msi');
    if (!(Test-Path -Path $tmpFile))
    {
        Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile $tmpFile;
    }
    Start-Process msiexec.exe -Wait -ArgumentList "/I `"$tmpFile`" /quiet";
    if ((Get-Command -Name AZ -ErrorAction SilentlyContinue) -eq $null)
    {
        Write-Warning 'Unable to find [AZ] command. Try restarting the powershell console and run again the whole script.'
        return;
    }
}

az extension add --name azure-devops;



####################################################
# Init starts here                                 #
####################################################

Write-Output '********* init repository *********'

#check status
git status | Out-Null;
$AzureDevOpsGirRepoUrl = "$AzureDevOpsCollection$DevOpsProject/_git/$RepositoryName";
if ($LASTEXITCODE -eq 0)
{
    Write-Output 'We are currently in GIT repository, checking if remote repo is as expected'
    $remoteRepositories= git remote -v;
    $expectedUrl = $AzureDevOpsGirRepoUrl.Replace('https://', '')
    if (($remoteRepositories |% {$_ -like "*$expectedUrl*"}) -notcontains $true)
    {
        Write-Output 'Found remote repositories:'
        Write-Output $remoteRepositories
        Write-Warning "the above remote repositories are not as expected ($expectedUrl). Please run script in new empty directory.";
        return;
    }

}else
{
    $message  = "Repository not initialized (code: $LASTEXITCODE)";
    $LASTEXITCODE = 0;
    $question = 'We need to download repository and init it in the current folder. Is this OK?';
    if (!(PromptUserYN -Message $message -Question $question))
    {
        return;
    }
    git clone $AzureDevOpsGirRepoUrl;
    if ($LASTEXITCODE -ne 0)
    {
        Write-Warning 'Error during git clone. Please fix the error and restart the script.';
        return;
    }
}
#switch to master branch
git checkout master;
if ($LASTEXITCODE -ne 0)
{
    Write-Warning 'Error during git checkout. Please fix the error and restart the script.';
    return;
}

$currentBranches=git branch;
if (!(($currentBranches |% {$_.Trim().Replace('*','')}) -contains 'develop'))
{
    #we do not have develop branch created, let's create it
    git branch develop
    if ($LASTEXITCODE -ne 0)
    {
        Write-Warning 'Error during git branch. Please fix the error and restart the script.';
        return;
    }
    git push origin develop
    if ($LASTEXITCODE -ne 0)
    {
        Write-Warning 'Error during git push. Please fix the error and restart the script.';
        return;
    }
}


# see https://docs.microsoft.com/en-us/azure/devops/repos/git/require-branch-folders?view=azure-devops&tabs=browser
Write-Output 'Cleaning previous explicit permissions ...'
&$tfExe git permission /remove:* /group:[$DevOpsProject]\Contributors /collection:$azureDevOpsCollection /teamproject:$DevOpsProject /repository:$RepositoryName | Out-Null
&$tfExe git permission /remove:* /group:"[$DevOpsProject]\Project Administrators" /collection:$azureDevOpsCollection /teamproject:$DevOpsProject /repository:$RepositoryName | Out-Null

Write-Output 'Setting new permissions ...'
&$tfExe git permission /deny:CreateBranch /group:[$DevOpsProject]\Contributors /collection:$azureDevOpsCollection /teamproject:$DevOpsProject /repository:$RepositoryName | Out-Null
&$tfExe git permission /allow:CreateBranch /group:[$DevOpsProject]\Contributors /collection:$azureDevOpsCollection /teamproject:$DevOpsProject /repository:$RepositoryName /branch:feature | Out-Null
&$tfExe git permission /allow:CreateBranch /group:[$DevOpsProject]\Contributors /collection:$azureDevOpsCollection /teamproject:$DevOpsProject /repository:$RepositoryName /branch:user | Out-Null
&$tfExe git permission /allow:CreateBranch /group:"[$DevOpsProject]\Project Administrators" /collection:$azureDevOpsCollection /teamproject:$DevOpsProject /repository:$RepositoryName /branch:user | Out-Null

Write-Output 'Permissions set:'
&$tfExe git permission /collection:$azureDevOpsCollection /teamproject:$DevOpsProject /repository:$RepositoryName

az login | Out-Null
$repos = az repos list --org $azureDevOpsCollection --project $DevOpsProject | ConvertFrom-Json;
$idOfRepo = $repos | where -Property name -eq $RepositoryName | select -ExpandProperty id
$existingPolicies = az repos policy list --org $azureDevOpsCollection --project $DevOpsProject --repository-id $idOfRepo | ConvertFrom-Json;

Write-Output ''
Write-Output 'EVERYTHING OK'