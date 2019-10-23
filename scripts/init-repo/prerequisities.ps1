####################################################
# prerequisities - check                           #
####################################################

function Invoke-InitRepoSectionPrerequisities
{
    [CmdLetBinding()]
    param
    (
        [ref]
        [Parameter(Mandatory=$true)]
        $success
    )
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

    #check for AZ CLI
    if ((Get-Command -Name AZ -ErrorAction SilentlyContinue) -eq $null)
    {
        $message  = "Unable to find AZ CLI";
        $LASTEXITCODE = 0;
        $question = 'We need to install AZ CLI. Is this OK?';
        if (!(PromptUserYN -Message $message -Question $question))
        {
            return;
        }   
        Write-Output '... installing Az CLI';
        $tmpFile = [System.Io.Path]::Combine([System.Io.Path]::GetTempPath(), 'AzureCLI.msi');
        if (!(Test-Path -Path $tmpFile))
        {
            Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile $tmpFile;
        }
        Start-Process msiexec.exe -Wait -ArgumentList "/I `"$tmpFile`" /quiet";
        if ((Get-Command -Name AZ -ErrorAction SilentlyContinue) -eq $null)
        {
            Write-Warning 'Unable to find [AZ] command. Try restarting the powershell console and run again the whole script.'
            return;
        }
    }

    az extension add --name azure-devops;
    $success.Value = $true;
}
