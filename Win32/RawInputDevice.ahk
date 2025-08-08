
class RawInputDevice {
    static __New() {
        this.DeleteProp('__New')
        this.Size :=
        2 +         ; USHORT     usUsagePage
        2 +         ; USHORT     usUsage
        4 +         ; DWORD      dwFlags
        A_PtrSize   ; HWND       hwndTarget
    }
    /**
     * @todo - convert this into its own class.
     * The function `RegisterRawInputDevices` inherently accepts an array of RAWINPUTDEVICE structures,
     * but I designed this class to, by default, support only one RAWINPUTDEVICE structure. If your
     * code needs to register multiple raw input devices, call this static method
     * `RawInputDevice.RegisterMultipleDevices` instead of calling `RawInputDevice.Prototype.__New`
     * multiple times, and you will receive one object that contains the data for all of the
     * devices.
     * @param {Object[]} Params - An array of objects with required properties { UsagePage, UsageId, Hwnd }
     * and optional property { Flags }. See {@link RawInputDevice#__New} for descriptions of the
     * parameters.
     * @returns {Object} - An object that supports an array of RAWINPUTDEVICE structures. The object
     * itself is one buffer object of size `RawInputDevice.Size * Params.Length`, but there's an
     * additional property `__Item` which is a `Map` object containing one item for each RAWINPUTDEVICE
     * structure. The key to the objects are the values on property "UsageId" from the objects in
     * `Params`. The values in the map are `RawInputDevice` objects, each associated with specific byte
     * offsets in the parent object's buffer. You can use them like you would an individual
     * `RawInputDevice` object.
     */
    static RegisterMultipleDevices(Params) {
        buf := Buffer(this.Size * Params.Length, 0)
        _rawInputDevices := { Buffer: buf, Ptr: buf.Ptr, Size: buf.Size, __Item: items := Map() }
        i := -1
        for obj in Params {
            ++i
            item := { Ptr: buf.Ptr + i * this.Size, Size: this.Size }
            ObjSetBase(item, this.Prototype)
            item.UsagePage := obj.UsagePage
            item.UsageId := obj.UsageId
            if HasProp(obj, 'Flags') {
                item.Flags := obj.Flags
            }
            item.Hwnd := obj.Hwnd
            items.Set(obj.UsageId, item)
        }
        if !DllCall(
            'RegisterRawInputDevices'
          , 'ptr', _rawInputDevices
          , 'uint', items.Count
          , 'uint', this.Size
          , 'int'
        ) {
            throw OSError()
        }
        return _rawInputDevices
    }
    /**
     * `RawInputDevice` is a wrapper around `RegisterRawInputDevices`. There are many more ways
     * it can be used besides tracking the mouse. To explore this further, see
     *
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-registerrawinputdevices}
     *
     * {@link https://learn.microsoft.com/en-us/windows/desktop/api/winuser/ns-winuser-rawinputdevice}
     *
     * {@link https://learn.microsoft.com/en-us/windows/desktop/inputdev/raw-input}.
     *
     * @param {Integer} UsagePage - A value from the below table:
     * @param {Integer} UsageId - A value from the below table:
     * <pre>
     * Usage page    Usage Id           Notes                                               Access mode
     * ------------------------------------------------------------------------------------------------
     * 0x0001        0x0001 - 0x0002    Mouse class driver and mapper driver                Exclusive
     * 0x0001        0x0004 - 0x0005    Game controllers                                    Shared
     * 0x0001        0x0006 - 0x0007    Keyboard / Keypad class driver and mapper driver    Exclusive
     * 0x0001        0x000C             Flight mode switch                                  Shared
     * 0x0001        0x0080             System controls (Power)                             Shared
     * 0x000C        0x0001             Consumer controls                                   Shared
     * 0x000D        0x0001             External pen device                                 Exclusive
     * 0x000D        0x0002             Integrated pen device                               Exclusive
     * 0x000D        0x0004             Touchscreen                                         Exclusive
     * 0x000D        0x0005             Precision touchpad (PTP)                            Exclusive
     * 0x0020        Multiple           Sensors                                             Shared
     * 0x0084        0x0004             HID UPS battery                                     Shared
     * 0x008C        0x0002             Barcode scanner (hidscanner.dll)                    Shared
     * </pre>
     *
     * @param {Integer} [Flags = 0] - A value from the below list:
     * <pre>
     * |  Value               |  Hex code    |  Meaning                                                   |
     * |  --------------------|--------------|----------------------------------------------------------  |
     * |  RIDEV_REMOVE        |  0x00000001  |  If set, this removes the top level collection from the    |
     * |                      |              |  inclusion list. This tells the operating system to stop   |
     * |                      |              |  reading from a device which matches the top level         |
     * |                      |              |  collection.                                               |
     * |  --------------------|--------------|----------------------------------------------------------  |
     * |  RIDEV_EXCLUDE       |  0x00000010  |  If set, this specifies the top level collections to       |
     * |                      |              |  exclude when reading a complete usage page. This flag     |
     * |                      |              |  only affects a TLC whose usage page is already            |
     * |                      |              |  specified with RIDEV_PAGEONLY.                            |
     * |  --------------------|--------------|----------------------------------------------------------  |
     * |  RIDEV_PAGEONLY      |  0x00000020  |  If set, this specifies all devices whose top level        |
     * |                      |              |  collection is from the specified usUsagePage. Note that   |
     * |                      |              |  usUsage must be zero. To exclude a particular top level   |
     * |                      |              |  collection, use RIDEV_EXCLUDE.                            |
     * |  --------------------|--------------|----------------------------------------------------------  |
     * |  RIDEV_NOLEGACY      |  0x00000030  |  If set, this prevents any devices specified by            |
     * |                      |              |  usUsagePage or usUsage from generating legacy messages.   |
     * |                      |              |  This is only for the mouse and keyboard. See Remarks.     |
     * |  --------------------|--------------|----------------------------------------------------------  |
     * |  RIDEV_INPUTSINK     |  0x00000100  |  If set, this enables the caller to receive the input      |
     * |                      |              |  even when the caller is not in the foreground. Note       |
     * |                      |              |  that hwndTarget must be specified.                        |
     * |  --------------------|--------------|----------------------------------------------------------  |
     * |  RIDEV_CAPTUREMOUSE  |  0x00000200  |  If set, the mouse button click does not activate the      |
     * |                      |              |  other window. RIDEV_CAPTUREMOUSE can be specified only    |
     * |                      |              |  if RIDEV_NOLEGACY is specified for a mouse device.        |
     * |  --------------------|--------------|----------------------------------------------------------  |
     * |  RIDEV_NOHOTKEYS     |  0x00000200  |  If set, the application-defined keyboard device hotkeys   |
     * |                      |              |  are not handled. However, the system hotkeys; for         |
     * |                      |              |  example, ALT+TAB and CTRL+ALT+DEL, are still handled.     |
     * |                      |              |  By default, all keyboard hotkeys are handled.             |
     * |                      |              |  RIDEV_NOHOTKEYS can be specified even if RIDEV_NOLEGACY   |
     * |                      |              |  is not specified and hwndTarget is NULL.                  |
     * |  --------------------|--------------|----------------------------------------------------------  |
     * |  RIDEV_APPKEYS       |  0x00000400  |  If set, the application command keys are handled.         |
     * |                      |              |  RIDEV_APPKEYS can be specified only if RIDEV_NOLEGACY     |
     * |                      |              |  is specified for a keyboard device.                       |
     * |  --------------------|--------------|----------------------------------------------------------  |
     * |  RIDEV_EXINPUTSINK   |  0x00001000  |  If set, this enables the caller to receive input in the   |
     * |                      |              |  background only if the foreground application does not    |
     * |                      |              |  process it. In other words, if the foreground             |
     * |                      |              |  application is not registered for raw input, then the     |
     * |                      |              |  background application that is registered will receive    |
     * |                      |              |  the input.                                                |
     * |  --------------------|--------------|----------------------------------------------------------  |
     * |  RIDEV_DEVNOTIFY     |  0x00002000  |  If set, this enables the caller to receive                |
     * |                      |              |  WM_INPUT_DEVICE_CHANGE notifications for device arrival   |
     * |                      |              |  and device removal.                                       |
     * </pre>
     *
     * @param {Integer} [Hwnd = 0] - The handle to the target window. If 0, raw input events follow the
     * keyboard focus to ensure only the focused application window receives the events.
     */
    __New(UsagePage, UsageId, Flags := 0, Hwnd := 0) {
        this.Buffer := Buffer(8 + A_PtrSize)
        this.Hwnd := Hwnd
        this.UsagePage := UsagePage
        this.UsageId := UsageId
        this.Flags := Flags
        if !DllCall(
            'RegisterRawInputDevices'
          , 'ptr', this
          , 'uint', 1
          , 'uint', this.Size
          , 'int'
        ) {
            throw OSError()
        }
    }
    UsagePage {
        Get => NumGet(this, 0, 'ushort')
        Set {
            NumPut('ushort', Value, this, 0)
        }
    }
    UsageId {
        Get => NumGet(this, 2, 'ushort')
        Set {
            NumPut('ushort', Value, this, 2)
        }
    }
    Flags {
        Get => NumGet(this, 4, 'uint')
        Set {
            NumPut('uint', Value, this, 4)
        }
    }
    Hwnd {
        Get => NumGet(this, 8, 'ptr')
        Set {
            NumPut('ptr', Value, this, 8)
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}
