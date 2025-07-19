/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/structs/RECT.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/*
    As of 7/19/25: Much of this is untested. Please report any unexpected errors. I will test soon.
*/

/**
    This library is designed to allow RECT members of any struct at an arbitrary, static offset
    to make use of the functions. For example, consider the WINDOWINFO struct. There are two
    members that are RECTs: rcWindow at offset 4, and rcClient at offset 20. To avoid repetitive
    code and unnecessary work, the `WindowInfo` class in file WindowInfo.ahk initializes instances
    like this:
    @example
        __New(Hwnd := 0) {
            this.Hwnd := Hwnd
            this.Buffer := Buffer(60)
            NumPut('uint', 60, this.Buffer)
            this()
            this.Rect := WinRect.FromPtr(this.Ptr + 4)
            this.ClientRect := WinRect.FromPtr(this.Ptr + 20)
        }
    @
    The objects can then make use of the existing buffer, and will be updated along with the other
    members whenever the `WindowInfo` object itself is updated. My original design was to define
    the classes as `Buffer` objects, and manipulate them by defining some preset offset. That approach
    was more complicated and less flexible than this approach, because not only can this approach
    still use a native AHK `Buffer` object, it can also use objects obtained from external code
    by specifying at what pointer offset the RECT is located.

    If you use a pointer obtained externally, your code is responsible for ensuring that the `Rect`
    object associated with it is invalidated and destroyed when the memory is released.
    Calling the "Dispose" method on any objects from a class in this library (Point, Rect, WinRect,
    or WindowInfo) is sufficient. If your code does not use a pointer to an object created externally,
    then you do not need to worry about this because this library handles it for you.

    To add to the flexibility offered by this library, each class has a static method "Make" which
    accepts a class object as a parameter, then defines the relevant methods on the class' prototype.
    @example
        class Rect {
            L {
                Get => NumGet(this, 'int', 0)
                Set => NumPut('int', Value, this, 0)
            }
            T {
                Get => NumGet(this, 'int', 4)
                Set => NumPut('int', Value, this, 4)
            }
            ; ... etc
        }
    @
    This creates multiple, separate function objects all doing essentially the same thing. This library
    follows this approach instead:
    @example
        class RectBase {
            static Make(Cls) {
                Proto := Cls.Prototype
                Proto.DefineProp('L', { Get: RectGetCoordinate.Bind(0), Set: RectSetCoordinate.Bind(0) })
                Proto.DefineProp('T', { Get: RectGetCoordinate.Bind(4), Set: RectSetCoordinate.Bind(4) })
                ; ... etc
            }
        }
    @
    The impact on memory usage is unclear to me because we are still creating new function objects,
    two `BoundFunc` objects for each property. But there are two benefits to this approach:

    - The base `Func` is the same for each property. This will save time if something needs updated
    in a function's logic or some feature is added beacuse the code only needs updated in one location.
    Though RECT-related functions are pretty straightforward, I found this to be a good exercise for
    applying this principle elsewhere.

    - Other classes can make use of the methods without requiring that class to inherit from `RectBase`
    or `Point` or `WinRect` or `WindowInfo`. AHK's object model is a single-inheritance model. This
    can make it complicated when we want an object to share properties or methods from two or more
    separate classes. With this library's approach, not only can we still define a class to inherit
    from one of the library's classes, with one simple function call we can define the methods on a
    separate class that does not inherit from one of the classes as well. Maximum flexibility :thumb:.

    Because properties { L, T, R, B, W, H } are defined with both a getter and setter, more complex
    functions don't need to rely on offsets and can instead access the values using the relevant
    property. When defining classes to inherit from one of this library's classes, or to make use of
    a static method "Make", your code does not need to be concerned about the ptr offsets and can
    make use of these properties directly.

    Note that the static method "Make" only defines the methods relevant to that specific class,
    not any class that it inherits from. For example, the static `WinRect.Make` defines all the
    relevant "WinRect" functions, but not the "Rect" functions. When we make an instance of
    `WinRect`, the instance object will have all of the "WinRect" and "Rect" methods because
    `WinRect` inherits from `Rect`. However, if I defined some other class and only called `WinRect.Make(cls)`
    then that class will be missing half of its methods and will throw errors.

    This an example of how to correctly define a class that inherits from any arbitrary class, and
    that makes use of the methods available from this library.
    @example
        ; Include the library
        #include <Rect>

        class MyClass extends Gui {
            static __New() {
                ; The static method "__New" is called whenever the class is first referenced, so it
                ; allows us to define our own initialization logic. You typically want to delete
                ; the method so inheritors don't repeat the same actions.
                this.DeleteProp('__New')
                ; We need both the methods from `RectBase` and `WinRect`.
                RectBase.Make(this)
                WinRect.Make(this)
            }
            static Call(Opt?, Title?, EventHandler?) {
                MyGui := Gui(Opt ?? unset, Title ?? unset, EventHandler ?? unset)
                ObjSetBase(MyGui, this.Prototype)
                ; The methods from this library still need a buffer object to be used with the dll
                ; calls even though we are using an AHK Gui.
                MyGui.Buffer := Buffer(16)
            }
        }
    @

    With the above example, the native AHK Gui objects created by calling `MyClass()` will also
    have the methods offered by this library.

    Understand that ONLY the instance methods are copied over, NOT the static methods like
    `WinRect.FromDesktop`, `WinRect.FromForeground`, etc.

    Whenever one of the static methods "Make" are called, the class object and the class' prototype
    object will also be defined with a "__Call" method (unless the prototype already has a "__Call"
    method). If you are not familiar with meta functions, you will want to read
    {@link https://www.autohotkey.com/docs/v2/Objects.htm#Meta_Functions}.

    This "__Call" method exposes a way to call `SetThreadDpiAwarenessContext` before any other method
    by adding "_S" to the end of the method. By default, the thread dpi awareness context is set to
    -4. To use another value, define a property "DpiAwarenessContext" on an individual object or
    on a prototype object, with the desired value. Typically you'll want to use -4 if your application
    is dpi aware. See {@link https://www.autohotkey.com/docs/v2/misc/DPIScaling.htm}.
    @example
        ; The default is already -4; this is for example.
        WinRect.Prototype.DpiAwarenessContext := -4
        hwnd := WinExist('A')
        if !hwnd {
            throw Error('Window not found.', -1)
        }
        wrc := WinRect(hwnd)
        ; This sets the dpi awareness context to -3 prior to performing the action
        wrc.GetPos_S(&x, &y, &w, &h)
    @
*/

/**
 * Calls `GetWindowInfo`. The object has a number of properties to make using it easier.
 * - cbSize - 0:4 - The size of this structure.
 * - rcWindow - 4:16 - The coordinates of the window.
 * - rcClient - 20:16 - THe coordinates of the client area.
 * - dwStyle - 36:4 - The window styles.
 * {@link https://learn.microsoft.com/en-us/windows/desktop/winmsg/window-styles}
 * - dwExStyle - 40:4 - The extende window styles.
 * {@link https://learn.microsoft.com/en-us/windows/desktop/winmsg/extended-window-styles}
 * - dwWindowStatus - 44:4 - The window status. Returns `1` if the window is active. Else, `0`.
 * - cxWindowBorders - 48:4 - The width of the window borders in pixels.
 * - cyWindowBorders - 52:4 - The height of the window border in pixels.
 * - atomWindowType - 56:2 - The window class atom.
 * {@link https://learn.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-registerclassa}.
 * - wCreatorVersion - 58:2 - The Windows version of the application that created the window.
 */
