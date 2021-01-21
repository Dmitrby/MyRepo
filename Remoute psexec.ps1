cls
#[Console]::outputEncoding = [System.Text.Encoding]::GetEncoding('cp866')

$pc = Get-Content -Path "C:\LOGS\PcForSepInstall.txt"
#$pc = Get-Content -Path "C:\LOGS\allPC.txt"

foreach ($computer in $pc){
  
   if (test-Connection -Cn $computer -quiet) {
   write-host "$computer is online" -BackgroundColor DarkGreen

  # xcopy \\crm00111.hq.icfed.com\logs\SepUpdate.bat \\$computer\c$\temp /H /Y /C /R /S /I
   
   #Invoke-psexec -ComputerName $computer -command 'c:\temp\SepUpdate.bat' 

    c:\PsExec.exe -d -s \\$computer "\\uran.hq.icfed.com\SEP & Sylink Files\Install\setup_x64.exe" cmd /S 
    #c:\PsExec.exe -d -s \\$computer "C:\Program Files (x86)\Symantec\Symantec Endpoint Protection\SepLiveUpdate.exe" cmd /S 
    #c:\PsExec.exe -d -s \\$computer "C:\Program Files\Symantec\Symantec Endpoint Protection\SepLiveUpdate.exe" cmd /S 
   } 
   else {
  
   }
}

