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
    $RepositoryName,

    [string]
    $dependenciesRepositoryUrl = "https://raw.githubusercontent.com/Oriflame/devops/feature/repository-init-script/scripts/init-script/"
)
$ErrorActionPreference='Stop';
$Error.Clear();
$LASTEXITCODE = 0;

Set-ExecutionPolicy Bypass -Scope Process -Force;

function GetResource ([string]$nameOfScript)
{
    return (New-Object System.Net.WebClient).DownloadString("${dependenciesRepositoryUrl}$nameOfScript");
}

#import functions from remote/local repo
iex (GetResource -nameOfScript branchpermissions.ps1)
iex (GetResource -nameOfScript branchpolicies.ps1)
iex (GetResource -nameOfScript cibuild.ps1)
iex (GetResource -nameOfScript functions.ps1)
iex (GetResource -nameOfScript gitrepo.ps1)
iex (GetResource -nameOfScript prerequisities.ps1)

#import&check resources from remote/local repo
$branchPoliciesForDevelop = GetResource -nameOfScript resources/branch-policies-develop.json | ConvertFrom-Json
$branchPoliciesForMaster = GetResource -nameOfScript resources/branch-policies-master.json | ConvertFrom-Json

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

[bool]$success = $false;

Invoke-InitRepoSectionPrerequisities -success ([ref]$success);
if (ErrorOccurred -success ([ref]$success)){return;}

Invoke-InitRepoSectionGitRepo -success ([ref]$success);
if (ErrorOccurred -success ([ref]$success)){return;}

Invoke-InitRepoSectionBranchPermissions -success ([ref]$success);
if (ErrorOccurred -success ([ref]$success)){return;}

Write-Output '********* AZ CLI LOGIN *********'
az login | Out-Null; #TODO: too chatty output..its not easy to reduce :(

[int] $ciBuildId
Invoke-InitRepoSectionInitCIBuild -success ([ref]$success) -ciBuildId ([ref]$ciBuildId);
if (ErrorOccurred -success ([ref]$success)){return;}

Invoke-InitRepoSectionInitBranchPolicies -success ([ref]$success) -ciBuildId $ciBuildId -branchPoliciesForDevelop $branchPoliciesForDevelop -branchPoliciesForMaster $branchPoliciesForMaster;
if (ErrorOccurred -success ([ref]$success)){return;}

Write-Output ''
Write-Output 'EVERYTHING OK'