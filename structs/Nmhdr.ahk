
class Nmhdr {
    static __New() {
        this.DeleteProp('__New')
        this.Prototype.Size := A_PtrSize * 3 ; +4 padding on x64
    }
    /**
     * @desc - A wrapper around the
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-nmhdr NMHDR}
     * structure.
     *
     * @param {Integer} ptr - The value passed to the "lParam" parameter of
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nc-commctrl-subclassproc SUBCLASSPROC}
     * when the message is
     * {@link https://learn.microsoft.com/en-us/windows/win32/controls/wm-notify WM_NOTIFY}.
     */
    __New(ptr) {
        this.ptr := ptr
    }
    code => NumGet(this.ptr, A_PtrSize * 2, 'uint')
    code_int => NumGet(this.ptr, A_PtrSize * 2, 'int')
    hwndFrom => NumGet(this.ptr, 'ptr')
    idFrom => NumGet(this.ptr, A_PtrSize, 'ptr')
}
