#Requires AutoHotkey v2
#Include <gdiplite>

IsSpotifyPlayingLocally(spotify) {
    tok := 0
    bmp := 0
    try {
        tok := Gdip_Startup()
        if !tok
            return false
        bmp := Gdip_BitmapFromHWND(spotify)
        if !bmp
            return false
        px := Gdip_GetPixel(bmp, 11, Gdip_GetImageHeight(bmp) - 11)
        return (px & 0xffffff) != 0x1ed760
    } finally {
        if bmp
            Gdip_DisposeImage bmp
        if tok
            Gdip_Shutdown tok
    }
}

WM_WTSSESSION_CHANGE(wParam, lParam, msg, hwnd) {
    static WTS_SESSION_LOCK := 0x7
    static WTS_SESSION_UNLOCK := 0x8
    if wParam = WTS_SESSION_LOCK {
        spotify := WinExist("ahk_exe spotify.exe")
        if !spotify || IsSpotifyPlayingLocally(spotify) {
            Sleep 500
            Send "{Media_Stop}"
        }
    } else if wParam = WTS_SESSION_UNLOCK {
    }
}
