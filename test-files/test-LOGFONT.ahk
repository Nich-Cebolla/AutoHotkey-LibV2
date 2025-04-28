#Include ..\structs\LOGFONT.ahk
#Include ..\structs\RECT.ahk
#Include ..\structs\WINDOWINFO.ahk
#Include ..\..\Display\lib\Display_ComboBox.ahk
DPI_AWARENESS_CONTEXT_DEFAULT := -4

test_LOGFONT()

; This isn't finished. I got side-tracked trying to figure out why `AdjustWindowRectEx` wasn't
; returning the value I expected, then got side-side-tracked on other things. I don't think LOGFONT
; has any issues that need tested, this was more going to showcase its uses.

class test_LOGFONT {
    static Call() {
        DllCall('SetThreadDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT_DEFAULT, 'ptr')
        G := this.G := Gui('+Resize -DPIScale')
        G.Checkboxes := []
        G.Windows := []
        ListSet := []
        ListGet := []
        ListCall := []
        for Prop in LOGFONT.Prototype.OwnProps() {
            Desc := LOGFONT.Prototype.GetOwnPropDesc(Prop)
            if Desc.HasOwnProp('Set') {
                ListSet.Push(Desc)
            } else if Desc.HasOwnProp('Get') {
                ListGet.Push(Desc)
            } else if Desc.HasOwnProp('Call') {
                ListCall.Push(Desc)
            }
        }
        G.Add('Button', 'Section', 'New Window').OnEvent('Click', HClickButtonNewWindow)
        G.Add('Button', 'ys', 'Add Text').OnEvent('Click', HClickButtonAddText)
        G.Add('Text', 'xs vTxtWindows', 'Windows').GetPos(&cx, &cy, &cw)
        G.Add('Text', Format('x{} y{} vTxtControls', cx + cw + G.MarginX + 15, cy), 'Controls')
        G.Show('x1700 y100')

        HClickButtonAddText(*) {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT_DEFAULT, 'ptr')
            Response := InputBox('Enter text to add to the new window:', 'Add Text', , 'Some text')
            if Response.Result == 'Cancel' {
                return
            }
            WG := G.LastCheckbox.Window
            WG.Texts.Push(WG.Add('Text', , Response.Value))
            try {
                GetTextExtentPoint32(Response.Value, WG.Texts[-1].hWnd, &W, &H)
            } catch OSError as err {
                MsgBox('Error: ' ErrorHandler(err))
                return
            }
            rc := RECT(0, 0, W + WG.MarginX * 2, H + WG.MarginY * 2)
            WINFO := WINDOWINFO(WG.hWnd)
            WINFO()
            W := rc.W
            H := rc.H
            WG.GetClientPos(&gx, &gy, &gw, &gh)
            DllCall('SetWindowPos', 'ptr', WG.hWnd, 'int', 0, 'int', 0, 'int', 0, 'int', W, 'int', H, 'int', 0x0002 | 0x0004, 'int')
            WG.GetClientPos(&gx, &gy, &gw, &gh)
            if G.Checkboxes.Length {
                G.Checkboxes[-1].GetPos(&chkX, &chkY, , &chkH)
            } else {
                G['TxtControls'].GetPos(&chkX, &chkY, , &chkH)
            }
            WG.Texts[-1].Checkbox := G.Add('Checkbox', Format('x{} y{}', chkX, chkY + chkH + G.MarginY), StrLen(Response.Value) > 20 ? SubStr(Response.Value, 1, 20) : Response.Value)
        }
        HClickButtonNewWindow(*) {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT_DEFAULT, 'ptr')
            if G.Checkboxes.Length {
                G.Checkboxes[-1].GetPos(&cx, &cy, , &ch)
            } else {
                G['TxtWindows'].GetPos(&cx, &cy, , &ch)
            }
            G.Windows.Push(Gui('+Resize -DPIScale', 'Window #' G.Windows.Length + 1))
            G.Windows[-1].Texts := []
            G.Checkboxes.Push(G.Add('CheckBox', Format('x{} y{}', cx, cy + ch + G.MarginY), G.Windows[-1].Title))
            G.Checkboxes[-1].Window := G.Windows[-1]
            G.Checkboxes[-1].OnEvent('Click', HClickCheckboxAny)
            HClickCheckboxAny(G.Checkboxes[-1])
            G.Windows[-1].Show()
        }
        HClickCheckboxAny(Ctrl, *) {
            if G.HasOwnProp('LastCheckbox') {
                G.LastCheckbox.Value := 0
                WG := G.LastCheckbox.Window
                for Txt in WG.Texts {
                    Txt.Checkbox.Visible := 0
                }
            }
            G.LastCheckbox := Ctrl
            Ctrl.Value := 1
        }
    }
}