class WindowInfo {
    static __New() {
        this.DeleteProp('__New')
        this.WindowStyles := Map()
        this.WindowExStyles := Map()
        this.WindowStyles.CaseSense := this.WindowExStyles.CaseSense := false
        this.WindowStyles.Set(
            'WS_OVERLAPPED', 0x00000000
          , 'WS_POPUP', 0x80000000
          , 'WS_CHILD', 0x40000000
          , 'WS_MINIMIZE', 0x20000000
          , 'WS_VISIBLE', 0x10000000
          , 'WS_DISABLED', 0x08000000
          , 'WS_CLIPSIBLINGS', 0x04000000
          , 'WS_CLIPCHILDREN', 0x02000000
          , 'WS_MAXIMIZE', 0x01000000
          , 'WS_CAPTION', 0x00C00000
          , 'WS_BORDER', 0x00800000
          , 'WS_DLGFRAME', 0x00400000
          , 'WS_VSCROLL', 0x00200000
          , 'WS_HSCROLL', 0x00100000
          , 'WS_SYSMENU', 0x00080000
          , 'WS_THICKFRAME', 0x00040000
          , 'WS_GROUP', 0x00020000
          , 'WS_TABSTOP', 0x00010000
          , 'WS_MINIMIZEBOX', 0x00020000
          , 'WS_MAXIMIZEBOX', 0x00010000
        )
        this.WindowExStyles.Set(
            'WS_EX_DLGMODALFRAME', 0x00000001
          , 'WS_EX_NOPARENTNOTIFY', 0x00000004
          , 'WS_EX_TOPMOST', 0x00000008
          , 'WS_EX_ACCEPTFILES', 0x00000010
          , 'WS_EX_TRANSPARENT', 0x00000020
          , 'WS_EX_MDICHILD', 0x00000040
          , 'WS_EX_TOOLWINDOW', 0x00000080
          , 'WS_EX_WINDOWEDGE', 0x00000100
          , 'WS_EX_CLIENTEDGE', 0x00000200
          , 'WS_EX_CONTEXTHELP', 0x00000400
          , 'WS_EX_RIGHT', 0x00001000
          , 'WS_EX_LEFT', 0x00000000
          , 'WS_EX_RTLREADING', 0x00002000
          , 'WS_EX_LTRREADING', 0x00000000
          , 'WS_EX_LEFTSCROLLBAR', 0x00004000
          , 'WS_EX_RIGHTSCROLLBAR', 0x00000000
          , 'WS_EX_CONTROLPARENT', 0x00010000
          , 'WS_EX_STATICEDGE', 0x00020000
          , 'WS_EX_APPWINDOW', 0x00040000
        )
        this.Make(this)
    }
    static FromPtr(Ptr, Hwnd := 0) {
        ObjAddRef(Ptr)
        winfo := { Ptr: Ptr, Size: 60, Hwnd: Hwnd }
        winfo.DefineProp('__Delete', { Call: RectDeletePtr })
        ObjSetBase(winfo, this.Prototype)
        winfo.__MakeWindowRectObjects()
        return winfo
    }
    static FromBuffer(Buf, Hwnd := 0) {
        winfo := { Buffer: buf, Hwnd: Hwnd }
        ObjSetBase(winfo, this.Prototype)
        winfo.__MakeWindowRectObjects()
        return winfo
    }
    static Make(Cls, Prefix := '', Suffix := '') {
        Proto := Cls.Prototype
        if !HasMethod(Cls, '__Call') {
            Cls.DefineProp('__Call', { Call: RectSetThreadDpiAwareness__Call })
        }
        if !HasMethod(Proto, '__Call') {
            Proto.DefineProp('__Call', { Call: RectSetThreadDpiAwareness__Call })
        }
        Proto.DefineProp(Prefix 'AdjustRectEx' Suffix, { Call: WindowInfoAdjustRectEx })
        Proto.DefineProp(Prefix 'CallbackFromDesktop' Suffix, { Call: WindowInfoCallbackFromDesktop })
        Proto.DefineProp(Prefix 'CallbackFromForeground' Suffix, { Call: WindowInfoCallbackFromForeground })
        Proto.DefineProp(Prefix 'CallbackFromNext' Suffix, { Call: WindowInfoCallbackFromNext })
        Proto.DefineProp(Prefix 'CallbackFromParent' Suffix, { Call: WindowInfoCallbackFromParent })
        Proto.DefineProp(Prefix 'Dispose' Suffix, { Call: WindowInfoDispose })
        Proto.DefineProp(Prefix 'GetExStyles' Suffix, { Call: WindowInfoGetExStyles })
        Proto.DefineProp(Prefix 'GetStyles' Suffix, { Call: WindowInfoGetStyles })
        Proto.DefineProp(Prefix 'HasExStyle' Suffix, { Call: WindowInfoHasExStyle })
        Proto.DefineProp(Prefix 'HasStyle' Suffix, { Call: WindowInfoHasStyle })
        Proto.DefineProp(Prefix 'MoveClient' Suffix, { Call: WindowInfoMoveClient })
    }
    __New(Hwnd := 0) {
        this.Hwnd := Hwnd
        this.Buffer := Buffer(60)
        NumPut('uint', 60, this.Buffer)
        this.__MakeWindowRectObjects()
    }
    Call() {
        if !DllCall(RectBase.GetWindowInfo, 'ptr', this.Hwnd, 'ptr', this, 'int') {
            throw OSError()
        }
    }
    /**
     * @description - Sets a callback that updates the object's property "Hwnd" when
     * `WindowInfo.Prototype.Call` is called. By default, `WindowInfo.Prototype.Call` does not
     * update the "Hwnd" property, and instead calls `GetWindowInfo` with the current "Hwnd". When
     * `WindowInfo.Prototype.SetCallback` is called, a new method "Call" is defined that calls
     * the callback function and uses the return value to update the property "Hwnd", then calls
     * `GetWindowInfo` using that new Hwnd. To remove the callback and return the "Call" method
     * to its original functionality, pass zero or an empty string to `Callback`.
     *
     * This library includes a number of functions that are useful for this, each beginning with
     * "WindowInfoCallback". However, your code will likely benefit from knowing when no "Hwnd" is
     * returned by one of the functions, so your code can respond in some type of way. To write your
     * own function that makes use of any of the built-in functions, you can define it this way:
     *
     * If your code does not need the `WindowInfo` object, exclude it using the "*" operator:
     * @example
     *  MyHelperFunc(*) {
     *      hwnd := WindowInfoCallbackFromForeground()
     *      if hwnd {
     *          return hwnd
     *      } else {
     *          ; do something
     *      }
     *  }
     *
     *  winfo := WindowInfo()
     *  winfo.SetCallback(MyHelperFunc)
     *  winfo()
     * @
     *
     * If your code does need the `WindowInfo` object, it will be the first and only parameter.
     * @example
     *  MyHelperFunc(winfo) {
     *      hwnd := WindowInfoCallbackFromParent(winfo)
     *      if hwnd {
     *          return hwnd
     *      } else {
     *          ; do something
     *      }
     *  }
     *
     *  hwnd := WinExist('A')
     *  if !hwnd {
     *      throw Error('Window not found.', -1)
     *  }
     *  winfo := WindowInfo(hwnd)
     *  winfo.SetCallback(MyHelperFunc)
     *  winfo()
     *  MsgBox(winfo.Hwnd == hwnd) ; 0
     * @
     *
     * @param {*} Callback - A `Func` or callable object that accepts the `WindowInfo` object as its
     * only parameter, and that returns a new "Hwnd" value. If the callback returns zero or an empty
     * string, the property "Hwnd" will not be updated and `GetWindowInfo` will not be called.
     * If the callback returns an integer, the property "Hwnd" is updated and `GetWindowInfo` is
     * called. If the callback returns another type of value, a TypeError is thrown.
     */
    SetCallback(Callback) {
        if Callback {
            this.DefineProp('Callback', { Call: Callback })
            this.DefineProp('Call', WindowInfo.Prototype.GetOwnPropDesc('__CallWithCallback'))
        } else {
            this.DeleteProp('Callback')
            this.DefineProp('Call', WindowInfo.Prototype.GetOwnPropDesc('Call'))
        }
    }
    __CallWithCallback() {
        if hwnd := this.Callback() {
            if IsInteger(hwnd) {
                this.Hwnd := hwnd
            } else {
                throw TypeError('Invalid ``Hwnd`` returned.', -1, Type(hwnd))
            }
            if !DllCall(RectBase.GetWindowInfo, 'ptr', this.Hwnd, 'ptr', this, 'int') {
                throw OSError()
            }
        }
    }
    __MakeWindowRectObjects() {
        if this.Hwnd {
            this()
        }
        this.Rect := WinRect.FromPtr(this.Ptr + 4)
        this.ClientRect := WinRect.FromPtr(this.Ptr + 20)
    }
    Atom => NumGet(this, 56, 'short')
    BorderHeight => NumGet(this, 52, 'int')
    BorderWidth => NumGet(this, 48, 'int')
    CreatorVersion => NumGet(this, 58, 'short')
    ExStyle => NumGet(this, 40, 'uint')
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
    Status => NumGet(this, 44, 'int')
    Style => NumGet(this, 36, 'uint')
}

