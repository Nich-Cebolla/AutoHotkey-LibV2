
#include ..\win32\WindowSubclass.ahk
#SingleInstance force

test()

class test {
    static Call() {
        g := this.g := Gui('+Resize')
        g.SetFont('s11 q5', 'Segoe Ui')
        g.Add('Text', 'w500', 'There are three actions registered with the subclass procedure.`r`n`r`nIf you focus the edit control, "Focused edit" should say "yes" briefly.`r`n`r`nIf you click on the row in the list-view control and press F2 on the keyboard, "Focused edit" should say "yes" briefly then when you submit your changes to the value "Label edit" should say "yes" briefly.`r`n`r`nIf you move the window around, "Window moved" should say "yes" briefly.')
        this.lv := g.Add('ListView', 'w500 r1 -ReadOnly', [ 'c1' ])
        this.lv.Add(, 'row1')
        this.lv.ModifyCol(1, 490)
        g.Add('Edit', 'w500 r5 vedit')
        g.Add('Text', 'Section', 'Focused edit:')
        g.Add('Text', 'ys w100 vfocusedEdit', 'no')
        g.Add('Text', 'xs Section', 'Label edit:')
        g.Add('Text', 'ys w100 vlabelEdit', 'no')
        g.Add('Text', 'xs Section', 'Window moved:')
        g.Add('Text', 'ys w100 vwindowMoved', 'no')
        g.Add('Button', 'xs', 'Exit').OnEvent('Click', _exit)
        g.Show('x400 y100')
        subclassController := this.subclassController := WindowSubclassController(SubclassProc, 1, g.Hwnd)
        subclassController.CommandAdd(0x0100, _focusedEdit) ; EN_SETFOCUS
        subclassController.NotifyAdd(-176, _labelEdit) ; LVN_ENDLABELEDIT
        subclassController.MessageAdd(0x0003, _windowMoved) ; WM_MOVE

        return

        _focusedEdit(*) {
            test.g['focusedEdit'].Text := 'yes'
            SetTimer(_reset, -1000)

            _reset() {
                test.g['focusedEdit'].Text := 'no'
            }
        }
        _labelEdit(*) {
            test.g['labelEdit'].Text := 'yes'
            SetTimer(_reset, -1000)

            _reset() {
                test.g['labelEdit'].Text := 'no'
            }
        }
        _windowMoved(*) {
            test.g['windowMoved'].Text := 'yes'
            SetTimer(_reset, -1000)

            _reset() {
                test.g['windowMoved'].Text := 'no'
            }
        }
        _exit(*) {
            test.subclassController.Dispose()
            ExitApp()
        }
    }
}

/**
 * @desc - {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nc-commctrl-subclassproc}
 *
 * @param {Integer} HwndSubclass - The handle to the subclassed window (the handle passed to `SetWindowSubclass`).
 *
 * @param {Integer} uMsg - The message being passed.
 *
 * @param {Integer} wParam - Additional message information. The contents of this parameter depend on the value of uMsg.
 *
 * @param {Integer} lParam - Additional message information. The contents of this parameter depend on the value of uMsg.
 *
 * @param {Integer} uIdSubclass - The subclass ID. This is the value pased to the `uIdSubclass` parameter of `SetWindowSubclass`.
 *
 * @param {Integer} dwRefData - The reference data provided to `SetWindowSubclass`.
 */
SubclassProc(HwndSubclass, uMsg, wParam, lParam, uIdSubclass, dwRefData) {
    Critical('On')
    subclassController := ObjFromPtrAddRef(dwRefData)
    switch uMsg {
    case 0x0111: ; WM_COMMAND
        if subclassController.flag_Command {
            if callbackCollection := subclassController.CommandGet((wParam >> 16) & 0xFFFF) {
                for cb in callbackCollection {
                    if result := cb(subclassController, (wParam >> 16) & 0xFFFF, HwndSubclass, uMsg, wParam, lParam, uIdSubclass) {
                        return result
                    }
                }
            }
        }
    case 0x004E: ; WM_NOTIFY
        if subclassController.flag_Notify {
            hdr := WindowSubclass_Nmhdr(lParam)
            if callbackCollection := subclassController.NotifyGet(hdr.code_int) {
                for cb in callbackCollection {
                    if result := cb(subclassController, hdr, HwndSubclass, uMsg, wParam, lParam, uIdSubclass) {
                        return result
                    }
                }
            }
        }
    default:
        if subclassController.flag_Message {
            if callbackCollection := subclassController.MessageGet(uMsg) {
                for cb in callbackCollection {
                    if result := cb(subclassController, HwndSubclass, uMsg, wParam, lParam, uIdSubclass) {
                        return result
                    }
                }
            }
        }
    }
    return DllCall(
        g_comctl32_DefSubclassProc
      , 'ptr', HwndSubclass
      , 'uint', uMsg
      , 'uptr', wParam
      , 'ptr', lParam
      , 'ptr'
    )
}
