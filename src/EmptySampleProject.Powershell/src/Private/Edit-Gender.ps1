function Edit-Gender {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [Person] $Person,

        [Parameter(Mandatory = $true)]
        [Sex] $NewGender
    )
    
    $Person.Sex = $NewGender
}