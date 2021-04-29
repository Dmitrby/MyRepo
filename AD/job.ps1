$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$runsid = @{Name="RunAs";Expression={[xml]$xml= $_.xml ; $xml.Task.Principals.principal.userID}}
$localSystem = "LocalSystem"
$domain = $env:USERDOMAIN
$smb1 = Get-WindowsOptionalFeature -online -FeatureName smb1protocol | select state | ForEach-Object {$_.state}
$smb2 = Get-SmbServerConfiguration | select enablesmb2protocol | ForEach-Object {$_.enablesmb2protocol}
$smb1e = "SMB1 enabled"
$smb2e = "SMB2 enabled"
$smb1d = "SMB1 disabled"

function smb1 {
$smb1
If ($smb1 -eq 'enabled'){$smb1e}
else {$smb1d}
}

function smb2 {
$smb2
If ($smb2 -eq 'enabled'){$smb2e}
}

# Укажите путь для вывода результата
$ResultPatch = "\\fr001\Data_it\_Script\ScheduledTask\jobs-$domain.txt"
$ResultPatch2 = "\\fr001\Data_it\_Script\ScheduledTask\jobs-sidUsers-$domain.txt"

#Проверка всех серверных систем в домене
$servers = Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*' } -Properties DNSHostName|Select DNSHostName -ExpandProperty DNSHostName
#$servers = Get-Content "\\crm00111\soft\servers.txt"

#Проверка по определённому UO
#$servers = Get-ADComputer -Filter * -searchbase "OU=Servers,DC=action-crm,DC=local" -Properties DNSHostName Select DNSHostName -ExpandProperty DNSHostName


function getsid {

IF ($tekst2 -like '*S-1-5-21-1052612494*') {Get-ADUser -Server "action-crm.local" -Identity $tekst2| Select-Object Name |ForEach-Object {$_.name}}
ELSEIF ($tekst2 -like '*S-1-5-21-2092451560*') {Get-ADUser -Server "actiondigital.ru" -Identity $tekst2| Select-Object Name |ForEach-Object {$_.name}}
ELSEIF ($tekst2 -like '*S-1-5-21-1713080955*') {Get-ADUser -Server "amedia.loc" -Identity $tekst2| Select-Object Name |ForEach-Object {$_.name}}
ELSEIF ($tekst2 -like '*S-1-5-21-789336058*') {Get-ADUser -Server "hq-dc1.hq.icfed.com" -Identity $tekst2| Select-Object Name |ForEach-Object {$_.name}}
ElseIF ($tekst2 -eq 'S-1-5-18') {$localSystem}
Else {$result = $tekst2 }
}

foreach ($Server in $servers) {

$objSchTaskService = New-Object -ComObject Schedule.Service
$objSchTaskService.connect($server)
#folder job
#$RootFolder = $objSchTaskService.GetFolder("\")
$RootFolder = $objSchTaskService.GetFolder("\Microsoft\Windows\Backup")

$ScheduledTasks = $RootFolder.GetTasks(0)
$smb1state = smb1
$smb2state = smb2
"  " |out-file -encoding default $ResultPatch -Append
$Server +"|$smb1state" + "|$smb2state" |out-file -encoding default $ResultPatch -Append
$ScheduledTasks | Select Name, LastRunTime, NextRunTime,$runsid | ForEach-Object {$_.name +"   |"+ $_.lastRunTime +"   |"+ $_.RunAs}  |out-file -encoding default  $ResultPatch -Append
}

$tekst = Get-Content -path "$ResultPatch" -Encoding UTF8

foreach ($teksts in $tekst){
$tekst2 = $teksts.Split("|")[-1]
$result = getsid
#write-host $result
If ($result -ne $NULL){
$tekst = $tekst -replace "$tekst2",$result}
$tekst | sc -Encoding UTF8 -path "$ResultPatch2"
}