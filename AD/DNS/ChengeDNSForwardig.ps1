#DNS Forwarding no domen

$ALLPC = Get-ADComputer -Filter * | Where-Object {$_.DNSHostName -like "dc-*"}| foreach {$_.DNSHostName}

foreach ($Server in $ALLPC){


$Server
Enter-PSSession $Server | Out-Null

    Invoke-Command -ComputerName $Server -ScriptBlock {




    Add-DnsServerConditionalForwarderZone -Name “amedia.loc” -MasterServers 10.5.200.5,10.5.200.6,10.5.200.7 -PassThru

#Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones\'
get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones\amedia.loc'

#Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones\amedia.loc' -name "MasterServers" -Value "10.5.200.6
#10.5.200.5
#10.5.200.7"

#restart-Service -Name DNS
#get-Service -Name DNS




    } # close invoke

Exit-PSSession

} #CLOSE  foreach