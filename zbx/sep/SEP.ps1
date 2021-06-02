$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$xmlFilePath = "C:\zabbix\scripts\SEPM.xml"
[xml]$xml= Get-Content $xmlFilePath

# считываем содержимое xml файла
#[xml]$xml= Get-Content $xmlFilePath
#psedit $xmlFilePath

$ITEM = [string]$args[0]
$ID = [string]$args[1]

switch ($ITEM) {
 "ExportXml" {

#$ErrorActionPreference = 'SilentlyContinue'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$xmlFilePath = "C:\zabbix\scripts\SEPM.xml"
$TodeleteDate = (get-date).AddDays(-1).ToString('yyyy.MM.dd HH:mm')

Import-Module SEPMPSModule
#Connect To Uran SEP
Function SepLogon() 
{
$username = 'boev'
[Byte[]] $key = (1..16)
$pass = Get-Content "C:\zabbix\scripts\activetionSep" | ConvertTo-SecureString -Key $key
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $pass
Connect-SEPM -name uran.hq.icfed.com -Credential $creds
}
SepLogon

$PC = (Get-SEPDevice )
$SepmV = (Get-SEPAPIVersion | foreach {$_.SEPMVersion}).tostring()
#sleep -Seconds 60
$AllPC = ($PC).count
$SepVirus = ($PC | where {$_.Infected -eq 1}).count
$PcOnline = ($PC | where {$_.OnlineStatus  -eq 1}).count
$PcOfline = ($PC | where {$_.OnlineStatus  -eq 0}).count
IF($SepVirus -eq $NUll){$SepVirus = 0}
$SepVirusName = ($PC | where {$_.Infected -eq 1}| foreach {$_.name})
$SepPcVersion = ($PC | foreach {$_.AgentVersion} |Select-Object -Unique)


#Если файл не существует создаём шаблон
IF (Test-Path $xmlFilePath){} else{
################################START add xml
# Set The Formatting
$xmlsettings = New-Object System.Xml.XmlWriterSettings
$xmlsettings.Indent = $true
$xmlsettings.IndentChars = "    "

# Set the File Name Create The Document
$XmlWriter = [System.XML.XmlWriter]::Create($xmlFilePath, $xmlsettings)

# Write the XML Decleration and set the XSL
$xmlWriter.WriteStartDocument()
$xmlWriter.WriteProcessingInstruction("xml-stylesheet", "type='text/xsl' href='style.xsl'")

# Start the Root Element
$xmlWriter.WriteStartElement("Catalog") # <-- Start <Jobs>
    $xmlWriter.WriteStartElement('sep')
    $XmlWriter.WriteAttributeString('versions', "default")
            $xmlWriter.WriteElementString("Result","default")
            $xmlWriter.WriteElementString("Date","default")
            $xmlWriter.WriteEndElement()
    $xmlWriter.WriteStartElement('sep')
    $XmlWriter.WriteAttributeString('versions', "default")
            $xmlWriter.WriteElementString("Result","default")
            $xmlWriter.WriteElementString("Date","default")
             $xmlWriter.WriteEndElement()
            $xmlWriter.WriteStartElement('sepm')
    $XmlWriter.WriteAttributeString('version', "default")
            $xmlWriter.WriteElementString("All","default")
            $xmlWriter.WriteElementString("Online","default")
            $xmlWriter.WriteElementString("Offline","default")
            $xmlWriter.WriteElementString("Infected","default")
            $xmlWriter.WriteElementString("InfectedNames","default")
        $xmlWriter.WriteEndElement() 
    $xmlWriter.WriteEndElement() # <-- End <Jobs>
# End, Finalize and close the XML Document
$xmlWriter.WriteEndDocument()
$xmlWriter.Flush()
$xmlWriter.Close()
################################ END add xml
}

# считываем содержимое xml файла
[xml]$xml= Get-Content $xmlFilePath

#Функция добавления в файл данных ($versions, $Result, $date)
function addxml 
{
param ($versions, $Result, $date)
$newxml = $xml.catalog.sep[1].clone()
$newxml.versions = "$versions"
$newxml.Result = "$Result"
$newxml.Date  = "$Date"
$xml.catalog.appendChild($newxml)
}

# Разбираем сообщения почтового ящика backup@mcfr.ru и добавляем в файл
 Foreach($versions in $SepPcVersion){

            $Result = ($PC  | where {$_.AgentVersion -eq "$versions"}).count
            $Date = (get-date).ToString('yyyy.MM.dd HH:mm')
            
    #Если в документе нет джоба с именем создаём

   IF($xml.Catalog.sep.versions -notcontains "$versions"){addxml $versions $Result $date}

    #Если в документе есть джоб с именем меняем значения
         Foreach($allsep in $xml.Catalog.sep){

            IF ($allsep.versions -contains "$versions"){
                #write-host $allsep.name $allsep.Date
                $allsep.Result = "$Result"
                $allsep.Date = "$Date"                       
                }
         }
}


$xml.Catalog.sepm.version = "$SepmV"
$xml.Catalog.sepm.All = "$AllPC"
$xml.Catalog.sepm.Online = "$PcOnline"
$xml.Catalog.sepm.Offline = "$PcOfline"
$xml.Catalog.sepm.Infected = "$SepVirus"
$xml.Catalog.sepm.InfectedNames = "$SepVirusName"

#Удаляем дубли в XML nodes
Foreach($group in ($XML.catalog.sep | Sort-Object @{ e = 'Date'; d = $true }|Group-Object versions))
{
$DeleteName=($group |Sort-Object name | Group-Object name | ForEach-Object {$_.Group[0] }).name
$DeleteDate=($group | Sort-Object @{ e = 'Date'; d = $true } |  ForEach-Object {$_.Group[0] }).Date
($xml.Catalog.ChildNodes |Where-Object { $DeleteName -contains $_.Name -and $DeleteDate -notlike $_.Date }) | ForEach-Object {[void]$_.ParentNode.RemoveChild($_)}
}

# Удаляем дефолтный шаблон default"
($xml.Catalog.ChildNodes |Where-Object { "default" -contains $_.versions }) | ForEach-Object {[void]$_.ParentNode.RemoveChild($_)}

#Удаляем записи старше 1днь без обновлений
Foreach($oldjob in $xml.Catalog.sep){

    IF($oldjob.Date -lt $TodeleteDate) {
       ($xml.Catalog.ChildNodes |Where-Object { $oldjob.versions -like $_.versions -and $oldjob.Date -like $_.Date }) | ForEach-Object {[void]$_.ParentNode.RemoveChild($_)}
        #write-host $TodeleteDate   $oldjob.name $oldjob.Date
     }
}

#Сохраняем в файл
$xml.Save($xmlFilePath)
}}

