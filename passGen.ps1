write-host  "����� ������ (1-128)"
$PassLength = Read-Host
write-host  "���������� ������������� ��������"
$NonAlfaNumeric = Read-Host
write-host "������� ���������� ����������� �������"
$maxVar = Read-Host
Add-Type -AssemblyName System.Web
$TestVar = 0

   WHILE ($TestVar -lt $maxVar){
      [System.Web.Security.Membership]::GeneratePassword($PassLength,$NonAlfaNumeri)
      $TestVar = $TestVar + 1 
   }
exit