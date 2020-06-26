#Start-Transcript ##Indicate location for transcript
Write-Warning "This script must be used with PowerShell opened with admin credentials.
If you have not launched PowerShell with endpoint or domain admin credentials, please exit and do so now."
Pause
#Set variables
$targetpath =  ##XLSX file path
$targetworksheet = "Sheet1"
$destinationpath = ##CSV file path, created by script
    #Delete CSV file of the same name, if it exists
    Remove-Item $destinationpath -Recurse -ErrorAction Ignore
###
 $ErrorActionPreference = "SilentlyContinue"
 $Excel.displayAlerts = $false 
 $Excel = New-Object -ComObject Excel.Application
 $Excel.visible = $False
 $Workbook = $Excel.Workbooks.Open($targetpath, $null, $true)
 $Worksheet = $Workbook.WorkSheets.item($targetworksheet)
 $Worksheet.activate()
     #Get sheet name
     $s1 = $workbook.sheets | Where-Object {$_.name -eq 'Sheet1'}
     $s1.name = "NewADUser"
    #Add names for the columns
    $s1.range("A1:A1").cells="Username"
    $s1.range("B1:B1").cells="FirstName"
    $s1.range("C1:C1").cells="LastName"
    $s1.range("D1:D1").cells="JobTitle"
    $s1.range("E1:E1").cells="DepartmentTitle"
    $s1.range("F1:F1").cells="OU"
    $s1.range("G1:G1").cells="Manager"
    $s1.range("H1:H1").cells="State"
    $s1.range("I1:I1").cells="Company"
        #Delete the second row
        [void]$s1.Cells.Item(20, 20).EntireColumn.Delete()
        [void]$s1.Cells.Item(19, 19).EntireColumn.Delete()
        [void]$s1.Cells.Item(18, 18).EntireColumn.Delete()
        [void]$s1.Cells.Item(17, 17).EntireColumn.Delete()
    #Save the spreadsheet as a CSV and exit
    $s1.SaveAs("$destinationpath", 6)
    $Excel.DisplayAlerts = $True
    $s1.Quit()
    $Excel.Quit()
Import-Module ActiveDirectory
$ADUsers = Import-CSV $destinationpath -Delimiter ","
foreach ($Line in $ADUsers)
{   $Username = $line.Username
    $Firstname = $Line.FirstName
    $Lastname = $Line.LastName
    $UserCheck = dsquery user -samid $username
    $Email = "$username@domain.com"
    $ManagerUN = $Line.Manager
    $ManagerDN = (Get-ADUser $ManagerUN).DistinguishedName
    
    If ($Null -eq $UserCheck) {Write-Host "Username "$username" does not exist in Active Directory. Will proceed with setup."
        New-ADUser -Name "$FirstName $LastName" `
        -SamAccountName $Line.Username `
        -GivenName $Line.FirstName `
        -Surname $Line.LastName `
        -Path $Line.OU `
        -EmailAddress "$Email" `
        -Title $Line.JobTitle `
        -Description $Line.JobTitle `
        -Company $Line.Company `
        -Manager $ManagerDN `
        -State $Line.State `
        -Department $Line.DepartmentTitle `
        -UserPrincipalName $Email `
        -DisplayName "$FirstName $LastName" `
        -AccountPassword (convertto-securestring "ExamplePassword123!!" -AsPlainText -Force) `
        -ChangePasswordAtLogon $false `
        -Enabled $true
        Set-ADUser -Identity $Username -Add @{
        proxyaddresses = "SMTP:$email"
        }
        Write-Host "AD account created for $Firstname $Lastname"
        }
    
    Else {Write-Warning "Error creating AD account for $Firstname $Lastname. User account in AD exists with username $username
        Please change the username $Firstname $Lastname to something unique and re-run"}
    }