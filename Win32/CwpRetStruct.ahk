/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/CwpRetStruct.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * For use with {@link https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/WindowsHook.ahk}.
 *
 * Use with WH_CALLWNDPROCRET (12) described
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowshookexa}.
 *
 * As described on {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nc-winuser-hookproc},
 * the `lParam` parameter of HOOKPROC is a CWPRETSTRUCT. Pass `lParam` to {@link CwpRetStruct.Prototype.__New}
 * to get an object that allows you to work with the structure using property notation.
 *
 * @example
 * HOOKPROC(code, wParam, lParam) {
 *     cwpret := CwpRetStruct(lParam)
 *     switch cwpret.message {
 *          ; hook logic goes here
 *     }
 *     return DllCall(
 *         'CallNextHookEx'
 *       , 'ptr', 0
 *       , 'int', code
 *       , 'uptr', wParam
 *       , 'ptr', lParam
 *       , 'ptr'
 *     )
 * }
 * @
 */
class CwpRetStruct {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.Size :=
        ; Size      Type         Symbol     Offset           Padding
        A_PtrSize + ; LRESULT    lResult    0
        A_PtrSize + ; LPARAM     lParam     A_PtrSize * 1
        A_PtrSize + ; WPARAM     wParam     A_PtrSize * 2
        A_PtrSize + ; UINT       message    A_PtrSize * 3    +4 on x64 only
        A_PtrSize   ; HWND       hwnd       A_PtrSize * 4
        proto.offset_lResult  := 0
        proto.offset_lParam   := A_PtrSize * 1
        proto.offset_wParam   := A_PtrSize * 2
        proto.offset_message  := A_PtrSize * 3
        proto.offset_hwnd     := A_PtrSize * 4
    }
    __New(ptr) {
        this.ptr := ptr
    }
    lResult {
        Get => NumGet(this.Buffer, this.offset_lResult, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_lResult)
        }
    }
    lParam {
        Get => NumGet(this.Buffer, this.offset_lParam, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_lParam)
        }
    }
    wParam {
        Get => NumGet(this.Buffer, this.offset_wParam, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_wParam)
        }
    }
    message {
        Get => NumGet(this.Buffer, this.offset_message, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_message)
        }
    }
    hwnd {
        Get => NumGet(this.Buffer, this.offset_hwnd, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_hwnd)
        }
    }
}
