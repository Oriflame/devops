####################################################
# common functions                                 #
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
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
        if ((Get-Command -Name choco -ErrorAction SilentlyContinue) -eq $null)
        {
            Write-Warning 'Unable to find [choco] command. Try restarting the powershell console and run again the whole script.'
            return;
        }
    }
}

function Test-FailureOrReset
{
    [cmdletbinding()]
    param
    (
        [ref]
        $success
    )
    if (!$success.Value)
    {
        Write-Warning 'Script failed. See previous output. Fix arguments/permissions/... and restart the script.'
        return $true;
    }
    #reset to false again
    $success.Value = $false;
    return $false;
}