class WinRect extends Rect {
    static __New() {
        this.DeleteProp('__New')
        this.Make(this)
    }
    static FromDesktop(ClientRect := false) => this(DllCall(RectBase.GetDesktopWindow, 'ptr'), ClientRect)
    static FromForeground(ClientRect := false) => this(DllCall(RectBase.GetForegroundWindow, 'ptr'), ClientRect)
    /**
     * @param Cmd -
     * - 2 : Returns a handle to the window below the given window.
     * - 3 : Returns a handle to the window above the given window.
     */
    static FromMouse(ClientRect := false) {
        pt := Point()
        DllCall(RectBase.GetCursorPos, 'ptr', pt, 'int')
        return this(DllCall(RectBase.WindowFromPoint, 'ptr', pt, 'ptr'))
    }
    static FromNext(Hwnd, Cmd, ClientRect := false) {
        return this(DllCall(RectBase.GetNextWindow, 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'uint', Cmd, 'ptr'), ClientRect)
    }
    static FromParent(Hwnd, ClientRect := false) => this(DllCall(RectBase.GetParent, 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'ptr'), ClientRect)
    static FromPoint(X, Y, ClientRect := false) {
        return this(DllCall(RectBase.WindowFromPoint, 'ptr', Point(X, Y), 'ptr'), ClientRect)
    }
    static FromPtr(Ptr, Hwnd := 0) {
        ObjAddRef(Ptr)
        wrc := { Ptr: Ptr, Size: 16, Hwnd: Hwnd }
        wrc.DefineProp('__Delete', { Call: RectDeletePtr })
        ObjSetBase(wrc, this.Prototype)
        return wrc
    }
    static FromShell(ClientRect := false) => this(DllCall(RectBase.GetShellWindow, 'ptr'), ClientRect)
    static FromTop(Hwnd := 0, ClientRect := false) => this(DllCall(RectBase.GetTopWindow, 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'ptr'), ClientRect)
    /**
     * @param Cmd -
     * - GW_CHILD - 5 - The retrieved handle identifies the child window at the top of the Z order,
     *  if the specified window is a parent window; otherwise, the retrieved handle is NULL. The
     *  function examines only child windows of the specified window. It does not examine descendant
     *  windows.
     *
     * - GW_ENABLEDPOPUP - 6 - The retrieved handle identifies the enabled popup window owned by the
     *  specified window (the search uses the first such window found using GW_HwndNEXT); otherwise,
     *  if there are no enabled popup windows, the retrieved handle is that of the specified window.
     *
     * - GW_HwndFIRST - 0 - The retrieved handle identifies the window of the same type that is highest
     *  in the Z order. If the specified window is a topmost window, the handle identifies a topmost
     *  window. If the specified window is a top-level window, the handle identifies a top-level
     *  window. If the specified window is a child window, the handle identifies a sibling window.
     *
     * - GW_HwndLAST - 1 - The retrieved handle identifies the window of the same type that is lowest
     *  in the Z order. If the specified window is a topmost window, the handle identifies a topmost
     *  window. If the specified window is a top-level window, the handle identifies a top-level window.
     *  If the specified window is a child window, the handle identifies a sibling window.
     *
     * - GW_HwndNEXT - 2 - The retrieved handle identifies the window below the specified window in
     *  the Z order. If the specified window is a topmost window, the handle identifies a topmost
     *  window. If the specified window is a top-level window, the handle identifies a top-level
     *  window. If the specified window is a child window, the handle identifies a sibling window.
     *
     * - GW_HwndPREV - 3 - The retrieved handle identifies the window above the specified window in
     *  the Z order. If the specified window is a topmost window, the handle identifies a topmost
     *  window. If the specified window is a top-level window, the handle identifies a top-level
     *  window. If the specified window is a child window, the handle identifies a sibling window.
     *
     * - GW_OWNER - 4 - The retrieved handle identifies the specified window's owner window, if any.
     *  For more information, see Owned Windows.
     */
    static Get(Hwnd, Cmd, ClientRect := false) {
        return this(DllCall(RectBase.GetWindow, 'ptr', IsObject(Hwnd) ? Hwnd.Hwnd : Hwnd, 'uint', Cmd, 'ptr'), ClientRect)
    }
    static Make(Cls, Prefix := '', Suffix := '') {
        Proto := Cls.Prototype
        if !HasMethod(Cls, '__Call') {
            Cls.DefineProp('__Call', { Call: RectSetThreadDpiAwareness__Call })
        }
        if !HasMethod(Proto, '__Call') {
            Proto.DefineProp('__Call', { Call: RectSetThreadDpiAwareness__Call })
        }
        Proto.DefineProp(Prefix 'Apply' Suffix, { Call: WinRectApply })
        Proto.DefineProp(Prefix 'BringToTop' Suffix, { Call: WinRectBringToTop })
        Proto.DefineProp(Prefix 'ChildFromPoint' Suffix, { Call: WinRectChildFromPoint })
        Proto.DefineProp(Prefix 'ChildFromPointEx' Suffix, { Call: WinRectChildFromPointEx })
        Proto.DefineProp(Prefix 'ChildWindowFromPointEx' Suffix, { Call: WinRectChildWindowFromPointEx })
        Proto.DefineProp(Prefix 'Dispose' Suffix, { Call: RectDispose })
        Proto.DefineProp(Prefix 'EnumChildWindows' Suffix, { Call: WinRectEnumChildWindows })
        Proto.DefineProp(Prefix 'GetChildBoundingRect' Suffix, { Call: WinRectGetChildBoundingRect })
        Proto.DefineProp(Prefix 'GetClientRect' Suffix, { Call: WinRectGetClientRect })
        Proto.DefineProp(Prefix 'GetDpi' Suffix, { Get: WinRectGetDpi })
        Proto.DefineProp(Prefix 'GetMonitor' Suffix, { Get: WinRectGetMonitor })
        Proto.DefineProp(Prefix 'GetPos' Suffix, { Call: WinRectGetPos })
        Proto.DefineProp(Prefix 'IsChild' Suffix, { Call: WinRectIsChild })
        Proto.DefineProp(Prefix 'IsParent' Suffix, { Call: WinRectIsParent })
        Proto.DefineProp(Prefix 'Visible' Suffix, { Get: WinRectIsVisible })
        Proto.DefineProp(Prefix 'MapPoints' Suffix, { Call: WinRectMapPoints })
        Proto.DefineProp(Prefix 'Move' Suffix, { Call: WinRectMove })
        Proto.DefineProp(Prefix 'RealChildFromPoint' Suffix, { Call: WinRectRealChildFromPoint })
        Proto.DefineProp(Prefix 'SetActive' Suffix, { Call: WinRectSetActive })
        Proto.DefineProp(Prefix 'SetForeground' Suffix, { Call: WinRectSetForeground })
        Proto.DefineProp(Prefix 'SetParent' Suffix, { Call: WinRectSetParent })
        Proto.DefineProp(Prefix 'SetPosKeepAspectRatio' Suffix, { Call: WinRectSetPosKeepAspectRatio })
        Proto.DefineProp(Prefix 'Show' Suffix, { Call: WinRectShow })
        Proto.DefineProp(Prefix 'Update' Suffix, { Call: WinRectUpdate })
    }
    __New(Hwnd := 0, ClientRect := false) {
        this.Hwnd := Hwnd
        this.Size := 16
        if ClientRect {
            this.Client := true
            if !DllCall(RectBase.GetClientRect, 'ptr', Hwnd, 'ptr', this, 'int') {
                throw OSError()
            }
        } else {
            this.Client := false
            if !DllCall(RectBase.GetWindowRect, 'ptr', Hwnd, 'ptr', this, 'int') {
                throw OSError()
            }
        }
    }
}

class Rect extends RectBase {
    static FromBuffer(buf) {
        rc := { Buffer: buf }
        ObjSetBase(rc, this.Prototype)
        return rc
    }
    static FromDimensions(X, Y, W, H) {
        return this(X, Y, X + W, Y + H)
    }
    static FromPtr(Ptr) {
        ObjAddRef(Ptr)
        rc := { Ptr: Ptr, Size: 16 }
        rc.DefineProp('__Delete', { Call: RectDeletePtr })
        ObjSetBase(rc, this.Prototype)
        return rc
    }
    __New(L := 0, T := 0, R := 0, B := 0) {
        NumPut('int', L, 'int', T, 'int', R, 'int', B, this.Buffer := Buffer(16))
    }

    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}

