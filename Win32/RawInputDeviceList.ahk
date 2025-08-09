/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/RawInputDeviceList.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @classdesc - A wrapper around `GetRawInputDeviceList`. Use this to get information about the
 * devices attached to the system. See "test-files\test-RawInputDeviceList.ahk" for a usage
 * example.
 */
class ArrayRawInputDeviceList {
    /**
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getrawinputdeviceinfow}.
     *
     * @param {Integer} [Which = 0] - One or more of the following. Combine with bit-wise "|" to
     * include more than one.
     * - 1 : Keyboard
     * - 2 : Mouse
     * - 4 : Other
     *
     * A value of 0 directs `ArrayRawInputDeviceList.Prototype.__New` to not call
     * `GetRawInputDeviceInfoW` for the devices; your code would need to call
     * `ArrayRawInputDeviceList.Prototype.GetInfo`.
     *
     * @returns {ArrayRawInputDeviceList} - An object with the following properties:
     * - Keyboard - An array of `RawInputDeviceList` object representing the keyboards attached to
     * the system.
     * - Mouse - An array of `RawInputDeviceList` object representing the mice attached to
     * the system.
     * - Other - An array of `RawInputDeviceList` object representing the HID devices attached to
     * the system that are neither mice nor keyboards.
     */
    __New(Which := 0) {
        puiNumDevices := 0
        cbSize := RawInputDeviceList.cbSize
        DllCall(
            'GetRawInputDeviceList'
          , 'ptr', 0
          , 'uint*', &puiNumDevices
          , 'uint', cbSize
          , 'uint'
        )
        if !puiNumDevices {
            throw OSError()
        }
        buf := Buffer(cbSize * puiNumDevices)
        if DllCall(
            'GetRawInputDeviceList'
          , 'ptr', buf
          , 'uint*', &puiNumDevices
          , 'uint', cbSize
          , 'uint'
        ) == 4294967295 {
            throw OSError()
        }
        keyboard := this.Keyboard := []
        mouse := this.Mouse := []
        other := this.Other := []
        ptr := buf.Ptr
        loop puiNumDevices {
            _rawInputDevice := RawInputDeviceList(ptr + (A_Index - 1) * cbSize)
            switch _rawInputDevice.Type {
                case 0: mouse.Push(_rawInputDevice.Handle)
                case 1: keyboard.Push(_rawInputDevice.Handle)
                case 2: other.Push(_rawInputDevice.Handle)
            }
        }
        if Which {
            this.GetInfo(Which)
        }
    }
    /**
     *
     * @param {Integer} [Which = 7] - One or more of the following. Combine with bit-wise "|" to
     * include more than one. The default value includes each of keyboard, mouse, and other.
     * - 1 : Keyboard
     * - 2 : Mouse
     * - 4 : Other
     */
    GetInfo(Which := 7) {
        if Which & 1 {
            this.KeyboardInfo := _Get(this.Keyboard, [], 'keyboard', RidDeviceInfoKeyboard)
        }
        if Which & 2 {
            this.MouseInfo := _Get(this.Mouse, [], 'mouse', RidDeviceInfoMouse)
        }
        if Which & 4 {
            this.OtherInfo := _Get(this.Other, [], 'other', RidDeviceInfoHid)
        }

        _Get(List, OutList, Name, Constructor) {
            if !List.Length {
                throw Error('There are zero ' name ' devices in the list.', -1)
            }
            for hDevice in List {
                OutList.Push(Constructor(hDevice))
            }
            return OutList
        }
    }
}

class RawInputDeviceList {
    static __New() {
        this.Prototype.cbSize := this.Prototype.Size :=
        A_PtrSize + ; HANDLE                        hDevice
        A_PtrSize   ; DWORD 4 bytes for alignment   dwType
    }
    static cbSize => this.Prototype.cbSize
    __New(Ptr) {
        this.Ptr := Ptr
    }
    Handle => NumGet(this, 0, 'ptr')
    Type => NumGet(this, A_PtrSize, 'uint')
}

/**
 * @classdesc - {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-rid_device_info_keyboard}
 */
class RidDeviceInfoKeyboard extends RidDeviceInfoBase {
    static __New() {
        this.Prototype.cbSize :=
        4 + ; DWORD cbSize                          0
        4 + ; DWORD dwType type of raw input data   4
        4 + ; DWORD dwType type of keyboard         8
        4 + ; DWORD dwSubType                       12
        4 + ; DWORD dwKeyboardMode                  16
        4 + ; DWORD dwNumberOfFunctionKeys          20
        4 + ; DWORD dwNumberOfIndicators            24
        4   ; DWORD dwNumberOfKeysTotal             28
    }

