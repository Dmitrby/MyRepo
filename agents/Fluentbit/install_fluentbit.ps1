# fluentbit vars: 
$FLUENT_BIT = "2.1.9"
$LOCATION = "C:\fluent-bit"
$FLUENT_SERVICE_NAME = "Fluentbit"
$pc= "$env:COMPUTERNAME.ToLower()"
$DOMAIN=""

function Set-Recovery{
    param
    (
        [string] [Parameter(Mandatory=$true)] $ServiceDisplayName,
        [string] $action1 = "restart",
        [int] $time1 =  10000, # in miliseconds
        [string] $action2 = "restart",
        [int] $time2 =  10000, # in miliseconds
        [string] $actionLast = "restart",
        [int] $timeLast = 10000, # in miliseconds
        [int] $resetCounter = 4000 # in seconds
    )
    $services = Get-CimInstance -ClassName 'Win32_Service' | Where-Object {$_.DisplayName -imatch $ServiceDisplayName}
    $action = $action1+"/"+$time1+"/"+$action2+"/"+$time2+"/"+$actionLast+"/"+$timeLast

    foreach ($service in $services){
        # https://technet.microsoft.com/en-us/library/cc742019.aspx
        $output = sc.exe failure $($service.Name) actions= $action reset= $resetCounter
    }
}

function Installfluentbit() { 
    New-Service $FLUENT_SERVICE_NAME -Description "Fluentbit" -BinaryPathName  "C:\fluent-bit\bin\fluent-bit.exe -c C:\fluent-bit\conf\fluent-bit.conf" -StartupType Automatic
}

#copy && install zabbix-agent if not
if (!(Test-Path -Path "$LOCATION") -and !(Get-Service -name "$FLUENT_SERVICE_NAME" -ErrorAction SilentlyContinue)) {
   New-Item $LOCATION -ItemType Directory
   Set-Location -Path "$LOCATION"
   copy \\$DOMAIN\SYSVOL\$DOMAIN\scripts\Logs\fluentbit\* -Recurse -Force
   Installfluentbit
   Set-Recovery -ServiceDisplayName "$FLUENT_SERVICE_NAME"

   if (($pc -like "*DEV*") -or ($pc -like "srvost5*") -or ($pc -like "srvnrd5*"))  {
     copy \\$DOMAIN\SYSVOL\$DOMAIN\scripts\Logs\fluent-bit-dev.conf .\conf\fluent-bit.conf -Force}

   Start-Service -Name "$FLUENT_SERVICE_NAME" -ErrorAction SilentlyContinue
}

# Version check
if (!(Get-Content -Path "$LOCATION\Version") -eq "$FLUENT_BIT") {

   Set-Location -Path "$LOCATION"
   Stop-Service -Name "$FLUENT_SERVICE_NAME"
   copy \\$DOMAIN\SYSVOL\$DOMAIN\scripts\Logs\fluentbit\* -Recurse -Force

   if (($pc -like "*DEV*") -or ($pc -like "srvost5*") -or ($pc -like "srvnrd5*"))  {
     copy \\$DOMAIN\SYSVOL\$DOMAIN\scripts\Logs\fluent-bit-dev.conf .\conf\fluent-bit.conf -Force}

   Start-Service -Name "$FLUENT_SERVICE_NAME"
   copy \\$DOMAIN\SYSVOL\$DOMAIN\scripts\Logs\fluentbit\Version ./  -Force
}