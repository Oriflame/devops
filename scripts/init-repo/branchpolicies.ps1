

function Invoke-InitRepoSectionInitBranchPolicies
{
    [CmdLetBinding()]
    param
    (
        [ref]
        [Parameter(Mandatory=$true)]
        $success,

        [int]
        [Parameter(Mandatory=$true)]
        $ciBuildId,

        [Parameter(Mandatory=$true)]
        $branchPoliciesForDevelop,

        [Parameter(Mandatory=$true)]
        $branchPoliciesForMaster
    )
    Write-Output '********* init branch policies *********'

    #see also https://www.visualstudiogeeks.com/azure/devops/azure-devops-cli-to-view-branch-policies
    Write-Output 'getting repository...'
    $repo = az repos list --org $azureDevOpsCollection --project $DevOpsProject --query "[?name=='$RepositoryName']" | ConvertFrom-Json;
    $idOfRepo = $repo.id
    #$existingPolicies = az repos policy list --org $azureDevOpsCollection --project $DevOpsProject --query "[?settings.scope[0].repositoryId=='$idOfRepo']"

    Write-Output 'getting existing repository policies...'
    $existingPolicies = az repos policy list --org $azureDevOpsCollection --project $DevOpsProject --query "[?settings.scope[0].repositoryId=='$($repo.id)' && settings.scope[0].refName=='refs/heads/develop']" | ConvertFrom-Json
    Write-Output 'cleaning up the policies...'
    $existingPolicies | select -ExpandProperty id |% { az repos policy delete --id $_ --org $azureDevOpsCollection --project $DevOpsProject --yes }


    Write-Output 'creating standard repository policies...'

    #load policy template
    $policies = Get-Content -Path C:\Users\JVilimek\Source\Repos\devops\scripts\branch-policies-develop.json | ConvertFrom-Json
    $tmpPolicyFile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "tmp-policy.config");
    foreach($policy in $policies)
    {
        Write-Output "Preparing template policy $($policy.type.displayName)..."
        if ($policy.settings.buildDefinitionId -eq -1)
        {
            #buildDefinitionId is defined in settings and set to default value => replace it with valid definition id
            $policy.settings.buildDefinitionId = $ciBuildId
        }
        if ($policy.settings.scope[0].repositoryId -eq "00000000-0000-0000-0000-000000000000")
        {
            #repositoryId is defined in settings and set to default value => replace it with valid definition id
            $policy.settings.scope[0].repositoryId = $idOfRepo
        }
        if (Test-Path -Path $tmpPolicyFile) {Remove-Item -Path $tmpPolicyFile -Force}
        $policy | ConvertTo-Json -Depth 10 | Set-Content -Path $tmpPolicyFile -Encoding Ascii;
        Write-Output "Applying policy..."
        az repos policy create --org $azureDevOpsCollection --project $DevOpsProject --config $tmpPolicyFile | Out-Null;
        if ($LASTEXITCODE -ne 0) {return;}
    }
    #cleanup
    if (Test-Path -Path $tmpPolicyFile) {Remove-Item -Path $tmpPolicyFile -Force}
    $success.Value = $true;
}