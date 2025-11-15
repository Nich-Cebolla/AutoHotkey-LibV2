
g := Gui()
g.SetFont('s12 q5')
g.Add('Link',, '<a href="https://github.com/Nich-Cebolla/AutoHotkey-MakeTable">MakeTable.ahk has moved to https://github.com/Nich-Cebolla/AutoHotkey-MakeTable</a>')
g.Show()
g.GetPos(, &y)
g.Move(, y - 200)
throw Error('MakeTable.ahk has moved to https://github.com/Nich-Cebolla/AutoHotkey-MakeTable')
