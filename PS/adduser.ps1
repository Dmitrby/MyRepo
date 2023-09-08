#"\\babylon.afm.renault.ru\AD\Org.csv"
cls
$Error.Clear()
$erorcount= "0"
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
# Import active directory module for running AD cmdlets
Import-Module ActiveDirectory
# Store the data from NewUsersFinal.csv in the $ADUsers variable
$UPN = "@moskvich.ru"
$Dismissed = "OU=Dismissed,OU=Employees,DC=moskvich,DC=ru"
$date = Get-Date -format yyyy.MM.dd
$time = Get-Date -Format HH.mm.ss
$logfile = "C:\OLD_ADU\addedusers\$date.logUseradd.csv"  
$Errorlog = "C:\OLD_ADU\Error\$date.Errorlog .csv"

$OU="OU=Test,OU=Employees,DC=moskvich,DC=ru"

#org.csv to trim
$fileDir = "\\fl.moskvich.ru\dfs\AD\Org.csv"
$trimfile = Import-Csv $fileDir -Delimiter ':' | select IPN, Surname, Name, ORG_TEXT_RU, EMAIL_short, MOBILEPHONE, ADDITIONALPHONE, FONC_RU, NAME_RU_ORG, IsActive, Patro
$trimfile | Export-Csv C:\OLD_ADU\trim\$date-$time.csv -Delimiter : -NoTypeInformation

#variable for compare
$filenew=Get-Content -Path "C:\OLD_ADU\trim\$date-$time.csv"
$fileoldpath=(Get-ChildItem  C:\OLD_ADU\Log | sort LastWriteTime | select -Last 1).FullName
$fileold=Get-Content  -Path $fileoldpath
$fileresult = "C:\OLD_ADU\Compare_log\$date-$time.result.csv"
#$zagolovoc="ORG_ORG:ORG_PORG:NAME_RU_ORG:NGEN_ORG:TABNUM:IPN:FIO_RU:FIO_FR:ORG:FONC_RU:IS_MANAGER:MOBILEPHONE:ADDITIONALPHONE:TabNumRM:OrgJoin:OrgJoinRUS:CdG:room:Photo:AnalT1:CATEGORY:TABNUM_CROSS_MANAGER:IPN_CROSS_MANAGER:WERKS:PLANT:ORG_TEXT_EN:ORG_TEXT_RU:EMAIL_short:email:Surname:Name:Patro:Surname_EN:Name_EN:IsActive"
$zagolovoc="IPN:Surname:Name:ORG_TEXT_RU:EMAIL_short:MOBILEPHONE:ADDITIONALPHONE:FONC_RU:NAME_RU_ORG:IsActive:Patro"
$zagolovoc | Out-File $fileresult



<#
function share_cred {

#generate aes key
$File = "C:\OLD_ADU\key"
$fileaes = "C:\OLD_ADU\_aes.key"
$AESKey = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)
$AESKey | out-file c:\temp\_aes.key
#generate key file
$Cred = Get-Credential
$Cred.Password| ConvertFrom-SecureString -Key (get-content $fileaes)| Set-Content $File

#execute key file
$File = "C:\OLD_ADU\key"
$fileaes = "C:\OLD_ADU\_aes.key"
$pass = Get-Content "$File" | ConvertTo-SecureString -Key (get-content $fileaes)

$username = 'afm\pu04984'
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $pass
return $creds
}

$mycreds = share_cred

$Dest   = "\\fl.moskvich.ru\dfs\AD"
New-PSDrive -Name J -PSProvider FileSystem -Root $Dest -Credential $mycreds -Persist
Copy-Item -Path "j:\Org.csv" -Destination "C:\OLD_ADU\Log\$date.$time.csv"

$ADUsers = Import-Csv "j:\Org.csv" -Delimiter ':'
Remove-PSDrive J
#>

#chek file data
$fileData=Get-ChildItem "\\fl.moskvich.ru\dfs\AD\Org.csv" | foreach {$_.LastWriteTime}
if ($fileData -gt (get-date).AddHours(-20)){} else {exit}

### compare
#foreach($string in $filenew){
#$compareline = Select-String -Path $fileoldpath -Pattern $string
#if($compareline -eq $null) {$string | Out-File $fileresult -Append}
#}

foreach($string in $filenew){
$compareline = Select-String -Path $fileoldpath -Pattern $string
if($compareline -eq $null){
      if (($string.Split(":")[-1]) -eq 'False'){
       $ifuser = $string.Split(":")[5]
       $IFstring=select-String -Path $fileDir -Pattern "$ifuser" -CaseSensitive| select -Last 1
            if ($IFstring -like '*:False') {
            $string | Out-File $fileresult -Append}
     }else {$string | Out-File $fileresult -Append}
}
#####

}





