$GpoPath = "C:\GPO Backups\"
$date=Get-Date -Format "dd.MM.yyyy"
$day,$month,$year=[datetime]::Today.AddDays(-33).ToString('dd-MM-yyyy').Split('-')
$Todelete="C:\GPO Backups\$day.$month.$year"
$Deletetrigger = Test-Path $Todelete
$GPOname=get-gpo -all |ForEach-Object { $(foreach ($prop in 'displayname') { $_.$prop }) -join '|'}

# создание директории
mkdir "C:\GPO Backups\$date"
mkdir "\\hq.icfed.com\dfs\GPOBackup\$env:USERDNSDOMAIN\$env:COMPUTERNAME\$date"

# бекап Гпо
Foreach ($name in $GPOname){
#write-host "$name" -BackgroundColor Cyan

Backup-Gpo -Name $name -Path "C:\GPO Backups\$date" -Comment "$name" 

}

# удаление старой записи

IF ($Deletetrigger -eq "True"){

Remove-item -Path $Todelete -Recurse -Force

}

# бекап Гпо to dfs

Foreach ($name in $GPOname){

Backup-Gpo -Name $name -Path "\\hq.icfed.com\dfs\GPOBackup\$env:USERDNSDOMAIN\$env:COMPUTERNAME\$date" -Comment "$name" 

}

exit