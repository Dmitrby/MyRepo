#for worck need Install-Module -Name PSWindowsUpdate
# or cope from C:\Program Files\WindowsPowerShell\Modules | PSWindowsUpdate | to ssever
#https://winitpro.ru/index.php/2018/10/01/pswindowsupdate-upravlenie-obnovleniyami-powershell/

Import-Module PSWindowsUpdate
$updates=Get-WUList
foreach ($update in $updates) { 
  IF ($update.Title -like "*Update for Microsoft Defender Antivirus*") {Get-WindowsUpdate -KBArticleID $update.KB -Install -Confirm:$false   }
wuauclt /reportnow
  }