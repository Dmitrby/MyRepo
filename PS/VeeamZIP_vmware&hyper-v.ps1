# Author: Vladimir Eremin
# Created Date: 3/24/2015
# http://forums.veeam.com/member31097.html
# 
$Error.Clear()
##################################################################
#                   User Defined Variables
##################################################################

# Names of VMs to backup separated by comma (Mandatory). For instance, $VMNames = “VM1”,”VM2”
$VMNames = 'машин'

# Name of vCenter or standalone host VMs to backup reside on (Mandatory)
$HostName = 'сервер'

# Directory that VM backups should go to (Mandatory; for instance, C:\Backup)
$Directory = "\\***\$VMNames"

# Desired compression level (Optional; Possible values: 0 - None, 4 - Dedupe-friendly, 5 - Optimal, 6 - High, 9 - Extreme) 
$CompressionLevel = "5"

# Quiesce VM when taking snapshot (Optional; VMware Tools are required; Possible values: $True/$False)
$EnableQuiescence = $True

# Protect resulting backup with encryption key (Optional; $True/$False)
$EnableEncryption = $False

# Encryption Key (Optional; path to a secure string)
$EncryptionKey = ""

# Retention settings (Optional; By default, VeeamZIP files are not removed and kept in the specified location for an indefinite period of time. 
# Possible values: Never , Tonight, TomorrowNight, In3days, In1Week, In2Weeks, In1Month, In3Months, In6Months, In1Year)
$Retention = "In1Month"

# Type of VM (Hyper-v/VMware)
$Type = "Hyper-v"
#
##################################################################
#                   Notification Settings
##################################################################

# Enable notification (Optional)
$EnableNotification = $True

# Email SMTP server
$SMTPServer = "смтп"

# Email FROM
$EmailFrom = "VeeamZIP@" 

# Email TO
$EmailTo = "кому"

# Email subject
$EmailSubject = "VeeamZIP $VMNames"

##################################################################
#                   Email formatting 
##################################################################

$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

##################################################################
#                   End User Defined Variables
##################################################################

#################### DO NOT MODIFY PAST THIS LINE ################
Asnp VeeamPSSnapin

$Server = Get-VBRServer -name $HostName
$MesssagyBody = @()

foreach ($VMName in $VMNames)
{

	if ($Type -eq "Hyper-v")
	{$VM = Find-VBRHvEntity  -Server $Server -Name $VMName}
	else{$VM = Find-VBRViEntity  -Server $Server -Name $VMName}
  
  If ($EnableEncryption)
  {
    $EncryptionKey = Add-VBREncryptionKey -Password (cat $EncryptionKey | ConvertTo-SecureString)
    $ZIPSession = Start-VBRZip -Entity $VM -Folder $Directory -Compression $CompressionLevel -DisableQuiesce:(!$EnableQuiescence) -AutoDelete $Retention -EncryptionKey $EncryptionKey
  }
  
  Else 
  {
    $ZIPSession = Start-VBRZip -Entity $VM -Folder $Directory -Compression $CompressionLevel -DisableQuiesce:(!$EnableQuiescence) -AutoDelete $Retention
  }
  
  If ($EnableNotification) 
  {
    $TaskSessions = $ZIPSession.GetTaskSessions().logger.getlog().updatedrecords
    $FailedSessions =  $TaskSessions | where {$_.status -eq "EWarning" -or $_.Status -eq "EFailed"}

  
  if ($FailedSessions -ne $Null)
  {
	$MesssagyBody = ("$VMNames $HostName Backup_NOT_Created").trim() | ConvertFrom-String -PropertyNames VM,HOST,ERROR
    $MesssagyBody = $MesssagyBody + ($ZIPSession | Select-Object @{n="Name";e={($_.name).Substring(0, $_.name.LastIndexOf("("))}} ,@{n="Start Time";e={$_.CreationTime}},@{n="End Time";e={$_.EndTime}},Result,@{n="Details";e={$FailedSessions.Title}})
	
	If ($EnableNotification)
	{
	$Message = New-Object System.Net.Mail.MailMessage $EmailFrom, $EmailTo
	$Message.Subject = $EmailSubject
	$Message.IsBodyHTML = $True
	$message.Body = $MesssagyBody | ConvertTo-Html -head $style | Out-String
	$SMTP = New-Object Net.Mail.SmtpClient($SMTPServer)
	$SMTP.Send($Message)
	}
  
  }
   
  Else
  {

    #$MesssagyBody = $MesssagyBody + ($ZIPSession | Select-Object @{n="Name";e={($_.name).Substring(0, $_.name.LastIndexOf("("))}} ,@{n="Start Time";e={$_.CreationTime}},@{n="End Time";e={$_.EndTime}},Result,@{n="Details";e={($TaskSessions | sort creationtime -Descending | select -first 1).Title}})
	
  }   
}
}

	If ($error.count -gt 0) 
	{
	
	$Message = New-Object System.Net.Mail.MailMessage $EmailFrom, $EmailTo
	$Message.Subject = $EmailSubject
	$Message.IsBodyHTML = $True
	$message.Body = (("$VMNames $HostName Backup_NOT_Created").trim() | ConvertFrom-String -PropertyNames VM,HOST,ERROR) | ConvertTo-Html -head $style | Out-String
	$SMTP = New-Object Net.Mail.SmtpClient($SMTPServer)
	$SMTP.Send($Message)
		
	exit 111
	}
	Else 
	{
	Exit
	}