#Выгрузка всех заданий
switch ($ITEM) {
  "discovery" {
       $idx = 1
write-host "{"
write-host " `"data`":[`n"
 foreach($ver in ($xml.Catalog.sep.versions))
{
    if ($idx -lt ($xml.Catalog.sep.versions).count)
    {
     
        $line= "{ `"{#VERSION}`" : `"" + $ver + "`" },"
        write-host $line
    }
    elseif ($idx -ge ($xml.Catalog.sep.versions).count)
    {
    $line= "{ `"{#VERSION}`" : `"" + $ver + "`" }"
    write-host $line
    }
    $idx++;
} 
write-host
write-host " ]"
write-host "}"}}

switch ($ITEM) {
"AllPC" {

            $xml.Catalog.sepm.All
        }
}

switch ($ITEM) {
"Online" {

            $xml.Catalog.sepm.Online

        }
}

switch ($ITEM) {
"Offline" {

           Write-Output ($xml.Catalog.sepm.Offline)

        }
}

switch ($ITEM) {
"Sep" {

            $xml.Catalog.sepm.version
        }
}
switch ($ITEM) {
"Infected" {


            $xml.Catalog.sepm.Infected

        }
}
switch ($ITEM) {
"InfectedNames" {

            $xml.Catalog.sepm.InfectedNames
        }
}
switch ($ITEM) {
"Vnum" {

            Foreach($allsep in $xml.Catalog.sep){
            IF ($allsep.versions -contains "$ID"){ $Result = $allsep.Result
                #write-host $allsep.name $allsep.Date
               IF (($allsep.Result) -lt 1) {($Result) = 1}
                  $Result                  
                }
         }






            $a=($xml.Catalog.sep.versions  | where {$_.AgentVersion -eq "$versions"}).Result
            $a
        }
}

exit