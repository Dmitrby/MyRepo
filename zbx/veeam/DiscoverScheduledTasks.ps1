﻿# Script: DiscoverSchelduledTasks
# Author: Romain Si
# Revision: Isaac de Moraes
# This script is intended for use with Zabbix > 3.x
#
#
# Add to Zabbix Agent
#   UserParameter=TaskSchedulerMonitoring[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent\DiscoverScheduledTasks.ps1" "$1" "$2"
#
## Modifier la variable $path pour indiquer les sous dossiers de Tâches Planifiées à traiter sous la forme "\nomDossier\","\nomdossier2\sousdossier\" voir (Get-ScheduledTask -TaskPath )
## Change the $path variable to indicate the Scheduled Tasks subfolder to be processed as "\nameFolder\","\nameFolder2\subfolder\" see (Get-ScheduledTask -TaskPath )
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
#[Console]::OutputEncoding = [Text.Encoding]::Utf8

$path = "\"

Function Convert-ToUnixDate ($PSdate) {
   $epoch = [timezone]::CurrentTimeZone.ToLocalTime([datetime]'12/31/1969 21:00')
   (New-TimeSpan -Start $epoch -End $PSdate).TotalSeconds
}

$ITEM = [string]$args[0]
$ID = [string]$args[1]

switch ($ITEM) {
  "DiscoverTasks" {
$apptasks = Get-ScheduledTask -TaskPath $path | where {$_.state -like "Ready" -and "Running"}
$apptasksok1 = $apptasks.TaskName
$apptasksok = $apptasksok1.replace('â','&acirc;').replace('à','&agrave;').replace('ç','&ccedil;').replace('é','&eacute;').replace('è','&egrave;').replace('ê','&ecirc;')
$idx = 1
write-host "{"
write-host " `"data`":[`n"
foreach ($currentapptasks in $apptasksok)
{
    if ($idx -lt $apptasksok.count)
    {
     
        $line= "{ `"{#APPTASKS}`" : `"" + $currentapptasks + "`" },"
        write-host $line
    }
    elseif ($idx -ge $apptasksok.count)
    {
    $line= "{ `"{#APPTASKS}`" : `"" + $currentapptasks + "`" }"
    write-host $line
    }
    $idx++;
} 
write-host
write-host " ]"
write-host "}"}}


switch ($ITEM) {
  "TaskLastResult" {
[string] $name = $ID
$name1 = $name.replace('&acirc;','â').replace('&agrave;','à').replace('&ccedil;','ç').replace('&eacute;','é').replace('&egrave;','è').replace('&ecirc;','ê')
$pathtask = Get-ScheduledTask -TaskPath "*" -TaskName "$name1"
$pathtask1 = $pathtask.Taskpath
$taskResult = Get-ScheduledTaskInfo -TaskPath "$pathtask1" -TaskName "$name1"
Write-Output ($taskResult.LastTaskResult)
}}

switch ($ITEM) {
  "TaskLastRunTime" {
[string] $name = $ID
$name1 = $name.replace('&acirc;','â').replace('&agrave;','à').replace('&ccedil;','ç').replace('&eacute;','é').replace('&egrave;','è').replace('&ecirc;','ê')
$pathtask = Get-ScheduledTask -TaskPath "*" -TaskName "$name1"
$pathtask1 = $pathtask.Taskpath
$taskResult = Get-ScheduledTaskInfo -TaskPath "$pathtask1" -TaskName "$name1"
$taskResult1 = $taskResult.LastRunTime
$date = get-date -date "1/1/1970"
$taskResult2 = (New-TimeSpan -Start $date -end $taskresult1).TotalSeconds
$taskResult2 = $taskResult2 - 10800 
Write-Output ($taskResult2)
}}

switch ($ITEM) {
  "TaskNextRunTime" {
[string] $name = $ID
$name1 = $name.replace('&acirc;','â').replace('&agrave;','à').replace('&ccedil;','ç').replace('&eacute;','é').replace('&egrave;','è').replace('&ecirc;','ê')
$pathtask = Get-ScheduledTask -TaskPath "*" -TaskName "$name1"
$pathtask1 = $pathtask.Taskpath
$taskResult = Get-ScheduledTaskInfo -TaskPath "$pathtask1" -TaskName "$name1"
$taskResult1 = $taskResult.NextRunTime
$date = get-date -date "1/1/1970"
$taskResult2 = (New-TimeSpan -Start $date -end $taskresult1).TotalSeconds
$taskResult2 = $taskResult2 - 10800 
Write-Output ($taskResult2)
}}

switch ($ITEM) {
  "TaskState" {
[string] $name = $ID
$name1 = $name.replace('&acirc;','â').replace('&agrave;','à').replace('&ccedil;','ç').replace('&eacute;','é').replace('&egrave;','è').replace('&ecirc;','ê')
$pathtask = Get-ScheduledTask -TaskPath "*" -TaskName "$name1"
$pathtask1 = $pathtask.State
Write-Output ($pathtask1)
}}

switch ($ITEM) {
  "AllResult" {
$Result = 0
$apptasks = Get-ScheduledTask -TaskPath $path | where {$_.state -like "Ready"}
$apptasksok1 = $apptasks.TaskName

foreach($apptasksok in $apptasksok1){
$taskResult = Get-ScheduledTaskInfo -TaskPath "$path" -TaskName "$apptasksok"

IF($taskResult.LastTaskResult -eq "267009" -or $taskResult.LastTaskResult -eq "267011" -or $taskResult.LastTaskResult -eq "2147946720")
{
$Result = $Result + 0
}
Else {$Result = $Result + $taskResult.LastTaskResult}
}

Write-Output ($Result)
}}