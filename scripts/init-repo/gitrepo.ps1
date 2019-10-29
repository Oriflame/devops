<#
.DESCRIPTION
Initialize git repo. See Docs/init-repo.md

.PARAMETER success
Should reference the global success variable: If the step succeed, it will be set to true.

#>
function Invoke-InitRepoSectionGitRepo
{
    [CmdLetBinding()]
    param
    (
        [ref]
        [Parameter(Mandatory=$true)]
        $success
    )
    Write-Output '********* init GIT repository *********'

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
    $success.Value = $true;
}