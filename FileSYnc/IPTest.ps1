$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$SyncToDisaster = Get-ScheduledTask SyncToDisaster| foreach {$_.State}
$ToDisk = Get-ScheduledTask ToDisk| foreach {$_.State}
$disk_30days = Get-ScheduledTask disk_30days| foreach {$_.State}

DO {
Start-Sleep -Seconds 300
IF ($ToDisk -eq 'Running') { $a=0}
    else {$a=1}
   
IF ($SyncToDisaster -eq 'Running') { $b=0}
    else {$b=1}


IF ($disk_30days -eq 'Running') { $c=0}
    else {$c=1}
    Write-host $a+$b+$c
 } Until ($a+$b+$c -eq 3)

Enable-NetAdapter -Name "Backup" -Confirm:$false
Start-Sleep -Seconds 200
IF(Test-Connection -Count '2' -ComputerName '172.254.254.1' -Quiet -ErrorAction Ignore) {Write-Host "yes"}
Else {
Disable-NetAdapter -Name "Backup" -Confirm:$false
Start-Sleep -Seconds 30
Restart-Computer -Force -Wait 0
}
Disable-NetAdapter -Name "Backup" -Confirm:$false
Start-Sleep -Seconds 30
exit