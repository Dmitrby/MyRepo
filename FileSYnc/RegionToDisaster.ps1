#[Console]::outputEncoding = [System.Text.Encoding]::GetEncoding('cp866')
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

$ErrorActionPreference = "SilentlyContinue" 
$hstart = get-date
$hstart = $hstart.ToString("G")
$ToDisk = Get-ScheduledTask ToDisk| foreach {$_.State}
$Date = get-date -Format "dd.MM.yyyy"
$LogDate ="$Date"
##########################################################################################################

IF ($ToDisk -eq 'Running') {
     DO {
    $ToDisk = Get-ScheduledTask ToDisk| foreach {$_.State}
    Start-Sleep -Seconds 1800
        } Until ($ToDisk -eq 'Ready')
}

#	enable interface
Enable-NetAdapter -Name "Backup" -Confirm:$false
Start-Sleep -Seconds 30
Test-Connection -ComputerName "172.254.254.1" -count '5'
Start-Sleep -Seconds 77

        $hstart + " START JOB" | Out-File \\172.254.254.1\Backups\backup_logs\RegionsSyncLog.txt -Append

        robocopy "\\172.254.254.1\Backups\Backup\RegionShara" "E:\Backup\RegionShara" /E /PURGE /NOCOPY /XF *.avi *.exe /R:3 /W:5 /MT:30 /UNICODE /UNILOG+:\\172.254.254.1\Backups\backup_logs\Todisaster\"$LogDate"_Todisaster_Regions.log

            $hend = get-date
            $hend = $hend.ToString("G")
			$hend + " END JOB" | Out-File \\172.254.254.1\Backups\backup_logs\RegionsSyncLog.txt -Append
            "END OK" | Out-File \\172.254.254.1\Backups\backup_logs\END_Regions_ToDisaster.txt
			Disable-NetAdapter -Name "Backup" -Confirm:$false
            $LASTEXITCODE = 0


Exit $LASTEXITCODE