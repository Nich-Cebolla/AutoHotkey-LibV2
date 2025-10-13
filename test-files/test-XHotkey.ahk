
#include ..\XHotkey.ahk
#include <TestInterfaceConfig>

persistent


test()

class test {
    static __New() {
        this.DeleteProp('__New')
        this.options := { CaseSense: false }
    }
    static Call() {
        this.xhotkeycollection()
        Subjects := TestInterface.SubjectCollection(false)
        ; Skip the first index in each array, unless intending to pass a value to the `this` parameter
        ; initialValues := Map('Write', [, '"string"' ])
        Subjects.Add('test', GetPropsInfo(this, , 'Base,Prototype', false), initialValues ?? unset)
        Subjects.Add('collection', GetPropsInfo(this.hkc, , 'Base,Prototype', false), initialValues ?? unset)
        Subjects.Add('controls', GetPropsInfo(this.hkc.Controls, , 'Base,Prototype', false), initialValues ?? unset)
        Subjects.Add('stringsort', GetPropsInfo(this.hkc.StringSort, , 'Base,Prototype', false), initialValues ?? unset)
        ti:= this.TI := TestInterface('XHotkey', Subjects)
        for xhk in this.List {
            ti.AddReference(xhk.__Id, xhk.Id, xhk.Id)
        }
    }
    static Sort() {

    }
    static SetCollectionDims(Rows, Columns) {
        this.hkc.Controls.Rows := Rows
        this.hkc.Controls.Columns := Columns
    }
    static XHotkeyCollection() {
        g := this.g := gui('+Resize')
        SetThreadDpiAwarenessContext(-4)
        g.Show()
        WinSetAlwaysOnTop(1, g.Hwnd)
        hkc := this.hkc := XHotkeyCollection('test', g.Hwnd, this.options)
        _Add(1, '^+1', HotIfVsCodeActive)
        _Add(2, '^+2', HotIfVsCodeActive)
        _Add(3, '^+3', HotIfVsCodeActive)
        _Add(4, '^+4', HotIfVsCodeActive)
        _Add(5, '^+5', HotIfVsCodeActive)
        _Add(6, '^+6', HotIfVsCodeActive)
        _Add(7, '^+7', HotIfVsCodeActive)
        _Add(8, '^+8', HotIfVsCodeActive)
        _Add(9, '^+9', HotIfVsCodeActive)
        _Add(10, '^+0', HotIfVsCodeActive)
        _Add(11, '!1', '')
        _Add(12, '!2', '')
        _Add(13, '!3', '')
        _Add(14, '!4', '')
        _Add(15, '!5', '')
        _Add(16, '#1', HotIfEdgeActive)
        _Add(17, '#2', HotIfEdgeActive)
        _Add(18, '#3', HotIfEdgeActive)
        _Add(19, '#4', HotIfEdgeActive)
        _Add(20, '#5', HotIfEdgeActive)
        _Add('ghi', '\ & 1', '')
        _Add('def', '\ & 2', '')
        _Add('abc', '\ & 3', '')
        this.dimensions := this.hkc.MakeControls({ Rows: 10, Columns: 2, ResizeWindow: true })
        g.GetPos(, , &w, &h)
        g.Show('x' (dMon[1].Right - w) ' y' (dMon[1].Top + 10))

        _Add(n, name, hotifcb) {
            hkc.Add('test-' n, name, Action.Bind('test-' n, name), , hotifcb)
        }
    }
    static List => this.hkc.List
}

Action(Id, KeyName) {
    OutputDebug('Id: ' Id '; KeyName: ' KeyName '`n')
}
HotIfVSCodeActive(*) {
    return WinActive('ahk_exe Code - Insiders.exe')
}
HotIfEdgeActive(*) {
    return WinActive('ahk_exe msedge.exe')
}
