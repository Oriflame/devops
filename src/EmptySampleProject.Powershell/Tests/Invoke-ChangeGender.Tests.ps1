$moduleRoot = (Get-Item $MyInvocation.MyCommand.Path).Directory.Parent.FullName

Describe "Testing public functions of EmptySampleProject.Powershell module" {
    Import-Module "$moduleRoot/EmptySampleProject.Powershell.psd1"

    Context "Testing Invoke-ChangeGender" {
        $testCases = @(
            @{ Person = [Person]::new("Jan",   "Novak",  ([Sex]::Unknown)); Expected = [Sex]::Unknown }
            @{ Person = [Person]::new("Jiri",  "Bohaty", ([Sex]::Male));    Expected = [Sex]::Female  }
            @{ Person = [Person]::new("Pavla", "Bila",   ([Sex]::Female));  Expected = [Sex]::Male    }
        )

        It "Given valid -Person '<Person>', it returns '<Expected>' gender after Invoke-ChangeGender" -TestCases $testCases {
            param($Person, $Expected)

            Invoke-ChangeGender -Person $Person
            $Person.Sex | Should Be $Expected
        }
    }
}