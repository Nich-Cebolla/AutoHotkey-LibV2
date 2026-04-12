
/**
 * @desc - Converts RGB to the numeric value of 0xRRGGBB.
 * @returns {Integer}
 */
RGB(r, g, b) {
    return Number('0x' Format('{:02X}{:02X}{:02X}', r & 0xFF, g & 0xFF, b & 0xFF))
}
/**
 * @desc - Converts RGB to win32 COLORREF value.
 * @returns {Integer}
 */
RGBToColorref(r := 0, g := 0, b := 0) {
    return (r & 0xFF) | ((g & 0xFF) << 8) | ((b & 0xFF) << 16)
}
/**
 * @desc - Converts RGB to the 0xRRGGBB hexadecimal representation as string.
 * @returns {String}
 */
RGBToHexString(r, g, b, prefix := '') {
    return prefix Format('{:02X}{:02X}{:02X}', r & 0xFF, g & 0xFF, b & 0xFF)
}
/**
 * @desc - Retrieves the RGB components from a COLORREF value.
 */
ParseColorref(colorref, &outR?, &outG?, &outB?) {
    outR := colorref & 0xFF
    outG := (colorref >> 8) & 0xFF
    outB := (colorref >> 16) & 0xFF
}
/**
 * @desc - Retrieves the RGB components from a 0xRRGGBB value.
 */
ParseRGB(color, &outR?, &outG?, &outB?) {
    color := color & 0xFFFFFF
    outR := (color >> 16) & 0xFF
    outG := (color >> 8) & 0xFF
    outB := color & 0xFF
}
/**
 * @desc - Converts ARGB to the numeric value of 0xAARRGGBB.
 * @returns {Integer}
 */
ARGB(a, r, g, b) {
    return Number('0x' Format('{:02X}{:02X}{:02X}{:02X}', a & 0xFF, r & 0xFF, g & 0xFF, b & 0xFF))
}
/**
 * @desc - Converts ARGB to the 0xAARRGGBB hexadecimal representation as string.
 * @returns {String}
 */
ARGBToHexString(a, r, g, b, prefix := '') {
    return prefix Format('{:02X}{:02X}{:02X}{:02X}', a & 0xFF, r & 0xFF, g & 0xFF, b & 0xFF)
}
/**
 * @desc - Retrieves the ARGB components from a 0xAARRGGBB value.
 */
ParseARGB(color, &outA?, &outR?, &outG?, &outB?) {
    color := color & 0xFFFFFFFF
    outA := (color >> 24) & 0xFF
    outR := (color >> 16) & 0xFF
    outG := (color >> 8) & 0xFF
    outB :=  color & 0xFF
}
/**
 * @desc - Retrieves the ARGB components from a 0xAARRGGBB value.
 * @returns {Integer}
 */
ColorrefToARGB(colorref, alpha := 255) {
    ParseColorref(colorref, &r, &g, &b)
    return ARGB(alpha, r, g, b)
}
/**
 * @desc - Converts an ARGB value to the 0xAARRGGBB representation as string.
 * @returns {String}
 */
PackedARGBToHexString(color, prefix := '') {
    return prefix Format('{:08X}', color & 0xFFFFFFFF)
}

/**
 * @example
 * GuiObj := Gui()
 * GuiObj.SetFont("s11 q5 bold")
 * GetColorFromUser(&r, &g, &b)
 * GuiObj.BackColor := RGBToHexString(r, g, b)
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
 * @desc - Converts COLORREF to the color hexadecimal representation as string.
 * @returns {String}
 */
ColorrefToHexString(colorref, prefix := '') {
    ParseColorref(colorref, &r, &g, &b)
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
    if RegExMatch(str, 'i)^(?:0x|#)?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$', &match) {
        return RGBToColorref(Number('0x' match[1]), Number('0x' match[2]), Number('0x' match[3]))
    } else {
        throw ValueError('Invalid input string.', , str)
    }
}
