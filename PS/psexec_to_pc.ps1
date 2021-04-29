#$pc = Get-ADComputer -SearchBase "OU=Computers_KRD,OU=Computers_CRM,DC=action-crm,DC=local" -filter *| sort name| ForEach-Object { $(foreach ($prop in 'Name') { $_.$prop }) }
$pc = "ULA123"
#$pc = "KRD001"
$Creds = Get-Credential
foreach ($computer in $pc){

write-host  $computer  
    
   if (test-Connection -Cn $computer -quiet) {
   write-host "$computer is online" -BackgroundColor DarkGreen

   xcopy \\crm.action-crm.local\CallCenter\RemoteHelp\Symantec\SylinkDrop \\$computer\c$\temp /H /Y /C /R /S /I
   
   Invoke-psexec -ComputerName $computer -Credential $creds -command 'c:\temp\ToHQ.bat' 

   } 
   else {
   write-host  "$computer is not online" -BackgroundColor DarkCyan
   }
}






