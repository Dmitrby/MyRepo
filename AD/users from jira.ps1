$PSDefaultParameterValues['*:Encoding'] = 'utf8'
cls

$patch = 'c:\temp'

# выгружаем пользователей из групп jira_press_software_users , jira_mс_software_users , jira_am_software_users
$jiraPress = (Get-ADGroup -Server "action-crm.local" -filter * -SearchBase 'CN=jira_press_software_users,OU=Jira2,DC=action-crm,DC=local' -prop *).Members
$jiraAmedia = (Get-ADGroup -Server "amedia.loc" -filter * -SearchBase 'CN=jira_am_software_users,OU=_Groups,OU=IT_Developers,OU=Users_Media,DC=amedia,DC=loc' -prop *).Members
$jiraHq = (Get-ADGroup -Server "hq.icfed.com" -filter * -SearchBase 'CN=jira_mс_software_users,OU=Jira,OU=Service Accounts,OU=1st_United,DC=hq,DC=icfed,DC=com' -prop *).Members

#(Get-ADGroup -Server "action-crm.local" -filter * -SearchBase 'CN=jira_press_software_users,OU=Jira2,DC=action-crm,DC=local' -prop *).Members


#press
foreach ($press in $jiraPress){
$SamAccountName = Get-ADUser -Server "action-crm.local" -identity $press| foreach { $_.SamAccountName}
$Lastlogon = [datetime]::FromFileTime((Get-ADUser -Server "action-crm.local" -prop * $SamAccountName | foreach {$_.lastLogon}))
$UserPress= Get-ADUser -Server "action-crm.local" -prop * $SamAccountName  | ForEach-Object { $(foreach ($prop in 'samaccountname','name', 'EmailAddress') { $_.$prop }) -join '|'}
"$UserPress|$Lastlogon" | out-file $patch\press.csv -Append
}

#media
foreach ($Amedia in $jiraAmedia){
$SamAccountName = Get-ADUser -Server "amedia.loc" -identity $Amedia| foreach { $_.SamAccountName}
$Lastlogon = [datetime]::FromFileTime((Get-ADUser -Server "amedia.loc" -prop * $SamAccountName | foreach {$_.lastLogon}))
$UserPress= Get-ADUser -Server "amedia.loc" -prop * $SamAccountName  | ForEach-Object { $(foreach ($prop in 'samaccountname','name', 'EmailAddress') { $_.$prop }) -join '|'}
"$UserPress|$Lastlogon"  | out-file $patch\Amedia.csv -Append
}

#HQ
foreach ($hq in $jiraHq){
$SamAccountName = Get-ADUser -Server "hq.icfed.com" -identity $hq| foreach { $_.SamAccountName}
$Lastlogon = [datetime]::FromFileTime((Get-ADUser -Server "hq.icfed.com" -prop * $SamAccountName | foreach {$_.lastLogon}))
$UserPress= Get-ADUser -Server "hq.icfed.com" -prop * $SamAccountName  | ForEach-Object { $(foreach ($prop in 'samaccountname','name', 'EmailAddress') { $_.$prop }) -join '|'}
"$UserPress|$Lastlogon"  | out-file $patch\HQ.csv -Append
}

#HQ all users
Get-ADUser -Server "hq.icfed.com" -prop samaccountname, name, EmailAddress -filter *|where {$_.enabled -ne "False"} | FT samaccountname, name, EmailAddress -AutoSize | out-file $patch\HQaLL.csv
