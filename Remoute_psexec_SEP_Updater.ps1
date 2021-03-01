cls
#$ErrorActionPreference = 'SilentlyContinue'
#[Console]::outputEncoding = [System.Text.Encoding]::GetEncoding('cp866')

# Чтение данных из файла
#$pc = Get-Content -Path "C:\LOGS\AllPC.txt"
$pc = Get-Content -Path "C:\LOGS\PcForSepInstall.txt"
# Проверка пк на онлайн и запуск команды
foreach ($computer in $pc){
  
   if (test-Connection -Cn $computer -quiet) {
   write-host "$computer is online" -BackgroundColor DarkGreen

# запуск удалённой команды 
    #c:\PsExec.exe -d -s \\$computer "C:\Program Files (x86)\Symantec\Symantec Endpoint Protection\SepLiveUpdate.exe" cmd /S 
    #c:\PsExec.exe -d -s \\$computer "C:\Program Files\Symantec\Symantec Endpoint Protection\SepLiveUpdate.exe" cmd /S 

    #c:\PsExec.exe -d -s \\$computer "taskkill /F /IM msiexec.exe" cmd /S 
    c:\PsExec.exe -d -s \\$computer "\\uran.hq.icfed.com\SEP & Sylink Files\Install\SepInstall.bat" cmd /S 
    
   } 
   else {
  
   }
}