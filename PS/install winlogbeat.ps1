$servername ="EXCH01.hq.icfed.com"
cp -Recurse "C:\Users\usertemp\Desktop\winlogbeat"    -Destination "\\$servername\c$\Program Files"


Enter-PSSession $servername
Invoke-Command -ComputerName $servername -ScriptBlock {
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\winlogbeat\install-service-winlogbeat.ps1"
Start-Service -name winlogbeat
Get-Service -Name winlogbeat
}
Exit-PSSession
