cls
#[Console]::outputEncoding = [System.Text.Encoding]::GetEncoding('cp866')

# Чтение данных из файла
$pc = Get-Content -Path "C:\LOGS\PcForSepInstall.txt"

# Проверка пк на онлайн и запуск команды
foreach ($computer in $pc){
  
   if (test-Connection -Cn $computer -quiet) {
   write-host "$computer is online" -BackgroundColor DarkGreen

   # запуск удалённой команды Учтановки SEP
    c:\PsExec.exe -d -s \\$computer "\\uran.hq.icfed.com\SEP & Sylink Files\Install\setup_x64.exe" cmd /S 
    
   } 
   else {
  
   }
}

