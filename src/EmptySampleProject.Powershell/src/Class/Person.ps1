Class Person {
    [string] $FirstName
    [string] $LastName
    [string] $Sex
 
    Person ([string] $FirstName, [string] $Lastname, [Sex] $Sex) {
        $this.FirstName = $FirstName
        $this.LastName = $LastName
        $this.Sex = $Sex
    }

    [string] GetFullName() {
        return "$($this.FirstName) $($this.LastName)"
    }
}