cls
#[Console]::outputEncoding = [System.Text.Encoding]::GetEncoding('cp866')

# Чтение данных из файла
$pc = Get-Content -Path "C:\LOGS\AllPC.txt"

# Проверка пк на онлайн и запуск команды
foreach ($computer in $pc){
  
   if (test-Connection -Cn $computer -quiet) {
   write-host "$computer is online" -BackgroundColor DarkGreen

# запуск удалённой команды 
    c:\PsExec.exe -d -s \\$computer "C:\Program Files (x86)\Symantec\Symantec Endpoint Protection\SepLiveUpdate.exe" cmd /S 
    #c:\PsExec.exe -d -s \\$computer "C:\Program Files\Symantec\Symantec Endpoint Protection\SepLiveUpdate.exe" cmd /S 
   } 
   else {
  
   }
}