function Get-StartMenuShortcuts
{
    $Shortcuts = Get-ChildItem -Recurse $env:USERPROFILE\Desktop -Include *.lnk
    $Shell = New-Object -ComObject WScript.Shell
    foreach ($Shortcut in $Shortcuts)
    {
        $Properties = @{
        ShortcutName = $Shortcut.Name;
        ShortcutFull = $Shortcut.FullName;
        ShortcutPath = $shortcut.DirectoryName
        Target = $Shell.CreateShortcut($Shortcut).targetpath
        }
        New-Object PSObject -Property $Properties
    }

[Runtime.InteropServices.Marshal]::ReleaseComObject($Shell) | Out-Null
}

$Output = Get-StartMenuShortcuts
#$Output.ShortcutFull
#$Output.ShortcutName
#$Output.Target
#$Output.ShortcutPath

$WshShell = New-Object -comObject WScript.Shell
Foreach ($Shortcut in $Output)
{   
    Switch -wildcard ($Shortcut.Target)
    {
        '*192.168.0.153*'
        {
            $NewFullName = $Shortcut.ShortcutFull
            $NewTarget = $Shortcut.Target -replace "192.168.0.153", "s5000.amedia.loc"
            $NewShortcut = $WshShell.CreateShortcut("$NewFullName")
            $NewShortcut.TargetPath = $NewTarget
            $NewShortcut.Save()
            break
        }
        '*192.168.2.99*'
        {
            $NewFullName = $Shortcut.ShortcutFull
            $NewTarget = $Shortcut.Target -replace "192.168.2.99", "servvideo.amedia.loc"
            $NewShortcut = $WshShell.CreateShortcut("$NewFullName")
            $NewShortcut.TargetPath = $NewTarget
            $NewShortcut.Save()
            break
        }
        '*192.168.2.101*'
        {
            $NewFullName = $Shortcut.ShortcutFull
            $NewTarget = $Shortcut.Target -replace "192.168.2.101", "fr001.amedia.loc"
            $NewShortcut = $WshShell.CreateShortcut("$NewFullName")
            $NewShortcut.TargetPath = $NewTarget
            $NewShortcut.Save()
            break
        }
        '*192.168.2.226*'
        {
            $NewFullName = $Shortcut.ShortcutFull
            $NewTarget = $Shortcut.Target -replace "192.168.2.226", "verstka2.amedia.loc"
            $NewShortcut = $WshShell.CreateShortcut("$NewFullName")
            $NewShortcut.TargetPath = $NewTarget
            $NewShortcut.Save()
            break
        }
        '*192.168.4.231*'
        {
            $NewFullName = $Shortcut.ShortcutFull
            $NewTarget = $Shortcut.Target -replace "192.168.4.231", "spps.action-crm.local"
            $NewShortcut = $WshShell.CreateShortcut("$NewFullName")
            $NewShortcut.TargetPath = $NewTarget
            $NewShortcut.Save()
            break
        }
        '*192.168.50.200*'
        {
            $NewFullName = $Shortcut.ShortcutFull
            $NewTarget = $Shortcut.Target -replace "192.168.50.200", "pravo.hq.icfed.com"
            $NewShortcut = $WshShell.CreateShortcut("$NewFullName")
            $NewShortcut.TargetPath = $NewTarget
            $NewShortcut.Save()
            break
        }
        '*192.168.50.233*'
        {
            $NewFullName = $Shortcut.ShortcutFull
            $NewTarget = $Shortcut.Target -replace "192.168.50.233", "mediafs1.amedia.loc"
            $NewShortcut = $WshShell.CreateShortcut("$NewFullName")
            $NewShortcut.TargetPath = $NewTarget
            $NewShortcut.Save()
            break
        }
        '*192.168.251.240*'
        {
            $NewFullName = $Shortcut.ShortcutFull
            $NewTarget = $Shortcut.Target -replace "192.168.251.240", "crm.action-crm.local"
            $NewShortcut = $WshShell.CreateShortcut("$NewFullName")
            $NewShortcut.TargetPath = $NewTarget
            $NewShortcut.Save()
            break
        }
        '*10.0.64.254*'
        {
            $NewFullName = $Shortcut.ShortcutFull
            $NewTarget = $Shortcut.Target -replace "10.0.64.254", "check.hq.icfed.com"
            $NewShortcut = $WshShell.CreateShortcut("$NewFullName")
            $NewShortcut.TargetPath = $NewTarget
            $NewShortcut.Save()
            break
        }
    }
}