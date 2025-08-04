/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/structs/LOGFONT.ahk
    Author: Nich-Cebolla
    Version: 2.0.0
    License: MIT
*/

/*
    See the bottom of the file for static Windows API symbols related to fonts.

    Note you cannot use an Ahk `Gui` handle with `Logfont`; it has to be a `Gui.Control` or some
    other type of window.
*/


/**
 * @classdesc - A wrapper around the LOGFONT structure.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/dimm/ns-dimm-logfontw}
 */
class Logfont {
    static __New() {
        this.DeleteProp('__New')
        global WM_GETFONT := 0x0031, WM_SETFONT := 0x0030, LF_DEFAULT_ENCODING := 'UTF-16'
        Proto := this.Prototype
        Proto.Encoding := LF_DEFAULT_ENCODING
        /**
         * The structure's size.
         * @memberof Logfont
         * @instance
         */
        Proto.Size :=
        4 + ; LONG  lfHeight                    0
        4 + ; LONG  lfWidth                     4
        4 + ; LONG  lfEscapement                8
        4 + ; LONG  lfOrientation               12
        4 + ; LONG  lfWeight                    16
        1 + ; BYTE  lfItalic                    20
        1 + ; BYTE  lfUnderline                 21
        1 + ; BYTE  lfStrikeOut                 22
        1 + ; BYTE  lfCharSet                   23
        1 + ; BYTE  lfOutPrecision              24
        1 + ; BYTE  lfClipPrecision             25
        1 + ; BYTE  lfQuality                   26
        1 + ; BYTE  lfPitchAndFamily            27
        64  ; WCHAR lfFaceName[LF_FACESIZE]     28
        Proto.Handle := Proto.Hwnd := 0
        Proto.DefineProp('Clone', { Call: LF_CloneBuffer })
    }
    /**
     * @description - Enumerates the fonts available on the system. You can supply a list of face names,
     * a character set, or both, to limit the fonts that get enumerated. If you provide neither a
     * face name nor a character set, then one of each face name on the system gets enumerated. This can
     * be a lengthy process, and so you typically will want to narrow the subset.
     *
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-enumfontfamiliesexw}.
     *
     * The expected use for this function is to evaluate the available fonts and score them according
     * to some characteristics defined by your callback function. Then, when the function returns,
     * your code can select the highest scoring font for whatever task the font is needed.
     *
     * An effective way to make use of the `lParam` parameter is to pass the ptr address of an
     * AHK object, and in the body of your callback function call `ObjFromPtrAddRef` to obtain a
     * reference to the object.
     *
     * Remember that the memory associated with the structures passed to your callback function is
     * managed by the system. If you use `EnumFontFamExProcParams`, you must not cache a reference
     * to that object. If you need to have access to the data outside of your callback function,
     * call the method "Clone", which will copy the memory into an AHK buffer.
     *
     * To instruct the enumerator to continue to enumerate fonts, your callback function must return
     * a nonzero number. To instruct the enumerator to cease enumerating fonts, your callback function
     * must return zero. In the context of `Logfont.EnumFonts`, if you provide a list of facenames,
     * then returning zero will only stop enumerating fonts for the face name that was being evaluated
     * at the time `Callback` returned zero. The next face name will be iterated and evaluated.
     *
     * The return value of `EnumFontFamiliesExW` (that is, the last value returned by `Callback` for
     * a given face name as described above) is added to an array and the array is returned by
     * `Logfont.EnumFonts`. For consistency, this is true even if you do not provide a face name or
     * if you provide only one face name; the return value is added to an array and that array is
     * returned in all cases.
     *
     * Here's an example demonstrating the usage of "Clone" and the `lParam` parameter.
     *
     * @example
     * faceNames := 'Roboto Mono,Ubuntu Mono,Cascadia Mono'
     * obj := []
     * result := Logfont.EnumFonts(EnumFontFamExProc, faceNames, , ObjPtr(obj))
     *
     * for params in obj {
     *     ; do something with the objects in the array
     * }
     *
     * EnumFontFamExProc(lpelfe, lpntme, FontType, lParam) {
     *     arr := ObjFromPtrAddRef(lParam)
     *     params := EnumFontFamExProcParams(lpelfe, lpntme, FontType)
     *     arr.Push(params.Clone())
     *     return 1
     * }
     * @
     *
     * The following describes various combinations of lfCharSet and lfFaceName values. If it
     * states `lfFaceName = ""`, that means the "lfFaceName" member of the LOGFONT structure has a
     * value of an empty string, which you can accomplish by literally setting `lf.FaceName := ""`,
     * or in the context of `Logfont.EnumFonts`, leave `ListFaceName` unset.
     *
     * lfCharSet = DEFAULT_CHARSET (1)
     * lfFaceName = ""
     * Enumerates all uniquely-named fonts within all character sets. If there are two fonts with
     * the same name, only one is enumerated.
     *
     * lfCharSet = DEFAULT_CHARSET (1)
     * lfFaceName = a specific font
     * Enumerates all character sets and styles in a specific font.
     *
     * lfCharSet = a specific character set
     * lfFaceName = ""
     * Enumerates all styles of all fonts in the specific character set.
     *
     * lfCharSet = a specific character set
     * lfFaceName = a specific font
     * Enumerates all styles of a font in a specific character set.
     *
     * @param {Integer} Callback - The func or callable object to use with `EnumFontFamiliesExW`.
     * `Callback` must return a nonzero value to continue the enumeration process. To stop the
     * enumeration process, `Callback` must return zero.
     * @param {String|String[]} [ListFaceName = ""] - Set `ListFaceName` to one or more face names to have
     * `Callback` called for each font matching the face name. If an array, an array of font typeface
     * names. If a string, a comma-separated list of font typeface names. Leave `ListFaceName` unset
     * to instruct the enumerator to enumerate all fonts in the character set defined by `CharSet`.
     * @param {Integer} [CharSet = 1] - If set to DEFAULT_CHARSET (1), the function enumerates all
     * uniquely-named fonts in all character sets. (If there are two fonts with the same name, only
     * one is enumerated). If set to a valid character set value, the function enumerates only fonts
     * in the specified character set. Also see the notes in the description of {@link Logfont.EnumFonts}.
     * @param {Integer} [lParam = 0] - The pointer to pass to the `lParam` parameter. This value also
     * gets passed to the fourth parameter of `Callback`.
     * @returns {*} -
     */
    static EnumFonts(Callback, ListFaceName := '', CharSet := 1, lParam := 0) {
        static maxLen := 32
        if !IsObject(ListFaceName) {
            ListFaceName := StrSplit(ListFaceName, ',', '`s')
        }
        lf := Logfont()
        lf.CharSet := CharSet
        cb := CallbackCreate(Callback)
        result := []
        hdc := DllCall('GetDC', 'ptr', 0, 'ptr')
        if ListFaceName.Length {
            for faceName in ListFaceName {
                lf.FaceName := faceName
                result.Push(DllCall('gdi32\EnumFontFamiliesExW', 'ptr', hdc, 'ptr', lf, 'ptr', cb, 'ptr', lParam, 'uint', 0, 'uint'))
            }
        } else {
            lf.FaceName := ''
            result.Push(DllCall('gdi32\EnumFontFamiliesExW', 'ptr', hdc, 'ptr', lf, 'ptr', cb, 'ptr', lParam, 'uint', 0, 'uint'))
        }
        DllCall('ReleaseDC', 'ptr', 0, 'ptr', hdc)
        CallbackFree(cb)

        return result
    }
    /**
     * @description - Returns the first font facename that exists on the system from a list
     * of names.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-enumfontfamiliesexw}.
     * @param {String|String[]} ListFaceName - If an array, an array of font typeface names. If a string,
     * a comma-separated list of font typeface names.
     * @param {Integer} [Charset = 1] - See {@link Logfont.EnumFonts} for details about how
     * this parameter interacts with the face names.
     * @param {*} [Callback] - The func or callable object to use with `EnumFontFamiliesExW`.
     * `Callback` must return a nonzero value to continue the enumeration process. To stop the
     * enumeration process, `Callback` must return zero. If `Callback` returns zero, `Logfont.FontExist`
     * stops iterating the names listed by `ListFaceName` and returns the name that was being
     * evaluated. If `Callback` never returns zero, `Logfont.FontExist` returns an empty string.
     *
     * The value passed to the fourth parameter of `Callback` is a pointer to the face name that
     * is being evaluated. To get that as a string, in the body of `Callback` include this
     * (where "lParam" is the symbol used for the fourth parameter):
     * @example
     *  faceName := StrGet(lParam, LF_DEFAULT_ENCODING)
     * @
     *
     * The default callback compares the name of the font to the item in the list that is being
     * evaluated, ignoring all other characteristics of the font.
     * @param {String} [Style = "Regular"] - If `Callback` is set, `Style` has no effect. If `Callback`
     * is unset, then the default callback is used. The default callback compares the names in
     * `ListFaceName` with the full name of the fonts being enumerated. The full name often includes
     * a style keyword, e.g. "Regular", "Bold", "Italic", after the font name. In order for the
     * default callback to return zero (ending the enumeration because a font was found), the
     * font's name must include both the name from `ListFaceName` and the style keyword. The comparison
     * is performed by using `InStr` on both segments; that is, there can be any substring in-between
     * the style keyword and the font name, as long as both `InStr(FontFullName, faceName)` and
     * `InStr(FontFullName, Style)` returns nonzero.
     *
     * Set `Style` to an empty string to ignore this behavior and to only require the names to match
     * with the face names in `ListFaceNames`.
     * @returns {String} - Returns the first found name from the list, if one is found. Else, returns
     * an empty string.
     */
    static FontExist(ListFaceName, CharSet := 1, Style := 'Regular', Callback?) {
        if !IsObject(ListFaceName) {
            ListFaceName := StrSplit(ListFaceName, ',', '`s')
        }
        lf := Logfont()
        lf.CharSet := CharSet
        result := ''
        hdc := DllCall('GetDC', 'ptr', 0, 'ptr')
        cb := CallbackCreate(Callback ?? Style ? EnumFontProc1 : EnumFontProc2)
        for faceName in ListFaceName {
            lf.FaceName := faceName
            if !DllCall('gdi32\EnumFontFamiliesExW', 'ptr', hdc, 'ptr', Lf, 'ptr', cb, 'ptr', Lf.Ptr + 28, 'uint', 0, 'uint') {
                result := faceName
                break
            }
        }
        DllCall('ReleaseDC', 'ptr', 0, 'ptr', hdc)
        CallbackFree(cb)

        return result

        EnumFontProc1(lpelfe, lpntme, FontType, lParam) {
            if InStr(StrGet(lpelfe + Logfont.Prototype.Size, LF_DEFAULT_ENCODING), StrGet(lParam, LF_DEFAULT_ENCODING))
            && InStr(StrGet(lpelfe + Logfont.Prototype.Size, LF_DEFAULT_ENCODING), Style) {
                return 0
            }
            return 1
        }
        EnumFontProc2(lpelfe, lpntme, FontType, lParam) {
            if StrGet(lpelfe + 28, LF_DEFAULT_ENCODING) = StrGet(lParam, LF_DEFAULT_ENCODING) {
                return 0
            }
            return 1
        }
    }
    /**
     * @description - Creates a `Logfont` object using a ptr address instead of a buffer. The
     * expected use case for this is when a Windows API function returns a LOGFONT structure. In
     * such cases, the system is managing that memory, and so it should be assumed that the memory
     * will only be available temporarily. When using `Logfont.FromPtr`, do not cache a reference to
     * the `Logfont` object; use it then let it go out of scope, or copy its values to an AHK buffer
     * using `Logfont.Prototype.Clone`.
     * @param {Integer} Ptr - The address of the LOGFONT structure.
     */
    static FromPtr(Ptr) {
        lf := { Buffer: { Ptr: Ptr, Size: this.Prototype.Size }, Handle: 0 }
        ObjSetBase(lf, this.Prototype)
        return lf
    }
    /**
     * Constructs a new `Logfont` object, optionally associating the object with a window handle.
     * @class
     *
     * @example
     *  g := Gui()
     *  edt := g.Add("Edit", "w100 r5 vEdt", "Hello, world!")
     *  g.Show()
     *  lf := Logfont(edt.Hwnd)
     *  if faceName := Logfont.FontExist("Roboto Mono,Ubuntu Mono,Cascadia Mono") {
     *      lf.FaceName := faceName
     *  } else {
     *      ; Get a generic monospaced font
     *      lf.FaceName := ""
     *      lf.Family := 0x30       ; FF_MODERN
     *      lf.Pitch := 1           ; FIXED_PITCH
     *  }
     *  lf.FontSize := 15
     *  lf.Apply()
     * @
     *
     * @param {Integer} [Hwnd = 0] - The window handle to associate with the `Logfont` object. If
     * `Hwnd` is set with a nonzero value, `Logfont.Prototype.Call` is called to initialize this
     * `Logfont` object's properties with values obtained from the window. If `Hwnd` is zero, this
     * `Logfont` object's properties will all be zero.
     * @param {String} [Encoding] - The encoding used when getting and setting string values associated
     * with LOGFONT members. The default encoding used by `Logfont` objects is UTF-16.
     * @return {Logfont}
     */
    __New(Hwnd := 0, Encoding?) {
        /**
         * A reference to the buffer object which is used as the LOGFONT structure.
         * @memberof Logfont
         * @instance
         */
        this.Buffer := Buffer(this.Size, 0)
        if IsSet(Encoding) {
            /**
             * The encoding to use with `StrPut` and `StrGet` when handling strings. Not seen
             * here, the value of `Logfont.Prototype.Encoding` is "UTF-16".
             * @memberof Logfont
             * @instance
             */
            this.Encoding := Encoding
        }
        /**
         * The handle to the font object created by this object. Initially, this object
         * will not have yet created an object, so the handle is `0` until `Logfont.Prototype.Apply`
         * is called.
         * @memberof Logfont
         * @instance
         */
        this.Handle := 0
        /**
         * The handle to the window associated with this object, if any.
         * @memberof Logfont
         * @instance
         */
        if this.Hwnd := Hwnd {
            this()
        }
    }
    /**
     * @description - Calls `CreateFontIndirectW` then sends WM_SETFONT to the window associated
     * with this `Logfont` object.
     * @param {Boolean} [Redraw = true] - The value to pass to the `lParam` parameter when sending
     * WM_SETFONT. If true, the control redraws itself.
     */
    Apply(Redraw := true) {
        hFontOld := SendMessage(WM_GETFONT,,, this.Hwnd)
        Flag := this.Handle = hFontOld
        this.Handle := DllCall('CreateFontIndirectW', 'ptr', this, 'ptr')
        SendMessage(WM_SETFONT, this.Handle, Redraw, this.Hwnd)
        if Flag {
            DllCall('DeleteObject', 'ptr', hFontOld, 'int')
        }
    }
    /**
     * @description - Sends WM_GETFONT to the window associated with this `Logfont` object, updating
     * this object's properties with the values obtained from the window.
     * @throws {OSError} - Failed to get font object.
     */
    Call(*) {
        hFont := SendMessage(WM_GETFONT,,, this.Hwnd)
        if !DllCall('Gdi32.dll\GetObject', 'ptr', hFont, 'int', this.Size, 'ptr', this, 'uint') {
            throw OSError('Failed to get font object.', -1)
        }
    }
    /**
     * @description - Copies the bytes from this `Logfont` object's buffer to another buffer.
     * @param {Logfont|Buffer|Object} [Buf] - If set, one of the following three kinds of objects:
     * - A `Logfont` object.
     * - A `Buffer` object.
     * - An object with properties { Ptr, Size }.
     *
     * The size of the buffer must be at least `Logfont.Prototype.Size + Offset`.
     *
     * If unset, `Logfont.Prototype.Clone` will create a buffer of adequate size.
     * @param {Integer} [Offset = 0] - The byte offset from the start of `Buf` into which the LOGFONT
     * structure will be copied. If `Buf` is unset, then the LOGFONT structure will begin at
     * byte `Offset` within the buffer created by `Logfont.Prototype.Clone`.
     * @param {Boolean} [MakeInstance = true] - If true, then an instance of `Logfont` will be
     * created and returned by the function. If false, then only the buffer object will be returned;
     * the object will not have any of the properties or methods associated with the `Logfont` class.
     * @returns {Buffer|Logfont} - Depending on the value of `MakeInstance`, the `Buffer` object
     * or the `Logfont` object.
     * @throws {Error} - The input buffer's size is insufficient.
     */
    Clone(Buf?, Offset := 0, MakeInstance := true) {
        ; This is overridden
    }
    /**
     * @description - If a font object has been created by this `Logfont` object, the font object
     * is deleted.
     */
    DisposeFont() {
        if this.Handle {
            DllCall('DeleteObject', 'ptr', this.Handle)
            this.Handle := 0
        }
    }
    /**
     * @description - Calls `EnumFontFamiliesExW`.
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-enumfontfamiliesexw}.
     *
     * This library provides a helper function to simplify the usage of the values passed to your
     * callback function. Your callback function should include a call to {@link EnumFontFamExProcParams},
     * described below.
     *
     * As explained within the documentation for `EnumFontFamExProc`
     * {@link https://learn.microsoft.com/en-us/previous-versions/dd162618(v=vs.85)}
     * the callback function will receive:
     * 1. Pointer to a LOGFONT structure.
     * 2. Pointer to a TEXTMETRIC structure.
     * 3. An integer indicating the type of font.
     * 4. The lParam.
     *
     * If you pass paramaters 1-3 to {@link EnumFontFamExProcParams}, what you receive is an object
     * that has processed the parameters into familiar AHK objects that have their properties mapped
     * to the structures' byte offsets. Also, for TrueType fonts, you will have access to the
     * {@link FontSignature} object, which makes use of two bit fields to provide you with all the
     * information available about the font that currently is being evaluated.
     *
     * When using {@link EnumFontFamExProcParams}, do not cache a reference to the object. You must
     * only use it within the scope of your callback function because the system is managing that
     * memory. If you need values outside of the callback function's scope, you'll have to copy
     * the memory into an AHK buffer. You can use `memmove`
     * {@link https://learn.microsoft.com/en-us/cpp/c-runtime-library/reference/memmove-wmemmove?view=msvc-170}.
     *
     * See {@link EnumFontFamExProcParams}, {@link TextMetric}, {@link NewTextMetric},
     * {@link NewTextMetricEx}, and {@link FontSignature} for details about those objects.
     *
     * @param {*} Callback - The function or callable object. `Callback` must return a nonzero value
     * to continue the enumeration process. To stop the enumeration process, `Callback` must return
     * zero.
     * @param {Integer|Buffer} [lParam = 0] - The value to pass to `lParam` that will also get passed
     * to `Callback`.
     * @returns {*} - The last value returned by `Callback`.
     */
    EnumFontFamilies(Callback, lParam := 0) {
        result := ''
        cb := CallbackCreate(Callback)
        hdc := DllCall('GetDC', 'ptr', 0, 'ptr')
        result := DllCall('gdi32\EnumFontFamiliesExW', 'ptr', hdc, 'ptr', this, 'ptr', cb, 'ptr', lParam, 'uint', 0, 'uint')
        DllCall('ReleaseDC', 'ptr', 0, 'ptr', hdc)
        CallbackFree(cb)
        return result
    }
    /**
     * @description - Updates a property's value and calls `Logfont.Prototype.Apply` immediately afterward.
     * @param {String} Name - The name of the property.
     * @param {String|Number} Value - The value.
     */
    Set(Name, Value) {
        this.%Name% := Value
        this.Apply()
    }
    __Delete() {
        if this.Handle {
            DllCall('DeleteObject', 'ptr', this.Handle)
            this.Handle := 0
        }
    }
    /**
     * Gets or sets the character set.
     * @memberof Logfont
     * @instance
     */
    CharSet {
        Get => NumGet(this, 23, 'uchar')
        Set => NumPut('uchar', Value, this, 23)
    }
    /**
     * Gets or sets the behavior when part of a character is clipped.
     * @memberof Logfont
     * @instance
     */
    ClipPrecision {
        Get => NumGet(this, 25, 'uchar')
        Set => NumPut('uchar', Value, this, 25)
    }
    /**
     * If this `Logfont` object is associated with a window, returns the dpi for the window.
     * @memberof Logfont
     * @instance
     */
    Dpi => this.Hwnd ? DllCall('User32\GetDpiForWindow', 'Ptr', this.Hwnd, 'UInt') : ''
    /**
     * Gets or sets the escapement measured in tenths of a degree.
     * @memberof Logfont
     * @instance
     */
    Escapement {
        Get => NumGet(this, 8, 'int')
        Set => NumPut('int', Value, this, 8)
    }
    /**
     * Gets or sets the font facename.
     * @memberof Logfont
     * @instance
     */
    FaceName {
        Get => StrGet(this.ptr + 28, 32, this.Encoding)
        Set => StrPut(SubStr(Value, 1, 31), this.Ptr + 28, 32, this.Encoding)
    }
    /**
     * Gets or sets the font family.
     * @memberof Logfont
     * @instance
     */
    Family {
        Get => NumGet(this, 27, 'uchar') & 0xF0
        Set => NumPut('uchar', (this.Family & 0x0F) | (Value & 0xF0), this, 27)
    }
    /**
     * Gets or sets the font size. "FontSize" requires that the `Logfont` object is associated
     * with a window handle because it needs a dpi value to work with.
     * @memberof Logfont
     * @instance
     */
    FontSize {
        Get => this.Hwnd ? Round(this.Height * -72 / this.Dpi, 2) : ''
        Set => this.Height := Round(Value * this.Dpi / -72)
    }
    /**
     * Gets or sets the font height.
     * @memberof Logfont
     * @instance
     */
    Height {
        Get => NumGet(this, 0, 'int')
        Set => NumPut('int', Value, this, 0)
    }
    /**
     * Gets or sets the italic flag.
     * @memberof Logfont
     * @instance
     */
    Italic {
        Get => NumGet(this, 20, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 20)
    }
    /**
     * Gets or sets the orientation measured in tenths of degrees.
     * @memberof Logfont
     * @instance
     */
    Orientation {
        Get => NumGet(this, 12, 'int')
        Set => NumPut('int', Value, this, 12)
    }
    /**
     * Gets or sets the behavior when multiple fonts with the same name exist on the system.
     * @memberof Logfont
     * @instance
     */
    OutPrecision {
        Get => NumGet(this, 24, 'uchar')
        Set => NumPut('uchar', Value, this, 24)
    }
    /**
     * Gets or sets the pitch.
     * @memberof Logfont
     * @instance
     */
    Pitch {
        Get => NumGet(this, 27, 'uchar') & 0x0F
        Set => NumPut('uchar', (this.Pitch & 0xF0) | (Value & 0x0F), this, 27)
    }
    /**
     * Returns the pointer to the buffer.
     * @memberof Logfont
     * @instance
     */
    Ptr => this.Buffer.Ptr
    /**
     * Gets or sets the quality flag.
     * @memberof Logfont
     * @instance
     */
    Quality {
        Get => NumGet(this, 26, 'uchar')
        Set => NumPut('uchar', Value, this, 26)
    }
    /**
     * Gets or sets the strikeout flag.
     * @memberof Logfont
     * @instance
     */
    StrikeOut {
        Get => NumGet(this, 22, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 22)
    }
    /**
     * Gets or sets the underline flag.
     * @memberof Logfont
     * @instance
     */
    Underline {
        Get => NumGet(this, 21, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 21)
    }
    /**
     * Gets or sets the weight flag.
     * @memberof Logfont
     * @instance
     */
    Weight {
        Get => NumGet(this, 16, 'int')
        Set => NumPut('int', Value, this, 16)
    }
    /**
     * Gets or sets the width.
     * @memberof Logfont
     * @instance
     */
    Width {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
    }
}

