#Requires AutoHotkey v2
#SingleInstance Force
#Include "RemoteTreeView.ahk"

#o:: {
    try {
        hw := WinActive("ahk_class CabinetWClass")
        if !hw
            return
        htv := ControlGetHwnd("SysTreeView321", "ahk_id " hw)
        tv := RemoteTreeView(htv)
        i := 0
        loop {
            i := tv.GetNext(i, "F")
            if not i
                break
            /*
            r := tv.GetItemRect(i)
            t := tv.GetText(i)
            if t = "Downloads" && r[1] >= 0 && r[2] >= 0 {
                SetControlDelay -1
                ControlClick htv, , , "LEFT", , "NA X" (r[1] + 6) " Y" (r[2] + 6)
                return
            }
            */
            tv.SetSelectionByText("Downloads")
        }
    } catch TargetError {
    }
}
