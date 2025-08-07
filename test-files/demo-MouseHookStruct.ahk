
#include ..\Win32
#include WindowsHook.ahk
#include MouseHookStruct.ahk

test()


class test {
    static Call() {
        g := this.Gui := Gui()
        g.SetFont('s11 q5', 'Segoe Ui')
        g.Add('Text', , 'Press start then move your mouse around over this window.')
        g.Add('Edit', 'w300 r1 vEdt')
        g.Add('Button', 'Section vBtnStart', 'Start').OnEvent('Click', HClickButtonStart)
        g.Add('Button', 'ys vBtnStop', 'Stop').OnEvent('Click', HClickButtonStop)
        g.Add('Button', 'ys vBtnExit', 'Exit').OnEvent('Click', (*) => ExitApp())
        g.Show()
        this.WindowsHook := WindowsHook(7, MouseProc, , , , true)

        HClickButtonStart(*) {
            this.WindowsHook.Hook()
        }
        HClickButtonStop(*) {
            if !this.WindowsHook.Unhook() {
                throw OSError()
            }
        }
    }
}


MouseProc(code, wParam, lParam) {
    if code == 0 {
        _mouseHookStruct := MouseHookStruct(lParam)
        test.Gui['Edt'].Text := ('The mouse moved to ( ' _mouseHookStruct.X ', ' _mouseHookStruct.Y ' )`n')
    }
    return DllCall(
        'CallNextHookEx'
      , 'ptr', 0
      , 'int', code
      , 'uptr', wParam
      , 'ptr', lParam
      , 'ptr'
    )
}
