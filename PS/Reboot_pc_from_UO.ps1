$pclist = Get-ADComputer -filter {OperatingSystem -Like '*10*' } -searchbase 'OU=Computers_YAR,OU=Computers_CRM,DC=action-crm,DC=local' | sort DNSHostName | FT name

write-host "Start-Sleep -s 8000"
Start-Sleep -s 8000

Foreach ($pc in $pslist)
{
Restart-Computer -ComputerName $_ -Force
}

