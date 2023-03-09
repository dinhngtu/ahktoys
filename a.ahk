#Requires AutoHotkey v2
#SingleInstance Force
#Include "RemoteTreeView.ahk"

#o:: {
    try {
        htv := ControlGetHwnd("Navigation Pane", "ahk_class CabinetWClass")
        tv := RemoteTreeView(htv)
        i := 0
        s := ""
        loop {
            i := tv.GetNext(i, "F")
            if not i
                break
            r := tv.GetItemRect(i)
            s := s . " / " . tv.GetText(i) . " " . r[1] . " " . r[2] . " " . r[3] . " " . r[4]
        }
        MsgBox s
    } catch TargetError {
    }
}
