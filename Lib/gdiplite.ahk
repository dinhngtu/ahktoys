Gdip_Startup()
{
    if !DllCall("GetModuleHandle", "str", "gdiplus", "UPtr") {
        DllCall("LoadLibrary", "str", "gdiplus")
    }

    si := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
    NumPut("UInt", 1, si)
    DllCall("gdiplus\GdiplusStartup", "UPtr*", &pToken := 0, "UPtr", si.Ptr, "UPtr", 0)
    /*
    if (!pToken) {
        throw Error("Gdiplus failed to start. Please ensure you have gdiplus on your system")
    }
    */

    return pToken
}

Gdip_Shutdown(pToken)
{
    DllCall("gdiplus\GdiplusShutdown", "UPtr", pToken)
    if hModule := DllCall("GetModuleHandle", "str", "gdiplus", "UPtr") {
        DllCall("FreeLibrary", "UPtr", hModule)
    }

    return 0
}

GetDC(hwnd := 0)
{
    return DllCall("GetDC", "UPtr", hwnd)
}

ReleaseDC(hdc, hwnd := 0)
{
    return DllCall("ReleaseDC", "UPtr", hwnd, "UPtr", hdc)
}

DeleteObject(hObject)
{
    return DllCall("DeleteObject", "UPtr", hObject)
}

DeleteDC(hdc)
{
    return DllCall("DeleteDC", "UPtr", hdc)
}

CreateRect(&Rect, x, y, w, h)
{
    Rect := Buffer(16)
    NumPut("UInt", x, Rect, 0), NumPut("UInt", y, Rect, 4), NumPut("UInt", w, Rect, 8), NumPut("UInt", h, Rect, 12)
}

CreateDIBSection(w, h, hdc := "", bpp := 32, &ppvBits := 0)
{
    hdc2 := hdc ? hdc : GetDC()
    bi := Buffer(40, 0)

    NumPut("UInt", w, bi, 4)
        , NumPut("UInt", h, bi, 8)
        , NumPut("UInt", 40, bi, 0)
        , NumPut("ushort", 1, bi, 12)
        , NumPut("uInt", 0, bi, 16)
        , NumPut("ushort", bpp, bi, 14)

    hbm := DllCall("CreateDIBSection"
        , "UPtr", hdc2
        , "UPtr", bi.Ptr
        , "UInt", 0
        , "UPtr*", &ppvBits
        , "UPtr", 0
        , "UInt", 0, "UPtr")

    if (!hdc) {
        ReleaseDC(hdc2)
    }
    return hbm
}

CreateCompatibleDC(hdc := 0)
{
    return DllCall("CreateCompatibleDC", "UPtr", hdc)
}

SelectObject(hdc, hgdiobj)
{
    return DllCall("SelectObject", "UPtr", hdc, "UPtr", hgdiobj)
}

PrintWindow(hwnd, hdc, Flags := 0)
{
    return DllCall("PrintWindow", "UPtr", hwnd, "UPtr", hdc, "UInt", Flags)
}

Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette := 0)
{
    DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "UPtr", hBitmap, "UPtr", Palette, "UPtr*", &pBitmap := 0)
    return pBitmap
}

Gdip_DisposeImage(pBitmap)
{
    return DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
}

Gdip_BitmapFromHWND(hwnd)
{
    CreateRect(&winRect := "", 0, 0, 0, 0) ;is 16 on both 32 and 64
    DllCall("GetWindowRect", "UPtr", hwnd, "UPtr", winRect.Ptr)
    Width := NumGet(winRect, 8, "UInt") - NumGet(winRect, 0, "UInt")
    Height := NumGet(winRect, 12, "UInt") - NumGet(winRect, 4, "UInt")
    hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
    PrintWindow(hwnd, hdc)
    pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
    SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
    return pBitmap
}

Gdip_GetPixel(pBitmap, x, y)
{
    DllCall("gdiplus\GdipBitmapGetPixel", "UPtr", pBitmap, "Int", x, "Int", y, "uint*", &ARGB := 0)
    return ARGB
}

Gdip_GetImageWidth(pBitmap)
{
    DllCall("gdiplus\GdipGetImageWidth", "UPtr", pBitmap, "uint*", &Width := 0)
    return Width
}

Gdip_GetImageHeight(pBitmap)
{
    DllCall("gdiplus\GdipGetImageHeight", "UPtr", pBitmap, "uint*", &Height := 0)
    return Height
}
