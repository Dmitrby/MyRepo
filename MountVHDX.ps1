$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$Error.Clear()
#диски для проверки 
$PatchD = "\\backup01.hq.icfed.com\Share_VHDX$\MARS_WSUS.vhdx"
$PatchE = "\\backup01.hq.icfed.com\Share_VHDX$\MARS_WDS.vhdx"
$diskD="D:"
$diskE="E:"

If(!(test-path $diskE)) {Mount-DiskImage -ImagePath $PatchE -Access ReadWrite -PassThru}
If(!(test-path $diskD)) {Mount-DiskImage -ImagePath $PatchD -Access ReadWrite -PassThru}

If ($error.count -gt 0) 
	{
	exit 111
	}
	Else 
	{
	Exit
	}