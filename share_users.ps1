#SEARCH DIRECTORY
$share = "\\spps.action-crm.local\Report\Актион-пресс\00_ОТЧЕТЫ"

#RESULT PATH
$Result ="\\crm00111.action-crm.local\soft\FolderReport.csv"

(Get-ACL $share).Access  | Foreach {
	$acl = $_
	$id = $acl.IdentityReference.Value.split("\")[2]
	try {
		$obj = Get-ADObject -Filter "samaccountname -eq '$id'"
		if(!$obj) {
			$obj = [pscustomobject]@{Name = $acl.IdentityReference.Value}
		}
		
		[pscustomobject]@{
			Name = $obj.Name
			IdentityReference = $acl.IdentityReference
			AccessControlType = $acl.AccessControlType
			FilesystemRights  = $acl.FilesystemRights
		}
#		if($obj.ObjectClass -eq "group") {
#			Get-ADGroupMember $obj -Recursive | Foreach {
#				[pscustomobject]@{
#					Name = $_.Name
#					IdentityReference = $acl.IdentityReference
#					AccessControlType = $acl.AccessControlType
#					FilesystemRights  = $acl.FilesystemRights
#				}
#			}
#		}
	}
	catch {
		[pscustomobject]@{
			Name = $acl.IdentityReference.Value
			IdentityReference = $acl.IdentityReference
			AccessControlType = $acl.AccessControlType
			FilesystemRights  = $acl.FilesystemRights
		}
	}
} | Export-Csv -Encoding UTF8 -Path $Result -Delimiter ";" -NoTypeInformation