/**
 * @classdesc - To be used with the Windows API function `EnumFontFamiliesExW`. Do not use with
 * the ANSI version (EnumFontFamiliesExA).
 *
 * Pass the first three parameters received by the callback function to
 * `EnumFontFamExProcParams`, and the values will be processed into familiar AHK objects with
 * the properties mapped to the structure byte offsets.
 *
 * When using `EnumFontFamExProcParams`, do not cache a reference to the object. You must
 * only use it within the scope of your callback function because the system is managing that
 * memory. If you need values outside of the callback function's scope, you'll have to copy
 * the memory into an AHK buffer. Simply call `EnumFontFamExProcParams.Prototype.Clone` to
 * copy the memory into an AHK buffer.
 *
 * See the description above {@link Logfont.EnumFonts} for an example.
 */
class EnumFontFamExProcParams {
    /**
     * For TrueType fonts, the object set to the property "TextMetric" has two properties.
     * - "TextMetric" (enumFontFamParamsObj.TextMetric.TextMetric) - A {@link NewTextMetric} object.
     * - "FontSignature" (enumFontFamParamsObj.TextMetric.FontSignature) - A {@link FontSignature} object.
     *
     * For all other fonts, the object set to the property "TextMetric" is a `TextMetric` object.
     * @class
     * @param {Integer} lpelfe - The first parameter received by `EnumFontFamExProc`, a pointer to
     * a LOGFONT structure.
     * @param {Integer} lpntme - The second parameter received by `EnumFontFamExProc`, a pointer
     * to a TEXTMETRIC or NEWTEXTMETRICEX structure.
     * @param {Integer} FontType - The third parameter received by `EnumFontFamExProc`, a value
     * indicating the font type.
     */
    __New(lpelfe, lpntme, FontType) {
        this.FontType := FontType
        if this.IsTrueType {
            /**
             * See the description above {@link EnumFontFamExProcParams#__New}.
             * @memberof EnumFontFamExProcParams
             * @instance
             */
            this.TextMetric := NewTextMetricEx(lpntme)
        } else {
            this.TextMetric := TextMetric(lpntme)
        }
        /**
         * A `Logfont` object.
         * @memberof EnumFontFamExProcParams
         * @instance
         */
        this.Logfont := Logfont.FromPtr(lpelfe)
        /**
         * The full name of the font, e.g. "Arial Bold".
         * @memberof EnumFontFamExProcParams
         * @instance
         */
        this.FullName := StrGet(lpelfe + this.Logfont.Size, LF_DEFAULT_ENCODING)
    }
    Clone() {
        Obj := {
            FontType: this.FontType
          , FullName: this.FullName
          , Logfont: this.Logfont.Clone()
          , TextMetric: this.TextMetric.Clone()
        }
        ObjSetBase(Obj, EnumFontFamExProcParams.Prototype)
        return Obj
    }