#$ADUsers = Import-Csv "\\fl.moskvich.ru\dfs\AD\Org.csv" -Delimiter ':'
$ADUsers = Import-Csv $fileresult -Delimiter ':'
Copy-Item -Path "\\fl.moskvich.ru\dfs\AD\Org.csv" -Destination "C:\OLD_ADU\source\$date-$time.csv"
Copy-Item -Path "C:\OLD_ADU\trim\$date-$time.csv" -Destination "C:\OLD_ADU\Log\$date-$time.csv"

# pass gen
function global:PassGen {
#   Add-Type -AssemblyName System.Web
#  $pass = [System.Web.Security.Membership]::GeneratePassword(6,0)
#  $charsUpper=65..90| Get-Random -Count 1  | %{ [Char] $_ }
#  $charsLower=97..122| Get-Random -Count 1  | %{ [Char] $_ }
#  $charsNumber=48..57| Get-Random -Count 1  | %{ [Char] $_ }
#  #$charsSymbol=35,36,40,41,42,44,45,46,47,58,59,63,64,92,95| Get-Random -Count 1  | %{ [Char] $_ }
#  $charsSymbol=35,36,64,95| Get-Random -Count 1  | %{ [Char] $_ }
#  return $charsUpper+$pass+$charsNumber+$charsLower
    $length = 4
    #$charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789{]+-[*=@:)}$^%;(_!&amp;#?>/|.'.ToCharArray()
    $charSet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.ToCharArray()
    $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $bytes = New-Object byte[]($length)
    $rng.GetBytes($bytes)
    $result = New-Object char[]($length)
    for ($i = 0 ; $i -lt $length ; $i++) {
        $result[$i] = $charSet[$bytes[$i]%$charSet.Length]
    }
    $charsUpper=65..90| Get-Random -Count 1  | %{ [Char] $_ }
    $charsLower=97..122| Get-Random -Count 1  | %{ [Char] $_ }
    $charsNumber=48..57| Get-Random -Count 1  | %{ [Char] $_ }
    $charsSymbol=35,36,64,95| Get-Random -Count 1  | %{ [Char] $_ }

    $result= (-join $result)
    return $charsUpper+$result+$charsSymbol+$charsNumber+$charsLower

}#end function global:PassGen

# serach OU function
function global:OUsearch{
param([string]$inString)
if([bool] (Get-ADOrganizationalUnit -Filter * | ? {$_.Distinguishedname -eq $inString} ))
{ return 1}
 else { return 0} 
}#end function global:OUsearch
# create OU function
function global:Create{
    param([string]$OUName)
        $create = $searh  = "OU=Employees,DC=moskvich,DC=ru" # начальная OU для создания ерархии
            if (OUsearch($OUName) -eq 1) {} 
                else {$path1 = $OUName.split(",")
                      $i =$path1.count -4  #так как с 0 нужно отнять 4 (3 элемента)
                      $count =0
                        while($i -ge $count)
                            {$result=$path1[$i]
                                $searh = "$result"+",$searh"
                                $text=$result.trim("OU=")

                               if (OUsearch($searh) -eq 1) {} else { New-ADOrganizationalUnit -name $text.Trim() -Path "$create"}
                                $create= "$result"+",$create"
                                $i -=1
                        }# end while
                }#end if
}#end function global:Create
# check username unic
function global:SName{
    param([string]$userNameUnic)
            $z =1
            while ($z -ne 0){
            if([bool](Get-ADUser -Properties * -filter * |where {$_.Name -like "$userNameUnic"}) ){$userNameUnic = "$userNameUnic"+"_"}else { $z = 0 }
            }
            return $userNameUnic
}#end function SName
# add IPON -password to SQL
function global:addToSql($username, $password) {
	$server = "hanuman.moskvich.ru"
	$database = "DIO"
	$sql = "exec DIO.[dbo].[AFM_MOSKVICH_FIRST_LOGIN_INIT] @IPN = $username,@PWD = $password"
	#$sql = "SELECT * FROM AFM_MOSKVICH_FIRST_LOGIN WHERE IPN = 'pu05071'"
	$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
	$SqlConnection.ConnectionString = "Server=$server;Database=$database;Integrated Security=True"
	$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
	$SqlCmd.CommandText = $sql
	$SqlCmd.Connection = $SqlConnection
	$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
	$SqlAdapter.SelectCommand = $SqlCmd
	$DataSet = New-Object System.Data.DataSet
	$SqlAdapter.Fill($DataSet)
	$SqlConnection.Close()
	#$DataSet.Tables[0]  #вывод действий
}

<#
FOREACH ($addou in $ADUsers){
    $OU = $addou.ORG_TEXT_RU
    create $OU }
#>

