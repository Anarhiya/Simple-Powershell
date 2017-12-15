$UserList = Get-ADGroupMember -Identity "Contoso Security Group" -Recursive | 
Get-ADUser -Properties SamAccountName,MobilePhone

ForEach ($User in $UserList) 
    {
     If ($User.MobilePhone -eq $null)
     {
     Write-Host -ForegroundColor Yellow "no number"
     }
     If ($User.MobilePhone -ne $null)
     {
     $PhoneReplace = $User.MobilePhone
     $PhoneReplace = $PhoneReplace -replace "[() +-]"
     $MobilePhoneReplaceFirstSymbol =$PhoneReplace[0]
     $PhoneReplace = $PhoneReplace -replace "^$MobilePhoneReplaceFirstSymbol",'+7'
     Write-Host $PhoneReplace
     Set-ADUser -Identity $User -MobilePhone $PhoneReplace
     }
}