    /**
     * A boolean indicating if the font is available only on the current output device
     * (e.g. a printer), not rendered via the Windows GDI font engine.
     * @memberof EnumFontFamExProcParams
     * @instance
     */
    IsDevice => this.FontType & 0x0002
    /**
     * A boolean indicating if the font is a raster font.
     * @memberof EnumFontFamExProcParams
     * @instance
     */
    IsRaster => this.FontType & 0x0001
    /**
     * A boolean indicating if the font is a TrueType font.
     * @memberof EnumFontFamExProcParams
     * @instance
     */
    IsTrueType => this.FontType & 0x0004
}

/**
 * @classdesc - Maps a pointer received by a Windows API function to object properties.
 *
 * Do not cache a reference to this object unless you are certain that the AHK process is
 * managing the memory. Typically the system will be managing the memory. If you need
 * access to the values outside of the scope which this object is constructed, copy
 * the memory to an AHK buffer using `memmove` or a similar function.
 * {@link https://learn.microsoft.com/en-us/cpp/c-runtime-library/reference/memmove-wmemmove?view=msvc-170}.
 */
class TextMetric {
    static __New() {
        this.DeleteProp('__New')
        /**
         * The structure's size.
         * @memberof TextMetric
         * @instance
         */
        this.Prototype.Size :=
        4 +    ; LONG tmHeight              0
        4 +    ; LONG tmAscent              4
        4 +    ; LONG tmDescent             8
        4 +    ; LONG tmInternalLeading     12
        4 +    ; LONG tmExternalLeading     16
        4 +    ; LONG tmAveCharWidth        20
        4 +    ; LONG tmMaxCharWidth        24
        4 +    ; LONG tmWeight              28
        4 +    ; LONG tmOverhang            32
        4 +    ; LONG tmDigitizedAspectX    36
        4 +    ; LONG tmDigitizedAspectY    40
        2 +    ; WCHAR tmFirstChar          44
        2 +    ; WCHAR tmLastChar           46
        2 +    ; WCHAR tmDefaultChar        48
        2 +    ; WCHAR tmBreakChar          50
        1 +    ; BYTE tmItalic              52
        1 +    ; BYTE tmUnderlined          53
        1 +    ; BYTE tmStruckOut           54
        1 +    ; BYTE tmPitchAndFamily      55
        1 +    ; BYTE tmCharSet             56
        3      ; alignment padding
        this.Prototype.DefineProp('Clone', { Call: LF_CloneBuffer })
    }
    /**
     * @class
     * @param {Integer} Ptr - The pointer to the structure.
     */
    __New(Ptr) {
        /**
         * A faux buffer object.
         * @memberof TextMetric
         * @instance
         */
        this.Buffer := { Ptr: Ptr, Size: this.Size }
    }
    /**
     * @description - Copies the bytes from this `TextMetric` object's buffer to another buffer.
     * @param {TextMetric|Buffer|Object} [Buf] - If set, one of the following three kinds of objects:
     * - A `TextMetric` object.
     * - A `Buffer` object.
     * - An object with properties { Ptr, Size }.
     *
     * The size of the buffer must be at least `TextMetric.Prototype.Size + Offset`.
     *
     * If unset, `TextMetric.Prototype.Clone` will create a buffer of adequate size.
     * @param {Integer} [Offset = 0] - The byte offset from the start of `Buf` into which the TEXTMETRIC
     * structure will be copied. If `Buf` is unset, then the TEXTMETRIC structure will begin at
     * byte `Offset` within the buffer created by `TextMetric.Prototype.Clone`.
     * @param {Boolean} [MakeInstance = true] - If true, then an instance of `TextMetric` will be
     * created and returned by the function. If false, then only the buffer object will be returned;
     * the object will not have any of the properties or methods associated with the `TextMetric` class.
     * @returns {Buffer|TextMetric} - Depending on the value of `MakeInstance`, the `Buffer` object
     * or the `TextMetric` object.
     * @throws {Error} - The input buffer's size is insufficient.
     */
    Clone(Buf?, Offset := 0, MakeInstance := true) {
        ; This is overridden
    }
    /**
     * Gets the height (ascent + descent) of characters.
     * @memberof TextMetric
     * @instance
     */
    Height => NumGet(this, 0, 'int')
    /**
     * Gets the ascent (units above the base line) of characters.
     * @memberof TextMetric
     * @instance
     */
    Ascent => NumGet(this, 4, 'int')
    /**
     * Gets the descent (units below the base line) of characters.
     * @memberof TextMetric
     * @instance
     */
    Descent => NumGet(this, 8, 'int')
    /**
     * Gets the The amount of leading (space) inside the bounds set by the tmHeight member. Accent
     * marks and other diacritical characters may occur in this area. The designer may set this
     * member to zero.
     * @memberof TextMetric
     * @instance
     */
    InternalLeading => NumGet(this, 12, 'int')
    /**
     * Gets the The amount of extra leading (space) that the application adds between rows. Since
     * this area is outside the font, it contains no marks and is not altered by text output calls
     * in either OPAQUE or TRANSPARENT mode. The designer may set this member to zero.
     * @memberof TextMetric
     * @instance
     */
    ExternalLeading => NumGet(this, 16, 'int')
    /**
     * Gets the average width of characters in the font (generally defined as the width of the letter
     * x). This value does not include overhang required for bold or italic characters.
     * @memberof TextMetric
     * @instance
     */
    AveCharWidth => NumGet(this, 20, 'int')
    /**
     * Gets the width of the widest character in the font.
     * @memberof TextMetric
     * @instance
     */
    MaxCharWidth => NumGet(this, 24, 'int')
    /**
     * Gets the weight.
     * @memberof TextMetric
     * @instance
     */
    Weight => NumGet(this, 28, 'int')
    /**
     * Gets the extra width per string that may be added to some synthesized fonts. When synthesizing
     * some attributes, such as bold or italic, graphics device interface (GDI) or a device may have
     * to add width to a string on both a per-character and per-string basis. For example, GDI makes
     * a string bold by expanding the spacing of each character and overstriking by an offset value;
     * it italicizes a font by shearing the string. In either case, there is an overhang past the
     * basic string. For bold strings, the overhang is the distance by which the overstrike is offset.
     * For italic strings, the overhang is the amount the top of the font is sheared past the bottom
     * of the font
     *
     * The tmOverhang member enables the application to determine how much of the character width
     * returned by a GetTextExtentPoint32 function call on a single character is the actual character
     * width and how much is the per-string extra width. The actual width is the extent minus the
     * overhang.
     * @memberof TextMetric
     * @instance
     */
    Overhang => NumGet(this, 32, 'int')
    /**
     * Gets the horizontal aspect of the device for which the font was designed.
     * @memberof TextMetric
     * @instance
     */
    DigitizedAspectX => NumGet(this, 36, 'int')
    /**
     * Gets the vertical aspect of the device for which the font was designed. The ratio of the
     * tmDigitizedAspectX and tmDigitizedAspectY members is the aspect ratio of the device for which
     * the font was designed.
     * @memberof TextMetric
     * @instance
     */
    DigitizedAspectY => NumGet(this, 40, 'int')
    /**
     * Gets the value of the first character defined in the font.
     * @memberof TextMetric
     * @instance
     */
    FirstChar => NumGet(this, 44, 'uchar')
    /**
     * Gets the value of the last character defined in the font.
     * @memberof TextMetric
     * @instance
     */
    LastChar => NumGet(this, 46, 'uchar')
    /**
     * Gets the value of the character to be substituted for characters that are not in the font.
     * @memberof TextMetric
     * @instance
     */
    DefaultChar => NumGet(this, 48, 'uchar')
    /**
     * Gets the value of the character to be used to define word breaks for text justification.
     * @memberof TextMetric
     * @instance
     */
    BreakChar => NumGet(this, 50, 'uchar')
    IsDevice => (NumGet(this, 55, 'uchar') >> 3) & 1
    IsRaster => !((NumGet(this, 55, 'uchar') >> 1) & 1) && !((NumGet(this, 55, 'uchar') >> 2) & 1)
    IsVector => ((NumGet(this, 55, 'uchar') >> 1) & 1) && !((NumGet(this, 55, 'uchar') >> 2) & 1)
    /**
     * Gets the italic flag (nonzero is italic).
     * @memberof TextMetric
     * @instance
     */
    Italic => NumGet(this, 52, 'uchar')
    /**
     * Gets the underlined flag (nonzero is underlined).
     * @memberof TextMetric
     * @instance
     */
    Underlined => NumGet(this, 53, 'uchar')
    /**
     * Gets the strikeout flag (nonzero is struckout).
     * @memberof TextMetric
     * @instance
     */
    StruckOut => NumGet(this, 54, 'uchar')
    /**
     * Gets the family.
     * @memberof TextMetric
     * @instance
     */
    Family => NumGet(this, 55, 'uchar') & 0xF0
    /**
     * Returns a boolean indicating if the font is variable pitch.
     * @memberof TextMetric
     * @instance
     */
    IsVariablePitch => NumGet(this, 55, 'uchar') & 1
    /**
     * Gets the tmPitchAndFamily member. The pitch and family of the selected font. The low-order
     * bit (bit 0) specifies the pitch of the font. If it is 1, the font is variable pitch (or
     * proportional). If it is 0, the font is fixed pitch (or monospace). Bits 1 and 2 specify the
     * font type. If both bits are 0, the font is a raster font; if bit 1 is 1 and bit 2 is 0, the
     * font is a vector font; if bit 1 is 0 and bit 2 is set, or if both bits are 1, the font is
     * some other type. Bit 3 is 1 if the font is a device font; otherwise, it is 0.
     *
     * The four high-order bits designate the font family. The tmPitchAndFamily member can be
     * combined with the hexadecimal value 0xF0 by using the bitwise AND operator and can then be
     * compared with the font family names for an identical match. For more information about the
     * font families, see LOGFONT.
     *
     * Also see {@link TextMetric#IsDevice}, {@link TextMetric#IsRaster}, {@link TextMetric#IsVector},
     * {@link TextMetric#Family}, {@link TextMetric#IsVariablePitch}.
     */
    PitchAndFamily => NumGet(this, 55, 'uchar')
    /**
     * Gets the character set of the font.
     * @memberof TextMetric
     * @instance
     */
    CharSet => NumGet(this, 56, 'uchar')
    Ptr => this.Buffer.Ptr
}

