$servername = "dc-smr"
Copy-Item -Recurse "C:\Program Files\winlogbeat" -Destination "\\$servername\c$\Program Files\winlogbeat"
Enter-PSSession $servername

Invoke-Command -ComputerName $servername -ScriptBlock {

   powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\winlogbeat\install-service-winlogbeat.ps1"

 Start-Service -name winlogbeat
   Get-Service -Name winlogbeat


}
Exit-PSSession 