class RectBase {
    static __New() {
        this.DeleteProp('__New')
        this.Modules := Map()
        this.Addresses := Map()
        this.Modules.CaseSense := this.Addresses.CaseSense := false
        this.ResidentModules := [ 'User32', 'Kernel32', 'ComCtl32', 'Gdi32' ]
        for dllName in this.ResidentModules {
            this.Modules.Set(dllName, DllCall('GetModuleHandle', 'str', dllName, 'ptr'))
        }
        this.Make(this)
    }
    static __Get(Name, Params) {
        if this.Addresses.Has(Name) {
            return this.Addresses.Get(Name)
        }
        if InStr(Name, '_') {
            modName := StrReplace(SubStr(Name, 1, InStr(Name, '_', , , -1) - 1), '_', '\')
            if this.Modules.Has(modName) {
                hModule := this.Modules.Get(modName)
            } else {
                hModule := DllCall('LoadLibrary','Str', SubStr(Name, 1, InStr(Name, '_', , , -1) - 1) '.dll', 'ptr')
                if hModule {
                    this.Modules.Set(modName, hModule)
                } else {
                    throw Error('Unable to locate module.', -1, modName)
                }
            }
            _name := SubStr(Name, InStr(Name, '_', , , -1) + 1)
        } else {
            for dllName in this.ResidentModules {
                if address := DllCall('GetProcAddress', 'ptr', this.Modules.Get(dllName), 'Astr', Name, 'ptr') {
                    this.Addresses.Set(Name, address)
                    return address
                }
            }
            return Name
        }
    }
    static UnloadAll(*) {
        for modName, hModule in this.Prototype.Modules {
            DllCall('FreeLibrary', 'ptr', hModule)
        }
    }
    static Make(Cls, Prefix := '', Suffix := '') {
        Proto := Cls.Prototype
        if !HasMethod(Cls, '__Call') {
            Cls.DefineProp('__Call', { Call: RectSetThreadDpiAwareness__Call })
        }
        if !HasMethod(Proto, '__Call') {
            Proto.DefineProp('__Call', { Call: RectSetThreadDpiAwareness__Call })
        }
        Proto.DefineProp(Prefix 'B' Suffix, { Get: RectGetCoordinate.Bind(12), Set: RectSetCoordinate.Bind(12) })
        Proto.DefineProp(Prefix 'BL' Suffix, { Get: RectGetPoint.Bind(0, 12) })
        Proto.DefineProp(Prefix 'BR' Suffix, { Get: RectGetPoint.Bind(8, 12) })
        Proto.DefineProp(Prefix 'Clone' Suffix, { Call: RectClone })
        Proto.DefineProp(Prefix 'Dispose' Suffix, { Call: RectDispose })
        Proto.DefineProp(Prefix 'Dpi' Suffix, { Get: RectGetDpi })
        Proto.DefineProp(Prefix 'Equal' Suffix, { Call: RectEqual })
        Proto.DefineProp(Prefix 'GetHeightSegment' Suffix, { Call: RectGetHeightSegment })
        Proto.DefineProp(Prefix 'GetWidthSegment' Suffix, { Call: RectGetWidthSegment })
        Proto.DefineProp(Prefix 'H' Suffix, { Get: RectGetLength.Bind(4), Set: RectSetLength.Bind(4) })
        Proto.DefineProp(Prefix 'Inflate' Suffix, { Call: RectInflate })
        Proto.DefineProp(Prefix 'Intersect' Suffix, { Call: RectIntersect })
        Proto.DefineProp(Prefix 'IsEmpty' Suffix, { Call: RectIsEmpty })
        Proto.DefineProp(Prefix 'L' Suffix, { Get: RectGetCoordinate.Bind(0), Set: RectSetCoordinate.Bind(0) })
        Proto.DefineProp(Prefix 'MidX' Suffix, { Get: (Self) => RectGetWidthSegment(Self, 2) })
        Proto.DefineProp(Prefix 'MidY' Suffix, { Get: (Self) => RectGetHeightSegment(Self, 2) })
        Proto.DefineProp(Prefix 'Monitor' Suffix, { Get: RectGetMonitor })
        Proto.DefineProp(Prefix 'MoveAdjacent' Suffix, { Call: MoveAdjacent })
        Proto.DefineProp(Prefix 'Offset' Suffix, { Call: RectOffset })
        Proto.DefineProp(Prefix 'PtIn' Suffix, { Call: RectPtIn })
        Proto.DefineProp(Prefix 'R' Suffix, { Get: RectGetCoordinate.Bind(8), Set: RectSetCoordinate.Bind(8) })
        Proto.DefineProp(Prefix 'Set' Suffix, { Call: RectSet })
        Proto.DefineProp(Prefix 'Subtract' Suffix, { Call: RectSubtract })
        Proto.DefineProp(Prefix 'T' Suffix, { Get: RectGetCoordinate.Bind(4), Set: RectSetCoordinate.Bind(4) })
        Proto.DefineProp(Prefix 'TL' Suffix, { Get: RectGetPoint.Bind(0, 4) })
        Proto.DefineProp(Prefix 'ToClient' Suffix, { Call: RectToClient })
        Proto.DefineProp(Prefix 'ToScreen' Suffix, { Call: RectToScreen })
        Proto.DefineProp(Prefix 'TR' Suffix, { Get: RectGetPoint.Bind(8, 4) })
        Proto.DefineProp(Prefix 'Union' Suffix, { Call: RectUnion })
        Proto.DefineProp(Prefix 'Union' Suffix, { Call: RectUnion })
        Proto.DefineProp(Prefix 'W' Suffix, { Get: RectGetLength.Bind(0), Set: RectSetLength.Bind(0) })
    }
    Size => 16
}

class Point {
    static __New() {
        this.DeleteProp('__New')
        this.Make(this)
    }
    static FromBuffer(buf) {
        if buf.Size < 8 {
            buf.Size := 8
        }
        pt := { Buffer: Buf }
        ObjSetBase(pt, this.Prototype)
        return pt
    }
    static FromCaretPos() {
        pt := Point()
        DllCall(RectBase.GetCaretPos, 'ptr', pt, 'int')
        return pt
    }
    static FromMouse() {
        pt := Point()
        DllCall(RectBase.GetCursorPos, 'ptr', pt, 'int')
        return pt
    }
    static FromPtr(Ptr) {
        ObjAddRef(Ptr)
        pt := { Ptr: Ptr, Size: 8 }
        pt.DefineProp('__Delete', { Call: RectDeletePtr })
        ObjSetBase(pt, this.Prototype)
        return pt
    }
    static Make(Cls, Prefix := '', Suffix := '') {
        Proto := Cls.Prototype
        if !HasMethod(Proto, '__Call') {
            Proto.DefineProp('__Call', { Call: RectSetThreadDpiAwareness__Call })
        }
        Proto.DefineProp(Prefix 'Clone' Suffix, { Call: PtClone })
        Proto.DefineProp(Prefix 'Dispose' Suffix, { Call: RectDispose })
        Proto.DefineProp(Prefix 'Dpi' Suffix, { Get: PtGetDpi })
        Proto.DefineProp(Prefix 'GetCursorPos' Suffix, { Call: PtGetCursorPos })
        Proto.DefineProp(Prefix 'LogicalToPhysical' Suffix, { Call: PtLogicalToPhysical })
        Proto.DefineProp(Prefix 'LogicalToPhysicalForPerMonitorDPI' Suffix, { Call: PtLogicalToPhysicalForPerMonitorDPI })
        Proto.DefineProp(Prefix 'Monitor' Suffix, { Get: PtGetMonitor })
        Proto.DefineProp(Prefix 'PhysicalToLogical' Suffix, { Call: PtPhysicalToLogical })
        Proto.DefineProp(Prefix 'PhysicalToLogicalForPerMonitorDPI' Suffix, { Call: PtPhysicalToLogicalForPerMonitorDPI })
        Proto.DefineProp(Prefix 'SetCaretPos' Suffix, { Call: PtSetCaretPos })
        Proto.DefineProp(Prefix 'ToClient' Suffix, { Call: PtToClient })
        Proto.DefineProp(Prefix 'ToScreen' Suffix, { Call: PtToScreen })
        Proto.DefineProp(Prefix 'Value' Suffix, { Get: PtGetValue })
        Proto.DefineProp(Prefix 'X' Suffix, { Get: RectGetCoordinate.Bind(0), Set: RectSetCoordinate.Bind(0) })
        Proto.DefineProp(Prefix 'Y' Suffix, { Get: RectGetCoordinate.Bind(4), Set: RectSetCoordinate.Bind(4) })

    }
    __New(X := 0, Y := 0) {
        this.Buffer := Buffer(8)
        NumPut('int', X, 'int', Y, this.Buffer, 0)
    }
    Call() {
        DllCall(RectBase.GetCursorPos, 'ptr', this, 'int')
    }
    /**
     * @param {Integer} Id -
     * - 1 : The default, which updates the object's X and Y values to the mouse's current position.
     * - 2 : Updates the object's X and Y values to the mouse's current position, and calls
     * `WindowFromPoint`, returning the window handle if one is obtained, else returning `0`.
     */
    SetCallAction(Id := 1) {
        switch Id, 0 {
            case 1: this.DefineProp('Call', Point.Prototype.GetOwnPropDesc('Call'))
            case 2: this.DefineProp('Call', Point.Prototype.GetOwnPropDesc('__CallGetWindowUnderMouse'))
        }
    }
    __CallGetWindowUnderMouse() {
        DllCall(RectBase.GetCursorPos, 'ptr', this, 'int')
        return DllCall(RectBase.WindowFromPoint, 'ptr', this, 'ptr')
    }
    Size => this.Buffer.Size
    Ptr => this.Buffer.Ptr
}
/**
 * @description - Moves the window adjacent to another window while ensuring that the window stays
 * within the monitor's work area. The properties { L, T, R, B } of `Subject` are updated with the
 * new values. Your code must call a function to move the window itrc.
 *
 * @param {Rect} Subject - The object representing the window that will be moved. This can be an
 * instance of `Rect` or any class that inherits from `Rect`, or any object with properties
 * { L, T, R B }. Those four property values will be updated with the result of this function call.
 *
 * @param {Rect} Target - The object representing the window that will be used as reference. This can
 * be an instance of `Rect` or any class that inherits from `Rect`, or any object with properties
 * { L, T, R, B }.
 *
 * If `ContainerRect` is unset and if `Target` does not inherit from `Rect`, `Target` must also
 * have a property `Monitor`. See {@link MoveAdjacent~ContainerRect}.
 *
 * @param {*} [ContainerRect] - If set, `ContainerRect` defines the boundaries which restrict
 * the area that the window is permitted to be moved within. The object must have poperties
 * { L, T, R, B } to be valid. If unset, `Target` must have a property `Monitor` which returns the
 * monitor handle to the monitor with which it shares the greatest area of intersection because this
 * is used to get the the work area of the monitor. `Rect` objects in this library have this property
 * built-in.
 *
 * @param {String} [Dimension = "X"] - Either "X" or "Y", specifying if the window is to be moved
 * adjacent to `Target` on either the X or Y axis.
 *
 * @param {String} [Prefer = ""] - A character indicating a preferred side. If `Prefer` is an
 * empty string, the function will move the window to the side the has the greatest amount of
 * space between the monitor's border and `Target`. If `Prefer` is any of the following values,
 * the window will be moved to that side unless doing so would cause the the window to extend
 * outside of the monitor's work area.
 * - "L" - Prefers the left side.
 * - "T" - Prefers the top side.
 * - "R" - Prefers the right side.
 * - "B" - Prefes the bottom.
 * Any other nonzero value is silently ignored.
 *
 * @param {Number} [Padding = 0] - The amount of padding to leave between the window and `Target`.
 *
 * @param {Integer} [InsufficientSpaceAction = 0] - Determines the action taken if there is
 * insufficient space to move the window adjacent to `Target` while also keeping the window
 * entirely within the monitor's work area. The function will always sacrifice some of the padding
 * if it will allow the window to stay within the monitor's work area. If the space is still
 * insufficient, the action can be one of the following:
 * - 0 : The function will not move the window.
 * - 1 : The function will move the window, allowing the window's area to extend into a non-visible
 *   region of the monitor.
 * - 2 : The function will move the window, keeping the window's area within the monitor's work
 *   area by allowing the window to overlap with `Target`.
 *
 * @returns {Integer} - If the insufficient space action was invoked, returns 1. Else, returns 0.
 */
MoveAdjacent(Subject, Target, ContainerRect?, Dimension := 'X', Prefer := '', Padding := 0, InsufficientSpaceAction := 0) {
    if IsSet(ContainerRect) {
        monL := ContainerRect.L
        monT := ContainerRect.T
        monR := ContainerRect.R
        monB := ContainerRect.B
        monW := monR - monL
        monH := monB - monT
    } else if Hmon := Target.Monitor {
        mon := Buffer(40)
        NumPut('int', 40, mon)
        if !DllCall(RectBase.user32_GetMonitorInfo, 'ptr', Hmon, 'ptr', mon, 'int') {
            throw OSError()
        }
        monL := NumGet(mon, 20, 'int')
        monT := NumGet(mon, 24, 'int')
        monR := NumGet(mon, 28, 'int')
        monB := NumGet(mon, 32, 'int')
        monW := monR - monL
        monH := monB - monT
    } else {
        throw Error('Failed to evaluate the monitor`'s bounding rectangle.', -1)
    }
    subL := Subject.L
    subT := Subject.T
    subR := Subject.R
    subB := Subject.B
    subW := subR - subL
    subH := subB - subT
    tarL := Target.L
    tarT := Target.T
    tarR := Target.R
    tarB := Target.B
    tarW := tarR - tarL
    tarH := tarB - tarT
    if Dimension = 'X' {
        if Prefer = 'L' {
            if tarL - subW - Padding >= monL {
                X := tarL - subW - Padding
            }
        } else if Prefer = 'R' {
            if tarR + subW + Padding <= monR {
                X := tarR + Padding
            }
        } else if Prefer {
            throw _ValueError('Prefer', Prefer)
        }
        if !IsSet(X) {
            flag_nomove := false
            X := _Proc(subW, subL, subR, tarW, tarL, tarR, monW, monL, monR, Prefer = 'L' ? 1 : Prefer = 'R' ? -1 : 0)
            if flag_nomove {
                return 1
            }
        }
        Subject.X := X
        Subject.Y := tarT + tarH / 2 - subH / 2
        Subject.R := X + subW
        Subject.B := Y + subH
    } else if Dimension = 'Y' {
        if Prefer = 'T' {
            if tarT - subH - Padding >= monL {
                Y := tarT - subH - Padding
            }
        } else if Prefer = 'B' {
            if tarB + subH + Padding <= monB {
                Y := tarB + Padding
            }
        } else if Prefer {
            throw _ValueError('Prefer', Prefer)
        }
        if !IsSet(Y) {
            flag_nomove := false
            Y := _Proc(subH, subT, subB, tarH, tarT, tarB, monH, monT, monB, Prefer = 'T' ? 1 : Prefer = 'B' ? -1 : 0)
            if flag_nomove {
                return 1
            }
        }
        Subject.X := tarL + tarW / 2 - subW / 2
        Subject.Y := Y
        Subject.R := X + subW
        Subject.B := Y + subH
    } else {
        throw _ValueError('Dimension', Dimension)
    }

    _Proc(SubLen, SubMainSide, SubAltSide, TarLen, TarMainSide, TarAltSide, MonLen, MonMainSide, MonAltSide, Prefer) {
        if Prefer == 1 && TarMainSide - SubLen - Padding > MonMainSide {
            return TarMainSide - SubLen - Padding
        } else if Prefer == -1 && TarAltSide + SubLen + Padding < MonAltSide {
            return TarAltSide + SubLen + Padding
        }
        if TarMainSide - MonMainSide > MonAltSide - TarAltSide {
            if TarMainSide - SubLen - Padding >= MonMainSide {
                return TarMainSide - SubLen - Padding
            } else if TarMainSide - SubLen >= MonMainSide {
                return MonMainSide + TarMainSide - SubLen
            } else {
                switch InsufficientSpaceAction, 0 {
                    case 0: flag_nomove := true
                    case 1: return TarMainSide - SubLen
                    case 2: return MonMainSide + SubLen
                    default: throw _ValueError('InsufficientSpaceAction', InsufficientSpaceAction)
                }
            }
        } else if TarAltSide + SubLen + Padding <= MonMainSide {
            return TarAltSide + SubLen + Padding
        } else if TarAltSide + SubLen >= MonMainSide {
            return TarAltSide + SubLen
        } else {
            switch InsufficientSpaceAction, 0 {
                case 0: flag_nomove := true
                case 1: return TarAltSide + SubLen
                case 2: return MonAltSide - SubLen
                default: throw _ValueError('InsufficientSpaceAction', InsufficientSpaceAction)
            }
        }
    }
    _ValueError(name, Value) {
        if IsObject(Value) {
            return TypeError('Invalid type passed to ``' name '``.', -2)
        } else {
            return ValueError('Unexpected value passed to ``' name '``.', -2, Value)
        }
    }
}
/**
 * @description - Reorders the objects in an array according to the input options.
 * @example
 *  List := [
 *      { L: 100, T: 100, Name: 1 }
 *    , { L: 100, T: 150, Name: 2 }
 *    , { L: 200, T: 100, Name: 3 }
 *    , { L: 200, T: 150, Name: 4 }
 *  ]
 *  Rect.Order(List, L2R := true, T2B := true, 'H')
 *  OutputDebug(_GetOrder()) ; 1 2 3 4
 *  Rect.Order(List, L2R := true, T2B := true, 'V')
 *  OutputDebug(_GetOrder()) ; 1 3 2 4
 *  Rect.Order(List, L2R := false, T2B := true, 'H')
 *  OutputDebug(_GetOrder()) ; 3 4 1 2
 *  Rect.Order(List, L2R := false, T2B := false, 'H')
 *  OutputDebug(_GetOrder()) ; 4 3 2 1
 *
 *  _GetOrder() {
 *      for item in List {
 *          Str .= item.Name ' '
 *      }
 *      return Trim(Str, ' ')
 *  }
 * @
 * @param {Array} List - The array containing the objects to be ordered.
 * @param {String} [Primary='X'] - Determines which axis is primarily considered when ordering
 * the objects. When comparing two objects, if their positions along the Primary axis are
 * equal, then the alternate axis is compared and used to break the tie. Otherwise, the alternate
 * axis is ignored for that pair.
 * - X: Check horizontal first.
 * - Y: Check vertical first.
 * @param {Boolean} [LeftToRight=true] - If true, the objects are ordered in ascending order
 * along the X axis when the X axis is compared.
 * @param {Boolean} [TopToBottom=true] - If true, the objects are ordered in ascending order
 * along the Y axis when the Y axis is compared.
 */
OrderRects(List, Primary := 'X', LeftToRight := true, TopToBottom := true) {
    ConditionH := LeftToRight ? (a, b) => a.L < b.L : (a, b) => a.L > b.L
    ConditionV := TopToBottom ? (a, b) => a.T < b.T : (a, b) => a.T > b.T
    if Primary = 'X' {
        _InsertionSort(List, _ConditionFnH)
    } else if Primary = 'Y' {
        _InsertionSort(List, _ConditionFnV)
    } else {
        throw ValueError('Unexpected ``Primary`` value.', -1, Primary)
    }

    return

    _InsertionSort(Arr, CompareFn) {
        i := 1
        loop Arr.Length - 1 {
            Current := Arr[++i]
            j := i - 1
            loop j {
                if CompareFn(Arr[j], Current) < 0
                    break
                Arr[j + 1] := Arr[j--]
            }
            Arr[j + 1] := Current
        }
    }
    _ConditionFnH(a, b) {
        if a.L == b.L {
            if ConditionV(a, b) {
                return -1
            }
        } else if ConditionH(a, b) {
            return -1
        }
        return 1
    }
    _ConditionFnV(a, b) {
        if a.T == b.T {
            if ConditionH(a, b) {
                return -1
            }
        } else if ConditionV(a, b) {
            return -1
        }
        return 1
    }
}
PtClone(pt) => Point(pt.X, pt.Y)
PtGetCursorPos(pt) => DllCall(RectBase.GetCursorPos, 'ptr', pt, 'int')
PtGetDpi(pt) {
    if DllCall(RectBase.Shcore_GetDpiForMonitor, 'ptr'
        , DllCall(RectBase.MonitorFromPoint, 'int', pt.Value, 'uint', 0, 'ptr')
    , 'uint', 0, 'uint*', &DpiX := 0, 'uint*', &DpiY := 0, 'int') {
        throw OSError('MonitorFomPoint received an invalid parameter.', -1)
    } else {
        return DpiX
    }
}
PtGetMonitor(pt) {
    return DllCall(RectBase.MonitorFromPoint, 'int', pt.Value, 'uint', 0, 'ptr')
}
PtGetValue(Pt) => (pt.X & 0xFFFFFFFF) | (pt.Y << 32)
PtLogicalToPhysical(pt, Hwnd) {
    DllCall(RectBase.LogicalToPhysical, 'ptr', Hwnd, 'ptr', pt)
}
PtLogicalToPhysicalForPerMonitorDPI(pt, Hwnd) {
    return DllCall(RectBase.LogicalToPhysicalPointForPerMonitorDPI, 'ptr', Hwnd, 'ptr', pt, 'int')
}
PtPhysicalToLogical(pt, Hwnd) {
    DllCall(RectBase.PhysicalToLogical, 'ptr', Hwnd, 'ptr', pt)
}
PtPhysicalToLogicalForPerMonitorDPI(pt, Hwnd) {
    return DllCall(RectBase.PhysicalToLogicalPointForPerMonitorDPI, 'ptr', Hwnd, 'ptr', pt, 'int')
}
PtSetCaretPos(pt) {
    return DllCall(RectBase.SetCaretPos, 'int', pt.X, 'int', pt.Y, 'int')
}
/**
 * @description - Use this to convert screen coordinates (which should already be contained by
 * this `Point` object), to client coordinates.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-screentoclient}
 * @param {Point} pt - The point.
 * @param {Integer} Hwnd - The handle to the window whose client area will be used for the conversion.
 * @param {Boolean} [InPlace = false] - If true, the function modifies the object's properties.
 * If false, the function creates a new object.
 * @returns {Point}
 */
PtToClient(Hwnd, InPlace := false) {
    if !InPlace {
        pt := Point(pt.X, pt.Y)
    }
    if !DllCall(RectBase.ScreenToClient, 'ptr', Hwnd, 'ptr', pt, 'int') {
        throw OSError()
    }
    return pt
}
/**
 * @description - Use this to convert client coordinates (which should already be contained by
 * this `Point` object), to screen coordinates.
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-clienttoscreen}
 * @param {Point} pt - The point.
 * @param {Integer} Hwnd - The handle to the window whose client area will be used for the conversion.
 * @param {Boolean} [InPlace = false] - If true, the function modifies the object's properties.
 * If false, the function creates a new object.
 * @returns {Point}
 */
PtToScreen(Pt, Hwnd, InPlace := false) {
    if !InPlace {
        pt := Point(pt.X, pt.Y)
    }
    if !DllCall(RectBase.ClientToScreen, 'ptr', Hwnd, 'ptr', pt, 'int') {
        throw OSError()
    }
    return pt
}
RectClone(rc) => Rect(rc.L, rc.T, rc.R, rc.B)
RectEqual(rc1, rc2) => DllCall(RectBase.EqualRect, 'ptr', rc1, 'ptr', rc2, 'int')
RectGetCoordinate(Offset, rc) => NumGet(rc, Offset, 'int')
RectGetDpi(rc) {
    if DllCall(RectBase.Shcore_GetDpiForMonitor, 'ptr'
        , DllCall(RectBase.Shcore_MonitorFromRect, 'ptr', rc, 'uint', 0, 'ptr')
    , 'uint', 0, 'uint*', &DpiX := 0, 'uint*', &DpiY := 0, 'int') {
        throw OSError('``MonitorFomPoint`` received an invalid parameter.', -1)
    } else {
        return DpiX
    }
}
RectGetHeightSegment(rc, Divisor, DecimalPlaces := 0) => Round(rc.H / Divisor, DecimalPlaces)
RectGetLength(Offset, rc) => NumGet(rc, 8 + Offset, 'int') - NumGet(rc, Offset, 'int')
RectGetMonitor(rc) => DllCall(RectBase.MonitorFromRect, 'ptr', rc, 'UInt', 0, 'Uptr')
RectGetPoint(Offset1, Offset2, rc) => Point(NumGet(rc, Offset1, 'int'), NumGet(rc, Offset2, 'int'))
RectGetWidthSegment(rc, Divisor, DecimalPlaces := 0) => Round(rc.W / Divisor, DecimalPlaces)
RectInflate(rc, dx, dy) => DllCall(RectBase.InflateRect, 'ptr', rc, 'int', dx, 'int', dy, 'int')
/**
 * @returns {Rect} - If the rectangles intersect, a new `Rect` object is returned. If the rectangles
 * do not intersect, returns an empty string.
 */
RectIntersect(rc1, rc2, Offset := 0) {
    rc := Rect()
    if DllCall(RectBase.IntersectRect, 'ptr', rc, 'ptr', rc1, 'ptr', rc2, 'int') {
        return rc
    }
}
RectIsEmpty(rc) => DllCall(RectBase.IsRectEmpty, 'ptr', rc, 'int')
RectDeletePtr(Obj) {
    if Obj.HasOwnProp('Ptr') {
        ObjRelease(Obj.Ptr)
        Obj.DeleteProp('Ptr')
    }
}
RectDispose(Obj) {
    if Obj.HasOwnProp('Ptr') {
        ObjRelease(Obj.Ptr)
        Obj.DeleteProp('Ptr')
    }
    if Obj.HasOwnProp('Buffer') {
        Obj.DeleteProp('Buffer')
    }
    Obj.DefineProp('Size', { Value: 0 })
    Obj.DefineProp('Ptr', { Value: 0 })
}
RectOffset(rc, dx, dy) => DllCall(RectBase.OffsetRect, 'ptr', rc, 'int', dx, 'int', dy, 'int')
RectPtIn(rc, pt) => DllCall(RectBase.PtInRect, 'ptr', rc, 'ptr', pt, 'int')
RectSet(rc, X?, Y?, W?, H?) {
    if IsSet(X) {
        rc.L := X
    }
    if IsSet(Y) {
        rc.T := Y
    }
    if IsSet(W) {
        rc.R := rc.L + W
    }
    if IsSet(H) {
        rc.B := rc.T + H
    }
}
RectSetCoordinate(Offset, rc, Value) => NumPut('int', Value, rc.Ptr, Offset)
RectSetLength(Offset, rc, Value) => NumPut('int', NumGet(rc, Offset, 'int') + Value, rc, 8 + Offset)
RectSetThreadDpiAwareness__Call(Obj, Name, Params) {
    Split := StrSplit(Name, '_')
    if Obj.HasMethod(Split[1]) && Split[2] = 'S' {
        DllCall(RectBase.SetThreadDpiAwarenessContext, 'ptr', HasProp(Obj, 'DpiAwarenessContext') ? Obj.DpiAwarenessContext : DPI_AWARENESS_CONTEXT_DEFAULT ?? -4, 'ptr')
        if Params.Length {
            return Obj.%Split[1]%(Params*)
        } else {
            return Obj.%Split[1]%()
        }
    } else {
        throw PropertyError('Property not found.', -1, Name)
    }
}
RectSubtract(rc1, rc2) {
    rc := Rect()
    DllCall(RectBase.SubtractRect, 'ptr', rc, 'ptr', rc1, 'ptr', rc2, 'int')
    return rc
}
/**
 * Calls `ClientToScreen` for the the rectangle.
 * @param {Integer} Hwnd - The handle to the window to which the rectangle's dimensions
 * are currently relative.
 * @param {Boolean} [InPlace = false] - If true, the function modifies the object's properties.
 * If false, the function creates a new object.
 * @returns {Rect}
 */
RectToClient(rc, Hwnd, InPlace := false) {
    if !InPlace {
        rc := rc.Clone()
    }
    if !DllCall(RectBase.ScreenToClient, 'ptr', Hwnd, 'ptr', rc, 'int') {
        throw OSError()
    }
    if !DllCall(RectBase.ScreenToClient, 'ptr', Hwnd, 'ptr', rc.Ptr + 8, 'int') {
        throw OSError()
    }
    return rc
}
/**
 * Calls `ClientToScreen` for the the rectangle.
 * @param {Integer} Hwnd - The handle to the window to which the rectangle's dimensions
 * are currently relative.
 * @param {Boolean} [InPlace = false] - If true, the function modifies the object's properties.
 * If false, the function creates a new object.
 * @returns {Rect}
 */
RectToScreen(rc, Hwnd, InPlace := false) {
    if !InPlace {
        rc := rc.Clone()
    }
    if !DllCall(RectBase.ClientToScreen, 'ptr', Hwnd, 'ptr', rc.ptr, 'int') {
        throw OSError()
    }
    if !DllCall(RectBase.ClientToScreen, 'ptr', Hwnd, 'ptr', rc.ptr + 8, 'int') {
        throw OSError()
    }
    return rc
}
/**
 * @returns {Rect} - If the specified structure contains a nonempty rectangle, a new `Rect` is created
 * and retured. If the specified structure does not contain a nonempty rectangle, returns an empty
 * string.
 */
RectUnion(rc1, rc2) {
    rc := Rect()
    if DllCall(RectBase.UnionRect, 'ptr', rc, 'ptr', rc1, 'ptr', rc2, 'int') {
        return rc
    }
}
SetCaretPos(X, Y) {
    return DllCall(RectBase.SetCaretPos, 'int', X, 'int', Y, 'int')
}
/**
 * @description - Input the desired client area and `AdjustWindowRectEx` will update the object
 * on the property `Rect` to the position and size that will accommodate the client area. This
 * does not update the window's display; call `WindowInfoObj.Rect.Apply()`
 */
WindowInfoAdjustRectEx(winfo, X?, Y?, W?, H?) {
    rc := winfo.Rect
    if IsSet(X) {
        rc.X := X
    }
    if IsSet(Y) {
        rc.Y := Y
    }
    if IsSet(W) {
        rc.R := rc.X + W
    }
    if IsSet(H) {
        rc.B := rc.T + H
    }
    if !DllCall(RectBase.AdjustWindowRectEx, 'ptr', rc, 'uint', winfo.Style, 'int', winfo.MenuBar ? 1 : 0, 'uint', winfo.ExStyle, 'int') {
        throw OSError()
    }
}
WindowInfoCallbackFromDesktop(*) {
    if hwnd := DllCall(RectBase.GetDesktopWindow, 'ptr') {
        return hwnd
    }
}
WindowInfoCallbackFromForeground(*) {
    if hwnd := DllCall(RectBase.GetForegroundWindow, 'ptr') {
        return hwnd
    }
}
/**
 * @description - To use this as a callback with `WindowInfo.Prototype.SetCallback`, you must
 * define it as a `BoundFunc` defining the "Cmd" value.
 * @example
 *  hwnd := DllCall(RectBase.GetDesktopWindow, 'ptr')
 *  winfo := WindowInfo(hwnd)
 *  winfo.SetCallback(WindowInfoCallbackFromNext.Bind(3))
 *  winfo()
 * @
 */
WindowInfoCallbackFromNext(Cmd, winfo) {
    if hwnd := DllCall(RectBase.GetNextWindow, 'ptr', winfo.Hwnd, 'uint', Cmd, 'ptr') {
        return hwnd
    }
}
WindowInfoCallbackFromParent(winfo) {
    if hwnd := DllCall(RectBase.GetParent, 'ptr', winfo.Hwnd, 'ptr') {
        return hwnd
    }
}
WindowInfoDispose(winfo) {
    for prop in ['Rect', 'ClientRect'] {
        if winfo.HasOwnProp(prop) {
            if winfo.%prop%.HasMethod('Dispose') {
                winfo.%prop%.Dispose()
            }
            winfo.DeleteProp(prop)
        }
    }
    RectDispose(winfo)
}
WindowInfoGetExStyles(winfo) {
    style := winfo.ExStyle
    result := []
    result.Capacity := winfo.WindowExStyles.Count
    for k, v in winfo.WindowExStyles {
        if style & v {
            result.Push(k)
        }
    }
    result.Capacity := result.Length
    return result
}
WindowInfoGetStyles(winfo) {
    style := winfo.Style
    result := []
    result.Capacity := winfo.WindowStyles.Count
    for k, v in winfo.WindowStyles {
        if style & v {
            result.Push(k)
        }
    }
    result.Capacity := result.Length
    return result
}
/**
 * @param {String|Integer} Id - Either the symbol as string (e.g. "WS_EX_WINDOWEDGE") or the integer
 * value (e.g. "0x00000100").
 */
WindowInfoHasExStyle(winfo, Id) {
    return winfo.ExStyle & (IsNumber(Id) ? Id : winfo.WindowStyles.Get(Id))
}
/**
 * @param {String|Integer} Id - Either the symbol as string (e.g. "WS_CAPTION") or the integer value
 * (e.g. "0x00C00000").
 */
WindowInfoHasStyle(winfo, Id) {
    return winfo.Style & (IsNumber(Id) ? Id : winfo.WindowStyles.Get(Id))
}
/**
 * Input the dimensions of the desired client area, and the window is moved to accommodate that
 * area.
 */
WindowInfoMoveClient(winfo, X := 0, Y := 0, W := 0, H := 0, InsertAfter := 0, Flags := 0) {
    wrc := winfo.Rect
    wrc.X := X
    wrc.Y := Y
    wrc.W := W
    wrc.H := H
    if !DllCall(RectBase.AdjustWindowRectEx, 'ptr', wrc, 'uint', winfo.Style, 'int', winfo.MenuBar ? 1 : 0, 'uint', winfo.ExStyle) {
        throw OSError()
    }
    if !DllCall(RectBase.SetWindowPos, 'ptr', winfo.Hwnd, 'ptr', InsertAfter, 'int', X, 'int', Y, 'int', W, 'int', H, 'uint', Flags, 'int') {
        throw OSError()
    }
    ; Update the AHK Rect object's property values.
    if !DllCall(RectBase.GetWindowRect, 'ptr', wrc.Hwnd, 'ptr', wrc, 'int') {
        throw OSError()
    }
}
WinRectApply(wrc, InsertAfter := 0, Flags := 0) {
    return DllCall(WinRect.SetWindowPos, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'ptr', InsertAfter, 'int', wrc.X, 'int', wrc.T, 'int', wrc.W, 'int', wrc.H, 'uint', Flags, 'int')
}
WinRectBringToTop(wrc) {
    return DllCall(RectBase.BringWindowToTop, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'int')
}
WinRectChildFromPoint(wrc, X, Y) => DllCall(RectBase.ChildWindowFromPoint, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
WinRectChildFromPointEx(wrc, X, Y, Flag := 0) => DllCall(RectBase.ChildWindowFromPoint, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'int', Flag, 'ptr')
/**
 * @param {Integer} [flag = 0] -
 * - CWP_ALL - 0x0000 : Does not skip any child windows
 * - CWP_SKIPDISABLED - 0x0002 : Skips disabled child windows
 * - CWP_SKIPINVISIBLE - 0x0001 : Skips invisible child windows
 * - CWP_SKIPTRANSPARENT - 0x0004 : Skips transparent child windows
 */
WinRectChildWindowFromPointEx(wrc, X, Y, flag := 0) {
    return DllCall(RectBase.ChildWindowFromPointEx, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'int', flag, 'ptr')
}
WinRectEnumChildWindows(wrc, Callback, lParam := 0) {
    cb := CallbackCreate(Callback)
    result := DllCall(RectBase.EnumChildWindows, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'ptr', cb, 'uint', lParam, 'int')
    CallbackFree(cb)
    return result
}
/**
 * @description - Gets the bounding rectangle of all child windows of a given window.
 * @param {Integer} Hwnd - The handle to the parent window.
 * @returns {Rect} - The bounding rectangle of all child windows, specifically the smallest
 * rectangle that contains all child windows.
 */
WinRectGetChildBoundingRect(wrc) {
    DllCall(RectBase.SetThreadDpiAwarenessContext, 'ptr', -4, 'ptr')
    rects := [Rect(), Rect(), Rect()]
    DllCall(RectBase.EnumChildWindows, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'ptr', cb := CallbackCreate(_EnumChildWindowsProc, 'fast',  1), 'int', 0, 'int')
    CallbackFree(cb)
    return rects[1]

    _EnumChildWindowsProc(hwnd) {
        DllCall(RectBase.GetWindowRect, 'ptr', Hwnd, 'ptr', rects[3], 'int')
        DllCall(RectBase.UnionRect, 'ptr', rects[2], 'ptr', rects[3], 'ptr', rects[1], 'int')
        rects.Push(rects.RemoveAt(1))
        return 1
    }
}
WinRectGetClientRect(wrc) {
    return WinRect(IsObject(wrc) ? wrc.Hwnd : wrc, true)
}
WinRectGetDpi(wrc) => DllCall(RectBase.GetDpiForWindow, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'int')
WinRectGetMonitor(wrc) => DllCall(RectBase.MonitorFromWindow, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'int', 0, 'ptr')
WinRectGetPos(wrc, &X?, &Y?, &W?, &H?) {
    X := wrc.L
    Y := wrc.T
    W := wrc.R - wrc.L
    H := wrc.B - wrc.T
}
WinRectIsChild(wrc, HwndChild) {
    return DllCall(RectBase.IsChild, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'ptr', IsObject(HwndChild) ? HwndChild.Hwnd : HwndChild, 'int')
}
WinRectIsParent(wrc, HwndParent) {
    return DllCall(RectBase.IsChild, 'ptr', HwndParent, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'int')
}
WinRectIsVisible(wrc) {
    return DllCall(RectBase.IsWindowVisible, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'int')
}
WinRectMapPoints(wrc1, wrc2, points) {
    buf := Buffer(points.Length * 4)
    for coord in points {
        NumPut('int', coord, buf, A_Index * 4 - 4)
    }
    result := DllCall(RectBase.MapWindowPoints, 'ptr', IsObject(wrc1) ? wrc1.Hwnd : wrc1, 'ptr', IsObject(wrc2) ? wrc2.Hwnd : wrc2, 'ptr', buf, 'uint', points.Length / 2)
    loop points.Length {
        points[A_Index] := NumGet(buf, A_Index * 4 - 4, 'int')
    }
    return result
}
/**
 * @param {Integer} [X] - The new x-coordinate of the window.
 * @param {Integer} [Y] - The new y-coordinate of the window.
 * @param {Integer} [W] - The new Width of the window.
 * @param {Integer} [H] - The new Height of the window.
 * @param {Integer} [InsertAfter = 0] - Either the handle of another window to insert this
 * window after, or one of the following:
 * - HWND_BOTTOM - (HWND)1 : Places the window at the bottom of the Z order. If the <i>hWnd</i>
 *   parameter identifies a topmost window, the window loses its topmost status and is placed at
 *   the bottom of all other windows.
 * - HWND_NOTOPMOST - (HWND)-2 : Places the window above all non-topmost windows (that is, behind
 *   all topmost windows). This flag has no effect if the window is already a non-topmost window.
 * - HWND_TOP - (HWND)0 : Places the window at the top of the Z order.
 * - HWND_TOPMOST - (HWND)-1 : Places the window above all non-topmost windows. The window
 *   maintains its topmost position even when it is deactivated.
 * @param {Integer} [Flags = 0] - A combination of the following. Use "|" to combine, e.g.
 * `Flags := 0x4000 | 0x0020 | 0x0010`.
 * - SWP_ASYNCWINDOWPOS - 0x4000 : If the calling thread and the thread that owns the window are
 *   attached to different input queues, the system posts the request to the thread that owns the
 *   window. This prevents the calling thread from blocking its execution while other threads
 *   process the request.
 * - SWP_DEFERERASE - 0x2000 : Prevents generation of the WM_SYNCPAINT message.
 * - SWP_DRAWFRAME - 0x0020 : Draws a frame (defined in the window's class description) around the
 *   window.
 * - SWP_FRAMECHANGED - 0x0020 : Applies new frame styles set using the SetWindowLong
 *   function. Sends a WM_NCCALCSIZE message to the window, even if the window's size is not being
 *   changed. If this flag is not specified, <b>WM_NCCALCSIZE</b> is sent only when the window's
 *   size is being changed.
 * - SWP_HIDEWINDOW - 0x0080 : Hides the window.
 * - SWP_NOACTIVATE - 0x0010 : Does not activate the window. If this flag is not set, the window
 *   is activated and moved to the top of either the topmost or non-topmost group (depending on the
 *   setting of the <i>hWndInsertAfter</i> parameter).
 * - SWP_NOCOPYBITS - 0x0100 : Discards the entire contents of the client area. If this flag is
 *   not specified, the valid contents of the client area are saved and copied back into the client
 *   area after the window is sized or repositioned.
 * - SWP_NOMOVE - 0x0002 : Retains the current position (ignores <i>X</i> and <i>Y</i>
 *   parameters).
 * - SWP_NOOWNERZORDER - 0x0200 : Does not change the owner window's position in the Z order.
 * - SWP_NOREDRAW - 0x0008 : Does not redraw changes. If this flag is set, no repainting of any
 *   kind occurs. This applies to the client area, the nonclient area (including the title bar and
 *   scroll bars), and any part of the parent window uncovered as a result of the window being
 *   moved. When this flag is set, the application must explicitly invalidate or redraw any parts
 *   of the window and parent window that need redrawing.
 * - SWP_NOREPOSITION - 0x0200 : Same as the <b>SWP_NOOWNERZORDER</b> flag.
 * - SWP_NOSENDCHANGING - 0x0400 : Prevents the window from receiving the WM_WINDOWPOSCHANGING
 *   message.
 * - SWP_NOSIZE - 0x0001 : Retains the current size (ignores the <i>cx</i> and <i>cy</i>
 *   parameters).
 * - SWP_NOZORDER - 0x0004 : Retains the current Z order (ignores the <i>hWndInsertAfter</i>
 *   parameter).
 * - SWP_SHOWWINDOW - 0x0040 : Displays the window.
 */
WinRectMove(wrc, X := 0, Y := 0, W := 0, H := 0, InsertAfter := 0, Flags := 0) {
    if !DllCall(WinRect.SetWindowPos, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'ptr', InsertAfter, 'int', X, 'int', Y, 'int', W, 'int', H, 'uint', Flags, 'int') {
        throw OSError()
    }
    ; Update the AHK Rect object's property values.
    if !DllCall(WinRect.GetWindowRect, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'ptr', wrc, 'int') {
        throw OSError()
    }
}
WinRectRealChildFromPoint(wrc, X, Y) {
    return DllCall(RectBase.RealChildWindowFromPoint, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'int', (X & 0xFFFFFFFF) | (Y << 32), 'ptr')
}
WinRectSetActive(wrc) {
    return DllCall(RectBase.SetActiveWindow, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'int')
}
WinRectSetForeground(wrc) {
    return DllCall(RectBase.SetForegroundWindow, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'int')
}
WinRectSetParent(wrc, HwndNewParent := 0) {
    return DllCall(RectBase.SetParent, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'ptr', IsObject(HwndNewParent) ? HwndNewParent.Hwnd : HwndNewParent, 'ptr')
}
WinRectSetPosKeepAspectRatio(wrc, Width, Height, AspectRatio?) {
    if !IsSet(AspectRatio) {
        AspectRatio := wrc.W / wrc.H
    }
    WidthFromHeight := Height / AspectRatio
    HeightFromWidth := Width * AspectRatio
    if WidthFromHeight > Width {
        wrc.H := HeightFromWidth
        wrc.W := Width
    } else {
        wrc.W := WidthFromHeight
        wrc.H := Height
    }
}
/**
 * @description - Shows the window.
 * @param {Integer} [Flag = 0] - One of the following.
 * - SW_HIDE - 0 - Hides the window and activates another window.
 * - SW_SHOWNORMAL / SW_NORMAL - 1 - Activates and displays a window. If the window is
 *   minimized, maximized, or arranged, the system restores it to its original size and position.
 *   An application should specify this flag when displaying the window for the first time.
 * - SW_SHOWMINIMIZED - 2 - Activates the window and displays it as a minimized window.
 * - SW_SHOWMAXIMIZED / SW_MAXIMIZE - 3 - Activates the window and displays it as a maximized
 *   window.
 * - SW_SHOWNOACTIVATE - 4 - Displays a window in its most recent size and position. This value
 *   is similar to <strong>SW_SHOWNORMAL</strong>, except that the window is not activated.
 * - SW_SHOW - 5 - Activates the window and displays it in its current size and position.
 * - SW_MINIMIZE - 6 - Minimizes the specified window and activates the next top-level window in
 *   the Z order.
 * - SW_SHOWMINNOACTIVE - 7 - Displays the window as a minimized window. This value is similar
 *   to <strong>SW_SHOWMINIMIZED</strong>, except the window is not activated.
 * - SW_SHOWNA - 8 - Displays the window in its current size and position. This value is similar
 *   to <strong>SW_SHOW</strong>, except that the window is not activated.
 * - SW_RESTORE - 9 - Activates and displays the window. If the window is minimized, maximized,
 *   or arranged, the system restores it to its original size and position. An application should
 *   specify this flag when restoring a minimized window.
 * - SW_SHOWDEFAULT - 10 - Sets the show state based on the <strong>SW_</strong> value specified
 *   in the structure passed to the function by the program that started the application.
 * - SW_FORCEMINIMIZE - 11 - Minimizes a window, even if the thread that owns the window is not
 *   responding. This flag should only be used when minimizing windows from a different thread.
 * @returns {Boolean} - If the window was previously visible, the return value is nonzero. If
 * the window was previously hidden, the return value is zero.
 */
WinRectShow(wrc, Flag := 0) {
    return DllCall(RectBase.ShowWindow, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'uint', Flag, 'int')
}
WinRectUpdate(wrc) {
    return DllCall(RectBase.GetWindowRect, 'ptr', IsObject(wrc) ? wrc.Hwnd : wrc, 'ptr', wrc, 'int')
}
