$PSDefaultParameterValues['*:Encoding'] = 'utf8'
cls
$domainCRM = "-Server action-crm.local"
$domainAmedia = "-Server amedia.loc"
$domainHQ = "-Server hq.icfed.com"

$timestamp=get-date -Format "dd-MM-yyyy--HH-mm"
$ResultPatch = "c:\temp\UsersInGroups-$timestamp.log"

$CRMGroups = Get-ADGroup $domainCRM –Filter * -Properties Members | where { $_.Members.Count –gt 0 }|foreach {$_.DistinguishedName}
$AmediaGroups = Get-ADGroup $domainAmedia –Filter * -Properties Members | where { $_.Members.Count –gt 0 }|foreach {$_.DistinguishedName}
$HQGroups = Get-ADGroup $domainHQ –Filter * -Properties Members | where { $_.Members.Count –gt 0 }|foreach {$_.DistinguishedName}


get-date | Out-File $ResultPatch

Import-Csv "c:\temp\UserList.csv" | ForEach-Object {
$user = $_.USER
$domain = $_.DOMAIN
$Sid = Get-ADUser -Server "$domain" -Identity $user -prop *| foreach { $_.Sid }| foreach { $_.value }
$DistinguishedName = Get-ADUser -Server "$domain" -Identity $user -prop *| foreach { $_.DistinguishedName }

"
$domain\$user|$Sid" | Out-File $ResultPatch -Append
"-----CRM" | Out-File $ResultPatch -Append

    foreach ($Group in $CRMGroups){
      $members = (Get-ADGroup $domainCRM $Group -prop *).Members

        foreach ($member in $members){
        IF ($member.Split(",")[0].Split("=")[-1] -like $Sid) {$Group.Split(",")[0].Split("=")[-1] | Out-File $ResultPatch -Append}

        ElseIF($member -eq $DistinguishedName) {$Group.Split(",")[0].Split("=")[-1] | Out-File $ResultPatch -Append}
        }
    }

"-----Amedia.loc" | Out-File $ResultPatch -Append

    foreach ($Group in $AmediaGroups){
      $members = (Get-ADGroup $domainAmedia $Group -prop *).Members

        foreach ($member in $members){
        IF ($member.Split(",")[0].Split("=")[-1] -like $Sid) {$Group.Split(",")[0].Split("=")[-1] | Out-File $ResultPatch -Append}

        ElseIF($member -eq $DistinguishedName) {$Group.Split(",")[0].Split("=")[-1] | Out-File $ResultPatch -Append}
        }
    }


"-----HQ" | Out-File $ResultPatch -Append

    foreach ($Group in $HQGroups){
      $members = (Get-ADGroup $domainHQ $Group -prop *).Members

        foreach ($member in $members){
        IF ($member.Split(",")[0].Split("=")[-1] -like $Sid) {$Group.Split(",")[0].Split("=")[-1] | Out-File $ResultPatch -Append}

        ElseIF($member -eq $DistinguishedName) {$Group.Split(",")[0].Split("=")[-1] | Out-File $ResultPatch -Append}
        }
    }


}