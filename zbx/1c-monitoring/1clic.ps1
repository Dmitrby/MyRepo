ping | Out-Null
Set-Location -Path "C:\Program Files\1cv8\8.3.22.1704\bin"
$Error.Clear()
$erorcount= "0"
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

$OutputEncoding = New-Object System.Text.Utf8Encoding
[Console]::OutputEncoding = New-Object System.Text.Utf8Encoding


$cluster = .\rac.exe cluster list | % {if ($_ -match 'cluster'){$_ -replace "^.*?: "}}

$cluster =$cluster[0]

#$cluster
$racInfobases = .\rac.exe infobase --cluster=$cluster summary list

#Total sessions
#$allsession = .\rac.exe session --cluster=$cluster list |  % {if ($_ -match 'session-id'){$_ -replace "^.*?: "}}
#$allsession.count
$session = .\rac.exe session --cluster=$cluster list
$licenseqery = .\rac.exe session --cluster=b065af13-252c-4fa4-889e-04e5de662f34 list --licenses
#$appID = $session |  % {if ($_ -match 'app-id'){$_ -replace "^.*?: "}} | sort -Unique
$appID = "1CV8C", "BackgroundJob", "COMConnection", "Designer", "HTTPServiceConnection", "ODataConnection", "SrvrConsole", "WebClient"

function sesall{
$sessionBase = @()
$infoBaseBase = @()
foreach ($racInfobase in $racInfobases)
{
    if ($racInfobase -match "infobase")
    {
        $infoBase = New-Object -TypeName PSObject
        $infoBase | Add-Member -Type NoteProperty -Name infobase -Value ([string]($racInfobase -replace "^.*?: "))
    }
    if ($racInfobase -match "name")
    {
        $infoBase | Add-Member -Type NoteProperty -Name name -Value ([string]($racInfobase -replace "^.*?: "))
        $infoBaseBase += $infoBase
    }
}
if ($debug -eq 1)
{
    $infoBaseBase | sort name | ft * -AutoSize
}

$racSessions = .\rac.exe session --cluster=$cluster list


Foreach($racSession in $racSessions)
{
    if ($racSession -match "session ")
    {
        if ($debug -eq 1)
        {
            $racSession -replace "^.*?: "
        }
        $Session = New-Object -TypeName PSObject
        $Session | Add-Member -Type NoteProperty -Name uid -Value ([string]($racSession-replace "^.*?: "))
    }
    elseif ($racSession -match "infobase")
    {
        $infoBaseUid = $racSession -replace "^.*?: "
        #$infoBaseUid
        $infoBaseName = $infoBaseBase | ? {$_.infobase -match "$infobaseUid"} | select -expand name
        #$infoBaseName
        $Session | Add-Member -Type NoteProperty -Name base -Value ([string]($infoBaseName))
    }
    elseif ($racSession -match "user.name")
    {
        $session | Add-Member -Type NoteProperty -Name user -Value ([string]($racSession-replace "^.*?: "))
    }
    elseif ($racSession -match "app-id")
    {
        $session | Add-Member -Type NoteProperty -Name type -Value ([string]($racSession-replace "^.*?: "))
    }
    elseif ($racSession -match "started.at")
    {
        $started = $racSession -replace "^.*?: "
        $session | Add-Member -Type NoteProperty -Name Started -Value ([string]($([datetime]$started).ToString("yyyy-MM-dd HH:mm:ss")))
    }
    elseif ($racSession -match "last.active.at")
    {
        $last = $racSession -replace "^.*?: "
        $session | Add-Member -Type NoteProperty -Name Last -Value ([string]($([datetime]$last).ToString("yyyy-MM-dd HH:mm:ss")))
    }
    elseif ($racsession -match "hibernate ")
    {
        if ($racsession -match "yes")
        {$Sleep = 1}
        elseif ($racsession -match "no")
        {$Sleep = 0}
        $session | Add-Member -Type NoteProperty -Name sleep -Value ([int]$Sleep)
    }
    elseif ($racSession -match "calls.last")
    {
        $session | Add-Member -Type NoteProperty -Name calls_5min -Value ([long]($racSession-replace "^.*?: "))
    }
  #  elseif ($racSession -match "bytes.last")
  #  {
  #      $session | Add-Member -Type NoteProperty -Name byt_5min -Value ([long]($racSession-replace "^.*?: "))
  #  }
    elseif ($racSession -match "duration.current ")
    {
        $session | Add-Member -Type NoteProperty -Name dur_current -Value ([long]($racSession-replace "^.*?: "))
    }
    elseif ($racSession -match "duration.current-dbms")
    {
        $session | Add-Member -Type NoteProperty -Name dur_db_cur -Value ([long]($racSession-replace "^.*?: "))
    }
    elseif ($racSession -match "read.last")
    {
        $session | Add-Member -Type NoteProperty -Name read_5min -Value ([long]($racSession-replace "^.*?: "))
    }
    elseif ($racSession -match "write.last")
    {
        $session | Add-Member -Type NoteProperty -Name write_5min -Value ([long]($racSession-replace "^.*?: "))
    }
    elseif ($racSession -match "cpu.time.last")
    {
        $session | Add-Member -Type NoteProperty -Name cpu_5min -Value ([long]($racSession-replace "^.*?: "))
    }
#    elseif ($racSession -match "memory.current")
 #   {
 #       $session | Add-Member -Type NoteProperty -Name m_current -Value ([long]($racSession-replace "^.*?: "))
  #  }
  #  elseif ($racSession -match "memory.last")
   # {
   #     $session | Add-Member -Type NoteProperty -Name m_5min -Value ([long]($racSession-replace "^.*?: "))
  #  }
    elseif ($racSession -match "memory.last")
    {
        if ($debug -eq 1)
        {
            $racSession
        }
        $session | Add-Member -Type NoteProperty -Name m_5min -Value ([long]($racSession-replace "^.*?: "))
        $sessionBase += $session
    }

}
 
 return $sessionBase
 #$opensessions= $sessionBase |sort uid -Unique | ConvertTo-Csv -NoTypeInformation -Delimiter ";"     #ConvertTo-Json #| ft * -AutoSize  
 #return $opensessions.replace('"','')

}

