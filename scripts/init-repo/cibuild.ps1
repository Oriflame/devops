
function Invoke-InitRepoSectionInitCIBuild
{
    [CmdLetBinding()]
    param
    (
        [ref]
        [Parameter(Mandatory=$true)]
        $success,

        [ref]
        $ciBuildId
    )
    Write-Output '********* init CI BUILD *********'

    Write-Output 'create standard CI build...'
    $existingCIBuildPipeline = az pipelines build definition list --org $azureDevOpsCollection --project $DevOpsProject --name "$RepositoryName-CI" | ConvertFrom-Json
    if ($existingCIBuildPipeline.Count -le 0)
    {
        #no CI build definition exists = create!

    }
    $ciBuildId.Value = $existingCIBuildPipeline[0].id;
    $success.Value = $true;
}