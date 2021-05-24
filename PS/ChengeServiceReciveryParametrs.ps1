$ErrorActionPreference = 'SilentlyContinue'
$Servers = Get-ADComputer -Server hq.icfed.com -filter {(OperatingSystem -Like '*server *') } -Property * |where {$_.enabled -eq "True"}  |ForEach-Object {$_.DNSHostName}|Sort-Object

foreach($Server in $Servers){
$test = Test-Connection $Server -Quiet -Count 2
if ($test -eq $false) {Write-Host "$Server is down" -ForeGroundColor RED}

$error.clear()
Enter-PSSession $Server | Out-Null
if ($error.Count -gt 0){ #adter the commands

    Write-Host "$server error connection -ForeGroundColor RED"

}

Invoke-Command -ComputerName $Server -ScriptBlock {

sc.exe failure "FusionInventory-Agent" actions= restart/180000/restart/180000/restart/180000 reset= 86400;
Start-Service -Name FusionInventory-Agent
}
Exit-PSSession
}
