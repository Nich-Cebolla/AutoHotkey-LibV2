
class rcTab extends Buffer {
    /**
     * @class
     * @description - A reusable buffer object that can be used to work with a tab's rectangle.
     */
    __New() {
        this.Size := 16
    }
    /**
     * @description - Sets the rect coordinates to the client rect of a tab control relative to the
     * client rect of the parent gui window. You can use these coordinates to place controls that
     * using positions that are relative to the interior of the tab control. For example, if you
     * placed a control at X = {@link rcTab#X}, Y = {@link rcTab#Y}, the top-left corner of the
     * control would be adjacent to the top-left corner of the tab's client area.
     *
     * @param {Gui.Tab} tab - The tab control.
     */
    GetClientDisplay(tab) {
        if !DllCall('GetWindowRect', 'ptr', tab.Hwnd, 'ptr', this, 'int') {
            throw OSError()
        }
        if !DllCall('ScreenToClient', 'ptr', tab.Gui.Hwnd, 'ptr', this, 'int') {
            throw OSError()
        }
        if !DllCall('ScreenToClient', 'ptr', tab.Gui.Hwnd, 'ptr', this.Ptr + 8, 'int') {
            throw OSError()
        }
        SendMessage(4904, false, this.Ptr, tab.Hwnd, tab.Gui.Hwnd) ; TCM_ADJUSTRECT
        return this
    }
    /**
     * @description - Sets the rect coordinates to the window rect of a tab control relative to the
     * client rect of the parent gui window. For example, if you placed a control at
     * X = {@link rcTab#X}, Y = {@link rcTab#Y}, the control would be overlapping the label for the
     * first tab.
     *
     * @param {Gui.Tab} tab - The tab control.
     */
    GetClientWindow(tab) {
        if !DllCall('GetWindowRect', 'ptr', tab.Hwnd, 'ptr', this, 'int') {
            throw OSError()
        }
        if !DllCall('ScreenToClient', 'ptr', tab.Gui.Hwnd, 'ptr', this, 'int') {
            throw OSError()
        }
        if !DllCall('ScreenToClient', 'ptr', tab.Gui.Hwnd, 'ptr', this.Ptr + 8, 'int') {
            throw OSError()
        }
        return this
    }
    /**
     * @description - Sets the coordinates to the control's display rectangle relative to the screen.
     *
     * @param {Gui.Tab} tab - The tab control.
     */
    GetScreenDisplay(tab) {
        if !DllCall('GetWindowRect', 'ptr', tab.Hwnd, 'ptr', this, 'int') {
            throw OSError()
        }
        SendMessage(4904, false, this.Ptr, tab.Hwnd, tab.Gui.Hwnd) ; TCM_ADJUSTRECT
        return this
    }

    /**
     * @description - Sets the coordinates to the control's window rectangle relative to the screen.
     *
     * @param {Gui.Tab} tab - The tab control.
     */
    GetScreenWindow(tab) {
        if !DllCall('GetWindowRect', 'ptr', tab.Hwnd, 'ptr', this, 'int') {
            throw OSError()
        }
        return this
    }
    /**
     * @description - Adjusts the current coordinates to specify the display rectangle that would
     * result from a window area that is the same size as the current coordinates. If you adjust a
     * tab control's dimensions, set this object with those dimensions, then call this method, the
     * result would be the tab control's display coordinates.
     *
     * @param {Gui.Tab} tab - The tab control.
     */
    ToDisplay(tab) {
        SendMessage(4904, false, this, tab.Hwnd, tab.Gui.Hwnd)  ; TCM_ADJUSTRECT
        return this
    }
    /**
     * @description - Adjusts the current coordinates to specify the window rectangle that is necessary
     * to achieve a display area that is the same size as the current coordinates. If you set the
     * coordinates to the desired display area, then call this method, you can use the new
     * coordinates to adjust the tab control's dimensions.
     *
     * @param {Gui.Tab} tab - The tab control.
     */
    ToWindow(tab) {
        SendMessage(4904, true, this, tab.Hwnd, tab.Gui.Hwnd)  ; TCM_ADJUSTRECT
        return this
    }
    X {
        Get => NumGet(this, 0, 'int')
        Set => NumPut('int', Value, this, 0)
    }
    Y {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
    }
    W {
        Get => NumGet(this, 8, 'int') - NumGet(this, 0, 'int')
        Set => NumPut('int', NumGet(this, 0, 'int') + Value, this, 8)
    }
    H {
        Get => NumGet(this, 12, 'int') - NumGet(this, 4, 'int')
        Set => NumPut('int', NumGet(this, 4, 'int') + Value, this, 12)
    }
    L {
        Get => NumGet(this, 0, 'int')
        Set => NumPut('int', Value, this, 0)
    }
    T {
        Get => NumGet(this, 4, 'int')
        Set => NumPut('int', Value, this, 4)
    }
    R {
        Get => NumGet(this, 8, 'int')
        Set => NumPut('int', Value, this, 8)
    }
    B {
        Get => NumGet(this, 12, 'int')
        Set => NumPut('int', Value, this, 12)
    }
}
