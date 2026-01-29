/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/LibraryManager.ahk
    Author: Nich-Cebolla
    License: MIT
*/

class LibraryManager extends Array {
    static __New() {
        global
        this.DeleteProp('__New')
        this.Prototype.invalidCharPattern := 'S)[^\p{L}0-9_\x{00A0}-\x{10FFFF}]'
        if !IsSet(LIBRARYMANAGER_VAR_PREFIX) {
            LIBRARYMANAGER_VAR_PREFIX := 'g'
        }
        local hmod := DllCall('GetModuleHandleW', 'wstr', 'kernel32', 'ptr')
        if !IsSet(g_kernel32_GetProcAddress) {
            g_kernel32_GetProcAddress := DllCall('GetProcAddress', 'ptr', hmod, 'astr', 'GetProcAddress', 'ptr')
        }
        if !IsSet(g_kernel32_LoadLibraryW) {
            g_kernel32_LoadLibraryW := DllCall(g_kernel32_GetProcAddress, 'ptr', hmod, 'astr', 'LoadLibraryW', 'ptr')
        }
        if !IsSet(g_kernel32_FreeLibrary) {
            g_kernel32_FreeLibrary := DllCall(g_kernel32_GetProcAddress, 'ptr', hmod, 'astr', 'FreeLibrary', 'ptr')
        }
    }
    /**
     * @description - The purpose of {@link LibraryManager} is to improve application performance by obtaining
     * procedure addresses and storing the addresses in a global variable so any subsystem that calls that
     * procedure can have access to the direct address.
     *
     * See {@link https://www.autohotkey.com/docs/v2/lib/DllCall.htm#load} for a discussion of this
     * in the AHK official docs.
     *
     * {@link LibraryManager} handles loading the libraries, and returns a token that makes it easy
     * to release the libraries when they are no longer needed.
     *
     *
     * # LoadLibrary and FreeLibrary
     *
     * Windows uses reference counts to manage calls to
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-loadlibraryw LoadLibraryW}
     * and
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-freelibrary FreeLibrary}.
     * When `LoadLibrary` is called, if the library has already been loaded, the reference count is
     * increased and the same handle is returned. When `FreeLibrary` is called, the reference count
     * is decreased. If the reference count reaches 0 then the library is unloaded and the handle
     * associated with the library is no longer valid. {@link LibraryManager} handles this internally;
     * your code is only responsible for storing a reference to the  {@link LibraryManager} object.
     *
     *
     * # Usage
     *
     * Using {@link LibraryManager} is easy, but requires some preparation. There are three
     * components to using {@link LibraryManager}:
     *
     * 1. Declare the global variables.
     * 2. Call {@link LibraryManager.Prototype.__New} (this method).
     * 3. (Optional) When the libraries are no longer needed, call
     *    {@link LibraryManager.Prototype.Free}.
     *
     *
     * ## Declare the global variables
     *
     * Since variables cannot be declared dynamically at runtime, we must adhere to a standard format.
     * The structure of the variable name is:
     *
     * `%LIBRARYMANAGER_VAR_PREFIX%_<library name>_<procedure name>`
     *
     * By default, {@link LIBRARYMANAGER_VAR_PREFIX} is "g". You can override this in your code before
     * calling {@link LibraryManager.Prototype.__New}, but generally this should be avoided.
     *
     * <library name> is the name of the dll without the ".dll" extension.
     *
     * <procedure name> is the name of the procedure. The address of this procedure will be assigned
     * to the variable.
     *
     * Internally, the variable names are dereferenced with this logic:
     *
     * @example
     * hmod := DllCall(g_kernel32_LoadLibraryW, "wstr", dllName, "ptr")
     * address := DllCall(g_kernel32_GetProcAddress, "ptr", hmod, "astr", procedureName, "ptr")
     * dllName := RegExReplace(StrReplace(dllName, ".dll", ""), LibraryManager.Prototype.invalidCharPattern, "")
     * %LIBRARYMANAGER_VAR_PREFIX%_%dllName%_%procedureName% := address
     * @
     *
     * The variables must be declared anywhere in the code as global variables. This could be in a
     * separate file as a simple list of variables, or anywhere in the auto-execute section of the
     * code. For example:
     *
     * @example
     * global g_user32_SetWindowPos, g_user32_GetClientRect, g_user32_GetWindowRect,
     * g_gdi32_GetTextExtentPoint32W, g_gdi32_GetTextExtentExPoint
     * @
     *
     * Variables can also be declared in a function statement. For example:
     *
     * @example
     * MyLibrary_InitializeVars() {
     *     global g_user32_SetWindowPos, g_user32_GetClientRect,
     *     g_user32_GetWindowRect, g_gdi32_GetTextExtentPoint32W,
     *     g_gdi32_GetTextExtentExPoint
     *     ; initialization logic...
     * }
     * @
     *
     *
     * ## Avoiding var unset warning
     *
     * Since the code will not contain an expression that sets the variables directly, you will see
     * a var unset warning before script startup unless you address this. There are two approaches.
     *
     * You can use {@link https://www.autohotkey.com/docs/v2/lib/_Warn.htm #Warn}, i.e.
     * `#warn VarUnset, Off`.
     *
     * If using `#Warn` is undesirable, you must set the variables to some initial value.
     *
     * @example
     * MyLibrary_InitializeVars() {
     *     global g_user32_SetWindowPos, g_user32_GetClientRect,
     *     g_user32_GetWindowRect, g_gdi32_GetTextExtentPoint32W,
     *     g_gdi32_GetTextExtentExPoint
     *
     *     g_user32_SetWindowPos := g_user32_GetClientRect :=
     *     g_user32_GetWindowRect := g_gdi32_GetTextExtentPoint32W :=
     *     g_gdi32_GetTextExtentExPoint := 0
     *
     *     ; initialization logic...
     * }
     * @
     *
     *
     * ## Calling LibraryManager
     *
     * Each subsystem calls {@link LibraryManager.Prototype.__New}, specifying the dll names to be
     * loaded along with an array of procedure names.
     *
     * {@link LibraryManager.Prototype.__New} then calls
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-loadlibraryw LoadLibraryW}
     * for the dlls, and calls
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-getprocaddress GetProcAddress}
     * for the procedures.
     *
     * @example
     * global g_user32_GetDC, g_gdi32_GetTextExtentPoint32W,
     * g_user32_ReleaseDC, g_gdi32_SelectObject
     *
     * token := LibraryManager(
     *     "gdi32", [ "GetTextExtentPoint32W", "SelectObject" ],
     *     "user32", [ "GetDC", "ReleaseDC" ]
     * )
     * @
     *
     * Your code can include any number of libraries in the function call. Alternate the values
     * as <dll name>, <array of procedure names>, <dll name>, <array of procedure names>, ...
     *
     * @example
     * global g_user32_GetDC, g_gdi32_GetTextExtentPoint32W,
     * g_user32_ReleaseDC, g_gdi32_SelectObject,
     * g_shcore_GetDpiForMonitor, g_shcore_GetProcessDpiAwareness
     *
     * token := LibraryManager(
     *     "gdi32", [ "GetTextExtentPoint32W", "SelectObject" ],
     *     "user32", [ "GetDC", "ReleaseDC" ],
     *     "shcore", [ "GetDpiForMonitor", "GetProcessDpiAwareness" ]
     * )
     * @
     *
     * Your code can also use a Map object if that is preferable.
     *
     * @example
     * global g_user32_GetDC, g_gdi32_GetTextExtentPoint32W,
     * g_user32_ReleaseDC, g_gdi32_SelectObject,
     * g_shcore_GetDpiForMonitor, g_shcore_GetProcessDpiAwareness
     *
     * token := LibraryManager(Map(
     *     "gdi32", [ "GetTextExtentPoint32W", "SelectObject" ],
     *     "user32", [ "GetDC", "ReleaseDC" ],
     *     "shcore", [ "GetDpiForMonitor", "GetProcessDpiAwareness" ]
     * ))
     * @
     *
     * ## Using the global variables
     *
     * The variables are used as the first parameter of
     * {@link https://www.autohotkey.com/docs/v2/lib/DllCall.htm DllCall}.
     *
     * @example
     * global g_user32_GetDC, g_gdi32_GetTextExtentPoint32W,
     * g_user32_ReleaseDC, g_gdi32_SelectObject
     *
     * token := LibraryManager(
     *     "gdi32", [ "GetTextExtentPoint32W", "SelectObject" ],
     *     "user32", [ "GetDC", "ReleaseDC" ]
     * )
     *
     * ; Do work. These are examples of using the variables with DllCall.
     * g := Gui()
     * txt := g.Add("Text")
     * hdc := DllCall(g_user32_GetDC, "ptr", txt.Hwnd, "ptr")
     * hFont := SendMessage(0x0031, 0, 0, , txt.Hwnd) ; WM_GETFONT
     * oldFont := DllCall(g_gdi32_SelectObject, "ptr", hdc, "ptr", hFont, "ptr")
     * sz := Buffer(8)
     * str := "Hello, world!"
     * if !DllCall(
     *     g_gdi32_GetTextExtentPoint32W
     *     , "ptr", hdc
     *     , "ptr", StrPtr(Str)
     *     , "int", StrLen(Str)
     *     , "ptr", sz
     *     , "int"
     * ) {
     *     throw OSError()
     * }
     * DllCall(g_gdi32_SelectObject, "ptr", hdc, "ptr", oldFont, "int")
     * DllCall(g_user32_ReleaseDC, "ptr", txt.Hwnd, "ptr", hdc, "int")
     * OutputDebug("The text's width is: " NumGet(sz, 0, "int") ", and the height is: " NumGet(sz, 4, "int") "`n")
     *
     * ; If the libraries are no longer needed
     * token.Free()
     * @
     *
     *
     * ## Call LibraryManager.Prototype.Free
     *
     * Call {@link LibraryManager.Prototype.Free} to decrement the Windows API"s reference count for
     * the libraries associated with that token.
     *
     * Note that {@link LibraryManager} only ever assigns values to the global variables; it never
     * unsets the variables. If a library is unloaded and the reference count reaches zero, the
     * procedures will no longer be accessible from the process, but the variables will still have
     * the addresses, which would then be invalid. This decision was made because including the logic
     * that would allow unsetting the variables when the libraries are unloaded would require
     * significant additional memory. Additionally, if a library is unloaded and one"s code attempts
     * to access a procedure from the library, that represents a logical error in the code, and
     * so an error should be thrown regardless.
     *
     *
     * # Usage patterns
     *
     *
     * ## Initialization function
     *
     * Using a function like the below example is helpful in cases when the following are true:
     * - Multiple subsystems will use the same libraries.
     * - It is not guaranteed that any of the subsystems will be accessed during the lifetime of the process.
     * - It is unknown which subsystem might be accessed first.
     * - Once the libraries are loaded, they will not be unloaded.
     *
     * In this context, the application can avoid using the memory until the libraries are needed,
     * but since multiple subsystems may potentially call the function, we include the `force`
     * parameter and the `MyLibrary_Initialized` global variable to avoid loading the libraries
     * multiple times. Since the application will never unload the libraries, there is no need for
     * multiple tokens to exist.
     *
     * @example
     * MyLibrary_InitializeVars(force := false) {
     *     global g_user32_GetDC, g_gdi32_GetTextExtentPoint32W,
     *     g_user32_ReleaseDC, g_gdi32_SelectObject, MyLibrary_Initialized
     *     if IsSet(MyLibrary_Initialized) && !force {
     *         return
     *     }
     *     LibraryManager(
     *         "gdi32", [ "GetTextExtentPoint32W", "SelectObject" ],
     *         "user32", [ "GetDC", "ReleaseDC" ]
     *     )
     *     MyLibrary_Initialized := true
     * }
     * @
     *
     *
     * ## Class initialization
     *
     * When writing a class with properties that frequently call `DllCall`, calling {@link LibraryManager}
     * from the static {@link https://www.autohotkey.com/docs/v2/Objects.htm#Custom_NewDelete __New}
     * method is an effective approach. The static "__New" method is invoked the first time a
     * class is referenced.
     *
     * @example
     * class MyLibrary {
     *     static __New() {
     *         global g_user32_GetDC, g_gdi32_GetTextExtentPoint32W,
     *         g_user32_ReleaseDC, g_gdi32_SelectObject
     *         this.DeleteProp("__New")
     *         this.libraryToken := LibraryManager(
     *             "gdi32", [ "GetTextExtentPoint32W", "SelectObject" ],
     *             "user32", [ "GetDC", "ReleaseDC" ]
     *         )
     *     }
     *     __New() {
     *         this.g := Gui()
     *         this.txt := this.g.Add("Text")
     *     }
     *     Measure(str) {
     *         hwnd := this.txt.Hwnd
     *         hdc := DllCall(g_user32_GetDC, "ptr", hwnd, "ptr")
     *         hFont := SendMessage(0x0031, 0, 0, , hwnd) ; WM_GETFONT
     *         oldFont := DllCall(g_gdi32_SelectObject, "ptr", hdc, "ptr", hFont, "ptr")
     *         sz := Buffer(8)
     *         if !DllCall(
     *             g_gdi32_GetTextExtentPoint32W
     *             , "ptr", hdc
     *             , "ptr", StrPtr(Str)
     *             , "int", StrLen(Str)
     *             , "ptr", sz
     *             , "int"
     *         ) {
     *             throw OSError()
     *         }
     *         DllCall(g_gdi32_SelectObject, "ptr", hdc, "ptr", oldFont, "int")
     *         DllCall(g_user32_ReleaseDC, "ptr", hwnd, "ptr", hdc, "int")
     *         return sz
     *     }
     * }
     * @
     *
     *
     * ## Class instance
     *
     * If your application is designed to unload the libraries when they are no longer needed, you
     * will likely want each subsystem to obtain and manage its own token, and so you would not use
     * a function like the above example. Instead, you would likely use a class object and define the
     * {@link https://www.autohotkey.com/docs/v2/Objects.htm#Custom_NewDelete __Delete} method.
     * For example:
     *
     * @example
     * class MyLibrary {
     *     __New() {
     *         global g_user32_GetDC, g_gdi32_GetTextExtentPoint32W,
     *         g_user32_ReleaseDC, g_gdi32_SelectObject
     *         this.libraryToken := LibraryManager(
     *             "gdi32", [ "GetTextExtentPoint32W", "SelectObject" ],
     *             "user32", [ "GetDC", "ReleaseDC" ]
     *         )
     *     }
     *     ; __Delete executes when an object's reference count
     *     ; reaches 0.
     *     __Delete() {
     *         if this.HasOwnProp("libraryToken") {
     *             this.libraryToken.Free()
     *             this.DeleteProp("libraryToken")
     *         }
     *     }
     * }
     * @
     *
     * @param {<String>,<String[]>, ...} Procedures - An alternating list of values where the first
     * value is the name of a dll and the second value is an array of names of procedures.
     */
    __New(Procedures*) {
        if Procedures.Length {
            pattern := this.invalidCharPattern
            if Procedures[1] is Map {
                loop Procedures.Length {
                    for dllName, list in Procedures[A_Index] {
                        if !(hmod := DllCall(g_kernel32_LoadLibraryW, 'wstr', dllName, 'ptr')) {
                            throw OSError(, , dllName)
                        }
                        LibraryManager_LoadLibraries(&dllName, RegExReplace(StrReplace(dllName, '.dll', ''), pattern, ''), hmod, list)
                        this.Push(hmod)
                    }
                }
            } else {
                loop Procedures.Length / 2 {
                    dllName := Procedures[A_Index * 2 - 1]
                    list := Procedures[A_Index * 2]
                    if !(hmod := DllCall(g_kernel32_LoadLibraryW, 'wstr', dllName, 'ptr')) {
                        throw OSError(, , dllName)
                    }
                    LibraryManager_LoadLibraries(&dllName, RegExReplace(StrReplace(dllName, '.dll', ''), pattern, ''), hmod, list)
                    this.Push(hmod)
                }
            }
        }
    }
    Free() {
        if this.Length {
            for hmod in this {
                if !DllCall(g_kernel32_FreeLibrary, 'ptr', hmod, 'int') {
                    throw OSError()
                }
            }
        }
    }
}

LibraryManager_LoadLibraries(&dllName, modifiedDllName, hmod, list) {
    global
    for proc in list {
        if !(%LIBRARYMANAGER_VAR_PREFIX%_%modifiedDllName%_%proc%
        := DllCall(g_kernel32_GetProcAddress, 'ptr', hmod, 'astr', proc, 'ptr')) {
            throw OSError(, , dllName '\' proc '. Note that the procedure names are case sensitive.')
        }
    }
}
