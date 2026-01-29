
#include ..\LibraryManager.ahk
#Warn VarUnset, Off

#SingleInstance force

test1()
test2()
test3()
test4()
MyLibrary_InitializeVars()
o := MyLibrary()
o := unset

test1() {
    global g_user32_GetDc, g_gdi32_GetTextExtentPoint32W,
    g_user32_ReleaseDc, g_gdi32_SelectObject
    token := LibraryManager(
        "gdi32", [ "GetTextExtentPoint32W", "SelectObject" ],
        "user32", [ "GetDC", "ReleaseDC" ]
    )

    ; Do work. These are examples of using the variables with DllCall.
    g := Gui()
    txt := g.Add("Text")
    hdc := DllCall(g_user32_GetDc, 'ptr', txt.Hwnd, 'ptr')
    hFont := SendMessage(0x0031, 0, 0, , txt.Hwnd) ; WM_GETFONT
    oldFont := DllCall(g_gdi32_SelectObject, 'ptr', hdc, 'ptr', hFont, 'ptr')
    sz := Buffer(8)
    str := "Hello, world!"
    if !DllCall(
        g_gdi32_GetTextExtentPoint32W
        , 'ptr', hdc
        , 'ptr', StrPtr(Str)
        , 'int', StrLen(Str)
        , 'ptr', sz
        , 'int'
    ) {
        throw OSError()
    }
    DllCall(g_gdi32_SelectObject, 'ptr', hdc, 'ptr', oldFont, 'int')
    DllCall(g_user32_ReleaseDc, 'ptr', txt.Hwnd, 'ptr', hdc, 'int')
    OutputDebug("The text's width is: " NumGet(sz, 0, "int") ", and the height is: " NumGet(sz, 4, "int") "`n")

    ; If the libraries are no longer needed
    token.Free()
}

test2() {
    global g_user32_GetDC, g_gdi32_GetTextExtentPoint32W,
    g_user32_ReleaseDC, g_gdi32_SelectObject

    token := LibraryManager(
        "gdi32", [ "GetTextExtentPoint32W", "SelectObject" ],
        "user32", [ "GetDC", "ReleaseDC" ]
    )
}

test3() {
    global g_user32_GetDC, g_gdi32_GetTextExtentPoint32W,
    g_user32_ReleaseDC, g_gdi32_SelectObject,
    g_shcore_GetDpiForMonitor, g_shcore_GetProcessDpiAwareness

    token := LibraryManager(
        "gdi32", [ "GetTextExtentPoint32W", "SelectObject" ],
        "user32", [ "GetDC", "ReleaseDC" ],
        "shcore", [ "GetDpiForMonitor", "GetProcessDpiAwareness" ]
    )
}

test4() {
    global g_user32_GetDC, g_gdi32_GetTextExtentPoint32W,
    g_user32_ReleaseDC, g_gdi32_SelectObject,
    g_shcore_GetDpiForMonitor, g_shcore_GetProcessDpiAwareness

    token := LibraryManager(Map(
        "gdi32", [ "GetTextExtentPoint32W", "SelectObject" ],
        "user32", [ "GetDC", "ReleaseDC" ],
        "shcore", [ "GetDpiForMonitor", "GetProcessDpiAwareness" ]
    ))
}


MyLibrary_InitializeVars(force := false) {
    global g_user32_GetDC, g_gdi32_GetTextExtentPoint32W,
    g_user32_ReleaseDC, g_gdi32_SelectObject, MyLibrary_Initialized
    if IsSet(MyLibrary_Initialized) && !force {
        return
    }
    LibraryManager(
        "gdi32", [ "GetTextExtentPoint32W", "SelectObject" ],
        "user32", [ "GetDC", "ReleaseDC" ]
    )
    MyLibrary_Initialized := true
}

class MyLibrary {
    __New() {
        global g_user32_GetDC, g_gdi32_GetTextExtentPoint32W,
        g_user32_ReleaseDC, g_gdi32_SelectObject
        this.libraryToken := LibraryManager(
            "gdi32", [ "GetTextExtentPoint32W", "SelectObject" ],
            "user32", [ "GetDC", "ReleaseDC" ]
        )
    }
    ; __Delete executes when an object's reference count
    ; reaches 0.
    __Delete() {
        if this.HasOwnProp("libraryToken") {
            this.libraryToken.Free()
            this.DeleteProp("libraryToken")
        }
    }
}
