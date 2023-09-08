cls
$Error.Clear()
$erorcount= "0"
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
# Import active directory module for running AD cmdlets
Import-Module ActiveDirectory

$date = get-date -Format yyyy-MM-dd

$users = Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False -and SamAccountName -like "*_adm"} –Properties "DisplayName", "SamAccountName", "msDS-UserPasswordExpiryTimeComputed", "mail" | Select-Object -Property "Displayname",  "SamAccountName", @{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}, "mail"
#Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} –Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed", "mail", "SamAccountName"| where {!$_.mail} | Select-Object -Property "Displayname",  "SamAccountName", @{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}, "mail"

$users | Out-File -FilePath c:\temp\testusers.txt

# Define the sender, recipient, subject, and body of the email
$SMTPServer = "outlook.dtln.ru"
$SMTPPort = 587
$From = "noreply@astrasend.ru"
$Subject = "Expire password for astra.local Report on "+ $date

function share_cred {
$File = "C:\scripts\key"
$fileaes = "C:\scripts\_aes.key"
$pass = Get-Content "$File" | ConvertTo-SecureString -Key (get-content $fileaes)
$username = 'noreply@astrasend.ru'
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $pass
return $creds
}
$mailcreds = share_cred


#HTML Template
$EmailBody = @"
<table style="width: 68%" style="border-collapse: collapse; border: 1px solid #008080;">
 <tr>
    <td colspan="2" bgcolor="#008080" style="color: #FFFFFF; font-size: large; height: 35px;"> 
        Expire password for astra.local Report on VarReportDate  
    </td>
 </tr>
 <tr style="border-bottom-style: solid; border-bottom-width: 1px; padding-bottom: 1px">
    <td style="width: 201px; height: 35px"> SamAccountName</td>
    <td style="text-align: center; height: 35px; width: 233px;">
    <b>VarApproved</b></td>
 </tr>
  <tr style="height: 39px; border: 1px solid #008080">
  <td style="width: 201px; height: 39px">  Date of expire</td>
 <td style="text-align: center; height: 39px; width: 233px;">
  <b>VarRejected</b></td>
 </tr>
  <tr style="height: 39px; border: 1px solid #008080">
  <td style="width: 201px; height: 39px">  Days left until expiration</td>
 <td style="text-align: center; height: 39px; width: 233px;">
  <b>ElapsedDays</b></td>
 </tr>
</table>
"@

#Replace the Variables VarApproved, VarRejected and VarReportDate
$EmailBody= $EmailBody.Replace("VarReportDate",$date)

foreach ($user in $users){
$mailtosend = $user.mail
$passwordexpiredate =$user.ExpiryDate.ToString("yyyy-MM-dd")
$accauntname=$user.SamAccountName

if (($user.ExpiryDate.AddDays(-10).ToString("yyyy-MM-dd")) -eq $date ) {
#Replace the Variables VarApproved, VarRejected and VarReportDate
$EmailBody= $EmailBody.Replace("VarApproved",$accauntname)
$EmailBody= $EmailBody.Replace("VarRejected",$passwordexpiredate)
$EmailBody= $EmailBody.Replace("ElapsedDays",10)

$To = "$mailtosend"
Send-MailMessage -From $From -To $To -Subject $Subject -Body $EmailBody -BodyAsHtml -SmtpServer "$SMTPServer" -port "$SMTPPort" -UseSsl -Credential $mailcreds
    }

elseif (($user.ExpiryDate.AddDays(-1).ToString("yyyy-MM-dd")) -eq $date ) {
#Replace the Variables VarApproved, VarRejected and VarReportDate
$EmailBody= $EmailBody.Replace("VarApproved",$accauntname)
$EmailBody= $EmailBody.Replace("VarRejected",$passwordexpiredate)
$EmailBody= $EmailBody.Replace("ElapsedDays",1)
$To = "$mailtosend"
Send-MailMessage -From $From -To $To -Subject $Subject -Body $EmailBody -BodyAsHtml -SmtpServer "$SMTPServer" -port "$SMTPPort" -UseSsl -Credential $mailcreds

    }
}