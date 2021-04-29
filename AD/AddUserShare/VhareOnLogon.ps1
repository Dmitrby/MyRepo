$Period = "-2" 
$lastday = ((Get-Date).AddDays($Period))
$users=Get-ADUser –SearchBase “OU=User_Izdat,DC=hq,DC=icfed,DC=com” -filter {(whencreated -ge $lastday) -and (Enabled -eq $True) } | select samaccountname


#$users=Get-ADUser –SearchBase “OU=User_Izdat,DC=hq,DC=icfed,DC=com” -filter {(Enabled -eq $True)} | select samaccountname
foreach ($User in $Users){
$sam=$user.samaccountname
$HomeDir ='\\hq.icfed.com\dfs\users data$\Wdata\{0}' -f $sam; #change it with your servername and share
	
    Set-ADUser -Identity $sam -HomeDirectory $HomeDir -HomeDrive W;

    $domain=((gwmi Win32_ComputerSystem).Domain).Split(".")[0]
        
        
        if (-not (Test-Path "$homedir"))
{
    $acl = Get-Acl (New-Item -Path $homedir -ItemType Directory)

     # Make sure access rules inherited from parent folders.
    $acl.SetAccessRuleProtection($false, $true)

    $ace = "$domain\$sam","FullControl", "ContainerInherit,ObjectInherit","None","Allow"
    $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($ace)
    $acl.AddAccessRule($objACE)
 Set-ACL -Path "$homedir" -AclObject $acl

}}#Remove-Item -Path -Force
Exit