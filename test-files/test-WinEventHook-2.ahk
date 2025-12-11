
#SingleInstance force

msgReady := 0
msgExit := 0
hwndParent := 0
x := 0
y := 0

test()

class test {
    static Call() {
        g := this.Gui := Gui('+Resize', , this)
        g.SetFont('s11 q5', 'Segoe Ui')
        g.Add('Button', 'Section', 'Hide').OnEvent('Click', 'HClickButtonHide')
        g.Add('Button', 'ys', 'Change title').OnEvent('Click', 'HClickButtonChangeTitle')
        g.Add('Text', 'xs Section', 'Title:')
        g.Add('Edit', 'ys w400 vEdtTitle', '*')
        g.Add('Edit', 'xs w400 r5', 'ABC123`r`nABC123`r`nABC123`r`nABC123`r`nABC123`r`nABC123`r`nABC123')
        s := ''
        loop 200 {
            s .= Chr(Random(33, 126))
        }
        g.Add('Edit', 'xs w400 r4 -Wrap +HScroll', s '`r`n' s '`r`n' s '`r`n' s)
        g.edit := g.Add('Edit', 'xs w400')
        g.Show('x' x ' y' y)
        OnMessage(msgExit, (*) => ExitApp(), 1)
        PostMessage(msgReady, g.Hwnd, 0, , Number(hwndParent))
    }
    static HClickButtonHide(*) {
        this.Gui.Hide()
        SetTimer(ObjBindMethod(this.Gui, 'Show'), -1000)
    }
    static HClickButtonChangeTitle(*) {
        this.Gui.Title := this.Gui['EdtTitle'].Text
    }
}
