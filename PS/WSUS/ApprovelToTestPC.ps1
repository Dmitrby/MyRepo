cls
#$data = (Get-Date).adddays(-100)
#Get-WsusUpdate  -Approval Unapproved -Status Needed | Where-Object { ($_.Update.CreationDate -lt $data) -and ($_.update.isdeclined -ne $true) -and ({$_.update.title -ilike "*Windows*" -or $_.update.title -ilike "*Office*"})} | Approve-WsusUpdate -Action Install -TargetGroupName "TestPC"
#Get-WsusUpdate -Classification All -Approval Unapproved | Where-Object { ($_.Update.CreationDate -lt $data) -and ($_.update.isdeclined -ne $true) -and ({$_.update.title -ilike "*Windows*" -or $_.update.title -ilike "*Office*"})} | Approve-WsusUpdate -Action Install -TargetGroupName "TestPC"

#Get-WsusUpdate |Where-Object {$_.Classification -notmatch "Upgrades*"}

#Get-WsusUpdate -Approval Unapproved -Status Needed  |Where-Object { ($_.Update.CreationDate -lt $data) -and ($_.update.isdeclined -ne $true) -and ({$_.update.title -ilike "*Windows*" -or $_.update.title -ilike "*Office*"}) -and ($_.Classification -notmatch "Upgrades*")} | Approve-WsusUpdate -Action Install -TargetGroupName "TestPC"



Get-WsusUpdate -Approval Unapproved -Status Needed  | Approve-WsusUpdate -Action Install -TargetGroupName "TestPC"