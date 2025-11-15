class WndClassExW {
    static __New() {
        this.DeleteProp('__New')
        WndClassExW_SetConstants()
        proto := this.Prototype
        proto.cbSizeInstance :=
        ; Size      Type           Symbol           Offset                Padding
        4 +         ; UINT         cbSize           0
        4 +         ; UINT         style            4
        A_PtrSize + ; WNDPROC      lpfnWndProc      8
        4 +         ; int          cbClsExtra       8 + A_PtrSize * 1
        4 +         ; int          cbWndExtra       12 + A_PtrSize * 1
        A_PtrSize + ; HINSTANCE    hInstance        16 + A_PtrSize * 1
        A_PtrSize + ; HICON        hIcon            16 + A_PtrSize * 2
        A_PtrSize + ; HCURSOR      hCursor          16 + A_PtrSize * 3
        A_PtrSize + ; HBRUSH       hbrBackground    16 + A_PtrSize * 4
        A_PtrSize + ; LPCWSTR      lpszMenuName     16 + A_PtrSize * 5
        A_PtrSize + ; LPCWSTR      lpszClassName    16 + A_PtrSize * 6
        A_PtrSize   ; HICON        hIconSm          16 + A_PtrSize * 7
        proto.offset_cbSize         := 0
        proto.offset_style          := 4
        proto.offset_lpfnWndProc    := 8
        proto.offset_cbClsExtra     := 8 + A_PtrSize * 1
        proto.offset_cbWndExtra     := 12 + A_PtrSize * 1
        proto.offset_hInstance      := 16 + A_PtrSize * 1
        proto.offset_hIcon          := 16 + A_PtrSize * 2
        proto.offset_hCursor        := 16 + A_PtrSize * 3
        proto.offset_hbrBackground  := 16 + A_PtrSize * 4
        proto.offset_lpszMenuName   := 16 + A_PtrSize * 5
        proto.offset_lpszClassName  := 16 + A_PtrSize * 6
        proto.offset_hIconSm        := 16 + A_PtrSize * 7

        hMod := DllCall('GetModuleHandleW', 'wstr', 'user32', 'ptr')
        global g_user32_GetClassInfoExW := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'GetClassInfoExW', 'ptr')
        , g_user32_GetClassLongW := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'GetClassLongW', 'ptr')
        , g_kernel32_GetModuleHandleW := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandleW', 'wstr', 'kernel32', 'ptr'), 'astr', 'GetModuleHandleW', 'ptr')
    }
    __New() {
        this.Buffer := Buffer(this.cbSizeInstance)
    }
    Call(ClassNameOrAtom, hInstance?) {
        if !IsNumber(ClassNameOrAtom) {
            this.__ClassName := Buffer(StrPut(ClassNameOrAtom, 'cp1200'))
            StrPut(ClassNameOrAtom, this.__ClassName, 'cp1200')
            ClassNameOrAtom := this.__ClassName
        }
        if !DllCall(
            g_user32_GetClassInfoExW
          , 'ptr', hInstance ?? DllCall(g_kernel32_GetModuleHandleW, 'int', 0, 'ptr')
          , 'ptr', ClassNameOrAtom
          , 'ptr', this
          , 'int'
        ) {
            throw OSError()
        }
    }
    GetClassLong(hwnd, value) {
        if value := DllCall(
            g_user32_GetClassLongW
          , 'ptr', hwnd
          , 'int', value
          , 'uint'
        ) {
            return value
        } else {
            throw OSError()
        }
    }
    cbSize {
        Get => NumGet(this.Buffer, this.offset_cbSize, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_cbSize)
        }
    }
    style {
        Get => NumGet(this.Buffer, this.offset_style, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_style)
        }
    }
    lpfnWndProc {
        Get => NumGet(this.Buffer, this.offset_lpfnWndProc, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_lpfnWndProc)
        }
    }
    cbClsExtra {
        Get => NumGet(this.Buffer, this.offset_cbClsExtra, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_cbClsExtra)
        }
    }
    cbWndExtra {
        Get => NumGet(this.Buffer, this.offset_cbWndExtra, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_cbWndExtra)
        }
    }
    hInstance {
        Get => NumGet(this.Buffer, this.offset_hInstance, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_hInstance)
        }
    }
    hIcon {
        Get => NumGet(this.Buffer, this.offset_hIcon, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_hIcon)
        }
    }
    hCursor {
        Get => NumGet(this.Buffer, this.offset_hCursor, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_hCursor)
        }
    }
    hbrBackground {
        Get => NumGet(this.Buffer, this.offset_hbrBackground, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_hbrBackground)
        }
    }
    lpszMenuName {
        Get {
            Value := NumGet(this.Buffer, this.offset_lpszMenuName, 'ptr')
            if Value > 0 {
                return StrGet(Value, 'cp1200')
            } else {
                return Value
            }
        }
        Set {
            if Type(Value) = 'String' {
                if !this.HasOwnProp('__lpszMenuName')
                || (this.__lpszMenuName is Buffer && this.__lpszMenuName.Size < StrPut(Value, 'cp1200')) {
                    this.__lpszMenuName := Buffer(StrPut(Value, 'cp1200'))
                    NumPut('ptr', this.__lpszMenuName.Ptr, this.Buffer, this.offset_lpszMenuName)
                }
                StrPut(Value, this.__lpszMenuName, 'cp1200')
            } else if Value is Buffer {
                this.__lpszMenuName := Value
                NumPut('ptr', this.__lpszMenuName.Ptr, this.Buffer, this.offset_lpszMenuName)
            } else {
                this.__lpszMenuName := Value
                NumPut('ptr', this.__lpszMenuName, this.Buffer, this.offset_lpszMenuName)
            }
        }
    }
    lpszClassName {
        Get {
            Value := NumGet(this.Buffer, this.offset_lpszClassName, 'ptr')
            if Value > 0 {
                return StrGet(Value, 'cp1200')
            } else {
                return Value
            }
        }
        Set {
            if Type(Value) = 'String' {
                if !this.HasOwnProp('__lpszClassName')
                || (this.__lpszClassName is Buffer && this.__lpszClassName.Size < StrPut(Value, 'cp1200')) {
                    this.__lpszClassName := Buffer(StrPut(Value, 'cp1200'))
                    NumPut('ptr', this.__lpszClassName.Ptr, this.Buffer, this.offset_lpszClassName)
                }
                StrPut(Value, this.__lpszClassName, 'cp1200')
            } else if Value is Buffer {
                this.__lpszClassName := Value
                NumPut('ptr', this.__lpszClassName.Ptr, this.Buffer, this.offset_lpszClassName)
            } else {
                this.__lpszClassName := Value
                NumPut('ptr', this.__lpszClassName, this.Buffer, this.offset_lpszClassName)
            }
        }
    }
    hIconSm {
        Get => NumGet(this.Buffer, this.offset_hIconSm, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_hIconSm)
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}

