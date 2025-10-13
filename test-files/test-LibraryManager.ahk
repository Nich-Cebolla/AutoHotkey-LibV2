
#include ..\LibraryManager.ahk

global g_kernel32_MulDiv := g_user32_MonitorFromRect := g_user32_GetMonitorInfoW :=
g_gdiplus_GdiplusStartup := g_gdiplus_GdiplusShutdown := 0

test()

class test {
    static Call() {
        procedures1 := this.procedures1 := Map('kernel32', ['MulDiv'])
        procedures2 := this.procedures2 := Map('kernel32', ['MulDiv'])
        procedures3 := this.procedures3 := Map('user32', [ 'MonitorFromRect', 'GetMonitorInfoW' ])
        procedures4 := this.procedures4 := Map('gdiplus', [ 'GdiplusStartup', 'GdiplusShutdown' ])
        procedures5 := this.procedures5 := Map('gdiplus', [ 'GdiplusStartup', 'GdiplusShutdown' ])

        token1 := this.token1 := LibraryManager(procedures1)
        DllCall(g_kernel32_MulDiv, 'int', 3, 'int', 4, 'int', 3)
        token2 := this.token2 := LibraryManager(procedures2)
        DllCall(g_kernel32_MulDiv, 'int', 3, 'int', 4, 'int', 3)
        token1.Free()
        DllCall(g_kernel32_MulDiv, 'int', 3, 'int', 4, 'int', 3)
        token2.Free()

        token3 := this.token3 := LibraryManager(procedures3)
        rc := Buffer(16)
        NumPut('int', 1, 'int', 1, 'int', 1, 'int', 1, rc)
        Hmon := DllCall(g_user32_MonitorFromRect, 'ptr', rc, 'uint', 0x00000002, 'ptr')
        mon := Buffer(40)
        NumPut('int', 40, mon)
        if !DllCall(g_user32_GetMonitorInfoW, 'ptr', Hmon, 'ptr', mon, 'int') {
            throw OSError()
        }
        token3.Free()

        token4 := this.token4 := LibraryManager(procedures4)
        GdiplusStartupInput := Buffer(24, 0)
        NumPut('uint', 1, GdiplusStartupInput, 0)
        gdipToken4 := Buffer(A_PtrSize)
        if status := DllCall(g_gdiplus_GdiplusStartup, 'ptr', gdipToken4, 'ptr', GdiplusStartupInput, 'ptr', 0, 'uint') {
            throw OSError('``GdiplusStartup`` failed.', -1, 'Status: ' status)
        }
        token5 := this.token5 := LibraryManager(procedures5)
        gdipToken5 := Buffer(A_PtrSize)
        if status := DllCall(g_gdiplus_GdiplusStartup, 'ptr', gdipToken5, 'ptr', GdiplusStartupInput, 'ptr', 0, 'uint') {
            throw OSError('``GdiplusStartup`` failed.', -1, 'Status: ' status)
        }
        DllCall(g_gdiplus_GdiplusShutdown, 'ptr', NumGet(gdipToken4, 0, 'ptr'))
        token4.Free()
        DllCall(g_gdiplus_GdiplusShutdown, 'ptr', NumGet(gdipToken5, 0, 'ptr'))
        token5.Free()
    }
}
