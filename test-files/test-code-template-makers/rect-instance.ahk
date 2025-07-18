
; I have not released TestInterface yet, you cannot run this test.
#include <TestInterfaceConfig>
#include <ResolveRelativePath>
#include <GuiResizer>
SplitPath(A_LineFile, , &Dir)
SetWorkingDir(Dir)

test.ToCode()

class test {
    static Gui := {
        Edit: {
            Width: 600
          , Rows: 10
          , Opt: '-Wrap +HScroll vEdtDisplay'
          , Resizer:  { X: 1, Y: 1, H: 1, W: 1 }
        }
    }
    , RcObj := [ 50, 50, 600, 250 ]
    , BufInput := [ 'int', -100, 'int', -100, 'int', 200, 'int', -20 ]
    , BufSize := 32
    , TxtResizer := { Y: 1 }
    static GetSubjects() {
        SetThreadDpiAwarenessContext(-3)
        g := this.g :=
        uis := this.uis := []
        edits := this.Edits := []
        editOpt := this.Gui.Edit
        loop 3 {
            uis.Push(dGui('+Resize -DPIScale'))
            edits.Push(uis[-1].Add('Edit', 'w' editOpt.Width ' r' editOpt.Rows ' ' editOpt.Opt))
            uis[-1].Add('Text', 'w' editOpt.Width ' vTxtInfo', 'Window ' A_Index)
            if A_Index > 1 {
                DllCall('SetParent', 'ptr', uis[-1].hwnd, 'ptr', uis[1].hwnd, 'ptr')
            }
            edits[-1].Resizer := editOpt.Resizer
            uis[-1]['TxtInfo'].Resizer := this.TxtResizer
            uis[-1].Resizer := GuiResizer(uis[-1])
        }
        SetThreadDpiAwarenessContext(-4)
        window_rect := this.window_rect := WinRect(edits[1].hwnd)
        client_rect := this.client_rect := WinRect(edits[1].hwnd, true)
        rc := this.rc := Rect(this.RcObj*)
        buf := this.buf := Buffer(this.BufSize)
        if this.BufInput.Length <= 8 {
            this.BufInput.Push(buf, 12)
        }
        NumPut(this.BufInput*)
        Subjects := TestInterface.SubjectCollection(false)
        Subjects.Add('Uis', GetPropsInfo(Uis, '-Array', , false))
        Subjects.Add('Edits', GetPropsInfo(Edits, '-Array', , false))
        Subjects.Add('window_rect', GetPropsInfo(window_rect, '-Buffer', , false))
        Subjects.Add('client_rect', GetPropsInfo(client_rect, '-Buffer', , false))
        Subjects.Add('rc', GetPropsInfo(rc, '-Buffer', , false))
        Subjects.Add('buf', GetPropsInfo(buf, '-Buffer', , false))
        return Subjects
    }
    static ToCode() {
        this.GetSubjects()
        A_Clipboard := SubjectsToCode('Uis', this.uis, 'Edits', this.edits
        , 'window_rect', this.window_rect, 'client_rect', this.client_rect
        , 'rc', this.rc, 'buf', this.buf)
    }
}
