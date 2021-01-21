On Error Resume Next
Dim adsinfo, ThisComp, oUser, osVersion
Set adsinfo = CreateObject("adsysteminfo")
Set ThisComp = GetObject("LDAP://" & adsinfo.ComputerName)
Set oUser = GetObject("LDAP://" & adsinfo.UserName)

strMsg = ""
strComputer = "."
Set objWMIService = GetObject("winmgmts:" _
  & "{impersonationLevel=impersonate}!\\" _
  & strComputer & "\root\cimv2")
Set IPConfigSet = objWMIService.ExecQuery("Select " _
  & "IPAddress from Win32_NetworkAdapterConfiguration " _
  & "WHERE IPEnabled = 'True'")
   
For Each IPConfig in IPConfigSet
 If Not IsNull(IPConfig.IPAddress) Then
 For i = LBound(IPConfig.IPAddress) To UBound(IPConfig.IPAddress)
  If Not Instr(IPConfig.IPAddress(i), ":") > 0 Then
  strMsg = strMsg & IPConfig.IPAddress(i) & vbcrlf
  End  If
 Next
 End If
Next

Thiscomp.put "description", "Онлайн: " + oUser.cn + " | " + CStr(Now) + " IP: " + strMsg
ThisComp.Setinfo

oUser.put "description", "PC:  " + ThisComp.cn + " | " + CStr(Now) + " IP: " + strMsg
oUser.Setinfo