/**
 * @classdesc - Maps a pointer received by a Windows API function to object properties.
 *
 * Do not cache a reference to this object unless you are certain that the AHK process is
 * managing the memory. Typically the system will be managing the memory. If you need
 * access to the values outside of the scope which this object is constructed, copy
 * the memory to an AHK buffer using `memmove` or a similar function.
 * {@link https://learn.microsoft.com/en-us/cpp/c-runtime-library/reference/memmove-wmemmove?view=msvc-170}.
 */
class NewTextMetric extends TextMetric {
    static __New() {
        this.DeleteProp('__New')
        /**
         * The structure's size.
         * @memberof NewTextMetric
         * @instance
         */
        this.Prototype.Size := this.Prototype.Base.Size +
        4 +    ; DWORD ntmFlags         60
        4 +    ; UINT  ntmSizeEM        64
        4 +    ; UINT  ntmCellHeight    68
        4      ; UINT  ntmAvgWidth      72
        this.Prototype.DefineProp('Clone', { Call: LF_CloneBuffer })
    }
    /**
     * @class
     * @param {Integer} Ptr - The pointer to the structure.
     */
    __New(Ptr) {
        /**
         * A faux buffer object.
         * @memberof NewTextMetric
         * @instance
         */
        this.Buffer := { Ptr: Ptr, Size: this.Size }
    }
    /**
     * @description - Copies the bytes from this `NewTextMetric` object's buffer to another buffer.
     * @param {NewTextMetric|Buffer|Object} [Buf] - If set, one of the following three kinds of objects:
     * - A `NewTextMetric` object.
     * - A `Buffer` object.
     * - An object with properties { Ptr, Size }.
     *
     * The size of the buffer must be at least `NewTextMetric.Prototype.Size + Offset`.
     *
     * If unset, `NewTextMetric.Prototype.Clone` will create a buffer of adequate size.
     * @param {Integer} [Offset = 0] - The byte offset from the start of `Buf` into which the NEWTEXTMETRIC
     * structure will be copied. If `Buf` is unset, then the NEWTEXTMETRIC structure will begin at
     * byte `Offset` within the buffer created by `NewTextMetric.Prototype.Clone`.
     * @param {Boolean} [MakeInstance = true] - If true, then an instance of `NewTextMetric` will be
     * created and returned by the function. If false, then only the buffer object will be returned;
     * the object will not have any of the properties or methods associated with the `NewTextMetric` class.
     * @returns {Buffer|NewTextMetric} - Depending on the value of `MakeInstance`, the `Buffer` object
     * or the `NewTextMetric` object.
     * @throws {Error} - The input buffer's size is insufficient.
     */
    Clone(Buf?, Offset := 0, MakeInstance := true) {
        ; This is overridden
    }
    /**
     * Takes an NTM flag as an input and returns nonzero if the value of this object's property
     * "Flags" contains that flag.
     * @param {Integer} Value - See {@link NewTextMetric#Flags} for a list of values.
     * @returns {Integer} - Returns nonzero if the value of this object's property "Flags" contains
     * the input flag.
     */
    QueryFontFlag(Value) {
        return this.Flags & Value
    }

    /**
     * Specifies whether the font is italic, underscored, outlined, bold, and so forth. May be any
     * reasonable combination of the following values:
     * - 0	- NTM_ITALIC          : italic
     * - 5	- NTM_BOLD            : bold
     * - 8	- NTM_REGULAR         : regular
     * - 16	- NTM_NONNEGATIVE_AC  : no glyph in a font at any size has a negative A or C space.
     * - 17	- NTM_PS_OPENTYPE     : PostScript OpenType font
     * - 18	- NTM_TT_OPENTYPE     : TrueType OpenType font
     * - 19	- NTM_MULTIPLEMASTER  : multiple master font
     * - 20	- NTM_TYPE1           : Type 1 font
     * - 21	- NTM_DSIG            : font with a digital signature. This allows traceability and ensures
     *   that the font has been tested and is not corrupted
     * @memberof NewTextMetric
     * @instance
     */
    Flags => NumGet(this, 60, 'uint')
    /**
     * Gets the size of the em square for the font. This value is in notional units (that is, the
     * units for which the font was designed).
     * @memberof NewTextMetric
     * @instance
     */
    SizeEM => NumGet(this, 64, 'uint')
    /**
     * Gets the height, in notional units, of the font. This value should be compared with the value
     * of the ntmSizeEM member.
     * @memberof NewTextMetric
     * @instance
     */
    CellHeight => NumGet(this, 68, 'uint')
    /**
     * Gets the average width of characters in the font, in notional units. This value should be
     * compared with the value of the ntmSizeEM member.
     * @memberof NewTextMetric
     * @instance
     */
    AvgWidth => NumGet(this, 72, 'uint')
    Ptr => this.Buffer.Ptr
}

/**
 * @classdesc - Maps a pointer received by a Windows API function to object properties.
 *
 * Do not cache a reference to this object unless you are certain that the AHK process is
 * managing the memory. Typically the system will be managing the memory. If you need
 * access to the values outside of the scope which this object is constructed, copy
 * the memory to an AHK buffer using `memmove` or a similar function.
 * {@link https://learn.microsoft.com/en-us/cpp/c-runtime-library/reference/memmove-wmemmove?view=msvc-170}.
 */
