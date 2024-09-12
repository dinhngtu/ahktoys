#Requires AutoHotkey v2
#Include <RemoteTreeView>
CoordMode "Mouse", "Client"

OpenDownloadsTabs(ThisHotkey) {
    SetTitleMatchMode 3
    DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")
    if WinExist("Downloads ahk_class CabinetWClass") {
        WinActivate
        Return
    }
    hw := WinExist("ahk_class CabinetWClass", , "Downloads")
    if !hw
        goto out
    htv := ControlGetHwnd("SysTreeView321")
    tv := RemoteTreeView(htv)
    hItem := tv.GetHandleByText("Downloads")
    if !hItem
        goto out
    tv.SetSelection(hItem, false)
    r := tv.GetItemRect(hItem)
    if r[1] < 0
        goto out
    ControlClick htv, , , "MIDDLE", , "NA X" r[1] " Y" r[2]
    WinActivate
    return
out:
    Run "shell:downloads"
    return
}

Hotkey "#e", OpenDownloadsTabs
