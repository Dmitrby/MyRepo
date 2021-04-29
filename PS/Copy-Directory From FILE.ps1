$Patch="\\file03"
$localpatch="d:"

$folders = (Get-ChildItem -Directory -Depth 0 -Path "$Patch\d$").name
#d:\
Foreach ($folder in $folders) {

new-item -ItemType "directory" -Name $folder -Path $localpatch\
$acl = Get-Acl -Path $Patch\d$\$folder
Set-Acl $localpatch\$folder $acl
}