class NewTextMetricEx {
    static __New() {
        this.DeleteProp('__New')
        /**
         * The structure's size.
         * @memberof NewTextMetricEx
         * @instance
         */
        this.Prototype.Size := NewTextMetric.Prototype.Size + FontSignature.Prototype.Size
    }
    /**
     * @class
     * @param {Integer} Ptr - The pointer to the structure.
     */
    __New(Ptr) {
        /**
         * A faux buffer object.
         * @memberof NewTextMetricEx
         * @instance
         */
        this.Buffer := { Ptr: Ptr, Size: this.Size }
        /**
         * A NEWTEXTMETRIC structure mapped to an AHK `NewTextMetric` object.
         * @memberof NewTextMetricEx
         * @instance
         */
        this.TextMetric := NewTextMetric(this.Ptr)
        /**
         * A FONTSIGNATURE structure mapped to an AHK `FontSignature` object.
         * @memberof NewTextMetricEx
         * @instance
         */
        this.FontSignature := FontSignature(this.Ptr + this.TextMetric.Size)
    }
    /**
     * @description - Copies the bytes from this `NewTextMetricEx` object's buffer to another buffer.
     * @param {NewTextMetricEx|Buffer|Object} [Buf] - If set, one of the following three kinds of objects:
     * - A `NewTextMetricEx` object.
     * - A `Buffer` object.
     * - An object with properties { Ptr, Size }.
     *
     * The size of the buffer must be at least `NewTextMetricEx.Prototype.Size + Offset`.
     *
     * If unset, `NewTextMetricEx.Prototype.Clone` will create a buffer of adequate size.
     * @param {Integer} [Offset = 0] - The byte offset from the start of `Buf` into which the NEWTEXTMETRICEX
     * structure will be copied. If `Buf` is unset, then the NEWTEXTMETRICEX structure will begin at
     * byte `Offset` within the buffer created by `NewTextMetricEx.Prototype.Clone`.
     * @param {Boolean} [MakeInstance = true] - If true, then an instance of `NewTextMetricEx` will be
     * created and returned by the function. If false, then only the buffer object will be returned;
     * the object will not have any of the properties or methods associated with the `NewTextMetricEx` class,
     * nor the properties or methods associated with `NewTextMetric` and `FontSignature`.
     * @returns {Buffer|NewTextMetricEx} - Depending on the value of `MakeInstance`, the `Buffer` object
     * or the `NewTextMetricEx` object.
     * @throws {Error} - The input buffer's size is insufficient.
     */
    Clone(Buf?, Offset := 0, MakeInstance := true) {
        if IsSet(Buf) {
            if not Buf is Buffer && Type(Buf) != this.__Class {
                throw TypeError('Invalid input parameter ``Buf``.', -1)
            }
        } else {
            Buf := Buffer(this.Size + Offset)
        }
        if Buf.Size < this.Size + Offset {
            throw Error('The input buffer`'s size is insufficient.', -1, Buf.Size)
        }
        DllCall(
            'msvcrt.dll\memmove'
          , 'ptr', Buf.Ptr + Offset
          , 'ptr', this.Ptr
          , 'int', this.Size
          , 'ptr'
        )
        if MakeInstance {
            Obj := { Buffer: Buf }
            ObjSetBase(Obj, NewTextMetricEx.Prototype)
            Obj.TextMetric := NewTextMetric(Obj.Ptr)
            Obj.FontSignature := FontSignature(Obj.Ptr + Obj.TextMetric.Size)
            return Obj
        }
        return Buf
    }

    Ptr => this.Buffer.Ptr
}

/**
 * @classdesc - Maps a pointer received by a Windows API function to object properties.
 *
 * Do not cache a reference to this object unless you are certain that the AHK process is
 * managing the memory. Typically the system will be managing the memory. If you need
 * access to the values outside of the scope which this object is constructed, copy
 * the memory to an AHK buffer using `memmove` or a similar function.
 * {@link https://learn.microsoft.com/en-us/cpp/c-runtime-library/reference/memmove-wmemmove?view=msvc-170}.
 */
class FontSignature {
    static __New() {
        this.DeleteProp('__New')
        /**
         * The structure's size.
         * @memberof FontSignature
         * @instance
         */
        this.Prototype.Size :=
        16 +   ; DWORD fsUsb[4]         0
        8      ; DWORD fsCsb[2]         16
        this.Prototype.DefineProp('Clone', { Call: LF_CloneBuffer })

        /**
         * The "Key" is the bit in the Unicode subset bitfield, and the value is an object with
         * properties { Bit, Lb, Ub, Desc }.
         * {@link https://learn.microsoft.com/en-us/windows/win32/intl/unicode-subset-bitfields}.
         * @memberof FontSignature
         */
        this.Usb := Map(
            0, { Bit: 0, Lb: 0x0000, Ub: 0x007F, Desc: 'Basic Latin' }
          , 1, { Bit: 1, Lb: 0x0080, Ub: 0x00FF, Desc: 'Latin-1 Supplement' }
          , 2, { Bit: 2, Lb: 0x0100, Ub: 0x017F, Desc: 'Latin Extended-A' }
          , 3, { Bit: 3, Lb: 0x0180, Ub: 0x024F, Desc: 'Latin Extended-B' }
          , 4, { Bit: 4, Ranges: [
                { Bit: 4, Lb: 0x0250, Ub: 0x02AF, Desc: 'IPA Extensions' }
              , { Bit: 4, Lb: 0x1D00, Ub: 0x1D7F, Desc: 'Phonetic Extensions' }
              , { Bit: 4, Lb: 0x1D80, Ub: 0x1DBF, Desc: 'Phonetic Extensions Supplement' }
            ]}
          , 5, { Bit: 5, Ranges: [
                { Bit: 5, Lb: 0x02B0, Ub: 0x02FF, Desc: 'Spacing Modifier Letters' }
              , { Bit: 5, Lb: 0xA700, Ub: 0xA71F, Desc: 'Modifier Tone Letters' }
            ]}
          , 6, { Bit: 6, Ranges: [
                { Bit: 6, Lb: 0x0300, Ub: 0x036F, Desc: 'Combining Diacritical Marks' }
              , { Bit: 6, Lb: 0x1DC0, Ub: 0x1DFF, Desc: 'Combining Diacritical Marks Supplement' }
            ]}
          , 7, { Bit: 7, Lb: 0x0370, Ub: 0x03FF, Desc: 'Greek and Coptic' }
          , 8, { Bit: 8, Lb: 0x2C80, Ub: 0x2CFF, Desc: 'Coptic' }
          , 9, { Bit: 9, Ranges: [
                { Bit: 9, Lb: 0x0400, Ub: 0x04FF, Desc: 'Cyrillic' }
              , { Bit: 9, Lb: 0x0500, Ub: 0x052F, Desc: 'Cyrillic Supplement' }
              , { Bit: 9, Lb: 0x2DE0, Ub: 0x2DFF, Desc: 'Cyrillic Extended-A' }
              , { Bit: 9, Lb: 0xA640, Ub: 0xA69F, Desc: 'Cyrillic Extended-B' }
            ]}
          , 10, { Bit: 10, Lb: 0x0530, Ub: 0x058F, Desc: 'Armenian' }
          , 11, { Bit: 11, Lb: 0x0590, Ub: 0x05FF, Desc: 'Hebrew' }
          , 12, { Bit: 12, Lb: 0xA500, Ub: 0xA63F, Desc: 'Vai' }
          , 13, { Bit: 13, Ranges: [
                { Bit: 13, Lb: 0x0600, Ub: 0x06FF, Desc: 'Arabic' }
              , { Bit: 13, Lb: 0x0750, Ub: 0x077F, Desc: 'Arabic Supplement' }
            ]}
          , 14, { Bit: 14, Lb: 0x07C0, Ub: 0x07FF, Desc: 'NKo' }
          , 15, { Bit: 15, Lb: 0x0900, Ub: 0x097F, Desc: 'Devanagari' }
          , 16, { Bit: 16, Lb: 0x0980, Ub: 0x09FF, Desc: 'Bangla' }
          , 17, { Bit: 17, Lb: 0x0A00, Ub: 0x0A7F, Desc: 'Gurmukhi' }
          , 18, { Bit: 18, Lb: 0x0A80, Ub: 0x0AFF, Desc: 'Gujarati' }
          , 19, { Bit: 19, Lb: 0x0B00, Ub: 0x0B7F, Desc: 'Odia' }
          , 20, { Bit: 20, Lb: 0x0B80, Ub: 0x0BFF, Desc: 'Tamil' }
          , 21, { Bit: 21, Lb: 0x0C00, Ub: 0x0C7F, Desc: 'Telugu' }
          , 22, { Bit: 22, Lb: 0x0C80, Ub: 0x0CFF, Desc: 'Kannada' }
          , 23, { Bit: 23, Lb: 0x0D00, Ub: 0x0D7F, Desc: 'Malayalam' }
          , 24, { Bit: 24, Lb: 0x0E00, Ub: 0x0E7F, Desc: 'Thai' }
          , 25, { Bit: 25, Lb: 0x0E80, Ub: 0x0EFF, Desc: 'Lao' }
          , 26, { Bit: 26, Ranges: [
                { Bit: 26, Lb: 0x10A0, Ub: 0x10FF, Desc: 'Georgian' }
              , { Bit: 26, Lb: 0x2D00, Ub: 0x2D2F, Desc: 'Georgian Supplement' }
            ]}
          , 27, { Bit: 27, Lb: 0x1B00, Ub: 0x1B7F, Desc: 'Balinese' }
          , 28, { Bit: 28, Lb: 0x1100, Ub: 0x11FF, Desc: 'Hangul Jamo' }
          , 29, { Bit: 29, Ranges: [
                { Bit: 29, Lb: 0x1E00, Ub: 0x1EFF, Desc: 'Latin Extended Additional' }
              , { Bit: 29, Lb: 0x2C60, Ub: 0x2C7F, Desc: 'Latin Extended-C' }
              , { Bit: 29, Lb: 0xA720, Ub: 0xA7FF, Desc: 'Latin Extended-D' }
            ]}
          , 30, { Bit: 30, Lb: 0x1F00, Ub: 0x1FFF, Desc: 'Greek Extended' }
          , 31, { Bit: 31, Ranges: [
                { Bit: 31, Lb: 0x2000, Ub: 0x206F, Desc: 'General Punctuation' }
              , { Bit: 31, Lb: 0x2E00, Ub: 0x2E7F, Desc: 'Supplemental Punctuation' }
            ]}
          , 32, { Bit: 32, Lb: 0x2070, Ub: 0x209F, Desc: 'Superscripts And Subscripts' }
          , 33, { Bit: 33, Lb: 0x20A0, Ub: 0x20CF, Desc: 'Currency Symbols' }
          , 34, { Bit: 34, Lb: 0x20D0, Ub: 0x20FF, Desc: 'Combining Diacritical Marks For Symbols' }
          , 35, { Bit: 35, Lb: 0x2100, Ub: 0x214F, Desc: 'Letterlike Symbols' }
          , 36, { Bit: 36, Lb: 0x2150, Ub: 0x218F, Desc: 'Number Forms' }
          , 37, { Bit: 37, Ranges: [
                { Bit: 37, Lb: 0x2190, Ub: 0x21FF, Desc: 'Arrows' }
              , { Bit: 37, Lb: 0x27F0, Ub: 0x27FF, Desc: 'Supplemental Arrows-A' }
              , { Bit: 37, Lb: 0x2900, Ub: 0x297F, Desc: 'Supplemental Arrows-B' }
              , { Bit: 37, Lb: 0x2B00, Ub: 0x2BFF, Desc: 'Miscellaneous Symbols and Arrows' }
            ]}
          , 38, { Bit: 38, Ranges: [
                { Bit: 38, Lb: 0x2200, Ub: 0x22FF, Desc: 'Mathematical Operators' }
              , { Bit: 38, Lb: 0x27C0, Ub: 0x27EF, Desc: 'Miscellaneous Mathematical Symbols-A' }
              , { Bit: 38, Lb: 0x2980, Ub: 0x29FF, Desc: 'Miscellaneous Mathematical Symbols-B' }
              , { Bit: 38, Lb: 0x2A00, Ub: 0x2AFF, Desc: 'Supplemental Mathematical Operators' }
            ]}
          , 39, { Bit: 39, Lb: 0x2300, Ub: 0x23FF, Desc: 'Miscellaneous Technical' }
          , 40, { Bit: 40, Lb: 0x2400, Ub: 0x243F, Desc: 'Control Pictures' }
          , 41, { Bit: 41, Lb: 0x2440, Ub: 0x245F, Desc: 'Optical Character Recognition' }
          , 42, { Bit: 42, Lb: 0x2460, Ub: 0x24FF, Desc: 'Enclosed Alphanumerics' }
          , 43, { Bit: 43, Lb: 0x2500, Ub: 0x257F, Desc: 'Box Drawing' }
          , 44, { Bit: 44, Lb: 0x2580, Ub: 0x259F, Desc: 'Block Elements' }
          , 45, { Bit: 45, Lb: 0x25A0, Ub: 0x25FF, Desc: 'Geometric Shapes' }
          , 46, { Bit: 46, Lb: 0x2600, Ub: 0x26FF, Desc: 'Miscellaneous Symbols' }
          , 47, { Bit: 47, Lb: 0x2700, Ub: 0x27BF, Desc: 'Dingbats' }
          , 48, { Bit: 48, Lb: 0x3000, Ub: 0x303F, Desc: 'CJK Symbols And Punctuation' }
          , 49, { Bit: 49, Lb: 0x3040, Ub: 0x309F, Desc: 'Hiragana' }
          , 50, { Bit: 50, Ranges: [
                { Bit: 50, Lb: 0x30A0, Ub: 0x30FF, Desc: 'Katakana' }
              , { Bit: 50, Lb: 0x31F0, Ub: 0x31FF, Desc: 'Katakana Phonetic Extensions' }
            ]}
          , 51, { Bit: 51, Ranges: [
                { Bit: 51, Lb: 0x3100, Ub: 0x312F, Desc: 'Bopomofo' }
              , { Bit: 51, Lb: 0x31A0, Ub: 0x31BF, Desc: 'Bopomofo Extended' }
            ]}
          , 52, { Bit: 52, Lb: 0x3130, Ub: 0x318F, Desc: 'Hangul Compatibility Jamo' }
          , 53, { Bit: 53, Lb: 0xA840, Ub: 0xA87F, Desc: 'Phags-pa' }
          , 54, { Bit: 54, Lb: 0x3200, Ub: 0x32FF, Desc: 'Enclosed CJK Letters And Months' }
          , 55, { Bit: 55, Lb: 0x3300, Ub: 0x33FF, Desc: 'CJK Compatibility' }
          , 56, { Bit: 56, Lb: 0xAC00, Ub: 0xD7AF, Desc: 'Hangul Syllables' }
          , 57, { Bit: 57, Lb: 0xD800, Ub: 0xDFFF, Desc: 'Non-Plane 0' }
          , 58, { Bit: 58, Lb: 0x10900, Ub: 0x1091F, Desc: 'Phoenician' }
          , 59, { Bit: 59, Ranges: [
                { Bit: 59, Lb: 0x2E80, Ub: 0x2EFF, Desc: 'CJK Radicals Supplement' }
              , { Bit: 59, Lb: 0x2F00, Ub: 0x2FDF, Desc: 'Kangxi Radicals' }
              , { Bit: 59, Lb: 0x2FF0, Ub: 0x2FFF, Desc: 'Ideographic Description Characters' }
              , { Bit: 59, Lb: 0x3190, Ub: 0x319F, Desc: 'Kanbun' }
              , { Bit: 59, Lb: 0x3400, Ub: 0x4DBF, Desc: 'CJK Unified Ideographs Extension A' }
              , { Bit: 59, Lb: 0x4E00, Ub: 0x9FFF, Desc: 'CJK Unified Ideographs' }
              , { Bit: 59, Lb: 0x20000, Ub: 0x2A6DF, Desc: 'CJK Unified Ideographs Extension B' }
            ]}
          , 60, { Bit: 60, Lb: 0xE000, Ub: 0xF8FF, Desc: 'Private Use Area' }
          , 61, { Bit: 61, Ranges: [
                { Bit: 61, Lb: 0x31C0, Ub: 0x31EF, Desc: 'CJK Strokes' }
              , { Bit: 61, Lb: 0xF900, Ub: 0xFAFF, Desc: 'CJK Compatibility Ideographs' }
              , { Bit: 61, Lb: 0x2F800, Ub: 0x2FA1F, Desc: 'CJK Compatibility Ideographs Supplement' }
            ]}
          , 62, { Bit: 62, Lb: 0xFB00, Ub: 0xFB4F, Desc: 'Alphabetic Presentation Forms' }
          , 63, { Bit: 63, Lb: 0xFB50, Ub: 0xFDFF, Desc: 'Arabic Presentation Forms-A' }
          , 64, { Bit: 64, Lb: 0xFE20, Ub: 0xFE2F, Desc: 'Combining Half Marks' }
          , 65, { Bit: 65, Ranges: [
                { Bit: 65, Lb: 0xFE10, Ub: 0xFE1F, Desc: 'Vertical Forms' }
              , { Bit: 65, Lb: 0xFE30, Ub: 0xFE4F, Desc: 'CJK Compatibility Forms' }
            ]}
          , 66, { Bit: 66, Lb: 0xFE50, Ub: 0xFE6F, Desc: 'Small Form Variants' }
          , 67, { Bit: 67, Lb: 0xFE70, Ub: 0xFEFF, Desc: 'Arabic Presentation Forms-B' }
          , 68, { Bit: 68, Lb: 0xFF00, Ub: 0xFFEF, Desc: 'Halfwidth And Fullwidth Forms' }
          , 69, { Bit: 69, Lb: 0xFFF0, Ub: 0xFFFF, Desc: 'Specials' }
          , 70, { Bit: 70, Lb: 0x0F00, Ub: 0x0FFF, Desc: 'Tibetan' }
          , 71, { Bit: 71, Lb: 0x0700, Ub: 0x074F, Desc: 'Syriac' }
          , 72, { Bit: 72, Lb: 0x0780, Ub: 0x07BF, Desc: 'Thaana' }
          , 73, { Bit: 73, Lb: 0x0D80, Ub: 0x0DFF, Desc: 'Sinhala' }
          , 74, { Bit: 74, Lb: 0x1000, Ub: 0x109F, Desc: 'Myanmar' }
          , 75, { Bit: 75, Ranges: [
                { Bit: 75, Lb: 0x1200, Ub: 0x137F, Desc: 'Ethiopic' }
              , { Bit: 75, Lb: 0x1380, Ub: 0x139F, Desc: 'Ethiopic Supplement' }
              , { Bit: 75, Lb: 0x2D80, Ub: 0x2DDF, Desc: 'Ethiopic Extended' }
            ]}
          , 76, { Bit: 76, Lb: 0x13A0, Ub: 0x13FF, Desc: 'Cherokee' }
          , 77, { Bit: 77, Lb: 0x1400, Ub: 0x167F, Desc: 'Unified Canadian Aboriginal Syllabics' }
          , 78, { Bit: 78, Lb: 0x1680, Ub: 0x169F, Desc: 'Ogham' }
          , 79, { Bit: 79, Lb: 0x16A0, Ub: 0x16FF, Desc: 'Runic' }
          , 80, { Bit: 80, Ranges: [
                { Bit: 80, Lb: 0x1780, Ub: 0x17FF, Desc: 'Khmer' }
              , { Bit: 80, Lb: 0x19E0, Ub: 0x19FF, Desc: 'Khmer Symbols' }
            ]}
          , 81, { Bit: 81, Lb: 0x1800, Ub: 0x18AF, Desc: 'Mongolian' }
          , 82, { Bit: 82, Lb: 0x2800, Ub: 0x28FF, Desc: 'Braille Patterns' }
          , 83, { Bit: 83, Ranges: [
                { Bit: 83, Lb: 0xA000, Ub: 0xA48F, Desc: 'Yi Syllables' }
              , { Bit: 83, Lb: 0xA490, Ub: 0xA4CF, Desc: 'Yi Radicals' }
            ]}
          , 84, { Bit: 84, Ranges: [
                { Bit: 84, Lb: 0x1700, Ub: 0x171F, Desc: 'Tagalog' }
              , { Bit: 84, Lb: 0x1720, Ub: 0x173F, Desc: 'Hanunoo' }
              , { Bit: 84, Lb: 0x1740, Ub: 0x175F, Desc: 'Buhid' }
              , { Bit: 84, Lb: 0x1760, Ub: 0x177F, Desc: 'Tagbanwa' }
            ]}
          , 85, { Bit: 85, Lb: 0x10300, Ub: 0x1032F, Desc: 'Old Italic' }
          , 86, { Bit: 86, Lb: 0x10330, Ub: 0x1034F, Desc: 'Gothic' }
          , 87, { Bit: 87, Lb: 0x10400, Ub: 0x1044F, Desc: 'Deseret' }
          , 88, { Bit: 88, Ranges: [
                { Bit: 88, Lb: 0x1D000, Ub: 0x1D0FF, Desc: 'Byzantine Musical Symbols' }
              , { Bit: 88, Lb: 0x1D100, Ub: 0x1D1FF, Desc: 'Musical Symbols' }
              , { Bit: 88, Lb: 0x1D200, Ub: 0x1D24F, Desc: 'Ancient Greek Musical Notation' }
            ]}
          , 89, { Bit: 89, Lb: 0x1D400, Ub: 0x1D7FF, Desc: 'Mathematical Alphanumeric Symbols' }
          , 90, { Bit: 90, Ranges: [
                { Bit: 90, Lb: 0xFF000, Ub: 0xFFFFD, Desc: 'Private Use (plane 15)' }
              , { Bit: 90, Lb: 0x100000, Ub: 0x10FFFD, Desc: 'Private Use (plane 16)' }
            ]}
          , 91, { Bit: 91, Ranges: [
                { Bit: 91, Lb: 0xFE00, Ub: 0xFE0F, Desc: 'Variation Selectors' }
              , { Bit: 91, Lb: 0xE0100, Ub: 0xE01EF, Desc: 'Variation Selectors Supplement' }
            ]}
          , 92, { Bit: 92, Lb: 0xE0000, Ub: 0xE007F, Desc: 'Tags' }
          , 93, { Bit: 93, Lb: 0x1900, Ub: 0x194F, Desc: 'Limbu' }
          , 94, { Bit: 94, Lb: 0x1950, Ub: 0x197F, Desc: 'Tai Le' }
          , 95, { Bit: 95, Lb: 0x1980, Ub: 0x19DF, Desc: 'New Tai Lue' }
          , 96, { Bit: 96, Lb: 0x1A00, Ub: 0x1A1F, Desc: 'Buginese' }
          , 97, { Bit: 97, Lb: 0x2C00, Ub: 0x2C5F, Desc: 'Glagolitic' }
          , 98, { Bit: 98, Lb: 0x2D30, Ub: 0x2D7F, Desc: 'Tifinagh' }
          , 99, { Bit: 99, Lb: 0x4DC0, Ub: 0x4DFF, Desc: 'Yijing Hexagram Symbols' }
          , 100, { Bit: 100, Lb: 0xA800, Ub: 0xA82F, Desc: 'Syloti Nagri' }
          , 101, { Bit: 101, Ranges: [
                { Bit: 101, Lb: 0x10000, Ub: 0x1007F, Desc: 'Linear B Syllabary' }
              , { Bit: 101, Lb: 0x10080, Ub: 0x100FF, Desc: 'Linear B Ideograms' }
              , { Bit: 101, Lb: 0x10100, Ub: 0x1013F, Desc: 'Aegean Numbers' }
            ]}
          , 102, { Bit: 102, Lb: 0x10140, Ub: 0x1018F, Desc: 'Ancient Greek Numbers' }
          , 103, { Bit: 103, Lb: 0x10380, Ub: 0x1039F, Desc: 'Ugaritic' }
          , 104, { Bit: 104, Lb: 0x103A0, Ub: 0x103DF, Desc: 'Old Persian' }
          , 105, { Bit: 105, Lb: 0x10450, Ub: 0x1047F, Desc: 'Shavian' }
          , 106, { Bit: 106, Lb: 0x10480, Ub: 0x104AF, Desc: 'Osmanya' }
          , 107, { Bit: 107, Lb: 0x10800, Ub: 0x1083F, Desc: 'Cypriot Syllabary' }
          , 108, { Bit: 108, Lb: 0x10A00, Ub: 0x10A5F, Desc: 'Kharoshthi' }
          , 109, { Bit: 109, Lb: 0x1D300, Ub: 0x1D35F, Desc: 'Tai Xuan Jing Symbols' }
          , 110, { Bit: 110, Ranges: [
                { Bit: 110, Lb: 0x12000, Ub: 0x123FF, Desc: 'Cuneiform' }
              , { Bit: 110, Lb: 0x12400, Ub: 0x1247F, Desc: 'Cuneiform Numbers and Punctuation' }
            ]}
          , 111, { Bit: 111, Lb: 0x1D360, Ub: 0x1D37F, Desc: 'Counting Rod Numerals' }
          , 112, { Bit: 112, Lb: 0x1B80, Ub: 0x1BBF, Desc: 'Sundanese' }
          , 113, { Bit: 113, Lb: 0x1C00, Ub: 0x1C4F, Desc: 'Lepcha' }
          , 114, { Bit: 114, Lb: 0x1C50, Ub: 0x1C7F, Desc: 'Ol Chiki' }
          , 115, { Bit: 115, Lb: 0xA880, Ub: 0xA8DF, Desc: 'Saurashtra' }
          , 116, { Bit: 116, Lb: 0xA900, Ub: 0xA92F, Desc: 'Kayah Li' }
          , 117, { Bit: 117, Lb: 0xA930, Ub: 0xA95F, Desc: 'Rejang' }
          , 118, { Bit: 118, Lb: 0xAA00, Ub: 0xAA5F, Desc: 'Cham' }
          , 119, { Bit: 119, Lb: 0x10190, Ub: 0x101CF, Desc: 'Ancient Symbols' }
          , 120, { Bit: 120, Lb: 0x101D0, Ub: 0x101FF, Desc: 'Phaistos Disc' }
          , 121, { Bit: 121, Ranges: [
                { Bit: 121, Lb: 0x10280, Ub: 0x1029F, Desc: 'Lycian' }
              , { Bit: 121, Lb: 0x102A0, Ub: 0x102DF, Desc: 'Carian' }
              , { Bit: 121, Lb: 0x10920, Ub: 0x1093F, Desc: 'Lydian' }
            ]}
          , 122, { Bit: 122, Ranges: [
                { Bit: 122, Lb: 0x1F000, Ub: 0x1F02F, Desc: 'Mahjong Tiles' }
              , { Bit: 122, Lb: 0x1F030, Ub: 0x1F09F, Desc: 'Domino Tiles' }
            ]}
        )

        ; This sorts the objects in order from lowest to highest using the value of "Lb"
        ; and adds them to array `NewTextMetic.UsbOrdered`.
        list := ''
        for bit, obj in this.Usb {
            if HasProp(obj, 'Ranges') {
                for _obj in obj.Ranges {
                    list .= _obj.Lb ':' ObjPtr(_obj) '`n'
                }
            } else {
                list .= obj.Lb ':' ObjPtr(obj) '`n'
            }
        }
        list := StrSplit(Sort(SubStr(list, 1, -1), 'N'), '`n')
        /**
         * An array containing references to the same objects in the map {@link FontSignature.Usb}
         * @memberof FontSignature
         */
        ordered := this.UsbOrdered := []
        ordered.Capacity := list.Length
        for str in list {
            ordered.Push(ObjFromPtrAddRef(SubStr(str, InStr(str, ':') + 1)))
            ordered[-1].Index := A_Index
        }

        /**
         * The "Key" is the bit in the code page bitfield, and the value is an object with
         * properties { Bit, Cp, Desc }.
         * {@link https://learn.microsoft.com/en-us/windows/win32/intl/code-page-bitfields}.
         * @memberof FontSignature
         */
        this.Cpb := Map(
            0, { Bit: 0, Cp: 1252, Desc: 'Latin 1' }
          , 1, { Bit: 1, Cp: 1250, Desc: 'Latin 2: Central Europe' }
          , 2, { Bit: 2, Cp: 1251, Desc: 'Cyrillic' }
          , 3, { Bit: 3, Cp: 1253, Desc: 'Greek' }
          , 4, { Bit: 4, Cp: 1254, Desc: 'Turkish' }
          , 5, { Bit: 5, Cp: 1255, Desc: 'Hebrew' }
          , 6, { Bit: 6, Cp: 1256, Desc: 'Arabic' }
          , 7, { Bit: 7, Cp: 1257, Desc: 'Baltic' }
          , 8, { Bit: 8, Cp: 1258, Desc: 'Vietnamese' }
          , 16, { Bit: 16, Cp: 874, Desc: 'Thai' }
          , 17, { Bit: 17, Cp: 932, Desc: 'Japanese, Shift-JIS' }
          , 18, { Bit: 18, Cp: 936, Desc: 'Simplified Chinese (PRC, Singapore)' }
          , 19, { Bit: 19, Cp: 949, Desc: 'Korean Unified Hangul Code (Hangul TongHabHyung Code)' }
          , 20, { Bit: 20, Cp: 950, Desc: 'Traditional Chinese (Taiwan; Hong Kong SAR, PRC)' }
          , 21, { Bit: 21, Cp: 1361, Desc: 'Korean (Johab)' }
          , 47, { Bit: 47, Cp: 1258, Desc: 'Vietnamese' }
          , 48, { Bit: 48, Cp: 869, Desc: 'Modern Greek' }
          , 49, { Bit: 49, Cp: 866, Desc: 'Russian' }
          , 50, { Bit: 50, Cp: 865, Desc: 'Nordic' }
          , 51, { Bit: 51, Cp: 864, Desc: 'Arabic' }
          , 52, { Bit: 52, Cp: 863, Desc: 'Canadian French' }
          , 53, { Bit: 53, Cp: 862, Desc: '' }
          , 54, { Bit: 54, Cp: 861, Desc: 'Icelandic' }
          , 55, { Bit: 55, Cp: 860, Desc: 'Portuguese' }
          , 56, { Bit: 56, Cp: 857, Desc: 'Turkish' }
          , 57, { Bit: 57, Cp: 855, Desc: 'Cyrillic; primarily Russian' }
          , 58, { Bit: 58, Cp: 852, Desc: 'Latin 2' }
          , 59, { Bit: 59, Cp: 775, Desc: 'Baltic' }
          , 60, { Bit: 60, Cp: 737, Desc: 'Greek; formerly 437G' }
          , 61, { Bit: 61, Cp: '708;720', Desc: 'Arabic;ASMO 708' }
          , 62, { Bit: 62, Cp: 850, Desc: 'Multilingual Latin 1' }
          , 63, { Bit: 63, Cp: 437, Desc: 'US' }
        )

        /**
         * The "Key" is a code page identifier, and the value is the bit number to which
         * that code page identifier is associated in the code page bitfield.
         * {@link https://learn.microsoft.com/en-us/windows/win32/intl/code-page-bitfields}.
         * @memberof FontSignature
         */
        cp2b := this.CodePageToBit := Map()
        for bit, obj in this.Cpb {
            cp2b.Set(obj.Cp, bit)
        }
        cp2b.Set(708, 61)
        cp2b.Set(720, 61)
    }
    /**
     * @class
     * @param {Integer} Ptr - The pointer to the structure.
     */
    __New(Ptr) {
        /**
         * A faux buffer object.
         * @memberof FontSignature
         * @instance
         */
        this.Buffer := { Ptr: Ptr, Size: this.Size }
    }
    /**
     * @description - Copies the bytes from this `FontSignature` object's buffer to another buffer.
     * @param {FontSignature|Buffer|Object} [Buf] - If set, one of the following three kinds of objects:
     * - A `FontSignature` object.
     * - A `Buffer` object.
     * - An object with properties { Ptr, Size }.
     *
     * The size of the buffer must be at least `FontSignature.Prototype.Size + Offset`.
     *
     * If unset, `FontSignature.Prototype.Clone` will create a buffer of adequate size.
     * @param {Integer} [Offset = 0] - The byte offset from the start of `Buf` into which the FONTSIGNATURE
     * structure will be copied. If `Buf` is unset, then the FONTSIGNATURE structure will begin at
     * byte `Offset` within the buffer created by `FontSignature.Prototype.Clone`.
     * @param {Boolean} [MakeInstance = true] - If true, then an instance of `FontSignature` will be
     * created and returned by the function. If false, then only the buffer object will be returned;
     * the object will not have any of the properties or methods associated with the `FontSignature` class.
     * @returns {Buffer|FontSignature} - Depending on the value of `MakeInstance`, the `Buffer` object
     * or the `FontSignature` object.
     * @throws {Error} - The input buffer's size is insufficient.
     */
    Clone(Buf?, Offset := 0, MakeInstance := true) {
        ; This is overridden
    }
    /**
     * Takes a code page identifier as an input and returns a boolean indicating whether the bit
     * in the bitfield is 1 or 0.
     *
     * All locales do not support code pages. The bitfields described in this topic do not apply to
     * Unicode locales. To determine supported scripts for a locale, your application can use the
     * locale identifier constant LOCALE_SSCRIPTS with GetLocaleInfoEx.
     *
     * The presence of a bit in a code page bitfield does not necessarily mean that all strings for
     * a locale can be encoded in that code page without loss. To preserve data without loss, using
     * Unicode UTF-8 or UTF-16 is recommended.
     *
     * {@link https://learn.microsoft.com/en-us/windows/win32/intl/code-page-bitfields}
     *
     * @param {Integer} cp - A code page identifier.
     *
     * @param {VarRef} [OutObj] - A variable that will receive a reference to the object associated
     * with the code page identifier.
     *
     * @returns {Boolean}
     */
    QueryCodePage(cp, &OutObj?) {
        if !FontSignature.CodePageToBit.Has(Number(cp)) {
            return -1
        }
        OutObj := FontSignature.CodePageToBit.Get(cp)
        return (NumGet(this.Ptr + 16, OutObj.Bit >> 3, 'uchar') >> (OutObj.Bit & 7)) & 1
    }
    /**
     * Takes a unicode code point as an input and returns an integer repesenting one of the following
     * conditions:
     *
     * - -2 : The unicode code point is invalid for this operation (the value is less than zero
     * or greater than 1114109, which is the greatest "Ub" in the set).
     * - -1 : The unicode code point does not fall within a subrange (the value does not fall between
     * the "Lb" and "Ub" for a subrange in the set).
     * - 0 : The unicode code point does fall within a subrange and the bit for the subrange is 0.
     * - 1 : The unicode code point does fall within a subrange and the bit for the subrange is 1.
     */
    QuerySubRange(Lb, &OutObj?) {
        ordered := FontSignature.UsbOrdered
        step := Floor(ordered.Length / 6)
        if Lb < ordered[1].Lb || Lb > ordered[-1].Ub {
            return -2
        }
        if Lb = ordered[1].Lb {
            return _Proc(1)
        }
        loop 6 {
            i := step * A_Index - step + 1
            if ordered[i].Lb > Lb {
                loop {
                    --i
                    if ordered[i].Lb <= Lb {
                        return _Proc(i)
                    }
                }
            } else if Lb = ordered[i].Lb {
                return _Proc(i)
            }
        }
        i := step * 5
        loop {
            if ++i > ordered.Length {
                --i
                if ordered[i].Ub >= Lb {
                    return _Proc(i)
                }
                return 0
            }
            if ordered[i].Lb > Lb {
                return _Proc(--i)
            } else if ordered[i].Lb = Lb {
                return _Proc(i)
            }
        }
        _Proc(i) {
            if ordered[i].Lb <= Lb && ordered[i].Ub >= Lb {
                OutObj := ordered[i]
                return (NumGet(this.Ptr, OutObj.Bit >> 3, 'uchar') >> (OutObj.Bit & 7)) & 1
            } else {
                return -1
            }
        }
    }
    Ptr => this.Buffer.Ptr
}

LF_CloneBuffer(Self, Buf?, Offset := 0, MakeInstance := true) {
    if IsSet(Buf) {
        if not Buf is Buffer && Type(Buf) != Self.__Class {
            throw TypeError('Invalid input parameter ``Buf``.', -1)
        }
    } else {
        Buf := Buffer(Self.Size + Offset)
    }
    if Buf.Size < Self.Size + Offset {
        throw Error('The input buffer`'s size is insufficient.', -1, Buf.Size)
    }
    DllCall(
        'msvcrt.dll\memmove'
      , 'ptr', Buf.Ptr + Offset
      , 'ptr', Self.Ptr
      , 'int', Self.Size
      , 'ptr'
    )
    if MakeInstance {
        b := Self
        loop {
            if b := b.Base {
                if Type(b) = 'Prototype' {
                    break
                }
            } else {
                throw Error('Unable to identify the prototype object.', -1)
            }
        }
        Obj := { Buffer: Buf }
        ObjSetBase(Obj, b)
        return Obj
    }
    return Buf
}


/*

Static values related to fonts:

#define OUT_DEFAULT_PRECIS          0
#define OUT_STRING_PRECIS           1
#define OUT_CHARACTER_PRECIS        2
#define OUT_STROKE_PRECIS           3
#define OUT_TT_PRECIS               4
#define OUT_DEVICE_PRECIS           5
#define OUT_RASTER_PRECIS           6
#define OUT_TT_ONLY_PRECIS          7
#define OUT_OUTLINE_PRECIS          8
#define OUT_SCREEN_OUTLINE_PRECIS   9
#define OUT_PS_ONLY_PRECIS          10

#define CLIP_DEFAULT_PRECIS     0
#define CLIP_CHARACTER_PRECIS   1
#define CLIP_STROKE_PRECIS      2
#define CLIP_MASK               0xf
#define CLIP_LH_ANGLES          (1<<4)
#define CLIP_TT_ALWAYS          (2<<4)
#if (_WIN32_WINNT >= _WIN32_WINNT_LONGHORN)
#define CLIP_DFA_DISABLE        (4<<4)
#endif // (_WIN32_WINNT >= _WIN32_WINNT_LONGHORN)
#define CLIP_EMBEDDED           (8<<4)

#define DEFAULT_QUALITY         0
#define DRAFT_QUALITY           1
#define PROOF_QUALITY           2
#if(WINVER >= 0x0400)
#define NONANTIALIASED_QUALITY  3
#define ANTIALIASED_QUALITY     4
#endif // WINVER >= 0x0400

#if (_WIN32_WINNT >= _WIN32_WINNT_WINXP)
#define CLEARTYPE_QUALITY       5
#define CLEARTYPE_NATURAL_QUALITY       6
#endif

#define DEFAULT_PITCH           0
#define FIXED_PITCH             1
#define VARIABLE_PITCH          2
#if(WINVER >= 0x0400)
#define MONO_FONT               8
#endif // WINVER >= 0x0400

#define ANSI_CHARSET            0
#define DEFAULT_CHARSET         1
#define SYMBOL_CHARSET          2
#define SHIFTJIS_CHARSET        128
#define HANGEUL_CHARSET         129
#define HANGUL_CHARSET          129
#define GB2312_CHARSET          134
#define CHINESEBIG5_CHARSET     136
#define OEM_CHARSET             255
#if(WINVER >= 0x0400)
#define JOHAB_CHARSET           130
#define HEBREW_CHARSET          177
#define ARABIC_CHARSET          178
#define GREEK_CHARSET           161
#define TURKISH_CHARSET         162
#define VIETNAMESE_CHARSET      163
#define THAI_CHARSET            222
#define EASTEUROPE_CHARSET      238
#define RUSSIAN_CHARSET         204

#define MAC_CHARSET             77
#define BALTIC_CHARSET          186

#define FS_LATIN1               0x00000001L
#define FS_LATIN2               0x00000002L
#define FS_CYRILLIC             0x00000004L
#define FS_GREEK                0x00000008L
#define FS_TURKISH              0x00000010L
#define FS_HEBREW               0x00000020L
#define FS_ARABIC               0x00000040L
#define FS_BALTIC               0x00000080L
#define FS_VIETNAMESE           0x00000100L
#define FS_THAI                 0x00010000L
#define FS_JISJAPAN             0x00020000L
#define FS_CHINESESIMP          0x00040000L
#define FS_WANSUNG              0x00080000L
#define FS_CHINESETRAD          0x00100000L
#define FS_JOHAB                0x00200000L
#define FS_SYMBOL               0x80000000L
#endif // WINVER >= 0x0400

// Font Families
#define FF_DONTCARE         0x00 (0)    /* Don't care or don't know.
#define FF_ROMAN            0x10 (16)   /* Variable stroke width, serifed.
                                        /* Times Roman, Century Schoolbook, etc.
#define FF_SWISS            0x20 (32)   /* Variable stroke width, sans-serifed.
                                        /* Helvetica, Swiss, etc.
#define FF_MODERN           0x30 (48)   /* Constant stroke width, serifed or sans-serifed.
                                        /* Pica, Elite, Courier, etc.
#define FF_SCRIPT           0x40 (64)   /* Cursive, etc.
#define FF_DECORATIVE       0x50 (80)   /* Old English, etc.

/* Font Weights
#define FW_DONTCARE         0
#define FW_THIN             100
#define FW_EXTRALIGHT       200
#define FW_LIGHT            300
#define FW_NORMAL           400
#define FW_MEDIUM           500
#define FW_SEMIBOLD         600
#define FW_BOLD             700
#define FW_EXTRABOLD        800
#define FW_HEAVY            900

#define FW_ULTRALIGHT       FW_EXTRALIGHT
#define FW_REGULAR          FW_NORMAL
#define FW_DEMIBOLD         FW_SEMIBOLD
#define FW_ULTRABOLD        FW_EXTRABOLD
#define FW_BLACK            FW_HEAVY

; https://learn.microsoft.com/en-us/previous-versions/dd162618(v=vs.85)
#define RASTER_FONTTYPE     0x0001
#define DEVICE_FONTTYPE     0x0002
#define TRUETYPE_FONTTYPE   0x0004
