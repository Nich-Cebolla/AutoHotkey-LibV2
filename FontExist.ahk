/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/FontExist.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @param {Array|String} - If an array, an array of font typeface names. If a string, a comma-separated
 * list of font typeface names.
 */
GetFirstFont(FaceNames) {
    if !IsObject(FaceNames) {
        FaceNames := StrSplit(FaceNames, ',', '`s')
    }
    for faceName in FaceNames {
        if FontExist(faceName) {
            return faceName
        }
    }
}

/**
 * @description - Returns nonzero if the system's font collection contains a font with the
 * input typeface name.
 * @param {String} FaceName - The font typeface name.
 * @returns {Integer} - If the font is found, returns 1. Else 0.
 */
FontExist(FaceName) {
    static maxLen := 31
    LOGFONTW := Buffer(92, 0)  ; LOGFONTW struct size = 92 bytes
    hdc := DllCall('GetDC', 'ptr', 0, 'ptr')
    if Min(StrLen(FaceName), maxLen) == maxLen {
        FaceName := SubStr(FaceName, 1, maxLen)
    }
    bytes := StrPut(FaceName, 'UTF-16')
    StrPut(FaceName, LOGFONTW.Ptr + 28, maxLen + 1, 'UTF-16')

    Found := false

    Callback := CallbackCreate(EnumFontProc)
    lParam := Buffer(A_PtrSize + 4)
    buf := Buffer(bytes)
    StrPut(FaceName, buf, bytes / 2, 'UTF-16')
    NumPut('ptr', buf.Ptr, lParam)
    NumPut('uint', 0, lParam, A_PtrSize)
    DllCall('gdi32\EnumFontFamiliesExW', 'ptr', hdc, 'ptr', LOGFONTW, 'ptr', Callback, 'ptr', lParam.Ptr, 'uint', 0, 'uint')
    CallbackFree(Callback)
    DllCall('ReleaseDC', 'ptr', 0, 'ptr', hdc)

    return NumGet(lParam, A_PtrSize, 'uint')

    EnumFontProc(lpelfe, lpntme, FontType, lParam) {
        if StrGet(lpelfe + 28, maxLen, 'UTF-16') = StrGet(NumGet(lParam, 0, 'ptr'), maxLen, 'UTF-16') {
            NumPut('uint', 1, lParam, A_PtrSize)
            return 0
        }
        return 1
    }
}
