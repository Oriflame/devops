<#
.DESCRIPTION
Initialize zure DevOps GIT repository with branches, policies, rights, build pipelines..see https://github.com/Oriflame/devops/blob/master/docs/init-repo.md

.PARAMETER AzureDevOpsCollection
Url of Azure DevOps organisation, e.g. https://dev.azure.com/organisationName/

.PARAMETER DevOpsProject
Name of the DevOps project, e.g. http://dev.azure.com/oriflame/{THIS}

.PARAMETER RepositoryName
Name of the GIT Repository, e.g. http://dev.azure.com/oriflame/something/_git/{THIS}

.PARAMETER dependenciesRepositoryUrl
Url of dependend scripts and resources, e.g. url from GitHub

#>
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
    $DependenciesRepositoryUrl = "https://raw.githubusercontent.com/Oriflame/devops/master/scripts/init-repo/"
)
$ErrorActionPreference='Stop';
$Error.Clear();
$LASTEXITCODE = 0;

Set-ExecutionPolicy Bypass -Scope Process -Force;

function GetResource ([string]$nameOfScript)
{
    $url = "${DependenciesRepositoryUrl}$nameOfScript";
    Write-Verbose "Downloading resource $url";
    return (New-Object System.Net.WebClient).DownloadString($url);
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

Invoke-InitRepoSectionInitBranchPolicies -success ([ref]$success) -ciBuildId $ciBuildId -branchName develop -branchPolicies $branchPoliciesForDevelop;
if (ErrorOccurred -success ([ref]$success)){return;}

Invoke-InitRepoSectionInitBranchPolicies -success ([ref]$success) -ciBuildId $ciBuildId -branchName master -branchPolicies $branchPoliciesForMaster;
if (ErrorOccurred -success ([ref]$success)){return;}

Write-Output ''
Write-Output 'EVERYTHING OK'