
RGB(r := 0, g := 0, b := 0) {
    return (r & 0xFF) | ((g & 0xFF) << 8) | ((b & 0xFF) << 16)
}
ParseColorref(colorref, &OutR?, &OutG?, &OutB?) {
    OutR := colorref & 0xFF
    OutG := (colorref >> 8) & 0xFF
    OutB := (colorref >> 16) & 0xFF
}
ARGB(a := 0, r := 0, g := 0, b := 0) {
    return ((a & 0xFF) << 24) | ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF)
}
ParseARGB(color, &OutA?, &OutR?, &OutG?, &OutB?) {
    OutA := (color >> 24) & 0xFF
    OutR := (color >> 16) & 0xFF
    OutG := (color >> 8) & 0xFF
    OutB := color & 0xFF
}
ColorrefToARGB(colorref, alpha := 255) {
    r := colorref & 0xFF
    g := (colorref >> 8) & 0xFF
    b := (colorref >> 16) & 0xFF
    return ARGB(alpha, r, g, b)
}

/**
 * @example
 * GuiObj := Gui()
 * GuiObj.SetFont("s11 q5 bold")
 * GetColorFromUser(&r, &g, &b)
 * GuiObj.BackColor := RGB(r, g, b)
 * txt := GuiObj.Add("Text", , "Hello, world!")
 * if RGBToBrightness(r, g, b) >= 130 {
 *    txt.SetFont("c0x" RGBToHexString(0, 0, 0)) ; use a dark font
 * } else {
 *    txt.SetFont("c0x" RGBToHexString(255, 255, 255)) ; use a light font
 * }
 * GuiObj.Show()
 *
 * GetColorFromUser(&r, &g, &b) {
 *     r := Random(0, 255)
 *     g := Random(0, 255)
 *     b := Random(0, 255)
 * }
 * @
 *
 * @returns {Float} - A float between 0 and 255 indicating the perceived brightness of a color. 0 is
 * totally black, 255 is totally white. A value of `130` is an approximate threshold between what someone
 * may perceive as relatively light vs. dark, though this varies by individual, context, device,
 * and display settings.
 */
RGBToBrightness(r, g, b) {
    return sqrt(0.299 * R ** 2 + 0.587 * G ** 2 + 0.114 * B ** 2)
}
/**
 * @desc - Takes a string in the format "R<n> G<n> B<n>" and returns a COLORREF as integer, where
 * <n> is an integer between 0-255, inclusive. For example, "R0 G245 B250".
 * @param {String} str - A string in the format "R<n> G<n> B<n>". For example, "R155 G4 B212".
 * @returns {Integer} - The COLORREF value.
 * @throws {ValueError} - "The string must be in the format `"R<n> G<n> B<n>`" where <n> is an
 * integer between 0-255, inclusive. For example, `"R0 G200 B250`"."
 */
RGBString(str) {
    if RegExMatch(str, '[rR]\s*(\d+)\s*[gG]\s*(\d+)\s*[bB]\s*(\d+)', &match) {
        return (match[1] & 0xFF) | ((match[2] & 0xFF) << 8) | ((match[3] & 0xFF) << 16)
    } else {
        throw ValueError('The string must be in the format "R<n> G<n> B<n>" where <n> is an integer between 0-255, inclusive. For example, "R0 G200 B250".', , str)
    }
}
ColorrefToHexString(colorref, prefix := '') {
    ParseColorRef(colorref, &r, &g, &b)
    str := prefix
    s := Format('{:X}', r)
    if StrLen(s) = 1 {
        str .= '0' s
    } else {
        str .= s
    }
    s := Format('{:X}', g)
    if StrLen(s) = 1 {
        str .= '0' s
    } else {
        str .= s
    }
    s := Format('{:X}', b)
    if StrLen(s) = 1 {
        return str '0' s
    } else {
        return str s
    }
}
/**
 * @desc - Converts a hexadecimal string representation of a color value to the COLORREF integer.
 *
 * @param {String} str - The string. The string can optionally have a "0x" prefix or "#" prefix.
 *
 * These are each valid:
 * - 0xFFFFFF
 * - #FFFFFF
 * - FFFFFF
 */
HexToColorref(str) {
    if RegExMatch(str, 'iS)(?:0x|#|^)([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})', &match) {
        return RGB(Number('0x' match[1]), Number('0x' match[2]), Number('0x' match[3]))
    } else {
        throw ValueError('Invalid input string.', , str)
    }
}
