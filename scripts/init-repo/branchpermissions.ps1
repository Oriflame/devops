<#
.DESCRIPTION
Initialize branch permissions. See Docs/init-repo.md

.PARAMETER success
Should reference the global success variable: If the step succeed, it will be set to true.

.PARAMETER tfExe
Path to tf.exe. Should be passed from prerequisities step.

#>
function Invoke-InitRepoSectionBranchPermissions
{
    [CmdLetBinding()]
    param
    (
        [ref]
        [Parameter(Mandatory=$true)]
        $success,

        [string]
        $tfExe
    )
    Write-Output '********* init GIT branch permissions *********'

    
    $message  = "Re-creating permissions for repository $RepositoryName";
    $question = "We need to remove all existing permissions for repository $RepositoryName and create new, standardized. Is this OK?";
    if (!(PromptUserYN -Message $message -Question $question))
    {
        return;
    }

    # see https://docs.microsoft.com/en-us/azure/devops/repos/git/require-branch-folders?view=azure-devops&tabs=browser
    Write-Output 'Cleaning previous explicit permissions ...'
    &$tfExe git permission /remove:* /group:[$DevOpsProject]\Contributors /collection:$azureDevOpsCollection /teamproject:$DevOpsProject /repository:$RepositoryName | Out-Null
    if ($LASTEXITCODE -ne 0) {return;}

    &$tfExe git permission /remove:* /group:"[$DevOpsProject]\Project Administrators" /collection:$azureDevOpsCollection /teamproject:$DevOpsProject /repository:$RepositoryName | Out-Null
    if ($LASTEXITCODE -ne 0) {return;}

    Write-Output 'Setting new permissions ...'
    &$tfExe git permission /deny:CreateBranch /group:[$DevOpsProject]\Contributors /collection:$azureDevOpsCollection /teamproject:$DevOpsProject /repository:$RepositoryName | Out-Null
    if ($LASTEXITCODE -ne 0) {return;}

    &$tfExe git permission /allow:CreateBranch /group:[$DevOpsProject]\Contributors /collection:$azureDevOpsCollection /teamproject:$DevOpsProject /repository:$RepositoryName /branch:feature | Out-Null
    if ($LASTEXITCODE -ne 0) {return;}

    &$tfExe git permission /allow:CreateBranch /group:[$DevOpsProject]\Contributors /collection:$azureDevOpsCollection /teamproject:$DevOpsProject /repository:$RepositoryName /branch:user | Out-Null
    if ($LASTEXITCODE -ne 0) {return;}

    &$tfExe git permission /allow:CreateBranch /group:"[$DevOpsProject]\Project Administrators" /collection:$azureDevOpsCollection /teamproject:$DevOpsProject /repository:$RepositoryName /branch:user | Out-Null
    if ($LASTEXITCODE -ne 0) {return;}

    Write-Output 'Permissions set:'
    &$tfExe git permission /collection:$azureDevOpsCollection /teamproject:$DevOpsProject /repository:$RepositoryName
    if ($LASTEXITCODE -ne 0) {return;}

    $success.Value = $true;
}