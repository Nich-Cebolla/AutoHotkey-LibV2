
/**
 * @class
 * @description - A wrapper around the LOGFONT structure.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/dimm/ns-dimm-logfontw}
 */
class LOGFONT extends Buffer {
    /**
     * @description - Creates a new `LOGFONT` object. This object is a reusable buffer object
     * that is used to get or set font details for a control (or other window).
     * @example
     * G := Gui('+Resize -DPIScale')
     * Txt := G.Add('Text', , 'Some text')
     * G.Show()
     * Font := LOGFONT(Txt.hWnd)
     * Font()
     * MsgBox(Font.FaceName) ; Ms Shell Dlg
     * MsgBox(Font.FontSize) ; 11.25
     * Txt.SetFont('s15', 'Roboto')
     * Font()
     * MsgBox(Font.FaceName) ; Roboto
     * MsgBox(Font.FontSize) ; 15.00
     * @param {Integer} hWnd - The handle of Gui control or window to get the font from. I have
     * not tested this with non-AHK windows.
     * @param {String} [Encoding='UTF-16'] - The encoding to use for the font name from the buffer.
     * @return {LOGFONT} - A new `LOGFONT` object.
     */
    __New(hWnd, Encoding := 'UTF-16') {
        this.Size := 92
        this.hWnd := hWnd
        this.Encoding := Encoding
        this.Handle := ''
    }

    Call() {
        if !WinExist(this.hWnd) {
            throw TargetError('Window not found.', -1, this.hWnd)
        }
        if !(hFont := SendMessage(0x0031,,, this.hWnd)) {
            throw Error('Failed to get hFont.', -1)
        }
        if !DllCall('Gdi32.dll\GetObject', 'ptr', hFont, 'int', 92, 'ptr', this) {
            throw Error('Failed to get font object.', -1)
        }

    }

    Set(Redraw := true) {
        if !(hFontOld := SendMessage(0x0031,,, this.hWnd)) {
            throw Error('Failed to get hFont.', -1)
        }
        Flag := this.Handle = hFontOld
        SendMessage(0x30, this.Handle := DllCall('CreateFontIndirectW', 'ptr', this, 'ptr'), Redraw, this.hWnd)  ; 0x30 = WM_SETFONT
        if Flag {
            DllCall('DeleteObject', 'ptr', hFontOld)
        }
    }

    DisposeFont() {
        if this.Handle {
            DllCall('DeleteObject', 'ptr', this.Handle)
            this.Handle := 0
        }
    }

    /**
     * @property {Integer} LOGFONT.Height - The height of the font in logical units.
     */
    Height {
        Get => NumGet(this, 0, 'int')
        Set => NumPut('int', Value, this, 0)
    }
    /**
     * @property {Integer} LOGFONT.Width - The average width of characters in the font.
     */
    Width {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
    }
    /**
     * @property {Integer} LOGFONT.Escapement - The angle of escapement, in tenths of degrees.
     */
    Escapement {
        Get => NumGet(this, 8, 'int')
        Set => NumPut('int', Value, this, 8)
    }
    /**
     * @property {Integer} LOGFONT.Orientation - The angle of orientation, in tenths of degrees.
     */
    Orientation {
        Get => NumGet(this, 12, 'int')
        Set => NumPut('int', Value, this, 12)
    }
    /**
     * @property {Integer} LOGFONT.Weight - The weight of the font.
     */
    Weight {
        Get => NumGet(this, 16, 'int')
        Set => NumPut('int', Value, this, 16)
    }
    /**
     * @property {Boolean} LOGFONT.Mask - The mask that specifies which members of the structure are
     * valid.
     */
    Italic {
        Get => NumGet(this, 20, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 20)
    }
    /**
     * @property {Boolean} LOGFONT.Underline - The underline flag.
     */
    Underline {
        Get => NumGet(this, 21, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 21)
    }
    /**
     * @property {Boolean} LOGFONT.StrikeOut - The strikeout flag.
     */
    StrikeOut {
        Get => NumGet(this, 22, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 22)
    }
    /**
     * @property {Integer} LOGFONT.CharSet - The character set of the font.
     */
    CharSet {
        Get => NumGet(this, 23, 'uchar')
        Set => NumPut('uchar', Value, this, 23)
    }
    /**
     * @property {Integer} LOGFONT.OutPrecision - The output precision of the font.
     */
    OutPrecision {
        Get => NumGet(this, 24, 'uchar')
        Set => NumPut('uchar', Value, this, 24)
    }
    /**
     * @property {Integer} LOGFONT.ClipPrecision - The clipping precision of the font.
     */
    ClipPrecision {
        Get => NumGet(this, 25, 'uchar')
        Set => NumPut('uchar', Value, this, 25)
    }
    /**
     * @property {Integer} LOGFONT.Quality - The quality of the font.
     */
    Quality {
        Get => NumGet(this, 26, 'uchar')
        Set => NumPut('uchar', Value, this, 26)
    }
    /**
     * @property {Integer} LOGFONT.Family - The font group to which the font belongs.
     */
    Family {
        Get => NumGet(this, 27, 'uchar') & 0xF0
        Set => NumPut('uchar', (this.Family & 0x0F) | (Value & 0xF0), this, 27)
    }
    /**
     * @property {Integer} LOGFONT.Pitch - The pitch of the font.
     */
    Pitch {
        Get => NumGet(this, 27, 'uchar') & 0x0F
        Set => NumPut('uchar', (this.Pitch & 0xF0) | (Value & 0x0F), this, 27)
    }
    /**
     * @property {String} LOGFONT.FaceName - The name of the font.
     */
    FaceName {
        Get => StrGet(this.ptr + 28, 32, this.Encoding)
        Set => StrPut(Value, this.ptr + 28, 32, this.Encoding)
    }
    /**
     * @property {Integer} LOGFONT.FontSize - The size of the font in points.
     */
    FontSize {
        Get => Round(this.Height * -72 / this.Dpi, 2)
        Set => this.Height := Round(Value * this.Dpi / -72, 0)
    }
    /**
     * @property {Integer} LOGFONT.Dpi - The DPI of the window to which `hWnd` is the handle.
     */
    Dpi => DllCall('User32\GetDpiForWindow', 'Ptr', this.hWnd, 'UInt')
    /**
     * @property {Gui.Control} LOGFONT.Ctrl - The control object associated with the hWnd.
     */
    Ctrl => GuiCtrlFromHwnd(this.hWnd)
}