# Loop through each row containing user details in the CSV file
foreach ($User in $ADUsers) {
    #Read user data from each field in each row and assign the data to a variable as below
    $username = $User.IPN.tolower().Trim()
    $firstname = $User.Surname.substring(0,1).toupper()+$User.Surname.substring(1).tolower()
    $lastname = $User.Name
    ##check if only name in FIO
    if($lastname -eq ""){$lastname=$firstname}else{$lastname=$lastname.substring(0,1).toupper()+$lastname.substring(1).tolower()}

    $OU = $User.ORG_TEXT_RU
    #chek mail entry
    if(($User.EMAIL_short.tolower() -eq $null) -or ($User.EMAIL_short.tolower() -eq ".") -or ($User.EMAIL_short.tolower() -eq "-") -or ($User.EMAIL_short.tolower() -eq "Empty") -or ($User.EMAIL_short.tolower() -eq "creation")){$email = " "} else {$email = $User.EMAIL_short.tolower()+"@moskvich-auto.ru"}
    #chek mobile number
    if($User.MOBILEPHONE -eq ""){$telephone = " "} else {$telephone = "8"+$User.MOBILEPHONE}
    if($User.ADDITIONALPHONE -eq ""){$OfficePhone = " "} else {$OfficePhone = $User.ADDITIONALPHONE}
    if($User.FONC_RU -eq ""){$jobtitle = " "} else {$jobtitle = $User.FONC_RU}
    $department = $User.NAME_RU_ORG.toupper()
    $IsActive = $User.IsActive
    if($User.Patro -eq ""){$fathername = "     "} else {$fathername = $User.Patro.substring(0,1).toupper()+$User.Patro.substring(1).tolower()}
    
    $SName = "$firstname $lastname"
    $DisplayName ="$firstname $lastname $fathername"

    ##check OU EXTERNALS PATH
    if ($OU -match "OU=EXTERNAL,DC=Moskvich,DC=ru"){$OU=$OU.replace("OU=EXTERNAL,DC=Moskvich,DC=ru","OU=EXTERNAL,OU=Employees,DC=Moskvich,DC=ru")}


    #check data to add usr
    if (($username -eq "") -or ($username[0] -match '[0-9]')){}
    else {

        #cheak Enable $ Disable
        if ($IsActive -eq "false") { Get-ADUser -Identity $username | Move-ADObject -TargetPath "$Dismissed";Set-ADUser -Identity $username -Enabled $false }
        else {

            # Check to see if the user already exists in AD
            if (Get-ADUser -F { SamAccountName -eq $username }) {

                try{

                # If user does exist, give a warning
                #Write-Warning "Add change"
                 #   Change user name
                 $chName = SName($sname)
                if ((Get-ADUser $username | foreach {$_.Name}) -ne $SName) {Get-ADUser $username | Rename-ADObject -NewName $chName}

                Set-ADUser -Identity $username `
                    -GivenName $firstname `
                    -Surname $lastname `
                    -Enabled $True `
                    -DisplayName "$DisplayName" `
                    -MobilePhone $telephone `
                    -OfficePhone $OfficePhone `
                    -EmailAddress $email `
                    -Title $jobtitle

                    #create OU if need
                    create $OU
                    #move to OU
                    Write-Host "$OU"
                    Get-ADUser -Identity $username | Move-ADObject -TargetPath "$OU" # move too OU
                   }
                    
                   catch
                   {

                    "$date; $username; error change " | Out-File -Encoding "UTF8" $Errorlog -Append

                   }

                   # reset variable
                   $firstname = $lastname = $DisplayName = $telephone = $OfficePhone = $UO = $email = $department = $jobtitle = $sname =  $null


            } #end if change
            else {

                # User does not exist then proceed to create the new user account
               $SName = SName ("$SName")
                #create OU if need
                create $OU
                $password = PassGen
                New-ADUser `
                    -SamAccountName $username `
                    -UserPrincipalName "$username$UPN" `
                    -Name "$SName" `
                    -GivenName $firstname `
                    -Surname $lastname `
                    -Enabled $True `
                    -DisplayName $DisplayName `
                    -MobilePhone $telephone `
                    -OfficePhone $OfficePhone `
                    -EmailAddress $email `
                    -Title $jobtitle `
                    -Path "$OU" `
                    -AccountPassword (ConvertTo-secureString $password -AsPlainText -Force) -ChangePasswordAtLogon $True
                    # -Department $department `
                    #write log to file
                    "$date; $username; $DisplayName; $password" | Out-File -Encoding "UTF8" $logfile -Append
                    #add user to SQL
                    addToSql $username $password
                   # reset variable
                   $firstname = $lastname = $DisplayName = $telephone = $OfficePhone = $UO = $email = $department = $jobtitle = $sname =  $null

            }#end else create

        }#end else $IsActive
    }#eds else check usr


 If ($Error.count -gt $erorcount){$erorcount=$Error.count; "$date; $username; error detected " | Out-File -Encoding "UTF8" $Errorlog -Append  }

}# end foreach 

Get-ADUser -SearchBase "OU=Employees,DC=moskvich,DC=ru" -filter "Enabled -eq '$true' " |set-aduser -replace @{msnpallowdialin=$true}

Write-Host "Errors=" $Error.count

If ($Error.count -gt "0"){$error | Out-File -Encoding "UTF8" $Errorlog -Append}

set-ADUser pu04984 -Enabled $true

#exit $Error.count
