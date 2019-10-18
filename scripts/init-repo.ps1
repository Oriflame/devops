#######################################
# this should init any GIT repository #
#######################################
[cmdletbinding()]
param
(
    [string]
    $AzureDevOpsCollection = "https://dev.azure.com/oriflame/",

    [Parameter(Mandatory=$true)]
    [string]
    $DevOpsProject,

    [Parameter(Mandatory=$true)]
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

Write-Output '************ INIT REPO SCRIPT ************';
Write-Output 'Author: jan.vilimek@oriflame.com'
Write-Output 'Downloaded from: https://github.com/Oriflame/devops'
Write-Output '******************************************';
Write-Output '';

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



####################################################
# Init starts here                                 #
####################################################

Write-Output '********* init repository *********'

#check status
git status | Out-Null;
if ($LASTEXITCODE -eq 0)
{
    Write-Output 'We are currently in GIT repository, checking if remote repo is as expected'
    $remoteRepositories= git remote -v;
    if (($remoteRepositories |% {$_ -like "*$AzureDevOpsCollection$DevOpsProject/_git/$RepositoryName*"}) -notcontains $true)
    {
        Write-Output 'Found remote repositories:'
        Write-Output $remoteRepositories
        Write-Warning "the above remote repositories are not as expected ($AzureDevOpsCollection$DevOpsProject/_git/$RepositoryName). Please run script in new empty directory.";
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
    git clone "$AzureDevOpsCollection$DevOpsProject/_git/$RepositoryName";
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
tf git permission /deny:CreateBranch /group:[$DevOpsProject]\Contributors /collection:$azureDevOpsCollection /teamproject:$DevOpsProject /repository:$RepositoryName
tf git permission /allow:CreateBranch /group:[$DevOpsProject]\Contributors /collection:$azureDevOpsCollection /teamproject:$DevOpsProject /repository:$RepositoryName /branch:feature
tf git permission /allow:CreateBranch /group:[$DevOpsProject]\Contributors /collection:$azureDevOpsCollection /teamproject:$DevOpsProject /repository:$RepositoryName /branch:user
tf git permission /allow:CreateBranch /group:"[$DevOpsProject]\Project Administrators" /collection:$azureDevOpsCollection /teamproject:$DevOpsProject /repository:$RepositoryName /branch:user