$ITEM = [string]$args[0]

switch ($ITEM) {
  "discovery" {
#####
$idx = 1
$totalappdata = 0
$sessions= sesall #|sort uid -Unique

#write-host "{"
write-host "[`n"

foreach ($app in $appID) {
    $appdata= $sessions  | where {$_.type -eq "$app"}
	$sleep= $sessions |  where {$_.sleep -eq "1"}
	#$tottallic= $licenseqery | % {if ($_ -match 'full-presentation'){$_ -replace "^.*?: "}}
    #$applic= $licenseqery  | % {if ($_ -match "$app"){$_ -replace "^.*?: "}}
    $totalappdata= $sessions.count
# Write-Host $app ":" $appdata.count

	$bindex=$idx-1
	
    if ($idx -lt ($appID).count)
    {
     
        $line= "{ `"APP`" : `"" + $app + "`", `"Slot`" : `"" + $bindex + "`", `"Sessions`" : `"" + $appdata.count + "`", `"TotalSleep`" : `"" + $sleep.count + "`", `"Totalsessions`" : `"" + $totalappdata + "`" },"
        write-host $line
    }
    elseif ($idx -ge ($appID).count)
    {
    $line= "{ `"APP`" : `"" + $app + "`", `"Slot`" : `"" + $bindex + "`", `"Sessions`" : `"" + $appdata.count + "`", `"TotalSleep`" : `"" + $sleep.count + "`", `"Totalsessions`" : `"" + $totalappdata + "`" }"
    write-host $line
    }
    $idx++;

}

write-host
write-host " ]"
#write-host "}"
 }
}

switch ($ITEM) {
  "LicenseKeys" {

    $lickeys = $licenseqery | % {if ($_ -match 'full-presentation'){$_ -replace "^.*?: "}} | sort -Descending -Unique
    #$lickeys = "Server, 5340, 1C-LIC, 1585, 8101922464 100 100, file://C:/ProgramData/1C/licenses/20220907121154.lic","Server, 5340, 1C-LIC, 1585, 8101924317 500 500, file://C:/ProgramData/1C/licenses/20221027084937.lic"

    $allkey= $licenseqery | % {if ($_ -match "file://C:/ProgramData/1C/licenses"){$_ -replace "^.*?: "}} 
    $idx = 1
    write-host "[`n"
    foreach ($key in $lickeys) {
       # if(($key.split(",").count) -inotmatch 6){continue }
        $z=$licenseqery | % {if ($_ -match $key){$_ -replace "^.*?: "}}
	    $cindex=$idx-1
        if ($idx -lt ($lickeys).count)
        {
            if(($key.split(",").count) -inotmatch 6){

    $line= "{ `"KeyNumber`" : `"" + $key.split(",")[2].split(" ")[1] + "`" , `"Slot`" : `"" + $cindex + "`", `"Usedkey`" : `"" + $z.count + "`", `"LicServer`" : `"" + $key.split(",")[0].trim() + "`", `"LicOnKey`" : `"" + $key.split(",")[2].split(" ")[2] + "`", `"TotalKey`" : `"" + $allkey.count/2 + "`"  },"
        write-host $line
            }
            else{
    $line= "{ `"KeyNumber`" : `"" + $key.split(",")[4].split(" ")[1] + "`" , `"Slot`" : `"" + $cindex + "`", `"Usedkey`" : `"" + $z.count + "`", `"LicServer`" : `"" + $key.split(",")[2].trim() + "`", `"LicOnKey`" : `"" + $key.split(",")[4].split(" ")[2] + "`", `"TotalKey`" : `"" + $allkey.count/2 + "`"  },"
    write-host $line
            }
        }
        elseif ($idx -ge ($lickeys).count)
        {
            if(($key.split(",").count) -inotmatch 6){

    $line= "{ `"KeyNumber`" : `"" + $key.split(",")[2].split(" ")[1] + "`" , `"Slot`" : `"" + $cindex + "`", `"Usedkey`" : `"" + $z.count + "`", `"LicServer`" : `"" + $key.split(",")[0].trim() + "`", `"LicOnKey`" : `"" + $key.split(",")[2].split(" ")[2] + "`", `"TotalKey`" : `"" + $allkey.count/2 + "`"  }"
    write-host $line
            }
            else{
    $line= "{ `"KeyNumber`" : `"" + $key.split(",")[4].split(" ")[1] + "`" , `"Slot`" : `"" + $cindex + "`", `"Usedkey`" : `"" + $z.count + "`", `"LicServer`" : `"" + $key.split(",")[2].trim() + "`", `"LicOnKey`" : `"" + $key.split(",")[4].split(" ")[2] + "`", `"TotalKey`" : `"" + $allkey.count/2 + "`"  }"
    write-host $line
            }
        }
        $idx++;
    }
write-host
write-host " ]"
 }
}