    /**
     * |  Value  |  Description                                           |
     * |  -------|------------------------------------------------------  |
     * |  0x4    |  Enhanced 101- or 102-key keyboards (and compatibles)  |
     * |  0x7    |  Japanese Keyboard                                     |
     * |  0x8    |  Korean Keyboard                                       |
     * |  0x51   |  Unknown type or HID keyboard                          |
     * @memberof RidDeviceInfoKeyboard
     * @instance
     */
    DataType => NumGet(this, 4, 'uint')
    Type => NumGet(this, 8, 'uint')
    SubType => NumGet(this, 12, 'uint')
    KeyboardMode => NumGet(this, 16, 'uint')
    NumberOfFunctionKeys => NumGet(this, 20, 'uint')
    NumberOfIndicators => NumGet(this, 24, 'uint')
    NumberOfKeysTotal => NumGet(this, 28, 'uint')
}

/**
 * @classdesc - {@link https://learn.microsoft.com/en-us/windows/desktop/api/winuser/ns-winuser-rid_device_info_mouse}
 */
class RidDeviceInfoMouse extends RidDeviceInfoBase {
    static __New() {
        this.Prototype.cbSize :=
        4 + ; DWORD cbSize                          0
        4 + ; DWORD dwType type of raw input data   4
        4 + ; DWORD dwId                            8
        4 + ; DWORD dwNumberOfButtons               12
        4 + ; DWORD dwSampleRate                    16
        4 + ; BOOL  fHasHorizontalWheel             20
        8   ; padding
    }

    DataType => NumGet(this, 4, 'uint')
    Id => NumGet(this, 8, 'uint')
    Buttons => NumGet(this, 12, 'uint')
    SampleRate => NumGet(this, 16, 'uint')
    HasHorizontalWheel => NumGet(this, 20, 'uint')
}

/**
 * @classdesc - {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-rid_device_info_hid}
 */
class RidDeviceInfoHid extends RidDeviceInfoBase {
    static __New() {
        this.Prototype.cbSize :=
        4 + ; DWORD cbSize                          0
        4 + ; DWORD dwType type of raw input data   4
        4 + ; DWORD  dwVendorId                     8
        4 + ; DWORD  dwProductId                    12
        4 + ; DWORD  dwVersionNumber                16
        2 + ; USHORT usUsagePage                    20
        2 + ; USHORT usUsage                        22
        8   ; padding
    }

    DataType => NumGet(this, 4, 'uint')
    VendorId => NumGet(this, 8, 'uint')
    ProductId => NumGet(this, 12, 'uint')
    VersionNumber => NumGet(this, 16, 'uint')
    UsagePage => NumGet(this, 20, 'ushort')
    Usage => NumGet(this, 22, 'ushort')
}

class RidDeviceInfoBase {
    static cbSize => this.Prototype.cbSize
    /**
     * @param {Integer} [hDevice] - A handle to the raw input device. This comes from the hDevice
     * member of RAWINPUTHEADER or from GetRawInputDeviceList.
     */
    __New(hDevice?, DeferRetrieval := false) {
        this.Buffer := Buffer(this.cbSize)
        NumPut('uint', this.cbSize, this.Buffer)
        if IsSet(hDevice) {
            this.Handle := hDevice
        }
        if !DeferRetrieval {
            this()
        }
    }
    /**
     * Calls `GetRawInputDeviceInfoW`.
     *
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getrawinputdeviceinfow}
     *
     * @param {Integer} [hDevice] - A handle to the raw input device. This comes from the hDevice
     * member of RAWINPUTHEADER or from GetRawInputDeviceList. If unset, this object must already
     * have a property `Handle` with the handle.
     */
    Call(hDevice?) {
        if IsSet(hDevice) {
            this.Handle := hDevice
        } else {
            hDevice := this.Handle
        }
        pcbSize := 0
        DllCall(
            'GetRawInputDeviceInfoW'
          , 'ptr', hDevice
          , 'uint', 0x20000007 ; RIDI_DEVICENAME
          , 'ptr', 0
          , 'uint*', &pcbSize
          , 'uint'
        )
        if !pcbSize {
            throw OSError()
        }
        name := Buffer(pcbSize * 2 + 2)
        if DllCall(
            'GetRawInputDeviceInfoW'
          , 'ptr', hDevice
          , 'uint', 0x20000007
          , 'ptr', name
          , 'uint*', &pcbSize
          , 'uint'
        ) == 4294967295 {
            throw OSError()
        }
        pcbSize := this.cbSize
        result := DllCall(
            'GetRawInputDeviceInfoW'
          , 'ptr', hDevice
          , 'uint', 0x2000000b
          , 'ptr', this.Buffer
          , 'uint*', &pcbSize
          , 'int'
        )
        if result <= 0 {
            throw OSError()
        }
        this.Name := StrGet(name, 'utf-16')
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}
