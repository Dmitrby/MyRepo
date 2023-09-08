$WsusServerFqdn='0rumgr.moskvich.ru'

$WsusSourceGroup = 'TestPC'
$WsusTargetGroup = 'FactoryPC'

[void][reflection.assembly]::LoadWithPartialName('Microsoft.UpdateServices.Administration')
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer( $WsusServerFqdn, $False, '8530')
$Groups = $wsus.GetComputerTargetGroups()
$WsusTargetGroupObj = $Groups | Where {$_.Name -eq $WsusTargetGroup}
$WsusSourceGroupObj = $Groups | Where {$_.Name -eq $WsusSourceGroup}
$Updates = $wsus.GetUpdates()
$i = 0
ForEach ($Update in $Updates)
{
if ($Update.GetUpdateApprovals($WsusSourceGroupObj).Count -ne 0 -and $Update.GetUpdateApprovals($WsusTargetGroupObj).Count -eq 0)
{
$i ++
Write-Host ("Approving" + $Update.Title)
$Update.Approve('Install',$WsusTargetGroupObj) | Out-Null
}
}
Write-Output ("Approved {0} updates for target group {1}" -f $i, $WsusTargetGroup)