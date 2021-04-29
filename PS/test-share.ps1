function recursive($path, $max, $level = 1)
{
  $path = (Resolve-Path $path).ProviderPath
  $path
  foreach ($item in @(Get-ChildItem $path | Where {$_.PsIsContainer}))
  {
    if ($level -eq $max) { return }
    recursive $item.PSPath $max ($level + 1)
  }
}

# Сюда вписываем целевую папку
$folder = "C:\soft"

# здесь задаем уровень вложенности папок (-max №)
$folders = recursive $folder -max 3

$foldername = $folder -replace "\\", "_"
$foldername = $foldername -replace ":", ""
$result = @()

foreach ($fld in $folders)
{
  $result += (Get-ACL $fld).Access | Foreach {
  $acl = $_
  $id = $acl.IdentityReference.Value.split("\")[1]
  try {
    $obj = Get-ADObject -Filter "samaccountname -eq '$id'"
    if(!$obj) {
      $obj = [pscustomobject]@{Name = $acl.IdentityReference.Value}
    }

    [pscustomobject]@{
      Folder = $fld
      Name = $obj.Name
      IdentityReference = $acl.IdentityReference
      AccessControlType = $acl.AccessControlType
      FilesystemRights = $acl.FilesystemRights
    }
    if($obj.ObjectClass -eq "group") {
      Get-ADGroupMember $obj -Recursive | Foreach {
        [pscustomobject]@{
          Folder = $fld
          Name = $_.Name
          IdentityReference = $acl.IdentityReference
          AccessControlType = $acl.AccessControlType
          FilesystemRights = $acl.FilesystemRights
        }
      }
    }
  }
  catch {
    [pscustomobject]@{
      Folder = $fld
      Name = $acl.IdentityReference.Value
      IdentityReference = $acl.IdentityReference
      AccessControlType = $acl.AccessControlType
      FilesystemRights = $acl.FilesystemRights
    }
  }
  }
}
$result | Export-Csv -path ('C:\soft\ReportShare({0})-{1:yyyyMMddHHmm}.csv' -f $foldername,(Get-Date)) -Encoding 'UTF8' -force -NoTypeInformation -UseCulture