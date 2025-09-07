
#include ..\GdipStartup.ahk

global g_proc_gdiplus_GdipLoadImageFromFile :=
g_proc_gdiplus_GdipGetImageHeight :=
g_proc_gdiplus_GdipGetImageWidth := 0

test()

class test {
    static Path := 'icons\20x20-black.ico'
    static Call() {
        path := Buffer(StrPut(A_ScriptDir  '\' this.Path, 'utf-16'))
        StrPut(A_ScriptDir  '\' this.Path, path, 'utf-16')
        libToken := this.LibToken := LibraryManager(Map('gdiplus', ['GdipLoadImageFromFile', 'GdipGetImageHeight', 'GdipGetImageWidth']))
        this.startup1 := GdipStartup()
        _Proc()
        this.startup2 := GdipStartup()
        _Proc()
        this.startup1.Shutdown()
        _Proc()
        this.startup2.Shutdown()
        flag := 0
        try {
            _Proc()
            flag := 1
        }
        if flag {
            throw Error('The function succeeded when it should have failed.', -1)
        }

        _Proc() {
            hImage := Buffer(A_PtrSize)
            if status := DllCall(g_proc_gdiplus_GdipLoadImageFromFile, 'ptr', path, 'ptr', hImage, 'uint') {
                throw OSError('GdipLoadImageFromFile failed.', -1, 'status: ' status)
            }
            _hImage := NumGet(hImage, 0, 'ptr')
            w := h := 0
            if status := DllCall(g_proc_gdiplus_GdipGetImageHeight, 'ptr', _hImage, 'uint*', &w, 'int') {
                throw OSError('GdipGetImageWidth failed.', -1, 'status: ' status)
            }
            if status := DllCall(g_proc_gdiplus_GdipGetImageWidth, 'ptr', _hImage, 'uint*', &h, 'int') {
                throw OSError('GdipGetImageWidth failed.', -1, 'status: ' status)
            }
            if w != 20 || h != 20 {
                throw ValueError('Invalid return value from ``GdipGetImageWidth`` or ``GdipGetImageHeight``.', -1, 'W: ' w '; h: ' h)
            }
        }
    }
}

