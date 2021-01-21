$PSDefaultParameterValues['*:Encoding'] = 'utf8'
cls
$timestamp=get-date -Format "dd-MM-yyyy--HH-mm"
$ResultPatch = "\\crm00111.action-crm.local\logs\UsersInGroups-$timestamp.log"

$Groups = Get-ADGroup –Filter * -Properties Members | where { $_.Members.Count –gt 0 }|foreach {$_.DistinguishedName}

get-date | Out-File $ResultPatch

Import-Csv "\\crm00111.action-crm.local\logs\UserList.csv" | ForEach-Object {
$user = $_.USER
$domain = $_.DOMAIN
$Sid = Get-ADUser -Server "$domain" -Identity $user -prop *| foreach { $_.Sid }| foreach { $_.value }
$DistinguishedName = Get-ADUser -Server "$domain" -Identity $user -prop *| foreach { $_.DistinguishedName }

"
$domain/$user|$Sid" | Out-File $ResultPatch -Append

    foreach ($Group in $Groups){
      $members = (Get-ADGroup $Group -prop *).Members

        foreach ($member in $members){
        IF ($member.Split(",")[0].Split("=")[-1] -like $Sid) {$Group.Split(",")[0].Split("=")[-1] | Out-File $ResultPatch -Append}

        ElseIF($member -eq $DistinguishedName) {$Group.Split(",")[0].Split("=")[-1] | Out-File $ResultPatch -Append}
        }
    }
}