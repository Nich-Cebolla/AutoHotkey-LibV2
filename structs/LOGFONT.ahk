/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/structs/LOGFONT.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/FontExist.ahk
#include <FontExist>

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
     * Font := LOGFONT(Txt.Hwnd)
     * Font()
     * MsgBox(Font.FaceName) ; Ms Shell Dlg
     * MsgBox(Font.FontSize) ; 11.25
     * Txt.SetFont('s15', 'Roboto')
     * Font()
     * MsgBox(Font.FaceName) ; Roboto
     * MsgBox(Font.FontSize) ; 15.00
     * @param {Integer} [Hwnd = 0] - The handle of Gui control or window to get the font from. I have
     * not tested this with non-AHK windows.
     * @param {String} [Encoding='UTF-16'] - The encoding to use for the font name from the buffer.
     * @return {LOGFONT} - A new `LOGFONT` object.
     */
    __New(Hwnd := 0, Encoding := 'UTF-16') {
        this.Size := 92
        this.Hwnd := Hwnd
        this.Encoding := Encoding
        this.Handle := ''
    }

    /**
     * @description - Attempts to set a window's font object using this object's values.
     */
    Apply(Redraw := true) {
        ; this.FindFont()
        if !(hFontOld := SendMessage(0x0031,,, this.Hwnd)) {
            throw Error('Failed to get hFont.', -1)
        }
        ; This checks if the `hFontOld` is a handle to an object that was created by this class.
        ; We don't want to delete any objects that we didn't create. We also want to make sure we
        ; do delete objects that we did create and that are no longer needed.
        Flag := this.Handle = hFontOld
        this.Handle := DllCall('CreateFontIndirectW', 'ptr', this, 'ptr')
        SendMessage(0x30, this.Handle, Redraw, this.Hwnd)  ; 0x30 = WM_SETFONT
        if Flag {
            DllCall('DeleteObject', 'ptr', hFontOld, 'int')
        }
        if Redraw {
            WinRedraw(this.Hwnd)
        }
    }

    Call(*) {
        if !WinExist(this.Hwnd) {
            throw TargetError('Window not found.', -1, this.Hwnd)
        }
        if !(hFont := SendMessage(0x0031,,, this.Hwnd)) {
            throw Error('Failed to get hFont.', -1)
        }
        if !DllCall('Gdi32.dll\GetObject', 'ptr', hFont, 'int', 92, 'ptr', this) {
            throw Error('Failed to get font object.', -1)
        }
    }

    Clone(lf?) {
        if !IsSet(lf) {
            lf := %this.__Class%()
        }
        lf.Height := this.Height
        lf.Width := this.Width
        lf.Escapement := this.Escapement
        lf.Orientation := this.Orientation
        lf.Weight := this.Weight
        lf.Italic := this.Italic
        lf.Underline := this.Underline
        lf.StrikeOut := this.StrikeOut
        lf.CharSet := this.CharSet
        lf.OutPrecision := this.OutPrecision
        lf.ClipPrecision := this.ClipPrecision
        lf.Quality := this.Quality
        lf.Pitch := this.Pitch
        lf.Family := this.Family
        lf.FaceName := this.FaceName
        return lf
    }

    DisposeFont() {
        if this.Handle {
            DllCall('DeleteObject', 'ptr', this.Handle)
            this.Handle := 0
        }
    }

    OnDpiChanged(newDpi) {
        this.Height := Round(this.BaseFontSize * newDpi / -72)
        this.Apply()
    }

    Set(Name, Value, Apply := true) {
        if HasProp(this, Name) {
            this.%Name% := Value
        } else {
            throw Error('Property not found.', -1, Name)
        }
        if Apply {
            this.Apply()
        }
    }

    SetFontSize(newSize, Apply := true) {
        this.BaseFontSize := newSize
        this.Height := Round(newSize * this.Dpi / -72)
        if Apply {
            this.Apply()
        }
    }

    /**
     * @property {Integer} LOGFONT.CharSet - The character set of the font.
     */
    CharSet {
        Get => NumGet(this, 23, 'uchar')
        Set => NumPut('uchar', Value, this, 23)
    }
    /**
     * @property {Integer} LOGFONT.ClipPrecision - The clipping precision of the font.
     */
    ClipPrecision {
        Get => NumGet(this, 25, 'uchar')
        Set => NumPut('uchar', Value, this, 25)
    }
    /**
     * @property {Integer} LOGFONT.Dpi - The DPI of the window to which `Hwnd` is the handle.
     */
    Dpi => DllCall('User32\GetDpiForWindow', 'Ptr', this.Hwnd, 'UInt')
    /**
     * @property {Integer} LOGFONT.Escapement - The angle of escapement, in tenths of degrees.
     */
    Escapement {
        Get => NumGet(this, 8, 'int')
        Set => NumPut('int', Value, this, 8)
    }
    /**
     * @property {String} LOGFONT.FaceName - The name of the font.
     */
    FaceName {
        Get => StrGet(this.ptr + 28, 32, this.Encoding)
        Set {
            if name := GetFirstFont(Value) {
                if Min(StrLen(name), 31) == 31 {
                    name := SubStr(name, 1, 31)
                }
                StrPut(name, this.Ptr + 28, 32, 'UTF-16')
            } else if IsObject(Value) {
                if Value.Has(1) {
                    StrPut(Value[1], this.Ptr + 28, 32, 'UTF-16')
                }
            } else {
                StrPut(StrSplit(Value, ',', '`s')[1], this.Ptr + 28, 32, 'UTF-16')
            }
        }
    }
    /**
     * @property {Integer} LOGFONT.Family - The font group to which the font belongs.
     */
    Family {
        Get => NumGet(this, 27, 'uchar') & 0xF0
        Set => NumPut('uchar', (this.Family & 0x0F) | (Value & 0xF0), this, 27)
    }
    /**
     * @property {Integer} LOGFONT.FontSize - The size of the font in points.
     */
    FontSize {
        Get => Round(this.Height * -72 / this.Dpi, 2)
        Set => this.SetFontSize(Value)
    }
    /**
     * @property {Integer} LOGFONT.Height - The height of the font in logical units.
     */
    Height {
        Get => NumGet(this, 0, 'int')
        Set => NumPut('int', Value, this, 0)
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
     * @property {Integer} LOGFONT.Orientation - The angle of orientation, in tenths of degrees.
     */
    Orientation {
        Get => NumGet(this, 12, 'int')
        Set => NumPut('int', Value, this, 12)
    }
    /**
     * @property {Integer} LOGFONT.OutPrecision - The output precision of the font.
     */
    OutPrecision {
        Get => NumGet(this, 24, 'uchar')
        Set => NumPut('uchar', Value, this, 24)
    }
    /**
     * @property {Integer} LOGFONT.Pitch - The pitch of the font.
     */
    Pitch {
        Get => NumGet(this, 27, 'uchar') & 0x0F
        Set => NumPut('uchar', (this.Pitch & 0xF0) | (Value & 0x0F), this, 27)
    }
    /**
     * @property {Integer} LOGFONT.Quality - The quality of the font.
     */
    Quality {
        Get => NumGet(this, 26, 'uchar')
        Set => NumPut('uchar', Value, this, 26)
    }
    /**
     * @property {Boolean} LOGFONT.StrikeOut - The strikeout flag.
     */
    StrikeOut {
        Get => NumGet(this, 22, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 22)
    }
    /**
     * @property {Boolean} LOGFONT.Underline - The underline flag.
     */
    Underline {
        Get => NumGet(this, 21, 'uchar')
        Set => NumPut('uchar', Value ? 1 : 0, this, 21)
    }
    /**
     * @property {Integer} LOGFONT.Weight - The weight of the font.
     */
    Weight {
        Get => NumGet(this, 16, 'int')
        Set => NumPut('int', Value, this, 16)
    }
    /**
     * @property {Integer} LOGFONT.Width - The average width of characters in the font.
     */
    Width {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
    }
}


/*

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
