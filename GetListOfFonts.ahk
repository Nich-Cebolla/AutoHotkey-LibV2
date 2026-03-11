
class GetListOfFonts {
    static __New() {
        global g_gdi32_EnumFontFamiliesExW, g_user32_GetDC, g_user32_ReleaseDC
        this.DeleteProp('__New')
        this.lf := Buffer(92, 0)
        this.cbList := CallbackCreate(CallbackList, 'F')
        this.cbMap := CallbackCreate(CallbackMap, 'F')

        if !IsSet(g_gdi32_EnumFontFamiliesExW) {
            g_gdi32_EnumFontFamiliesExW := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandleW', 'wstr', 'gdi32', 'ptr'), 'astr', 'EnumFontFamiliesExW', 'ptr')
        }
        if !IsSet(g_user32_GetDC) {
            g_user32_GetDC := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandleW', 'wstr', 'user32', 'ptr'), 'astr', 'GetDC', 'ptr')
        }
        if !IsSet(g_user32_ReleaseDC) {
            g_user32_ReleaseDC := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandleW', 'wstr', 'user32', 'ptr'), 'astr', 'ReleaseDC', 'ptr')
        }

        CallbackList(lpelfe, lpntme, FontType, lParam) {
            ObjFromPtrAddRef(lParam).Push(StrGet(lpelfe + 92, 'cp1200'))
            return 1
        }
        CallbackMap(lpelfe, lpntme, FontType, lParam) {
            ObjFromPtrAddRef(lParam).Set(StrGet(lpelfe + 92, 'cp1200'), 0)
            return 1
        }
    }
    /**
     * @desc - Enumerates the fonts on the system and returns an array of font names as string.
     * This calls
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-enumfontfamiliesexw EnuFontFamiliesExW}.
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
        NumPut('ushort', CharSet, this.lf, 23)
        hdc := DllCall(g_user32_GetDC, 'ptr', 0, 'ptr')
        list := []
        list.Capacity := 1024
        DllCall(g_gdi32_EnumFontFamiliesExW, 'ptr', hdc, 'ptr', this.lf, 'ptr', this.cbList, 'ptr', ObjPtr(list), 'uint', 0, 'uint')
        DllCall(g_user32_ReleaseDC, 'ptr', 0, 'ptr', hdc)
        list.Capacity := list.Length
        return list
    }
    /**
     * @desc - Enumerates the fonts on the system and returns an array of font names as string.
     * This calls
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-enumfontfamiliesexw EnuFontFamiliesExW}.
     *
     * @param {Integer} hdc - The device context to pass to `EnuFontFamiliesExW`.
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
    static WithDeviceContext(hdc, CharSet := 0) {
        NumPut('ushort', CharSet, this.lf, 23)
        list := []
        list.Capacity := 1024
        DllCall(g_gdi32_EnumFontFamiliesExW, 'ptr', hdc, 'ptr', this.lf, 'ptr', this.cbList, 'ptr', ObjPtr(list), 'uint', 0, 'uint')
        list.Capacity := list.Length
        return list
    }
    /**
     * @desc - Enumerates the fonts on the system and returns a `Map` object where each key is
     * a font name as string and each value is arbitrary.
     *
     * This calls
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-enumfontfamiliesexw EnuFontFamiliesExW}.
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
        NumPut('ushort', CharSet, this.lf, 23)
        hdc := DllCall(g_user32_GetDC, 'ptr', 0, 'ptr')
        list := Map()
        list.Capacity := 1024
        DllCall(g_gdi32_EnumFontFamiliesExW, 'ptr', hdc, 'ptr', this.lf, 'ptr', this.cbMap, 'ptr', ObjPtr(list), 'uint', 0, 'uint')
        DllCall(g_user32_ReleaseDC, 'ptr', 0, 'ptr', hdc)
        list.Capacity := list.Count
        return list
    }
    /**
     * @desc - Enumerates the fonts on the system and returns a `Map` object where each key is
     * a font name as string and each value is arbitrary.
     *
     * This calls
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-enumfontfamiliesexw EnuFontFamiliesExW}.
     *
     * @param {Integer} hdc - The device context to pass to `EnuFontFamiliesExW`.
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
    static ToMapWithDeviceContext(hdc, CharSet := 0) {
        NumPut('ushort', CharSet, this.lf, 23)
        list := Map()
        list.Capacity := 1024
        DllCall(g_gdi32_EnumFontFamiliesExW, 'ptr', hdc, 'ptr', this.lf, 'ptr', this.cbMap, 'ptr', ObjPtr(list), 'uint', 0, 'uint')
        list.Capacity := list.Count
        return list
    }
}
