function Show-Menu {
    param (
        [string]$Title = 'Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Get User PC From Name"
    Write-Host "2: Get List of Users With Identical Job Titles"
    Write-Host "3: Unlock User Account (Admin Required)"
    Write-Host "4: Reset User Password (Admin Required)"
    Write-Host "Q: Press 'Q' to quit."
}

do
 {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    '1' {
    $name =  Read-Host 'What is the first and last name of the user?'
    Get-ADComputer -Filter { Description -Like $name }}
    '2' {
    $name =  Read-Host 'What is the users job title?'
    Get-ADUser -Filter {Description -Like $name}}
    '3' { Write-Warning "You must open Powershell with admin credentials to execute this command.
    Please exit and reopen if this has not been launched with endpoint or domain admin credentials."
    $user =  Read-Host 'What is the username?'
    Unlock-ADAccount -Identity $user}
    '4' { Write-Warning "You must open Powershell with admin credentials to execute this command.
    Please exit and reopen if this has not been launched with endpoint or domain admin credentials."
    $name =  Read-Host 'What is the username?'
    $pass =  Read-Host 'What will the new password be?'
    Set-ADAccountPassword -Identity $User -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$pass" -Force)}

    } Pause
 }
 until ($selection -eq 'Q')

 pause