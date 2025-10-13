/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GDI/GdipBitmap.ahk
    Author: Nich-Cebolla
    License: MIT
*/

; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/LibraryManager.ahk
#include <LibraryManager>
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GDI/GdipStartup.ahk
#include <GdipStartup>

class GdipBitmap {
    static __New() {
        global GDIPBITMAP_DEFAULT_ENCODING
        this.DeleteProp('__New')
        if !IsSet(GDIPBITMAP_DEFAULT_ENCODING) {
            GDIPBITMAP_DEFAULT_ENCODING := 'cp1200'
        }
        this.GdipStartup := this.LibToken := 0
        this.__InitializeProcedureVars()
        this.LoadLibrary()
    }
    static LoadLibrary() {
        if !this.GdipStartup {
            this.GdipStartup := GdipStartup()
        }
        if !this.LibToken {
            this.LibToken := LibraryManager(Map(
                'gdiplus', ['GdipDisposeImage', 'GdipLoadImageFromFile', 'GdipGetImageHeight'
                  , 'GdipGetImageWidth', 'GdipCreateBitmapFromFile', 'GdipCreateHBITMAPFromBitmap']
              , 'gdi32', ['DeleteObject']
            ))
        }
    }
    static FreeLibrary() {
        this.GdipStartup.Shutdown()
        this.LibToken.Free()
        this.GdipStartup := this.LibToken := 0
    }
    static FromBitmap(pBitmap) {
        img := { pBitmap: pBitmap }
        ObjSetBase(img, this.Prototype)
        return img
    }
    static __InitializeProcedureVars() {
        global
        if !IsSet(g_gdiplus_GdipDisposeImage) {
            g_gdiplus_GdipDisposeImage := 0
        }
        if !IsSet(g_gdiplus_GdipLoadImageFromFile) {
            g_gdiplus_GdipLoadImageFromFile := 0
        }
        if !IsSet(g_gdiplus_GdipGetImageHeight) {
            g_gdiplus_GdipGetImageHeight := 0
        }
        if !IsSet(g_gdiplus_GdipGetImageWidth) {
            g_gdiplus_GdipGetImageWidth := 0
        }
        if !IsSet(g_gdiplus_GdipCreateBitmapFromFile) {
            g_gdiplus_GdipCreateBitmapFromFile := 0
        }
        if !IsSet(g_gdiplus_GdipCreateHBITMAPFromBitmap) {
            g_gdiplus_GdipCreateHBITMAPFromBitmap := 0
        }
        if !IsSet(g_gdi32_DeleteObject) {
            g_gdi32_DeleteObject := 0
        }
    }
    __New(Path, Load := false) {
        this.__Path := Buffer(StrPut(Path, GDIPBITMAP_DEFAULT_ENCODING))
        StrPut(Path, this.__Path, GDIPBITMAP_DEFAULT_ENCODING)
        if Load {
            this.LoadImage()
        }
    }
    DeleteBitmap() {
        if this.pBitmap {
            if status := DllCall(g_gdiplus_GdipDisposeImage, 'ptr', this.pBitmap, 'uint') {
                throw OSError('``GdipDisposeImage`` failed.', -1, 'status: ' status)
            }
            this.pBitmap := 0
        } else {
            throw Error('The bitmap has not been created.', -1)
        }
    }
    DeleteHBitmap() {
        if this.hBitmap {
            if !DllCall(g_gdi32_DeleteObject, 'ptr', this.hBitmap, 'uint'){
                throw OSError()
            }
            this.hBitmap := 0
        } else {
            throw Error('The HBITMAP has not been created.', -1)
        }
    }
    Dispose() {
        if this.hBitmap {
            DllCall(g_gdi32_DeleteObject, 'ptr', this.hBitmap, 'uint')
            this.hBitmap := 0
        }
        if this.pBitmap {
            DllCall(g_gdiplus_GdipDisposeImage, 'ptr', this.pBitmap, 'int')
            this.pBitmap := 0
        }
    }
    GetAspectRatio(Digits := 2, &OutWidth?, &OutHeight?) {
        w := Abs(this.Width)
        h := Abs(this.Height)

        if w {
            if h {
                ; Euclidean algorithm (GCD)
                a := w
                b := h
                while (b) {
                    t := Mod(a, b)
                    a := b
                    b := t
                }
                g := a  ; gcd
                if Mod(w, g) {
                    OutWidth := Round(w / g, Digits)
                } else {
                    OutWidth := Round(w / g, 0)
                }
                if Mod(h, g) {
                    OutHeight := Round(h / g, Digits)
                } else {
                    OutHeight := Round(h / g, 0)
                }
                return OutWidth ':' OutHeight
            } else {
                OutWidth := 1
                OutHeight := 0
                return '1:0'
            }
        } else {
            if h {
                OutWidth := 0
                OutHeight := 1
                return '0:1'
            } else {
                OutWidth := 0
                OutHeight := 0
                return '0:0'
            }
        }
    }
    GetBitmapFromFile() {
        if !this.pBitmap {
            if status := DllCall(g_gdiplus_GdipCreateBitmapFromFile, 'ptr', this.__Path, 'ptr', this.__pBitmap, 'uint') {
                throw OSError('GdipCreateBitmapFromFile failed.', -1, 'status: ' status)
            }
        }
        return this.pBitmap
    }
    GetHBitmap(Background := 0xFFFFFFFF) {
        if !this.hBitmap {
            if !this.pBitmap {
                if status := DllCall(g_gdiplus_GdipCreateBitmapFromFile, 'ptr', this.__Path, 'ptr', this.__pBitmap, 'uint') {
                    throw OSError('GdipCreateBitmapFromFile failed.', -1, 'status: ' status)
                }
            }
            if status := DllCall(g_gdiplus_GdipCreateHBITMAPFromBitmap, 'ptr', this.pBitmap, 'ptr', this.__hBitmap, 'uint', Background, 'uint') {
                throw OSError('GdipCreateHBITMAPFromBitmap failed.', -1, 'status: ' status)
            }
        }
        return this.hBitmap
    }
    LoadImage() {
        if !this.pBitmap {
            if status := DllCall(g_gdiplus_GdipLoadImageFromFile, 'ptr', this.__Path, 'ptr', this.__pBitmap, 'uint') {
                throw OSError('GdipLoadImageFromFile failed.', -1, 'status: ' status)
            }
        }
        return this.pBitmap
    }
    __Delete() {
        this.Dispose()
    }
    AspectRatio => this.Width / this.Height
    Height {
        Get {
            h := 0
            if status := DllCall(g_gdiplus_GdipGetImageHeight, 'ptr', this.pBitmap, 'uint*', &h, 'int') {
                throw OSError('GdipGetImageHeight failed.', -1, 'status: ' status)
            }
            return h
        }
    }
    hBitmap {
        Get {
            if !this.HasOwnProp('__hBitmap') {
                this.__hBitmap := GdipBitmap_hBitmap()
            }
            this.DefineProp('hBitmap', GdipBitmap.Prototype.GetOwnPropDesc('__hBitmap__'))
            return this.hBitmap
        }
        Set {
            if !this.HasOwnProp('__hBitmap') {
                this.__hBitmap := GdipBitmap_hBitmap()
            }
            this.DefineProp('hBitmap', GdipBitmap.Prototype.GetOwnPropDesc('__hBitmap__'))
            this.hBitmap := Value
        }
    }
    Path {
        Get => StrGet(this.__Path, GDIPBITMAP_DEFAULT_ENCODING)
        Set {
            bytes := StrPut(Value, GDIPBITMAP_DEFAULT_ENCODING)
            if bytes > this.__Path.Size {
                this.__Path.Size := bytes
            }
            StrPut(Value, this.__Path, GDIPBITMAP_DEFAULT_ENCODING)
        }
    }
    pBitmap {
        Get {
            if !this.HasOwnProp('__pBitmap') {
                this.__pBitmap := GdipBitmap_pBitmap()
            }
            this.DefineProp('pBitmap', GdipBitmap.Prototype.GetOwnPropDesc('__pBitmap__'))
            return this.pBitmap
        }
        Set {
            if !this.HasOwnProp('__pBitmap') {
                this.__pBitmap := GdipBitmap_pBitmap()
            }
            this.DefineProp('pBitmap', GdipBitmap.Prototype.GetOwnPropDesc('__pBitmap__'))
            this.pBitmap := Value
        }
    }
    Width {
        Get {
            w := 0
            if status := DllCall(g_gdiplus_GdipGetImageWidth, 'ptr', this.pBitmap, 'uint*', &w, 'int') {
                throw OSError('GdipGetImageWidth failed.', -1, 'status: ' status)
            }
            return w
        }
    }
    __hBitmap__ {
        Get => NumGet(this.__hBitmap, 0, 'ptr')
        Set => NumPut('ptr', Value, this.__hBitmap, 0)
    }
    __pBitmap__ {
        Get => NumGet(this.__pBitmap, 0, 'ptr')
        Set => NumPut('ptr', Value, this.__pBitmap, 0)
    }
}

class GdipBitmap_pBitmap extends GdipBitmap_BufferBase {
}
class GdipBitmap_hBitmap extends GdipBitmap_BufferBase {
}
class GdipBitmap_BufferBase extends Buffer {
    __New() {
        this.Size := A_PtrSize
        NumPut('ptr', 0, this)
    }
}
