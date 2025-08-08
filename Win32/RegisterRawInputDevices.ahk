

/**
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-registerrawinputdevices}.
 * To receive WM_INPUT messages, an application must first register the raw input devices using
 * RegisterRawInputDevices. By default, an application does not receive raw input.
 *
 * To receive WM_INPUT_DEVICE_CHANGE messages, an application must specify the RIDEV_DEVNOTIFY flag
 * for each device class that is specified by the usUsagePage and usUsage fields of the RAWINPUTDEVICE
 * structure . By default, an application does not receive WM_INPUT_DEVICE_CHANGE notifications for
 * raw input device arrival and removal.
 *
 * If a RAWINPUTDEVICE structure has the RIDEV_REMOVE flag set and the hwndTarget parameter is not set
 * to NULL, then parameter validation will fail.
 *
 * Only one window per raw input device class may be registered to receive raw input within a process
 * (the window passed in the last call to RegisterRawInputDevices). Because of this, RegisterRawInputDevices
 * should not be used from a library, as it may interfere with any raw input processing logic already
 * present in applications that load it.
 *
 * @param {Buffer|RawInputDevice} pRawInputDevices - An array of RAWINPUTDEVICE structures that
 * represent the devices that supply the raw input. Pointer should be aligned on a DWORD (32-bit)
 * boundary.
 * @param {Integer} uiNumDevices - The number of RAWINPUTDEVICE structures pointed to by pRawInputDevices.
 * @param {Integer} cbSize - The size, in bytes, of a RAWINPUTDEVICE structure.
 * @returns {Boolean} - TRUE if the function succeeds; otherwise, FALSE. If the function fails,
 * call GetLastError for more information.
 * @throws {OSError}
 */
RegisterRawInputDevices(pRawInputDevices, uiNumDevices, cbSize) {
    if DllCall(
        'RegisterRawInputDevices'
      , 'ptr', pRawInputDevices
      , 'uint', uiNumDevices
      , 'uint', cbSize
      , 'int'
    ) {
        return 1
    } else {
        throw OSError()
    }
}
