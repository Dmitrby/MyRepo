#выгрузка пк в файлик
#Get-ADComputer -SearchBase 'OU=Computers_VLD,DC=action-crm,DC=local' -Filter '*' | Select -Exp Name > \\crm00111\soft\rebootlist.txt
# задержка в секундах
write-host "Start-Sleep -s 7200"
Start-Sleep -s 7200

#перезагрузка по файлику
Get-Content -Path \\crm00111\soft\rebootlist.txt | Where-Object {Test-Connection -ComputerName $_ -Quiet -Count 2} |
   ForEach-Object {
       Write-host "Restarting $_ " -ForegroundColor Green
       Restart-Computer -ComputerName $_ -Force
 }