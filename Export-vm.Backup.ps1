cls
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$errorcount = $error.count
# указываем имя vm
$VMName="ws-cloud13.amedia.loc"
$date = get-date -Format "dd.MM.yyyy"
# Выполняем настройку скрипта.
$TargetFolder = "C:\Program Files\Temp\Trace" # Путь к папке логов.
$Period = "-10" # Количество хранимых дней.
# Вычисляем дату после которой будем удалять файлы.
$CurrentDay = Get-Date
$ChDaysDel = $CurrentDay.AddDays($Period)

# Export vm
Export-VM -Name $VMName -Path \\backupcrm.action-crm.local\Backup\Hyper-v\$VMName\$date
 
# Удаление файлов, дата создания которых больше заданного количества дней
GCI -Path $TargetFolder -Recurse | Where-Object {$_.CreationTime -LT $ChDaysDel} | RI -Recurse -Force 
#GCI -Path $TargetFolder -Recurse | Where-Object {$_.LastWriteTime -LT $ChDaysDel} | RI -Recurse -Force 
GCI -Path $TargetFolder -Recurse | Where-Object {$_.PSIsContainer -and @(Get-ChildItem -Path $_.Fullname -Recurse | Where { -not $_.PSIsContainer }).Count -eq 0 } | RI -Recurse
Exit $errorcount