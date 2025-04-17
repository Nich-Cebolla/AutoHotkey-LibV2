#Include RECT.ahk

/**
 * @class
 * @description - Creates a reusable buffer object that, when called, retrieves the window information.
 */
class WINDOWINFO extends Buffer {
    /**
     * @description - The class constructor.
     * @param {Integer} hWnd - The handle to the window whose information will be retrieved.
     * @returns {WINDOWINFO} - The instance of the `WINDOWINFO` class.
     */
    __New(hWnd) {a
        this.hWnd := hWnd
        ; DWORD - 4 bytes x 4, RECT - 16 bytes x 2, UINT - 4 bytes x 2, ATOM - 2 bytes, WORD - 2 bytes
        this.Size := 60
    }

    /**
     * @description - Calls the `GetWindowInfo` function to retrieve the window information.
     * @throws {OSError} - If the `GetWindowInfo` function fails.
     */
    Call() {
        if !DllCall('GetWindowInfo', 'ptr', this.hWnd, 'ptr', this, 'int') {
            throw OSError('GetWindowInfo failed.', -1, A_LastError)
        }
    }

    Size => NumGet(this, 0, 'uint')
    Window => Rect.FromBuffer(this, 4)
    Client => Rect.FromBuffer(this, 20)
    WindowStyle => NumGet(this, 36, 'uint')
    WindowStyleEx => NumGet(this, 40, 'uint')
    WindowStatus => NumGet(this, 44, 'uint')
    WindowBordersX => NumGet(this, 48, 'uint')
    WindowBordersY => NumGet(this, 52, 'uint')
    Type => NumGet(this, 56, 'uint')
    CreatorVersion => NumGet(this, 58, 'ushort')
}