/**
 * @description - Gets the bounding rectangle of all child windows of a given window.
 * @param {Integer} hWnd - The handle to the parent window.
 * @returns {Rect} - The bounding rectangle of all child windows, specifically the smallest
 * rectangle that contains all child windows.
 */
GetChildrenBoundingRect(hWnd) {
    rects := [Rect(0, 0, 0, 0), Rect(0, 0, 0, 0), Rect()]
    DllCall('EnumChildWindows', 'ptr', hWnd, 'ptr', cb := CallbackCreate(_EnumChildWindowsProc, 'fast',  1), 'int', 0, 'int')
    CallbackFree(cb)
    return rects[1]

    _EnumChildWindowsProc(hWnd) {
        DllCall('GetWindowRect', 'ptr', hWnd, 'ptr', rects[1], 'int')
        DllCall('UnionRect', 'ptr', rects[2], 'ptr', rects[3], 'ptr', rects[1], 'int')
        rects.Push(rects.RemoveAt(1))
        return 1
    }
}

GetTextExtentPoint32(str, hWnd, &Width?, &Height?) {
    hDC := DllCall('GetDC', 'Ptr', hWnd)
    if !hDc {
        throw OSError('Failed to get DC.', -1, A_LastError)
    }
    hFont := SendMessage(0x0031,,,hWnd)

    ; Select the font into the DC
    if !(oldFont := DllCall('Gdi32\SelectObject', 'Ptr', hDC, 'Ptr', hFont, 'Ptr')) {
        throw OSError('Failed to select font into DC.', -1, A_LastError)
    }
    ; Create buffer to store SIZE
    StrPut(str, lpStr := Buffer(StrPut(str, 'utf-16')), StrLen(str), 'utf-16')
    ; Measure the text
    if !DllCall('C:\Windows\System32\Gdi32.dll\GetTextExtentPoint32', 'Ptr'
    , hDC, 'Ptr', lpStr, 'Int', StrLen(str), 'Ptr', SIZE := Buffer(8)) {
        throw OSError('Failed to get text extent point.', -1, A_LastError)
    }
    DllCall('SelectObject', 'ptr', hdc, 'ptr', oldFont)
    DllCall('ReleaseDC', 'Ptr', hWnd, 'Ptr', hDC)
    Width := NumGet(SIZE, 0, 'UINT')
    Height := NumGet(SIZE, 4, 'UINT')
}


ErrorHandler(err?) {
    code := (IsSet(err) ? err.Extra : '') || A_LastError
    if !code {
        return -1
    }
    buf := Buffer(A_PtrSize)
    bytes := DllCall('FormatMessage'
        , 'uint', 0x00000100 | 0x00001000   ; dwFlags - FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM
        , 'ptr', 0                          ; lpSource
        , 'uint', code                      ; dwMessageId
        , 'uint', 0                         ; dwLanguageId
        , 'ptr', buf                        ; lpBuffer
        , 'uint', 0                         ; nSize
        , 'ptr', 0                          ; arguments
        , 'int'                             ; the number of TCHARs written to the buffer
    )
    ptr := NumGet(buf, 'ptr')
    str := StrGet(ptr, bytes)
    DllCall('LocalFree', 'ptr', ptr)
    return str
}
