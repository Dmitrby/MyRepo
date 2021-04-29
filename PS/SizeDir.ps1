#cls
$c =0
$targetfolder='E:\Backup\VEEAM'
$dirs = Get-ChildItem $targetfolder -Directory -Recurse

$dirsf=$dirs.fullname

Foreach($dir in $dirsf){$A = Get-ChildItem $dir -include *.vbk  -Recurse |sort LastWriteTime | Select-Object -last 1


$b = '{0:N2}' -f ($A.Length/1Gb)

$c=$c+$b
write-host $dir - $b

}

write-host $c 
