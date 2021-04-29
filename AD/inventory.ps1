$ErrorActionPreference = 'SilentlyContinue'
#IF need all servers in ad
$servers = Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*' } -Properties DNSHostName|Select DNSHostName -ExpandProperty DNSHostName

#IF need multiple servers 
#$servers = "srvvm-001"

# Directory for saving report
$domain = $env:USERDOMAIN
$date=Get-Date -UFormat "%m/%d/%Y" 
$filedate= $date -replace '/', '.'
$ResultPatch = "\\crm00111.action-crm.local\soft\Invent\Servers_$domain-$filedate.txt"

# mark the server on which there was a connection
Write-Host "Server info List" -ForeGroundColor Green



foreach ($Server in $servers) {

$test = Test-Connection $Server -Quiet -Count 2
if ($test -eq $false) {Write-Host "$Server is down" -ForeGroundColor RED}

$error.clear()
Enter-PSSession $Server | Out-Null
if ($error.Count -gt 0){ #adter the commands
    
    Write-Host "$servers error connection -ForeGroundColor RED"

}

Invoke-Command -ComputerName $Server -ScriptBlock {

$Server

"Network Name | OS | x64/32 | Version | S/n"
Get-WmiObject Win32_OperatingSystem | select-object csname, caption, Serialnumber, Version, OSArchitecture | ForEach-Object {$_.csname +"   |"+ $_.caption +"   |"+ $_.OSArchitecture +"   |"+ $_.Version+"   |"+ $_.Serialnumber}

"System Name | Vendor | S/n | UUID"
Get-WmiObject Win32_ComputerSystemProduct | select-object Name, Vendor, IdentifyingNumber, UUID | ForEach-Object {$_.name +"   |"+ $_.vendor +"   |"+ $_.IdentifyingNumber +"   |"+ $_.UUID} 

"Processor| Socket | Description"  
Get-WmiObject Win32_Processor | select-object name, SocketDesignation, Description | ForEach-Object {$_.name +"   |"+ $_.SocketDesignation +"   |"+ $_.Description} 

"Matherboard Manufacture | Product | S/n" 
Get-WmiObject Win32_BaseBoard | select-object Manufacturer, Product, SerialNumber | ForEach-Object {$_.Manufacturer +"   |"+ $_.Product +"   |"+ $_.SerialNumber} 

"HDD Model| Partitions | Size GB | Interface type" 
Get-WmiObject Win32_DiskDrive | select-object Model, Partitions, Size, interfacetype | ForEach-Object {$_.Model +"   |"+ $_.Partitions +"   |"+ ($_.Size/1GB).tostring("F00") +"   |"+ $_.interfaceType}

"HDD Name| FileSystem| Size GB| FreeSpace"
Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | select-object DeviceID, FileSystem, Size, FreeSpace |  ForEach-Object {$_.DeviceID +"   |"+ $_.FileSystem +"   |"+ ($_.Size/1GB).tostring("F00") +"   |"+ ($_.FreeSpace/1GB).tostring("F00")} 

"Memory GB| Device Location| ClockSpeed"
Get-WmiObject Win32_Physicalmemory | Select-Object capacity, DeviceLocator,ConfiguredClockSpeed | ForEach-Object {($_.capacity/1GB).tostring("F00") +"   |"+ $_.DeviceLocator +"   |"+ $_.ConfiguredClockSpeed} 

"video| Memory GB| VideoProcessor"
Get-WmiObject Win32_videoController |Select-Object name, AdapterRAM, VideoProcessor | ForEach-Object {$_.name +"   |"+ ($_.AdapterRAM/1GB).tostring("F00") +"   |"+ $_.VideoProcessor} 

"NetworkAdapter| IPAddress | VideoProcessor | DefaultIPGateway | MACAddress"
Get-WmiObject Win32_NetworkAdapterConfiguration -Filter IPEnabled=$true | Select-Object Description, IPAddress, DefaultIPGateway, MACAddress | ForEach-Object {$_.Description +"   |"+ $_.IPAddress +"   |"+ $_.DefaultIPGateway +"   |"+ $_.MACAddress} 

"VMName | State | Memory GB| Uptime | Status" 
try {
get-vm | select-object VMName, State, MemoryStartup, Uptime, status | ForEach-Object {$_.VMName +"   |"+ $_.State+"   |"+ ($_.MemoryStartup/1GB).tostring("F00") +"   |"+ $_.Uptime +"   |"+ $_.status} 
}
catch {
"no Hyper-v"   
}

} |  out-file $ResultPatch -Append

Exit-PSSession
Write-Host " $Server READY" -ForeGroundColor Green
}