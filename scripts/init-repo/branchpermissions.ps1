
function Invoke-InitRepoSectionBranchPermissions
{
    [CmdLetBinding()]
    param
    (
        [ref]
        [Parameter(Mandatory=$true)]
        $success
    )
    Write-Output '********* init GIT branch permissions *********'

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