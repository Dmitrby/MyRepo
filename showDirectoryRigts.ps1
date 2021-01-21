$TargetDir = "\\mediafs1\DigitalMarketing" 

Get-ChildItem $TargetDir -Depth 1 | where {$_.attributes -like "Directory*"} | Foreach {
$group = (Get-ACL $_.Fullname).AccessToString

Write-Host "Каталог: " $_.Fullname
Write-Host "$group"
write-host "------------------------------------------------------------------"
}
