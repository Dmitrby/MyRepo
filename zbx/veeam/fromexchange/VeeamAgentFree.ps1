$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$xmlFilePath = "\\backupcrm.action-crm.local\Backups\backup_logs\VeeamFreeAgent.txt"

#загрузка данных из почтового ящика backup@mcfr.ru за последие 24 часа (сортировка по дате по возрастанию обязательна)
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
$Mails=Get-MessageTrackingLog -Recipients backup@mcfr.ru  -Start (Get-Date).AddHours(-24) |Where-Object {($_.Source -Like "STOREDRIVER" )-and ($_.MessageSubject -like "*Warning*" -or "*Success*" -or "*Failed*")}| select MessageSubject | foreach {$_.MessageSubject} | out-file $xmlFilePath 
Exit