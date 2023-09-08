# Zabbix server vars: 
$ZBX_VERSION = "6.4.4"
$LOCATION = "C:\Program Files\zabbix_agent2"
$ZBX_SERVICE_NAME = "Zabbix Agent 2"
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

function InstallZbxAgent() {
    #msiexec /i \\dc01\klanetagent\zabbix_agent2-6.0.14-windows-amd64-openssl.msi /qn SERVER=$ZBX_SERVER LISTENPORT=$AGENT_PORT HOSTNAME=$HOSTNAME 
    .\zabbix_agent2.exe --config ".\zabbix_agent2.conf" --install
}

#copy && install zabbix-agent if not
if (!(Test-Path -Path "$LOCATION") -and !(Get-Service -name "$ZBX_SERVICE_NAME" -ErrorAction SilentlyContinue)) {
   New-Item $LOCATION -ItemType Directory
   Set-Location -Path "$LOCATION"
   copy \\$DOMAIN\SYSVOL\$DOMAIN\scripts\Zabbix\zabbix_agent2\* -Recurse -Force
   InstallZbxAgent
   Set-Recovery -ServiceDisplayName "$ZBX_SERVICE_NAME"
   Start-Service -Name "$ZBX_SERVICE_NAME" -ErrorAction SilentlyContinue
}

# Version check
if (!(Get-Content -Path "$LOCATION\Version") -eq "$ZBX_VERSION") {

   Set-Location -Path "$LOCATION"
   Stop-Service -Name "$ZBX_SERVICE_NAME"
   copy \\$DOMAIN\SYSVOL\$DOMAIN\scripts\Zabbix\zabbix_agent2\zabbix_agent2.exe ./  -Force
   Start-Service -Name "$ZBX_SERVICE_NAME"
   copy \\$DOMAIN\SYSVOL\$DOMAIN\scripts\Zabbix\zabbix_agent2\Version ./  -Force
}
