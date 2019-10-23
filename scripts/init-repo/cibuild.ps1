
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

    Write-Output "Checking if there is [$RepositoryName-CI] build..."
    $existingCIBuildPipeline = az pipelines build definition list --org $azureDevOpsCollection --project $DevOpsProject --name "$RepositoryName-CI" | ConvertFrom-Json
    if ($existingCIBuildPipeline.Count -le 0)
    {
        Write-Output 'create standard CI build...'
        #no CI build definition exists = create!
        Write-Warning "TBD: need to create CI BUILD!"
        return
    }
    $buildid = $existingCIBuildPipeline[0].id;
    Write-Output "$RepositoryName-CI build id: $buildid";
    $ciBuildId.Value = $buildid;
    $success.Value = $true;
}