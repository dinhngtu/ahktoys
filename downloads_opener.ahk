#Requires AutoHotkey v2
#SingleInstance Force
#Include "RemoteTreeView.ahk"
SetControlDelay -1

#o:: {
    if WinExist("ahk_class CabinetWClass", "Downloads") {
        WinActivate
        return
    }
    hw := WinExist("ahk_class CabinetWClass", , "Downloads")
    if !hw {
        Run "shell:downloads"
        return
    }
    htv := ControlGetHwnd("SysTreeView321")
    tv := RemoteTreeView(htv)
    /*
    i := 0
    loop {
        i := tv.GetNext(i, "F")
        if not i
            break

        r := tv.GetItemRect(i)
        t := tv.GetText(i)
        if t = "Downloads" && r[1] >= 0 && r[2] >= 0 {
            SetControlDelay -1
            ControlClick htv, , , "LEFT", , "NA X" (r[1] + 6) " Y" (r[2] + 6)
            return
        }
    }
    */
    hItem := tv.GetHandleByText("Downloads")
    if hItem {
        tv.SetSelection(hItem, false)
        r := tv.GetItemRect(hItem)
        if r[1] >= 0 && r[2] >= 0 {
            ControlClick htv, , , "MIDDLE", , "NA X" r[1] " Y" r[2]
        }
        WinActivate "ahk_id" hw
    }
}

/*
#j:: {
    hw := WinActive("ahk_class CabinetWClass")
    if !hw
        return
    ControlSend "^{Tab}", hw
}
*/

HotIfWinActive "ahk_class CabinetWClass"
Hotkey "MButton", MButtonAction
HotIf

MButtonAction(ThisHotkey) {
    MouseGetPos &x, &y, &win, &ctrl
    if ctrl = "SysTreeView321" && (x < 51 || x > 100) {
        ;&& WinGetClass("ahk_id" win) = "CabinetWClass"
        ControlClick ctrl, "ahk_id" win, , "MIDDLE", , "NA X60 Y" y
    } else {
        Send "{MButton}"
    }
}
