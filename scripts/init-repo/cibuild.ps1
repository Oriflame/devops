<#
.DESCRIPTION
Initialize CI build. See Docs/init-repo.md

.PARAMETER success
Should reference the global success variable: If the step succeed, it will be set to true.

.PARAMETER ciBuildId
Returns the id of the CI build.

#>
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
        $message  = "Unable to find $RepositoryName-CI build";
        $LASTEXITCODE = 0;
        $question = 'We need to create CI build so we can use it later in branch policies. Is this OK?';
        if (!(PromptUserYN -Message $message -Question $question))
        {
            return;
        }
        Write-Output 'creating standard CI build...'
        #no CI build definition exists = create!
        Write-Warning "TBD: need to create CI BUILD!"
        return
    }
    $buildid = $existingCIBuildPipeline[0].id;
    Write-Output "$RepositoryName-CI build id: $buildid";
    $ciBuildId.Value = $buildid;
    $success.Value = $true;
}