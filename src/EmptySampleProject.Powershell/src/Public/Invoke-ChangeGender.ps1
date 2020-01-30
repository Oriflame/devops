function Invoke-ChangeGender {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [Person] $Person
    )

    switch ($Person.Sex) {
        ([Sex]::Male) { Edit-Gender -Person $Person -NewGender ([Sex]::Female) }
        ([Sex]::Female) { Edit-Gender -Person $Person -NewGender ([Sex]::Male) }
    }
}