#[Console]::outputEncoding = [System.Text.Encoding]::GetEncoding('cp866')
$PsDefaultParameterValues['*:Encoding'] = 'utf8'
$path = 'C:\FileSYnc'
$ErrorActionPreference = "SilentlyContinue" 
$hstart = get-date
$hstart = $hstart.ToString("G")
$disk=Test-Path G:
$PSEmailServer = "95.214.56.25"
$LSdisk = ls G:/ -recurse
$SyncToDisaster = Get-ScheduledTask ToDisk| foreach {$_.State}
get-date -Format "HH.mm dd.MM.yyyy" | Out-File C:\FileSYnc\CopyTodisk\CopyDisk.log -Encoding utf8
#############################################################################


# ожидание выполнени€ других заданий в шедуллере
IF ($SyncToDisaster -eq 'Running') {
     DO {
    $SyncToDisaster = Get-ScheduledTask SyncToDisaster| foreach {$_.State}
    Start-Sleep -Seconds 1800
        } Until ($SyncToDisaster -eq 'Ready')
}  


if ($disk -eq 'true') {
$pathVeeam = "G:\"
#Get-ChildItem $pathVeeam -Recurse -File | Remove-Item -Recurse -Force -Credential
 

    #cmd.exe /c "erase G:\ /F"
 
    Format-Volume -DriveLetter G -FileSystem NTFS -Confirm:$false
    #clear-disk -Number 4 -RemoveData -Confirm:$false -r
       # ls G:\ -Recurse | Remove-Item -Force -Confirm:$false
	Start-Sleep -Seconds 60
	Enable-NetAdapter -Name "Backup" -Confirm:$false
	Start-Sleep -Seconds 100
Test-Connection -ComputerName "172.254.254.1" -count '5'
		$hstart + " START COPY DISK G:" | Out-File \\172.254.254.1\Backups\backup_logs\CopyDisk.txt -Append
	Disable-NetAdapter -Name "Backup" -Confirm:$false
	
	Start-Sleep -Seconds 15
#copy sql
    $pathSQL = "E:\SQL"
    New-Item -ItemType "directory" -Path "G:\SQL"
    #$excludeDirectory = "SPPS|ACTION-CRM_sv|REC"
    $ResultDirectory = Get-ChildItem -Path $pathSQL -Directory -Recurse #| where Name -NotMatch $excludeDirectory 
    
    foreach($my in $ResultDirectory){
    $DirectoryTo = Get-ChildItem -Path $my.fullname -filter *.bak | Sort-Object lastwritetime | Select-Object -last 1
    $DirectoryToCopy = $DirectoryTo.fullname
    $FilePath = $my.fullname
    $file = $DirectoryTo.name
    IF ($file -eq $null){}
    else {
    
    robocopy "$FilePath" "G:\SQL" "$file" /R:3 /W:5 /MT:3 /UNILOG+:"C:\FileSYnc\CopyTodisk\CopyDisk.log"

    }
   
  }


  #copy Cisco
        robocopy "E:\Backup\Backup_Cisco" "G:\Backup_Cisco" /E /PURGE /COPY:DATSOU /R:3 /W:5 /MT:3 /MAXAGE:14 /UNILOG+:"C:\FileSYnc\CopyTodisk\CopyDisk.log"

        
#copy veeam disaster
        robocopy "E:\Backup\VeeamInfinite\Job DISASTER" "G:\DISASTER" /E /PURGE /COPY:DATSOU /R:3 /W:5 /MT:3 /MAXAGE:14 /UNILOG+:"C:\FileSYnc\CopyTodisk\CopyDisk.log"

#copy mdeamon config
    robocopy "E:\Backup\MdemonConfigBackup" "G:\Mdemon" /E /PURGE /COPY:DATSOU /R:3 /W:5 /MT:3 /MAXAGE:14 /UNILOG+:"C:\FileSYnc\CopyTodisk\CopyDisk.log"


#copy veeam config
    robocopy "E:\Backup\VEEAM\VeeamConfigBackup" "G:\CONFIG" *.BCO /E /PURGE /COPY:DATSOU /R:3 /W:5 /MT:3 /MAXAGE:14 /UNILOG+:"C:\FileSYnc\CopyTodisk\CopyDisk.log"

#copy veeam backups  
    $pathVeeam = "E:\Backup\VEEAM"
    New-Item -ItemType "directory" -Path "G:\VEEAM"
    $excludeDirectory = "SPPS|Backup_Exch01|VERSTKA2|Woodwing|file02|RAFT|FR001"
    $ResultDirectory = Get-ChildItem -Path $pathVeeam -Directory -Recurse | where Name -NotMatch $excludeDirectory 

    $vfiles = Get-ChildItem -Path $pathVeeam -file -Recurse -filter *.vbm  | where Name -NotMatch $excludeDirectory
    $vbms = $vfiles.fullname
    foreach($vbm in $vbms){ Copy-Item "$vbm"  "G:\VEEAM" -ErrorAction Ignore } 

    foreach($my in $ResultDirectory){
    $DirectoryTo = Get-ChildItem -Path $my.fullname -filter *.vbk | Sort-Object lastwritetime | Select-Object -last 1
    $DirectoryToCopy = $DirectoryTo.fullname
    $FilePath = $my.fullname
    $file = $DirectoryTo.name
      IF ($file -eq $null){}
    else {

    robocopy "$FilePath" "G:\VEEAM" "$file" /R:3 /W:5 /MT:3 /UNILOG+:"C:\FileSYnc\CopyTodisk\CopyDisk.log"
     }
}
#robocopy "$FilePath" "G:\VEEAM" *.vbm /R:3 /W:5 /MT:3 /LOG+:"C:\FileSYnc\CopyTodisk\CopyDisk.log"



"Files on Disk" | out-File C:\FileSYnc\CopyTodisk\CopyDisk.log -Append
(Get-ChildItem "G:\" -Recurse).FullName | out-File C:\FileSYnc\CopyTodisk\CopyDisk.log -Append
Get-PSDrive G | out-File C:\FileSYnc\CopyTodisk\CopyDisk.log -Append

	



#after backup saccess
Enable-NetAdapter -Name "Backup" -Confirm:$false
			Start-Sleep -Seconds 100
Test-Connection -ComputerName "172.254.254.1" -count '5'
            $hend = get-date
            $hend = $hend.ToString("G")
           			$hend + " END COPY DISK G:" | Out-File \\172.254.254.1\Backups\backup_logs\CopyDisk.txt -Append
						
                        " DISK G: READY" | Out-File \\172.254.254.1\Backups\backup_logs\DiskReady.txt
           Copy-Item "C:\FileSYnc\CopyTodisk\CopyDisk.log" -Destination "\\172.254.254.1\Backups\backup_logs\CopyDisk\CopyDisk.Log"
           # Send-MailMessage -From "Disaster@ction-press.ru" -To "smg@action-press.ru" -Subject "ALERT DISASTER" -Body "ALERT DISASTER: HDD READY
           #$LSdisk .
            #«амените диск в серверной 1 этажа. "
            $LASTEXITCODE = 0
            Start-Sleep -Seconds 100
			Disable-NetAdapter -Name "Backup" -Confirm:$false
			exit $LASTEXITCODE


}

  
else  {
			Enable-NetAdapter -Name "Backup" -Confirm:$false
			Start-Sleep -Seconds 100
Test-Connection -ComputerName "172.254.254.1" -count '5'
			$hend = get-date
            $hend = $hend.ToString("G")
					$hend + " INSERT DISK G:" | Out-File \\172.254.254.1\Backups\backup_logs\CopyDisk.txt -Append
            
         #   Send-MailMessage -From "Disaster@ction-press.ru" -To "smg@action-press.ru" -Subject "ALERT DISASTER" -Body "ALERT DISASTER: INSERT DISK E
         #
         #¬ставьте диск в серверной 1 этажа. "
            $LASTEXITCODE = 1
            Start-Sleep -Seconds 100
			Disable-NetAdapter -Name "Backup" -Confirm:$false
			Exit $LASTEXITCODE

}
Exit $LASTEXITCODE