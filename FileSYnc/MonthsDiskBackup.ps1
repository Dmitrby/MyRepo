#[Console]::outputEncoding = [System.Text.Encoding]::GetEncoding('cp866')
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$Paths = "E:\SQL\SQL-NODE2.action-crm.local\db.mssql.prod.crm.AHello\FULL", "E:\SQL\SQL-NODE2.action-crm.local\db.mssql.prod.crm.ActionCRM_MSCRM_MOVED\FULL", "E:\SQL\SQL-NODE2.action-crm.local\db.mssql.prod.crm.ActionInternal\FULL", "E:\SQL\SQL-NODE2.action-crm.local\db.mssql.prod.crm.Loyalty\FULL", "E:\SQL\SQL-NODE2.action-crm.local\db.mssql.prod.crm.MSCRM_CONFIG\FULL", "E:\SQL\SQL-NODE1.action-crm.local\db.mssql.prod.crm.APress_MSCRMAnalysis\FULL"

$RemovePath = "F:\*.bak"
$disk = Test-Path F:\
$hstart = get-date
$hstart = $hstart.ToString("G")
$LSdisk = ls F:\ -recurse

#############################################################################
if ($disk -eq 'true') {

	Enable-NetAdapter -Name "Backup" -Confirm:$false
	Start-Sleep -Seconds 100
    Test-Connection -ComputerName '172.254.254.1' -count '3'
	$hstart + " START COPY DISK F:" | Out-File \\172.254.254.1\Backups\backup_logs\CopyDisk_30_days_Log.txt -Append
	Disable-NetAdapter -Name "Backup" -Confirm:$false
		Start-Sleep -Seconds 15
			
		# Удаляем файл 
	
		Remove-Item -path $RemovePath -Force | Out-Null
		Start-Sleep -Seconds 15
		#копирование


		foreach ($cpath in $paths){
		
				$scan = Get-Childitem $cpath -Recurse -force  | Sort-Object lastwritetime | Select-Object -first 1
	
		Copy-Item -Path "$cpath\$scan" -Destination "F:\"
				
			}
    Start-Sleep -Seconds 15

		Enable-NetAdapter -Name "Backup" -Confirm:$false
			Start-Sleep -Seconds 15
            Test-Connection -ComputerName '172.254.254.1' -count '3'
            $hend = get-date
            $hend = $hend.ToString("G")
		$hend + " END COPY DISK F:" | Out-File \\172.254.254.1\Backups\backup_logs\CopyDisk_30_days_Log.txt -Append
			$LSdisk | Out-File \\172.254.254.1\Backups\backup_logs\CopyDisk_30_days_Log.txt -Append
			
            Start-Sleep -Seconds 15
			Disable-NetAdapter -Name "Backup" -Confirm:$false


}

else  {
			Enable-NetAdapter -Name "Backup" -Confirm:$false
			Start-Sleep -Seconds 15
            Test-Connection -ComputerName '172.254.254.1' -count '3'
			$hend = get-date
            $hend = $hend.ToString("d")
			$hend + " INSERT DISK F:" | Out-File \\172.254.254.1\Backups\backup_logs\CopyDisk_30_days_Log.txt -Append
			Disable-NetAdapter -Name "Backup" -Confirm:$false
			Exit

}
Exit