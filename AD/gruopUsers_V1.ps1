$domain = $env:USERDOMAIN
$ResultPatch = "\\spps.action-crm.local\UserShare\_Общая_\ad\$domain-UsersInGroup.txt"

#For group in list#############################################
#$AmediaGroups = 'CN=VPN_Media,OU=VPN,OU=Users_Media,DC=amedia,DC=loc','CN=Cons_Access,OU=Groups_for_AnoverCompany_Access,OU=Users_Media,DC=amedia,DC=loc','CN=jira_am_software_users,OU=_Groups,OU=IT_Developers,OU=Users_Media,DC=amedia,DC=loc','CN=Jira_am_bitbucket,OU=_Groups,OU=IT_Developers,OU=Users_Media,DC=amedia,DC=loc'
#$CRMGroups = 'CN=VPN_PRESS,OU=SYSuser,DC=action-crm,DC=local','CN=jira_press_software_users,OU=Jira2,DC=action-crm,DC=local','CN=jira_press_bitbucket,OU=Jira2,DC=action-crm,DC=local','CN=2018_managers_otchetnost,OU=SHARA,DC=action-crm,DC=local'
#$HQGroups = 'CN=VPN_Global,OU=INTERNET Access Groups,DC=hq,DC=icfed,DC=com','CN=Consultant_Users,OU=Pravo,OU=Folders Access On Servers,DC=hq,DC=icfed,DC=com','CN=jira_mс_software_users,OU=Jira,OU=Service Accounts,OU=1st_United,DC=hq,DC=icfed,DC=com'
#$ActiondigitalGroups = 'CN=jira_ad_software_users,OU=ActionDigitalUsers,DC=ActionDigital,DC=ru','CN=Jira_ad_bitbucket,OU=ActionDigitalUsers,DC=ActionDigital,DC=ru'
$CRMGroups = 'CN=2018_managers_otchetnost,OU=SHARA,DC=action-crm,DC=local'



IF ($domain -eq 'action-crm'){$groups = $CRMGroups}
ElseIF ($domain -eq 'actiondigital'){$groups = $ActiondigitalGroups}
ElseIF ($domain -eq 'amedia'){$groups = $AmediaGroups}
Else {$groups = $HQGroups}
###############################################################

#for all domain groups
#$groups = Get-ADGroup –Filter * -Properties Members | where { $_.Members.Count –gt 0 }|foreach {$_.DistinguishedName}

