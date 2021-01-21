$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$data=get-date -Format yyyy.MM.dd
$backuppath = "\\backup01.hq.icfed.com\Backup$\Backup_HyperV\AD\$data"
If(!(test-path $backuppath))
{
      New-Item -ItemType Directory -Force -Path $backuppath
}

Copy-Item -Path "d:\Hyper-V\Virtual Hard Disks\hq-dc5.hq.icfed.com.vhdx" -Destination $backuppath -Force
Copy-Item -Path "d:\Hyper-V\Virtual Hard Disks\icfed-dc1.icfed.com.vhdx" -Destination $backuppath -Force


#очистка логов
$TargetFolder = "\\backup01.hq.icfed.com\Backup$\Backup_HyperV\AD\$date" # Путь к папке логов.
$Period = "-15" # Количество хранимых дней.
# Вычисляем дату после которой будем удалять файлы.
$CurrentDay = Get-Date
$ChDaysDel = $CurrentDay.AddDays($Period)
# Удаление файлов, дата создания которых больше заданного количества дней
GCI -Path $TargetFolder -Recurse | Where-Object {$_.CreationTime -LT $ChDaysDel} | RI -Recurse -Force 
#GCI -Path $TargetFolder -Recurse | Where-Object {$_.LastWriteTime -LT $ChDaysDel} | RI -Recurse -Force 
GCI -Path $TargetFolder -Recurse | Where-Object {$_.PSIsContainer -and @(Get-ChildItem -Path $_.Fullname -Recurse | Where { -not $_.PSIsContainer }).Count -eq 0 } | RI -Recurse

Exit