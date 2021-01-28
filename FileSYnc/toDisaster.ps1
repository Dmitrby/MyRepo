#[Console]::outputEncoding = [System.Text.Encoding]::GetEncoding('cp866')
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

$path = 'C:\FileSYnc'
$ErrorActionPreference = "SilentlyContinue" 
$hstart = get-date
$hstart = $hstart.ToString("G")
$alert = "ALERT BED FILES "
$ToDisk = Get-ScheduledTask ToDisk| foreach {$_.State}
$Date = get-date -Format "dd.MM.yyyy"
$LogDate ="$Date"
$subbota= (get-date).DayOfWeek # Saturday
##########################################################################################################


#удаление из E:\Backup\VEEAM записи старше 15 дней
$ToDeleteDate = (Get-Date).AddDays(-7)
$pathVeeam = "E:\Backup\VEEAM"
$allFiles = Get-ChildItem $pathVeeam -Recurse -File


IF ($ToDisk -eq 'Running') {
     DO {
    $ToDisk = Get-ScheduledTask ToDisk| foreach {$_.State}
    Start-Sleep -Seconds 600
        } Until ($ToDisk -eq 'Ready')
}


#	enable interface Backup
Enable-NetAdapter -Name "Backup" -Confirm:$false
Start-Sleep -Seconds 30
Test-Connection -ComputerName "172.254.254.1" -count '5'
Start-Sleep -Seconds 77

        $hstart + " START JOB" | Out-File \\172.254.254.1\Backups\backup_logs\FileSyncLog.txt -Append

# IF Saturday or Sunday not Copy data from Backupcrm
        IF(($subbota -like "Saturday") -or ($subbota -like "Sunday")){}
            else {

# Remove files from veeam older then 7 days
                foreach($my in $allfiles){
                $filesdate=(Get-Item $my.fullname).LastWriteTime.date
                 IF ($filesdate -lt $ToDeleteDate) {
                    #Write-Host $my.fullname 
                    Remove-Item $my.fullname  -Recurse -Force
                     }
                 }

#Copy veeam all for 4 last days
        robocopy "\\172.254.254.1\Backup\veeam" "E:\Backup\veeam" /E /PURGE  /R:3 /W:5 /MT:3 /maxage:4 /UNILOG+:\\172.254.254.1\Backups\backup_logs\Todisaster\"$LogDate"_Todisaster.log

#Copy VeeamInfinite        
        robocopy "\\172.254.254.1\Backup\VeeamInfinite" "E:\Backup\VeeamInfinite" /E /PURGE  /R:3 /W:5 /MT:5 /UNILOG+:\\172.254.254.1\Backups\backup_logs\Todisaster\"$LogDate"_Todisaster.log
        
#Copy directory witch exceptions                
        robocopy "\\172.254.254.1\Backup" "E:\Backup" /E /PURGE /Xd "\\172.254.254.1\Backup\RegionShara", "\\172.254.254.1\Backup\veeam", "\\172.254.254.1\Backup\VeeamInfinite", "\\172.254.254.1\Backup\veeamzip" /R:3 /W:5 /MT:3 /UNILOG+:\\172.254.254.1\Backups\backup_logs\Todisaster\"$LogDate"_Todisaster.log
       
#copy veeamzip backups  - only last *.VBK
            $pathVeeamzip = "\\172.254.254.1\Backup\VEEAMzip"
            #New-Item -ItemType "directory" -Path "X:\VEEAM"
            #$excludeDirectory = "SPPS|Backup_Exch01|VERSTKA2|Woodwing|file02|RAFT|FR001"
            $ResultDirectory = Get-ChildItem -Path $pathVeeamzip -Directory -Recurse #| where Name -NotMatch $excludeDirectory 

            foreach($my in $ResultDirectory){
            $DirectoryTo = Get-ChildItem -Path $my.fullname -filter *.vbk | Sort-Object lastwritetime | Select-Object -last 1
            $DirectoryToCopy = $DirectoryTo.fullname
            $FilePath = $my.fullname
            $file = $DirectoryTo.name
            $destenationDirectory = $FilePath.Replace("\\172.254.254.1","E:")
            write-host $FilePath   $destenationDirectory  $file
   
                IF ($file -eq $null){}
                    else {
                        IF ((ls $destenationDirectory).name -like "*$file*") {} else {
                            Remove-Item -Path $destenationDirectory\*.vbk -Force -ErrorAction SilentlyContinue
                            }
                        robocopy "$FilePath" "$destenationDirectory" "$file" /R:3 /W:5 /MT:3 /UNILOG+:\\172.254.254.1\Backups\backup_logs\Todisaster\"$LogDate"_Todisaster.log
                         }
            }
        
#Copy VEEAMzip -VBM Only
        robocopy "\\172.254.254.1\Backup\VEEAMzip" "E:\Backup\VEEAMzip" *.vbm /E /PURGE /R:3 /W:5 /MT:5 /UNILOG+:\\172.254.254.1\Backups\backup_logs\Todisaster\"$LogDate"_Todisaster.log

#Copy zabbix data from Backupcrm
        robocopy "\\172.254.254.1\c$\zabbix" "C:\zabbix\" /E /PURGE /R:3 /W:5 /MT:10 /UNILOG+:\\172.254.254.1\Backups\backup_logs\Todisaster\"$LogDate"_Todisaster.log

#Copy Sheduller jobs from Backupcrm
        robocopy "\\172.254.254.1\c$\VMZeepTasks" "C:\VMZeepTasks\" /E /PURGE /R:3 /W:5 /MT:10 /UNILOG+:\\172.254.254.1\Backups\backup_logs\Todisaster\"$LogDate"_Todisaster.log
        }

#	enable interface BackupSQL
            Enable-NetAdapter -Name "Backupsql" -Confirm:$false
            Start-Sleep -Seconds 100
            Test-Connection -ComputerName "172.254.254.9" -count '5'
#Copy Sql backups and logs
            robocopy "\\172.254.254.9\SQL" "E:\SQL" /E /PURGE /Xd /R:3 /W:5 /MT:3 /UNILOG+:\\172.254.254.1\Backups\backup_logs\Todisaster\"$LogDate"_Todisaster.log
            Disable-NetAdapter -Name "Backupsql" -Confirm:$false



            Get-PSDrive E | Out-File \\172.254.254.1\Backups\backup_logs\Todisaster\"$LogDate"_Todisaster.log -Append

            $hend = get-date
            $hend = $hend.ToString("G")
			$hend + " END JOB" | Out-File \\172.254.254.1\Backups\backup_logs\FileSyncLog.txt -Append
            "END OK" | Out-File \\172.254.254.1\Backups\backup_logs\END_ToDisaster.txt
			Disable-NetAdapter -Name "Backup" -Confirm:$false
            $LASTEXITCODE = 0
			

	
Exit $LASTEXITCODE