WndClassExW_SetConstants(force := false) {
    global
    if IsSet(WndClassExW_constants_set) && !force {
        return
    }

    ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-wndclassexw
    COLOR_SCROLLBAR                  := 0
    COLOR_BACKGROUND                 := 1
    COLOR_ACTIVECAPTION              := 2
    COLOR_INACTIVECAPTION            := 3
    COLOR_MENU                       := 4
    COLOR_WINDOW                     := 5
    COLOR_WINDOWFRAME                := 6
    COLOR_MENUTEXT                   := 7
    COLOR_WINDOWTEXT                 := 8
    COLOR_CAPTIONTEXT                := 9
    COLOR_ACTIVEBORDER               := 10
    COLOR_INACTIVEBORDER             := 11
    COLOR_APPWORKSPACE               := 12
    COLOR_HIGHLIGHT                  := 13
    COLOR_HIGHLIGHTTEXT              := 14
    COLOR_BTNFACE                    := 15
    COLOR_BTNSHADOW                  := 16
    COLOR_GRAYTEXT                   := 17
    COLOR_BTNTEXT                    := 18
    COLOR_INACTIVECAPTIONTEXT        := 19
    COLOR_BTNHIGHLIGHT               := 20

    ; https://learn.microsoft.com/en-us/windows/win32/winmsg/window-class-styles
    CS_VREDRAW                       := 0x0001
    CS_HREDRAW                       := 0x0002
    CS_DBLCLKS                       := 0x0008
    CS_OWNDC                         := 0x0020
    CS_CLASSDC                       := 0x0040
    CS_PARENTDC                      := 0x0080
    CS_NOCLOSE                       := 0x0200
    CS_SAVEBITS                      := 0x0800
    CS_BYTEALIGNCLIENT               := 0x1000
    CS_BYTEALIGNWINDOW               := 0x2000
    CS_GLOBALCLASS                   := 0x4000
    CS_IME                           := 0x00010000
    CS_DROPSHADOW                    := 0x00020000

    ; Retrieves an ATOM value that uniquely identifies the window class. This is the same atom that
    ; the RegisterClassEx function returns.
    GCW_ATOM                         := -32
    ; Retrieves the size, in bytes, of the extra memory associated with the class.
    GCL_CBCLSEXTRA                   := -20
    ; Retrieves the size, in bytes, of the extra window memory associated with each window in the
    ; class. For information on how to access this memory, see GetWindowLong.
    GCL_CBWNDEXTRA                   := -18
    ; Retrieves a handle to the background brush associated with the class.
    GCL_HBRBACKGROUND                := -10
    ; Retrieves a handle to the cursor associated with the class.
    GCL_HCURSOR                      := -12
    ; Retrieves a handle to the icon associated with the class.
    GCL_HICON                        := -14
    ; Retrieves a handle to the small icon associated with the class.
    GCL_HICONSM                      := -34
    ; Retrieves a handle to the module that registered the class.
    GCL_HMODULE                      := -16
    ; Retrieves the address of the menu name string. The string identifies the menu resource
    ; associated with the class.
    GCL_MENUNAME                     := -8
    ; Retrieves the window-class style bits.
    GCL_STYLE                        := -26
    ; Retrieves the address of the window procedure, or a handle representing the address of the
    ; window procedure. You must use the CallWindowProc function to call the window procedure.
    GCL_WNDPROC                      := -24

    WndClassExW_constants_set := true
}
