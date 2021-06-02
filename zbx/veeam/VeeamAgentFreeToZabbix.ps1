$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$xmlFilePath = "\\backupcrm.action-crm.local\Backups\backup_logs\VeeamFreeAgent.xml"
# считываем содержимое xml файла
[xml]$xml= Get-Content $xmlFilePath
#psedit $xmlFilePath

$ITEM = [string]$args[0]
$ID = [string]$args[1]

#Выгрузка всех заданий
switch ($ITEM) {
  "DiscoverJobs" {
    $Alljobs = $xml.Catalog.job.name
    $idx = 1
write-host "{"
write-host " `"data`":[`n"
foreach ($currentjob in $Alljobs)
{
    if ($idx -lt $Alljobs.count)
    {
     
        $line= "{ `"{#APPTASKS}`" : `"" + $currentjob + "`" },"
        write-host $line
    }
    elseif ($idx -ge $Alljobs.count)
    {
    $line= "{ `"{#APPTASKS}`" : `"" + $currentjob + "`" }"
    write-host $line
    }
    $idx++;
} 
write-host
write-host " ]"
write-host "}"}}

#Выгрузка результата заания
switch ($ITEM) {
  "JobLastResult" {
[string] $ResultJob = $ID
$ResultState = $xml.Catalog.job | Where-Object { "$ResultJob" -contains $_.Name } | select Result |foreach {$_.Result}
Write-Output ($ResultState)
}}

#Выгрузка даты выполнения
switch ($ITEM) {
  "JobLastRunTime" {
[string] $ResultJob = $ID
$ResultDate = $xml.Catalog.job |Where-Object {"$ResultJob" -contains $_.Name} | select Date |foreach {$_.Date}
Write-Output ($ResultDate)
}}

#Выгрузка сыммарного результата заания
switch ($ITEM) {
  "AllResult" {

$SummState=0
for($i = 0; $i -lt ($xml.Catalog.job|foreach {$_.Result}).count; $i++){
  #do something
$SummState = $SummState +($xml.Catalog.job|foreach {$_.Result})[$i]
}

Write-Output ($SummState)
}}


switch ($ITEM) {
  "ExportXml" {

$ErrorActionPreference = 'SilentlyContinue'
$Mails =Get-Content E:\backup_logs\VeeamFreeAgent.txt

$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$xmlFilePath = "\\backupcrm.action-crm.local\Backups\backup_logs\VeeamFreeAgent.xml"
$TodeleteDate = (get-date).AddDays(-7).ToString('yyyy.MM.dd HH:mm')

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
    $xmlWriter.WriteStartElement('Job')
    $XmlWriter.WriteAttributeString('Name', "default")
            $xmlWriter.WriteElementString("Result","default")
            $xmlWriter.WriteElementString("Date","default")
            $xmlWriter.WriteEndElement() 
    $xmlWriter.WriteStartElement('Job')
    $XmlWriter.WriteAttributeString('Name', "default")
            $xmlWriter.WriteElementString("Result","default")
            $xmlWriter.WriteElementString("Date","default")
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

#Функция добавления в файл данных ($Name, $Result, $date)
function addxml 
{
param ($Name, $Result, $date)
$newxml = $xml.catalog.job[1].clone()
$newxml.Name = "$Name"
$newxml.Result = "$Result"
$newxml.Date  = "$Date"
$xml.catalog.appendChild($newxml)
}


#загрузка данных из почтового ящика backup@mcfr.ru за последие 24 часа (сортировка по дате по возрастанию обязательна)
#Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
#$Mails = Get-MessageTrackingLog -Recipients backup@mcfr.ru  -Start (Get-Date).AddHours(-24) |Where-Object {$_.Source -Like "STOREDRIVER"} |Sort-Object @{ e = 'Date'; d = $true }| select MessageSubject


# Разбираем сообщения почтового ящика backup@mcfr.ru и добавляем в файл
 Foreach($Message in $Mails){

            IF($Message -like "*Success*" -or "*Warning*"){$Result = "0"} ifelse($Message -like "*Failed*") {$Result = "1"}
            $Machine=$Message.split("-")[1].Trim() -replace "\s+"
            #$Date = ([DateTime]($Message.split("-")[2].Split(",")[1])).ToString('dd.MM.yyyy HH:mm')
            $Date = ([DateTime]($Message.split("-")[2].Split(",")[1])).ToString('yyyy.MM.dd HH:mm')
            
    #Если в документе нет джоба с именем создаём

   IF($xml.Catalog.job.name -notcontains "$Machine"){addxml $Machine $Result $date}

    #Если в документе есть джоб с именем меняем значения
         Foreach($alljob in $xml.Catalog.job){

            IF ($alljob.name -contains "$Machine"){
                #write-host $alljob.name $alljob.Date
                $alljob.Result = "$Result"
                $alljob.Date = "$Date"                       
                }
         }
}

#Удаляем дубли в XML nodes
#$XML.catalog.job|Group-Object name|ForEach-Object {$_.Group[0] }
Foreach($group in ($XML.catalog.job | Sort-Object @{ e = 'Date'; d = $true }|Group-Object name))
{
$DeleteName=($group |Sort-Object name | Group-Object name | ForEach-Object {$_.Group[0] }).name
$DeleteDate=($group | Sort-Object @{ e = 'Date'; d = $true } |  ForEach-Object {$_.Group[0] }).Date
($xml.Catalog.ChildNodes |Where-Object { $DeleteName -contains $_.Name -and $DeleteDate -notlike $_.Date }) | ForEach-Object {[void]$_.ParentNode.RemoveChild($_)}
}

# Удаляем дефолтный шаблон default"
#$DeleteNames = "default"
($xml.Catalog.ChildNodes |Where-Object { "default" -contains $_.Name }) | ForEach-Object {[void]$_.ParentNode.RemoveChild($_)}

#Удаляем записи старше 7дней без обновлений
Foreach($oldjob in $xml.Catalog.job){

    IF($oldjob.Date -lt $TodeleteDate) {
       ($xml.Catalog.ChildNodes |Where-Object { $oldjob.name -like $_.Name -and $oldjob.Date -like $_.Date }) | ForEach-Object {[void]$_.ParentNode.RemoveChild($_)}
        #write-host $TodeleteDate   $oldjob.name $oldjob.Date
     }
}

#Сохраняем в файл
$xml.Save($xmlFilePath)
}}


