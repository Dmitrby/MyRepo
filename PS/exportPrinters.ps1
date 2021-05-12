$Error.clear()
#Добавим отметку даты к конфигу принтеров
$date = get-date -Format dd-MM-yyyy
#Путь к утилите PrintBrm
$ProgramPath = 'C:\Windows\System32\Spool\Tools\PrintBrm.exe'

#Основной и резервный серверы
$SourceServer = 'Print01.hq.icfed.com'

#Файл, куда выгружаем настройки. Путь не должен содержать пробелы, т.к. утилита PrintBrm не понимает кавычки в пути файла
$ConfigFilePath = "\\hq.icfed.com\dfs\PrintSync\$date-print-config.printerExport"

#Экспортируем принтеры в файл
$Arguments = "-s $SourceServer -f $ConfigFilePath -b"
Start-process -NoNewWindow -FilePath $ProgramPath -ArgumentList $Arguments -Wait -PassThru

#завершаем работу без очистки если были ошибки
if (($Error).count -gt 0){Exit $Error}

# Очистка старых выгрузок конфигурации

$TargetFolder = "\\hq.icfed.com\dfs\PrintSync" # Путь к папке логов.
$Period = "-10" # Количество хранимых дней.
# Вычисляем дату после которой будем удалять файлы.
$CurrentDay = Get-Date
$ChDaysDel = $CurrentDay.AddDays($Period)
# Удаление файлов, дата создания которых больше заданного количества дней
GCI -Path $TargetFolder -Recurse | Where-Object {$_.CreationTime -LT $ChDaysDel} | RI -Recurse -Force
GCI -Path $TargetFolder -Recurse | Where-Object {$_.PSIsContainer -and @(Get-ChildItem -Path $_.Fullname -Recurse | Where { -not $_.PSIsContainer }).Count -eq 0 } | RI -Recurse


#ls \\hq.icfed.com\dfs\PrintSync | sort CreationTime | select -Last 1 | select fullname
Exit
