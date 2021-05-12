Start-Sleep -s 1000
#Путь к утилите PrintBrm
$ProgramPath = 'C:\Windows\System32\Spool\Tools\PrintBrm.exe'

#Основной и резервный серверы
$DestServer = 'Print02.hq.icfed.com'

#Файл, куда выгружаем настройки. Путь не должен содержать пробелы, т.к. утилита PrintBrm не понимает кавычки в пути файла
$ConfigFilePath = ls \\hq.icfed.com\dfs\PrintSync | sort CreationTime | select -Last 1 | foreach {$_.fullname}

#Импортируем принтеры из файла
$Arguments = "-s $DestServer -f $ConfigFilePath -r -o force"
Start-process -NoNewWindow -FilePath $ProgramPath -ArgumentList $Arguments -Wait -PassThru

Start-Sleep -Seconds 1800

exit
