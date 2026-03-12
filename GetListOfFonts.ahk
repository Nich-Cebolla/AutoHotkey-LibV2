
class GetListOfFonts {
    static __New() {
        global g_gdi32_EnumFontFamiliesExW, g_user32_GetDC, g_user32_ReleaseDC
        this.DeleteProp('__New')
        if !IsSet(g_gdi32_EnumFontFamiliesExW) {
            g_gdi32_EnumFontFamiliesExW := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandleW', 'wstr', 'gdi32', 'ptr'), 'astr', 'EnumFontFamiliesExW', 'ptr')
        }
        if !IsSet(g_user32_GetDC) {
            g_user32_GetDC := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandleW', 'wstr', 'user32', 'ptr'), 'astr', 'GetDC', 'ptr')
        }
        if !IsSet(g_user32_ReleaseDC) {
            g_user32_ReleaseDC := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandleW', 'wstr', 'user32', 'ptr'), 'astr', 'ReleaseDC', 'ptr')
        }
    }
    /**
     * @desc - Enumerates the fonts on the system with
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-enumfontfamiliesexw EnuFontFamiliesExW},
     * adding the font names to an array.
     *
     * This skips fonts that begin with "@".
     *
     * @param {Integer} [CharSet = 0] - One of the following:
     *
     *    |  Name                 |  Value  |
     *    |  ---------------------|-------  |
     *    |  ANSI_CHARSET         |  0      |
     *    |  DEFAULT_CHARSET      |  1      |
     *    |  SYMBOL_CHARSET       |  2      |
     *    |  SHIFTJIS_CHARSET     |  128    |
     *    |  HANGEUL_CHARSET      |  129    |
     *    |  HANGUL_CHARSET       |  129    |
     *    |  GB2312_CHARSET       |  134    |
     *    |  CHINESEBIG5_CHARSET  |  136    |
     *    |  OEM_CHARSET          |  255    |
     *    |  JOHAB_CHARSET        |  130    |
     *    |  HEBREW_CHARSET       |  177    |
     *    |  ARABIC_CHARSET       |  178    |
     *    |  GREEK_CHARSET        |  161    |
     *    |  TURKISH_CHARSET      |  162    |
     *    |  VIETNAMESE_CHARSET   |  163    |
     *    |  THAI_CHARSET         |  222    |
     *    |  EASTEUROPE_CHARSET   |  238    |
     *    |  RUSSIAN_CHARSET      |  204    |
     *    |  MAC_CHARSET          |  77     |
     *    |  BALTIC_CHARSET       |  186    |
     *
     * @returns {String[]}
     */
    static Call(CharSet := 0) {
        static lf := Buffer(92, 0)
        , cb := CallbackCreate(Callback, 'F')
        originalCritical := Critical('On')
        NumPut('uchar', CharSet, lf, 23)
        list := []
        list.Capacity := 1024
        hdc := DllCall(g_user32_GetDC, 'ptr', 0, 'ptr')
        DllCall(g_gdi32_EnumFontFamiliesExW, 'ptr', hdc, 'ptr', lf, 'ptr', cb, 'ptr', 0, 'uint', 0, 'uint')
        DllCall(g_user32_ReleaseDC, 'ptr', 0, 'ptr', hdc)
        list.Capacity := list.Length
        Critical(originalCritical)

        return list

        Callback(lpelfe, *) {
            if NumGet(lpelfe + 92, 'char') != 64 { ; if the first character is not "@"
                list.Push(StrGet(lpelfe + 92, 'cp1200'))
            }
            return 1
        }
    }
    /**
     * @desc - Enumerates the fonts on the system with
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-enumfontfamiliesexw EnuFontFamiliesExW},
     * adding the font names to a `Map` object where each key is a font name as string and each value
     * is arbitrary.
     *
     * This skips fonts that begin with "@".
     *
     * @param {Integer} [CharSet = 0] - One of the following:
     *
     *    |  Name                 |  Value  |
     *    |  ---------------------|-------  |
     *    |  ANSI_CHARSET         |  0      |
     *    |  DEFAULT_CHARSET      |  1      |
     *    |  SYMBOL_CHARSET       |  2      |
     *    |  SHIFTJIS_CHARSET     |  128    |
     *    |  HANGEUL_CHARSET      |  129    |
     *    |  HANGUL_CHARSET       |  129    |
     *    |  GB2312_CHARSET       |  134    |
     *    |  CHINESEBIG5_CHARSET  |  136    |
     *    |  OEM_CHARSET          |  255    |
     *    |  JOHAB_CHARSET        |  130    |
     *    |  HEBREW_CHARSET       |  177    |
     *    |  ARABIC_CHARSET       |  178    |
     *    |  GREEK_CHARSET        |  161    |
     *    |  TURKISH_CHARSET      |  162    |
     *    |  VIETNAMESE_CHARSET   |  163    |
     *    |  THAI_CHARSET         |  222    |
     *    |  EASTEUROPE_CHARSET   |  238    |
     *    |  RUSSIAN_CHARSET      |  204    |
     *    |  MAC_CHARSET          |  77     |
     *    |  BALTIC_CHARSET       |  186    |
     *
     * @returns {Map}
     */
    static ToMap(CharSet := 0) {
        static lf := Buffer(92, 0)
        , cb := CallbackCreate(Callback, 'F')
        originalCritical := Critical('On')
        NumPut('uchar', CharSet, lf, 23)
        list := Map()
        list.Capacity := 1024
        hdc := DllCall(g_user32_GetDC, 'ptr', 0, 'ptr')
        DllCall(g_gdi32_EnumFontFamiliesExW, 'ptr', hdc, 'ptr', lf, 'ptr', cb, 'ptr', 0, 'uint', 0, 'uint')
        DllCall(g_user32_ReleaseDC, 'ptr', 0, 'ptr', hdc)
        list.Capacity := list.Count
        Critical(originalCritical)

        return list

        Callback(lpelfe, *) {
            if NumGet(lpelfe + 92, 'char') != 64 { ; if the first character is not "@"
                list.Set(StrGet(lpelfe + 92, 'cp1200'), 0)
            }
            return 1
        }
    }
    /**
     * @desc - Enumerates the fonts on the system with
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-enumfontfamiliesexw EnuFontFamiliesExW},
     * adding each font name to a string, separated by a linefeed ( `n ) character. Calls
     * {@link https://www.autohotkey.com/docs/v2/lib/Sort.htm Sort} and returns the string.
     *
     * This skips fonts that begin with "@".
     *
     * @param {Integer} [CharSet = 0] - One of the following:
     *
     *    |  Name                 |  Value  |
     *    |  ---------------------|-------  |
     *    |  ANSI_CHARSET         |  0      |
     *    |  DEFAULT_CHARSET      |  1      |
     *    |  SYMBOL_CHARSET       |  2      |
     *    |  SHIFTJIS_CHARSET     |  128    |
     *    |  HANGEUL_CHARSET      |  129    |
     *    |  HANGUL_CHARSET       |  129    |
     *    |  GB2312_CHARSET       |  134    |
     *    |  CHINESEBIG5_CHARSET  |  136    |
     *    |  OEM_CHARSET          |  255    |
     *    |  JOHAB_CHARSET        |  130    |
     *    |  HEBREW_CHARSET       |  177    |
     *    |  ARABIC_CHARSET       |  178    |
     *    |  GREEK_CHARSET        |  161    |
     *    |  TURKISH_CHARSET      |  162    |
     *    |  VIETNAMESE_CHARSET   |  163    |
     *    |  THAI_CHARSET         |  222    |
     *    |  EASTEUROPE_CHARSET   |  238    |
     *    |  RUSSIAN_CHARSET      |  204    |
     *    |  MAC_CHARSET          |  77     |
     *    |  BALTIC_CHARSET       |  186    |
     *
     * @returns {String}
     */
    static ToString(CharSet := 0) {
        static lf := Buffer(92, 0)
        , cb := CallbackCreate(Callback, 'F')
        originalCritical := Critical('On')
        NumPut('uchar', CharSet, lf, 23)
        s := ''
        VarSetStrCapacity(&s, 1024 * 128)
        hdc := DllCall(g_user32_GetDC, 'ptr', 0, 'ptr')
        DllCall(g_gdi32_EnumFontFamiliesExW, 'ptr', hdc, 'ptr', lf, 'ptr', cb, 'ptr', 0, 'uint', 0, 'uint')
        DllCall(g_user32_ReleaseDC, 'ptr', 0, 'ptr', hdc)
        Critical(originalCritical)

        return Sort(SubStr(s, 1, -1), 'U')

        Callback(lpelfe, *) {
            if NumGet(lpelfe + 92, 'char') != 64 { ; if the first character is not "@"
                s .= StrGet(lpelfe + 92, 'cp1200') '`n'
            }
            return 1
        }
    }
}