####################################################################
#main
function GetUsers {

$Base = Get-ADUser -Filter {DistinguishedName -eq $member} -Properties EmailAddress | select name

        If ($Base -ne $NULL) {Get-ADUser -Filter {DistinguishedName -eq $member} -Properties * | ForEach-Object { $(foreach ($prop in 'name', 'EmailAddress', 'samaccountname') { $_.$prop }) -join '|'}  |out-file -encoding utf8 $ResultPatch -Append}
        Else {IF ($member -like '*S-1-5-21-*'){$member=$member.Split("=")[1]
               $member=$member.Split("\")[0]
                }
            noDefaulDomain
        }

}
function noDefaulDomain {
  
  IF ($member -like '*S-1-5-21-2092451560*') {Get-ADUser -Server "actiondigital.ru" -Identity $member.Split(",")[0] -Properties * | ForEach-Object { $(foreach ($prop in 'name', 'EmailAddress', 'samaccountname') { $_.$prop }) -join '|'}  |out-file -encoding utf8 $ResultPatch -Append}
        ElseIF ($member -like '*S-1-5-21-1713080955*') {Get-ADUser -Server "amedia.loc" -Identity $member.Split(",")[0] -Properties * | ForEach-Object { $(foreach ($prop in 'name', 'EmailAddress', 'samaccountname') { $_.$prop }) -join '|'}  |out-file -encoding utf8 $ResultPatch -Append}
        ElseIF ($member -like '*S-1-5-21-789336058*') {Get-ADUser -Server "hq-dc1.hq.icfed.com" -Identity $member.Split(",")[0] -Properties * | ForEach-Object { $(foreach ($prop in 'name', 'EmailAddress', 'samaccountname') { $_.$prop }) -join '|'}  |out-file -encoding utf8 $ResultPatch -Append}
        ElseIF ($member -like '*S-1-5-21-1052612494*') {Get-ADUser -Server "action-crm.local" -Identity $member.Split(",")[0] -Properties * | ForEach-Object { $(foreach ($prop in 'name', 'EmailAddress', 'samaccountname') { $_.$prop }) -join '|'}  |out-file -encoding utf8 $ResultPatch -Append}
        ElseIF ($member -like '*S-1-5-21-*') {out-file -encoding utf8 $ResultPatch -Append }
        Else {InGroups}
}
#First in
function InGroups {
    #write-host $member
    #$member +'|||1st in Group' |out-file -encoding utf8 $ResultPatch -Append
    $InMembers =  (Get-ADGroup "$member" -prop *).Members 

      foreach ($InMember in $InMembers)
               {
            GetInUsers
                   }
    #$member +'|||END in Group' |out-file -encoding utf8 $ResultPatch -Append
  
}
function GetInUsers {

$InBase = Get-ADUser -Filter {DistinguishedName -eq $InMember} -Properties EmailAddress | select name

        If ($InBase -ne $NULL) {Get-ADUser -Filter {DistinguishedName -eq $InMember} -Properties * | ForEach-Object { $(foreach ($prop in 'name', 'EmailAddress', 'samaccountname') { $_.$prop }) -join '|'}  |out-file -encoding utf8 $ResultPatch -Append}
        Else {IF ($InMember -like '*S-1-5-21-*'){$InMember=$InMember.Split("=")[1]
               $InMember=$InMember.Split("\")[0]
                }
            InnoDefaulDomain
        }

}
function InNoDefaulDomain {
  
  IF ($InMember -like '*S-1-5-21-2092451560*') {Get-ADUser -Server "actiondigital.ru" -Identity $InMember.Split(",")[0] -Properties * | ForEach-Object { $(foreach ($prop in 'name', 'EmailAddress', 'samaccountname') { $_.$prop }) -join '|'}  |out-file -encoding utf8 $ResultPatch -Append}
        ElseIF ($InMember -like '*S-1-5-21-1713080955*') {Get-ADUser -Server "amedia.loc" -Identity $InMember.Split(",")[0] -Properties * | ForEach-Object { $(foreach ($prop in 'name', 'EmailAddress', 'samaccountname') { $_.$prop }) -join '|'}  |out-file -encoding utf8 $ResultPatch -Append}
        ElseIF ($InMember -like '*S-1-5-21-789336058*') {Get-ADUser -Server "hq-dc1.hq.icfed.com" -Identity $InMember.Split(",")[0] -Properties * | ForEach-Object { $(foreach ($prop in 'name', 'EmailAddress', 'samaccountname') { $_.$prop }) -join '|'}  |out-file -encoding utf8 $ResultPatch -Append}
        ElseIF ($InMember -like '*S-1-5-21-1052612494*') {Get-ADUser -Server "action-crm.local" -Identity $InMember.Split(",")[0] -Properties * | ForEach-Object { $(foreach ($prop in 'name', 'EmailAddress', 'samaccountname') { $_.$prop }) -join '|'}  |out-file -encoding utf8 $ResultPatch -Append}
        ElseIF ($InMember -like '*S-1-5-21-*') {out-file -encoding utf8 $ResultPatch -Append }
        Else {InGroups2}
}
#Second in
function InGroups2 {
    #write-host $InMember
    #$Inmember +'|||2nd in Group' |out-file -encoding utf8 $ResultPatch -Append
    $InMembers2 =  (Get-ADGroup "$InMember" -prop *).Members 

      foreach ($InMember2 in $InMembers2)
               {
            GetInUsers2
                   }
    #$InMember +'|||END in Group' |out-file -encoding utf8 $ResultPatch -Append
  
}
function GetInUsers2 {

$InBase2 = Get-ADUser -Filter {DistinguishedName -eq $InMember2} -Properties EmailAddress | select name

        If ($InBase2 -ne $NULL) {Get-ADUser -Filter {DistinguishedName -eq $InMember2} -Properties * | ForEach-Object { $(foreach ($prop in 'name', 'EmailAddress', 'samaccountname') { $_.$prop }) -join '|'}  |out-file -encoding utf8 $ResultPatch -Append}
        Else {IF ($InMember2 -like '*S-1-5-21-*'){$InMember2=$InMember2.Split("=")[1]
               $InMember2=$InMember2.Split("\")[0]
                }
            InnoDefaulDomain2
        }

}
function InNoDefaulDomain2 {
  
  IF ($InMember2 -like '*S-1-5-21-2092451560*') {Get-ADUser -Server "actiondigital.ru" -Identity $InMember2.Split(",")[0] -Properties * | ForEach-Object { $(foreach ($prop in 'name', 'EmailAddress', 'samaccountname') { $_.$prop }) -join '|'}  |out-file -encoding utf8 $ResultPatch -Append}
        ElseIF ($InMember2 -like '*S-1-5-21-1713080955*') {Get-ADUser -Server "amedia.loc" -Identity $InMember2.Split(",")[0] -Properties * | ForEach-Object { $(foreach ($prop in 'name', 'EmailAddress', 'samaccountname') { $_.$prop }) -join '|'}  |out-file -encoding utf8 $ResultPatch -Append}
        ElseIF ($InMember2 -like '*S-1-5-21-789336058*') {Get-ADUser -Server "hq-dc1.hq.icfed.com" -Identity $InMember2.Split(",")[0] -Properties * | ForEach-Object { $(foreach ($prop in 'name', 'EmailAddress', 'samaccountname') { $_.$prop }) -join '|'}  |out-file -encoding utf8 $ResultPatch -Append}
        ElseIF ($InMember2 -like '*S-1-5-21-1052612494*') {Get-ADUser -Server "action-crm.local" -Identity $InMember2.Split(",")[0] -Properties * | ForEach-Object { $(foreach ($prop in 'name', 'EmailAddress', 'samaccountname') { $_.$prop }) -join '|'}  |out-file -encoding utf8 $ResultPatch -Append}
        ElseIF ($InMember2 -like '*S-1-5-21-*') {out-file -encoding utf8 $ResultPatch -Append }
        Else {$InMember2 | out-file -encoding utf8 $ResultPatch -Append}
}
####################################################################
foreach ($group in $groups) 
{  
    $group +'|||Group' |out-file -encoding utf8 $ResultPatch -Append
    $members = (Get-ADGroup "$group" -prop *).Members

    foreach ($member in $members)
        {
            GetUsers
        }
  
}