#необходимо копировать новые данные на диск с проверкой свобного места
#[Console]::outputEncoding = [System.Text.Encoding]::GetEncoding('cp866')
$Error.Clear()
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$PSEmailServer = "mail.action-crm.local"
#$ErrorActionPreference = 'SilentlyContinue'

#Глубина бекапа в днях
$LogDate=(Get-Date).TOSTRING("d")
$BackupDate = (Get-Date).AddDays(-7)
#Удаление файлов старше * дней
$ToDeleteDate = (Get-Date).AddDays(-270)

#Имя диска для синхронизации
$DiscName = "G"
# Пороговое значение Свободного места на диске для остановки синхронизации
$MinimalDiscSize = 1150
$ErrorDiscSize = 512

#Создаём директории если их нет
$ALLDirectory = ls -recurse -directory -Depth 0 \\rec1.action-crm.local\golos |ForEach-Object {$_.Name}
Foreach ($Directory in $ALLDirectory){
$Test = Test-Path \\rec7.action-crm.local\Golos\Beckup_Rec1\$Directory
If ($Test -eq "True"){}
Else {New-Item \\rec7.action-crm.local\Golos\Beckup_Rec1\$Directory -type directory}
}

# Задаём измеряемый диск
$Freespace = Get-PSDrive -name $DiscName | select-object Free | ForEach-Object {($_.Free/1GB)}
IF ($Freespace -ge $ErrorDiscSize){

# вставляем код синхронизации и проверки по дням

	Foreach ($Directory in $ALLDirectory){

	$Directory
	$RecordsDirectory = ls -recurse  -Depth 0 \\rec1.action-crm.local\golos\$Directory |ForEach-Object {$_.Name}


		Foreach ($Record in $RecordsDirectory){

		$filesdate=(Get-Item \\rec1.action-crm.local\golos\$Directory\$Record).LastWriteTime.date

			IF ($filesdate -ge $BackupDate){

				Write-Host "$Record норм"
				robocopy "\\rec1.action-crm.local\golos\$Directory\$Record" "\\rec7.action-crm.local\Golos\Beckup_Rec1\$Directory\$Record" *.mp3 /E /COPY:DATSOU /R:2 /W:5 /MT:24 /LOG+:G:\Rec1ToRec7Log\"$LogDate"_backup.log
			}
		}
	}
}

IF ($Freespace -lt $MinimalDiscSize) {

#Для очистки от старых файлов снять коментирование (' ниже)

$ALLDirectory = ls -recurse -directory -Depth 0 G:\Golos\Beckup_Rec1 |ForEach-Object {$_.Name}
	Foreach ($Directory in $ALLDirectory){

	#$Directory
	$RecordsDirectory = ls -recurse  -Depth 0 G:\Golos\Beckup_Rec1\$Directory |ForEach-Object {$_.Name}

		Foreach ($Record in $RecordsDirectory){

		$filesdate=(Get-Item G:\Golos\Beckup_Rec1\$Directory\$Record).LastWriteTime.date
 
			IF ($filesdate -lt $ToDeleteDate) {

			Remove-Item "G:\Golos\Beckup_Rec1\$Directory\$Record" -Recurse -Force
			}
		}
	}
}



IF ($Freespace -lt $ErrorDiscSize){

Send-MailMessage -From "REC7@action-press.ru" -To "smg@action-press.ru" -Subject "ALERT REC7.action-crm.local На диске G меньше 1TB" -Body "ALERT REC7.action-crm.local На диске G меньше 1TB.
Требуется очистить место.
Необходимо запустить скрипт с выбранной глубиной хранения и убрать коментирование в скрипте  "
}

#очистка логов
$TargetFolder = "G:\Rec1ToRec7Log" # Путь к папке логов.
$Period = "-14" # Количество хранимых дней.
# Вычисляем дату после которой будем удалять файлы.
$CurrentDay = Get-Date
$ChDaysDel = $CurrentDay.AddDays($Period)
# Удаление файлов, дата создания которых больше заданного количества дней
GCI -Path $TargetFolder -Recurse | Where-Object {$_.CreationTime -LT $ChDaysDel} | RI -Recurse -Force 
#GCI -Path $TargetFolder -Recurse | Where-Object {$_.LastWriteTime -LT $ChDaysDel} | RI -Recurse -Force 
GCI -Path $TargetFolder -Recurse | Where-Object {$_.PSIsContainer -and @(Get-ChildItem -Path $_.Fullname -Recurse | Where { -not $_.PSIsContainer }).Count -eq 0 } | RI -Recurse


If ($error.count -gt 0) 
	{
	exit 111
	}
	Else 
	{
	Exit
	}