
#include ..\win32\WindowSubclassController.ahk
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
        subclassController := this.subclassController := WindowSubclassController(g.Hwnd)
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
