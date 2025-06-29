#include ..\DirCreateEx.ahk

test()

test() {
    path := 'test-DirCreateEx\test\test\test'
    result := DirCreateEx(path)
    if result.Result {
        _Show()
        return
    }
    if !DirExist(path) {
        result.Result := [Error('Failed to create the directory.', -1, path)]
        _Show()
        return
    }
    DirDelete('test-DirCreateEx', true)

    HClickButtonClose(Ctrl, *) {
        Ctrl.Gui.Destroy()
    }
    HClickButtonCopy(Ctrl, *) {
        A_Clipboard := ctrl.Gui['EdtOutput'].Text
    }
    HClickButtonExit(Ctrl, *) {
        ExitApp()
    }
    _Show() {
        s := ''
        for err in result.Result {
            if A_Index > 1 {
                s .= '`r`n=================`r`n'
            }
            for prop in Error.Prototype.OwnProps() {
                if prop = '__Class' {
                    continue
                }
                s .= prop '`r`n' err.%prop% '`r`n'
            }
        }
        g := Gui()
        g.Add('Edit', 'w' (A_ScreenWidth * 0.4) ' Section -wrap +HScroll vEdtOutput', s)
        g.Add('Button', 'xs Section vBtnCopy', 'Copy').OnEvent('Click', HClickButtonCopy)
        g.Add('Button', 'ys vBtnClose', 'Close').OnEvent('Click', HClickButtonClose)
        g.Add('Button', 'ys vBtnExit', 'Exit').OnEvent('Click', HClickButtonExit)
        g.Show()
    }
}
