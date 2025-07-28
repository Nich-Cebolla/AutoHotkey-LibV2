#Include ..\structs\LOGFONT.ahk
#Include ..\structs\RECT.ahk
#include <TestInterfaceConfig>

DPI_AWARENESS_CONTEXT_DEFAULT := -4

test_LOGFONT()

; This isn't finished. I got side-tracked trying to figure out why `AdjustWindowRectEx` wasn't
; returning the value I expected, then got side-side-tracked on other things. I don't think LOGFONT
; has any issues that need tested, this was more going to showcase its uses.

class test_LOGFONT {
    static Call() {
        DllCall('SetThreadDpiAwarenessContext', 'ptr', -3, 'ptr')
        G := this.G := Gui('+Resize -DPIScale')
        DllCall('SetThreadDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT_DEFAULT, 'ptr')
        G.SetFont('s11 q5', 'Cambria')
        txt := this.TextCtrl := G.Add('Text', 'vTxt', 'Hello, world!')
        G.Show('x100 y100 w500 h500')
        lf := this.Lf := LOGFONT(txt.Hwnd)
        lf()
        PropsInfoObj := GetPropsInfo(lf, , 'Base,Prototype', false)
        Subjects := TestInterface.SubjectCollection(false)
        ; Skip the first index in each array, unless intending to pass a value to the `this` parameter
        initialValues := Map('FontSize', Map('Set', [, 15]))
        Subjects.Add('Logfont', PropsInfoObj, initialValues)
        Subjects.Add('ControlFitText', GetPropsInfo(ControlFitText, '-Class', , false), Map('Call', [, '%txt%', 1, 1]))
        Subjects.Add('TextCtrl', GetPropsInfo(txt, '-Object', , false))
        TI := this.TI := TestInterface('FileMapping', Subjects)
        TI.AddReference(txt, 'txt', 'txt')
    }
}
