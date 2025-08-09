/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/RawInputDevice.ahk
    Author: Nich-Cebolla
    License: MIT
*/

class RawInputDevice {
    static __New() {
        this.DeleteProp('__New')
        this.Prototype.cbSize :=
        2 +         ; USHORT     usUsagePage
        2 +         ; USHORT     usUsage
        4 +         ; DWORD      dwFlags
        A_PtrSize   ; HWND       hwndTarget
    }
    static FromPtr(Ptr) {
        _rawInputDevice := { Ptr: Ptr, Size: this.Size }
        ObjSetBase(_rawInputDevice, this.Prototype)
        return _rawInputDevice
    }
    static cbSize => this.Prototype.cbSize
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
     * @param {Integer} [Flags = 0] - A value from the below table. To register a raw input device so
     * an application can receive WM_INPUT for that device whether or not one of the application's
     * windows is in the foreground, use RIDEV_INPUTSINK (0x00000100).
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
     *
     * @param {Boolean} [DeferRegistration = false] - If true, `RegisterRawInputDevices` is not
     * called; your code will need to call `ArrayRawInputDevices.Prototype.Register`.
     */
    __New(UsagePage, UsageId, Flags := 0, Hwnd := 0, DeferRegistration := false) {
        this.Buffer := Buffer(this.cbSize)
        this.Hwnd := Hwnd
        this.UsagePage := UsagePage
        this.UsageId := UsageId
        this.Flags := Flags
        if !DeferRegistration {
            this.Register()
        }
    }
    Register() {
        if !DllCall(
            'RegisterRawInputDevices'
          , 'ptr', this
          , 'uint', 1
          , 'uint', this.cbSize
          , 'int'
        ) {
            throw OSError()
        }
    }
    Unregister() {
        this.Hwnd := 0
        this.Flags := 0x00000001 ; RIDEV_REMOVE
        if !DllCall(
            'RegisterRawInputDevices'
          , 'ptr', this
          , 'uint', 1
          , 'uint', this.cbSize
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

class ArrayRawInputDevices {
    /**
     * Retrieves the registered raw input devices for the current application.
     * @returns {ArrayRawInputDevices}
     * @throws {OSError}
     */
    static Retrieve() {
        cbSize := RawInputDevice.cbSize
        puiNumDevices := 0
        DllCall(
            'GetRegisteredRawInputDevices'
          , 'ptr', 0
          , 'uint*', &puiNumDevices
          , 'uint', cbSize
          , 'uint'
        )
        if !puiNumDevices {
            throw OSError()
        }
        _arrayRawInputDevices := { Buffer: Buffer(cbSize * puiNumDevices), Map: Map(), List: [] }
        ObjSetBase(_arrayRawInputDevices, this.Prototype)
        if DllCall(
            'GetRegisteredRawInputDevices'
          , 'ptr', _arrayRawInputDevices
          , 'uint*', &puiNumDevices
          , 'uint', cbSize
          , 'uint'
        ) == 4294967295 {
            throw OSError()
        }
        m := _arrayRawInputDevices.Map
        list := _arrayRawInputDevices.List
        ptr := _arrayRawInputDevices.Ptr
        loop puiNumDevices {
            list.Push(RawInputDevice.FromPtr(ptr + (A_Index - 1) * cbSize))
            m.Set(list[-1].UsageId, list.Length)
        }
        return _arrayRawInputDevices
    }
    /**
     * Constructs an array of RAWINPUTDEVICE structures.
     * @param {Object[]} Params - An array of objects with required properties { UsagePage, UsageId }
     * and optional properties { Flags, Hwnd }. See {@link RawInputDevice#__New} for descriptions of the
     * parameters.
     * @param {Boolean} [DeferRegistration = false] - If true, `RegisterRawInputDevices` is not
     * called; your code will need to call `ArrayRawInputDevices.Prototype.Register`.
     * @returns {ArrayRawInputDevices} - An object that supports an array of RAWINPUTDEVICE structures.
     * The buffer object is set to property "Buffer" and has a size of `RawInputDevice.cbSize * Params.Length`.
     * Though all of the data is contained in one Buffer, you can access the individual `RawInputDevice`
     * using various methods. References to the `RawInputDevice` objects are held by the array
     * on property "List". The map on property "Map" associates the UsageId with the index in the
     * array.
     * @example
     *  _rawInputDevice := _arrayRawInputDevices.List[_arrayRawInputDevices.Map.Get(usageId)]
     * @
     */
    __New(Params, DeferRegistration := false) {
        this.Buffer := Buffer(RawInputDevice.cbSize * Params.Length, 0)
        this.Map := Map()
        this.List := []
        if IsSet(Params) {
            for obj in Params {
                this.__Make(obj, A_Index)
            }
        }
        if !DeferRegistration {
            this.Register()
        }
    }
    Add(Params, DeferRegistration := false) {
        cbSize := RawInputDevice.cbSize
        if not Params is Array {
            Params := [ Params ]
        }
        if this.Size + cbSize * Params.Length > this.MaxSize {
            buf := Buffer(this.Size + cbSize * Params.Length)
            if buf.Size < this.Size {
                throw Error('Invalid size.', -1)
            }
            DllCall(
                'msvcrt.dll\memmove'
              , 'ptr', buf
              , 'ptr', this
              , 'int', this.Size
              , 'ptr'
            )
            this.Buffer := buf
            ptr := buf.Ptr
            for _rawInputDevice in this.List {
                _rawInputDevice.Ptr := ptr + (A_Index - 1) * cbSize
            }
        }
        i := k := this.List.Length := this.Map.Count
        for obj in Params {
            this.__Make(obj, ++i)
        }
        if !DeferRegistration {
            this.RegisterIndex(k + 1, Params.Length)
        }
    }
    Dispose() {
        this.Delete(1, this.Map.Count)
    }
    Delete(Index, Count := 1, Remove := true) {
        m := this.Map
        if Index < 1 || Index > m.Count {
            throw IndexError('Index out of range.', -1)
        }
        cbSize := RawInputDevice.cbSize
        if cbSize < 1 {
            throw Error('Invalid size.', -1)
        }
        ptr := this.Buffer.Ptr
        list := this.List
        if Remove {
            i := Index - 1
            loop Count {
                list[++i].Hwnd := 0
                list[i].Flags := 0x00000001 ; RIDEV_REMOVE
            }
            if !DllCall(
                'RegisterRawInputDevices'
              , 'ptr', this.Ptr + (Index - 1) * cbSize
              , 'uint', Count
              , 'uint', cbSize
              , 'int'
            ) {
                throw OSError()
            }
        }
        if bytes := (m.Count - Index - Count + 1) * cbSize {
            if bytes < cbSize {
                throw Error('Invalid byte count.', -1)
            }
            offset := cbSize * (Index - 1)
            DllCall(
                'msvcrt.dll\memmove'
              , 'ptr', ptr + offset
              , 'ptr', ptr + offset + cbSize * Count
              , 'int', bytes
              , 'ptr'
            )
        }
        end := Index + Count - 1
        del := []
        bufSize := this.Buffer.Size
        for usageId, i in m {
            if i >= Index {
                if i <= end {
                    del.Push(usageId)
                } else {
                    _rawInputDevice := list[i]
                    i -= Count
                    _rawInputDevice.Ptr := Ptr + (i - 1) * cbSize
                    list[i] := _rawInputDevice
                    m.Set(usageId, i)
                }
            }
        }
        for usageId in del {
            m.Delete(usageId)
        }
        list.Length := m.Count
    }
    DeleteByUsageId(UsageId, Remove := true) {
        return this.Delete(this.Map.Get(UsageId), 1, Remove)
    }
    Get(Index) {
        return this.List[Index]
    }
    GetByUsageId(UsageId) {
        return this.List[this.Map.Get(UsageId)]
    }
    GetIndex(UsageId) {
        return this.Map.Get(UsageId)
    }
    Register() {
        if !DllCall(
            'RegisterRawInputDevices'
          , 'ptr', this
          , 'uint', this.Map.Count
          , 'uint', RawInputDevice.cbSize
          , 'int'
        ) {
            throw OSError()
        }
    }
    RegisterIndex(Index, Count := 1) {
        if !DllCall(
            'RegisterRawInputDevices'
          , 'ptr', this.Ptr + RawInputDevice.cbSize * (Index - 1)
          , 'uint', Count
          , 'uint', RawInputDevice.cbSize
          , 'int'
        ) {
            throw OSError()
        }
    }
    __Make(Params, Index) {
        cbSize := RawInputDevice.cbSize
        item := RawInputDevice.FromPtr(this.Buffer.Ptr + (Index - 1) * cbSize)
        item.UsagePage := Params.UsagePage
        item.UsageId := Params.UsageId
        item.Flags := HasProp(Params, 'Flags') ? Params.Flags : 0
        item.Hwnd := HasProp(Params, 'Hwnd') ? Params.Hwnd : 0
        this.List.Push(item)
        this.Map.Set(Params.UsageId, this.List.Length)
    }
    Ptr => this.Buffer.Ptr
    Size => this.Map.Count * RawInputDevice.cbSize
    MaxSize => this.Buffer.Size
}
