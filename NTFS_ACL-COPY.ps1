
$names = Get-ChildItem -Path D:\System_Share | foreach {$_.name}
#$names = "System_Share"
foreach ($name in $names) {
$acl = Get-Acl -Path \\file02\e$\System_Share\$name
Set-Acl \\file03\d$\System_Share\$name $acl

}

