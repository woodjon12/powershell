function Show-Menu {
    param (
        [string]$Title = 'Menu'
    )
    Clear-Host
    Write-Host "=============== $Title ==============="
    Write-Host 
    "Note: All scripts in this menu create a transcript that will be placed in C:\Users\'Logged-On User'\
    "

    Write-Host "1: Import Fuze Phone Numbers"
    Write-Host "2: Import Fuze Fax Numbers"
    Write-Host "3: Import Five9 Phone Numbers"
    Write-Host "Q: Press 'Q' to quit"
}

do
 {
     Show-Menu
     $selection = Read-Host "
     Please make a selection"
     switch ($selection)
     {
     '1' {
        Start-Transcript C:\Users\$UserProfile\FuzePhoneTranscript.txt
        
        Write-Host "Please check '\\fileserver\data\IT Department\AD Script\FuzeExtInstructions.pdf' for specific instructions regarding this process."
        
        $target = Read-Host "Type the source location of the Fuze Extension CSV file"
        
        $CSVData = Import-CSV $target
        $UserProfile = $env:USERNAME
        
        If ((Get-Module).Name -notcontains "ActiveDirectory") {Import-Module ActiveDirectory}
        $Users = Get-ADUser -Filter * -Properties EmailAddress
        Foreach ($Line in $CSVData) {
            $Email = $Line."Email"
            $Username = ($Users | Where-Object {$_.EmailAddress -eq $Email}).SamAccountName
            $Params = @{
                Identity = $Username
                OfficePhone = $Line."DID"
            }
            If ($Username) {Set-ADUser -Replace @Params; Set-ADUser $Username -Replace @{info=$line.Department}; Write-Host "Phone information set for $Username"}
            Else {Write-Warning "No user found with the email $Email"}
        }
            Pause
        }
        '2' {
            Start-Transcript C:\Users\$UserProfile\FuzeFaxTranscript.txt
            
            (Get-Credential)

            Write-Host "Please check '\\fileserver\data\IT Department\AD Script\FuzeFaxReport.pdf' for specific instructions regarding this process."
            
            $target = Read-Host "Type the source location of the Fuze Fax CSV file"
            
            $CSVData = Import-CSV $target
            $UserProfile = $env:USERNAME
            
            If ((Get-Module).Name -notcontains "ActiveDirectory") {Import-Module ActiveDirectory}
            $Users = Get-ADUser -Filter * -Properties EmailAddress
            Foreach ($Line in $CSVData) {
                $Email = $Line."assigned to"
                $Username = ($Users | Where-Object {$_.EmailAddress -eq $Email}).SamAccountName
                $Params = @{
                    Identity = $Username
                    Fax = $line."inbound phone number"
                }
                If ($Username) {Set-ADUser -Replace @Params; Write-Host "Fax information set for $Username"}
                Else {Write-Warning "No user found with the email $Email"}
            }
            Pause
            }
        '3' {
            Start-Transcript C:\Users\$UserProfile\Five9PhoneNumberTranscript.txt
            
            Write-Host "Please check '\\fileserver\data\IT Department\AD Script\Five9Report.pdf' for specific instructions regarding this process."
            
            $target = Read-Host "Type the source location of the Five9 Phone Number CSV file"
            
            $CSVData = Import-CSV $target
            $UserProfile = $env:USERNAME
            
            If ((Get-Module).Name -notcontains "ActiveDirectory") {Import-Module ActiveDirectory}
            $Users = Get-ADUser -Filter * -Properties EmailAddress
            Foreach ($Line in $CSVData) {
                $Email = $Line."email"
                $Username = ($Users | Where-Object {$_.EmailAddress -eq $Email}).SamAccountName
                $Params = @{
                    Identity = $Username
                    OfficePhone = $line."DID"
                }
                If ($Username) {Set-ADUser -Replace @Params; Set-ADUser $Username -Replace @{info=$line.Skill}; Write-Host "Phone information set for $Username"}
                Else {Write-Warning "No user found with the email $Email"}
            }
            Pause
            }
    }
 }
 until ($selection -eq 'Q')

 Pause

 Pause