switch ($ITEM) {
  "Sessions" {

(sesall |sort uid -Unique | ConvertTo-Csv -NoTypeInformation -Delimiter ";" ).replace('"','').replace(';?????????????;',';Администратор;')
}}

switch ($ITEM) {
  "ToGraylog" {
$GraylogUdpPort = 12201
$GraylogUdpHost = "server ip"
$UDPclient = new-Object System.Net.Sockets.UdpClient
$UDPclient.Connect($GraylogUdpHost, $GraylogUdpPort)
$Enc = [system.Text.Encoding]::UTF8

#$data=(sesall |sort uid -Unique | ConvertTo-Json -Compress ).replace(';?????????????;',';Администратор;')

$data=(sesall)
#$timenow =(Get-Date).ToUniversalTime().ToString(‘yyMMddTHHmmss’)
$timenow = [Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
#$dataColumn = $data.Columns | Select-Object -ExpandProperty ColumnName
$data | ForEach-Object {
    $Row = $_
    New-Object psobject -Property @{
        version = "1.1"
        host = "1C-EDOC-APP01-CLUSTERDATA"
        short_message = ($Row |ConvertTo-Json -Compress) -join "`t"
        timestamp = $timenow #[Math]::Floor([decimal](Get-Date.ToUniversalTime()-uformat "%s")) 
        _Uid = $Row.uid
        _Base = $Row.base
        _User = $Row.user
        _Type = $Row.type
        _Started = $Row.Started
        _Last = $Row.Last
        _Sleep = $Row.sleep
        _Calls_5min = $Row.calls_5min
        _Dur_curren = $Row.dur_curren
        _Dur_db_cur = $Row.dur_db_cur
        _M_5min = $Row.m_5min
        _Read_5min = $Row.read_5min
        _Write_5min = $Row.write_5min
        _Cpu_5min = $Row.cpu_5min
    }
} | ForEach-Object {
    # This will be really, really slow because launching Invoke-RestMethod for every record, but it's a proof-of-concept
    # Invoke-RestMethod -Method Post -Uri $GraylogUrl -Body ($_ | ConvertTo-Json -Compress) -ContentType "application/json"

    # Since it's not re-creating an object maybe it will be faster
    $packet = $Enc.GetBytes( ( $_ | ConvertTo-Json -Compress ) )
    $UDPclient.Send($packet, $packet.Length) | Out-Null
}

}}






#$sessionBase |sort M_Current -Unique | ConvertTo-Csv -NoTypeInformation       #ConvertTo-Json #| ft * -AutoSize  




<#
$dataSource = “db01.admin.ru”
$database = “monitoring”
$auth = “Integrated Security=SSPI;”
$connectionString = “Provider=sqloledb; ” +
“Data Source=$dataSource; ” +
“Initial Catalog=$database; ” +
“$auth; “
$connection = New-Object System.Data.OleDb.OleDbConnection $connectionString
$command = New-Object System.Data.OleDb.OleDbCommand $sql,$connection
$connection.Open()


foreach ($sOut in $sessionBase)
{
    if ($sOut){
    $values = "'$server','"+$sOut.uid+"','"+$sOut.base+"','"+$sOut.user+"','"+$sOut.type+"','"+$sOut.started+"','"+$sOut.last+"','"+$sOut.sleep+"','"+$sOut.dur_current+"','"+$sOut.dur_db_cur+"','"+$sOut.m_current+"','"+$sOut.m_5min+"','"+$sOut.m_total+"'"
    $values 
    
    $command.CommandText = "INSERT INTO [1c_monitoring].[dbo].[sessions] ([server],[uuid],[base],[user],[type],[started],[last],[sleep],[duration_cur],[duration_db_cur],[Current],[5min],[Total]) VALUES ($values);"
      $command.ExecuteNonQuery()                                                   
        }
}

#$Reader.Close()

$command = New-Object data.OleDb.OleDbCommand $sql
$command.connection = $connection

$Connection.Close()
#>
