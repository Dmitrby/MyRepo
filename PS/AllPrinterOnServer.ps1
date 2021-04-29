 cls
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

#For first run need install commands. для первого за пуска на принт сервере необходимо зпустить в powershell ##команды
##Import-Module ServerManager
##Add-WindowsFeature RSAT-AD-PowerShell,RSAT-AD-AdminCenter
##Get-Module -ListAvailable ActiveDirectory
##import-module activedirectory

###############parametrs###########################
 # полное имя принтсервера
 $Printserver = 'Print01.hq.icfed.com'
 #директория с файлом
 $path = 'c:\temp'
 $date =Get-Date -Format "dd.MM.yyyy_HH.mm"
  
 
 ############################# PROGRAMM ###################################################
 #Проверка существования директории
 if (!(Test-Path $path)) {new-item c:\temp -itemtype directory}
 
 #Priners Listed in Ad
 #$adprinters=Get-ADObject -LDAPFilter "(objectCategory=printQueue)" -Properties * |where {$_.serverName -eq $Printserver} | foreach {$_.printerName, $_.portName}
 #$end = ($adprinters).Count
 #$end 
 #$a=0
 #$b=1
 #Do {
 #$IP = Get-PrinterPort $adprinters[$b] | foreach {$_.PrinterHostAddress}
 #$adprinters[$a] +"|"+ $adprinters[$b] +"|"+ $IP | out-file c:\temp\$date_PrintserverPrinters.csv -Append
  #$a=$a+2
 #$b=$b+2
 # }Until($a -eq $end -or $b -eq $end)

#Priners NO Listed in Ad
$printerS = Get-Printer -ComputerName $Printserver |foreach {$_.Name}
($printerS).count
Foreach($printer in $Printers){
$Port = Get-Printer $printer |foreach {$_.PortName}
$IP = Get-PrinterPort $Port | foreach {$_.PrinterHostAddress}

$Printer +"|"+ $port +"|"+ $IP | out-file c:\temp\$date_PrintserverPrinters.csv -Append
}
write-host "OK"
exit