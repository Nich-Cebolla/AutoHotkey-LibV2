/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/RawInput.ahk
    Author: Nich-Cebolla
    License: MIT
*/

; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/RawInputDeviceList.ahk
; This is only needed to use the "GetDeviceInfo" method.
#include *i <RawInputDeviceList>

/**
 * @classdesc - Proceses WM_INPUT messages.
 *
 * {@link https://learn.microsoft.com/en-us/windows/win32/inputdev/wm-input}
 *
 * To get the value of wParam, use `wParam & 0xff`
 * <pre>
 * |  Value            |  Meaning                                                             |
 * |  -----------------|--------------------------------------------------------------------  |
 * |  RIM_INPUT 0      |  Input occurred while the application was in the foreground. The     |
 * |                   |  application must call DefWindowProc so the system can perform       |
 * |                   |  cleanup.                                                            |
 * |  RIM_INPUTSINK 1  |  Input occurred while the application was not in the foreground.     |
 * </pre>
 *
 * @example
 *  if wParam & 0xff {
 *      ; logic for input that occurred while the application was not in the foreground
 *  } else {
 *      ; logic for input that occurred while the application was in the foreground
 *  }
 * @
 *
 * If the focused state of the application is irrelevant to the functionality for which you registered
 * a raw input device, you can just ignore wParam altogether.
 */
class RawInput {
    static Call(lParam) {
        pcbSize := 0
        cbSizeHeader := RawInputBase.cbSizeHeader
        if DllCall(
            'GetRawInputData'
          , 'ptr', lParam
          , 'uint', 0x10000003 ; RID_INPUT
          , 'ptr', 0
          , 'uint*', &pcbSize
          , 'uint', cbSizeHeader
          , 'uint'
        ) {
            _Throw()
        }
        rawInputDevice := { Buffer: Buffer(pcbSize) }
        if DllCall(
            'GetRawInputData'
          , 'ptr', lParam
          , 'uint', 0x10000003 ; RID_INPUT
          , 'ptr', rawInputDevice.Buffer
          , 'uint*', &pcbSize
          , 'uint', cbSizeHeader
          , 'uint'
        ) == 4294967295 {
            _Throw()
        }
        switch NumGet(rawInputDevice.Buffer, 0, 'uint') {
            case 0: ObjSetBase(rawInputDevice, RawMouse.Prototype)
            case 1: ObjSetBase(rawInputDevice, RawKeyboard.Prototype)
            case 2: return ''               ; This does not currently support other HID devices.
        }

        return rawInputDevice

        _Throw() {
            if A_LastError {
                throw OSError()
            } else {
                throw OSError('``GetRawInputData`` failed.', -1)
            }
        }
    }
    static FromPtr(Ptr) {
        rawInputDevice := { Ptr: Ptr, Size: NumGet(Ptr, 4, 'uint') }
        switch NumGet(Ptr, 0, 'uint') {
            case 0: ObjSetBase(rawInputDevice, RawMouse.Prototype)
            case 1: ObjSetBase(rawInputDevice, RawKeyboard.Prototype)
            case 2: return ''               ; This does not currently support other HID devices.
        }
        return rawInputDevice
    }
}


/**
 * @classdesc -
 * For information see {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-rawmouse}.
 */
class RawMouse extends RawInputBase {
    static __New() {
        this.DeleteProp('__New')
        cbSizeHeader := this.cbSizeHeader
        this.Prototype.cbSize :=
        cbSizeHeader +
        4 +     ; USHORT + 2 for alignment     usFlags              RawInputBase.HeaderSize
        4 +     ; union {
                ;   ULONG ulButtons
                ;   struct {
                ;     USHORT                usButtonFlags;          RawInputBase.HeaderSize + 4
                ;     USHORT                usButtonData;           RawInputBase.HeaderSize + 6
                ;   } DUMMYSTRUCTNAME;
                ; } DUMMYUNIONNAME;
        4 +     ; ULONG                     ulRawButtons            RawInputBase.HeaderSize + 8
        4 +     ; LONG                      lLastX                  RawInputBase.HeaderSize + 12
        4 +     ; LONG                      lLastY                  RawInputBase.HeaderSize + 16
        4       ; ULONG                     ulExtraInformation      RawInputBase.HeaderSize + 20
        Proto := this.Prototype
        Proto.OffsetFlags := cbSizeHeader
        Proto.OffsetButtonFlags := Proto.OffsetFlags + 4
        Proto.OffsetButtonData := Proto.OffsetButtonFlags + 2
        Proto.OffsetRawButtons := Proto.OffsetButtonData + 2
        Proto.OffsetLastX := Proto.OffsetRawButtons + 4
        Proto.OffsetLastY := Proto.OffsetLastX + 4
        Proto.OffsetExtraInformation := Proto.OffsetLastY + 4
        this.TypeId := 0
    }

    GetDeviceInfo() {
        this.DeviceInfo := RidDeviceInfoMouse(this.Handle)
    }

    /**
     * One of the following:
     * <pre>
     * Name                      |  Value  |  Meaning
     * --------------------------|---------|----------------------------------------------------------
     * MOUSE_MOVE_RELATIVE       |  0x00   |  Mouse movement data is relative to the last mouse
     *                           |         |  position. For further information about mouse motion,
     *                           |         |  see the following Remarks section.
     * --------------------------|---------|----------------------------------------------------------
     * MOUSE_MOVE_ABSOLUTE       |  0x01   |  Mouse movement data is based on absolute position. For
     *                           |         |  further information about mouse motion, see the
     *                           |         |  following Remarks section.
     * --------------------------|---------|----------------------------------------------------------
     * MOUSE_VIRTUAL_DESKTOP     |  0x02   |  Mouse coordinates are mapped to the virtual desktop
     *                           |         |  (for a multiple monitor system). For further
     *                           |         |  information about mouse motion, see the following
     *                           |         |  Remarks section.
     * --------------------------|---------|----------------------------------------------------------
     * MOUSE_ATTRIBUTES_CHANGED  |  0x04   |  Mouse attributes changed; application needs to query
     *                           |         |  the mouse attributes.
     * --------------------------|---------|----------------------------------------------------------
     * MOUSE_MOVE_NOCOALESCE     |  0x08   |  This mouse movement event was not coalesced. Mouse
     *                           |         |  movement events can be coalesced by default.
     * </pre>
     * @memberof RawMouse
     * @instance
     */
    Flags => NumGet(this, this.OffsetFlags, 'ushort')
    /**
     * One of the following:
     * <pre>
     * Name                      |  Value   |  Meaning
     * --------------------------|----------|----------------------------------------------------------
     * RI_MOUSE_BUTTON_1_DOWN    |  0x0001  |  Left button changed to down.
     * RI_MOUSE_LEFT_BUTTON_DOWN |          |
     * --------------------------|----------|----------------------------------------------------------
     * RI_MOUSE_BUTTON_1_UP      |  0x0002  |  Left button changed to up.
     * RI_MOUSE_LEFT_BUTTON_UP   |          |
     * --------------------------|----------|----------------------------------------------------------
     * RI_MOUSE_BUTTON_2_DOWN    |  0x0004  |  Right button changed to down.
     * RI_MOUSE_RIGHT_BUTTON_DO  |          |
     * WN                        |          |
     * --------------------------|----------|----------------------------------------------------------
     * RI_MOUSE_BUTTON_2_UP      |  0x0008  |  Right button changed to up.
     * RI_MOUSE_RIGHT_BUTTON_UP  |          |
     * --------------------------|----------|----------------------------------------------------------
     * RI_MOUSE_BUTTON_3_DOWN    |  0x0010  |  Middle button changed to down.
     * RI_MOUSE_MIDDLE_BUTTON_D  |          |
     * OWN                       |          |
     * --------------------------|----------|----------------------------------------------------------
     * RI_MOUSE_BUTTON_3_UP      |  0x0020  |  Middle button changed to up.
     * RI_MOUSE_MIDDLE_BUTTON_UP |          |
     * --------------------------|----------|----------------------------------------------------------
     * RI_MOUSE_BUTTON_4_DOWN    |  0x0040  |  XBUTTON1 changed to down.
     * --------------------------|----------|----------------------------------------------------------
     * RI_MOUSE_BUTTON_4_UP      |  0x0080  |  XBUTTON1 changed to up.
     * --------------------------|----------|----------------------------------------------------------
     * RI_MOUSE_BUTTON_5_DOWN    |  0x0100  |  XBUTTON2 changed to down.
     * --------------------------|----------|----------------------------------------------------------
     * RI_MOUSE_BUTTON_5_UP      |  0x0200  |  XBUTTON2 changed to up.
     * --------------------------|----------|----------------------------------------------------------
     * RI_MOUSE_WHEEL            |  0x0400  |  Raw input comes from a mouse wheel. The wheel delta is
     *                           |          |  stored in usButtonData. A positive value indicates that
     *                           |          |  the wheel was rotated forward, away from the user; a
     *                           |          |  negative value indicates that the wheel was rotated
     *                           |          |  backward, toward the user. For further information see
     *                           |          |  the following Remarks section.
     * --------------------------|----------|----------------------------------------------------------
     * RI_MOUSE_HWHEEL           |  0x0800  |  Raw input comes from a horizontal mouse wheel. The
     *                           |          |  wheel delta is stored in usButtonData. A positive value
     *                           |          |  indicates that the wheel was rotated to the right; a
     *                           |          |  negative value indicates that the wheel was rotated to
     *                           |          |  the left. For further information see the following
     *                           |          |  Remarks section.
     * </pre>
     * @memberof RawMouse
     * @instance
     */
    ButtonFlags => NumGet(this, this.OffsetButtonFLags, 'ushort')
    /**
     * "If usButtonFlags has RI_MOUSE_WHEEL or RI_MOUSE_HWHEEL, this member specifies the distance
     * the wheel is rotated. For further information see the following Remarks section."
     * @memberof RawMouse
     * @instance
     */
    ButtonData => NumGet(this, this.OffsetButtonData, 'ushort')
    /**
     * "The raw state of the mouse buttons. The Win32 subsystem does not use this member."
     * @memberof RawMouse
     * @instance
     */
    RawButtons => NumGet(this, this.OffsetRawButtons, 'uint')
    /**
     * "The motion in the X direction. This is signed relative motion or absolute motion, depending
     * on the value of usFlags."
     * @memberof RawMouse
     * @instance
     */
    LastX => NumGet(this, this.OffsetLastX, 'Int')
    /**
     * "The motion in the Y direction. This is signed relative motion or absolute motion, depending
     * on the value of usFlags."
     * @memberof RawMouse
     * @instance
     */
    LastY => NumGet(this, this.OffsetLastY, 'Int')
    /**
     * "Additional device-specific information for the event. See Distinguishing Pen Input from Mouse
     * and Touch for more info."
     * @memberof RawMouse
     * @instance
     */
    ExtraInformation => NumGet(this, this.OffsetExtraInformation, 'uint')
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}

/**
 * @classdesc -
 * For information see {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-rawkeyboard}.
 */
class RawKeyboard extends RawInputBase {
    static __New() {
        this.DeleteProp('__New')
        cbSizeHeader := this.cbSizeHeader
        this.Prototype.cbSize :=
        cbSizeHeader +
        2 + ; USHORT     MakeCode
        2 + ; USHORT     Flags
        2 + ; USHORT     Reserved
        2 + ; USHORT     VKey
        4 + ; UINT       Message
        4   ; ULONG      ExtraInformation
        Proto := this.Prototype
        Proto.OffsetMakeCode := cbSizeHeader
        Proto.OffsetFlags := Proto.OffsetMakeCode + 2
        Proto.OffsetReserved := Proto.OffsetFlags + 2
        Proto.OffsetVKey := Proto.OffsetReserved + 2
        Proto.OffsetMessage := Proto.OffsetVKey + 2
        Proto.OffsetExtraInformation := Proto.OffsetMessage + 4
        this.TypeId := 1
    }

    GetDeviceInfo() {
        this.DeviceInfo := RidDeviceInfoKeyboard(this.Handle)
    }
    /**
     * There's a list of scan codes in file "Win32\Keyboard scan codes and virtual-key codes.md".
     *
     * KEYBOARD_OVERRUN_MAKE_CODE (0xFF) is a special MakeCode value sent when an invalid or
     * unrecognizable combination of keys is pressed or the number of keys pressed exceeds the limit
     * for this keyboard.
     * @memberof RawKeyboard
     * @instance
     */
    MakeCode => NumGet(this, this.OffsetMakeCode, 'ushort')
    Flags => NumGet(this, this.OffsetFlags, 'ushort')
    IsUp => this.Flags & 1
    IsE0 => this.Flags & 2
    IsE1 => this.Flags & 4
    /**
     * There's a list of virtual-key codes in file "Win32\Keyboard scan codes and virtual-key codes.md".
     * @memberof RawKeyboard
     * @instance
     */
    VKey => NumGet(this, this.OffsetVKey, 'ushort')
    /**
     * The corresponding window message
     *
     * |  WM_ACTIVATE     |  0x0319  |
     * |  ----------------|--------  |
     * |  WM_APPCOMMAND   |  0x0319  |
     * |  WM_CHAR         |  0x0102  |
     * |  WM_DEADCHAR     |  0x0103  |
     * |  WM_HOTKEY       |  0x0312  |
     * |  WM_KEYDOWN      |  0x0100  |
     * |  WM_KEYUP        |  0x0101  |
     * |  WM_KILLFOCUS    |  0x0008  |
     * |  WM_SETFOCUS     |  0x0007  |
     * |  WM_SYSDEADCHAR  |  0x0107  |
     * |  WM_SYSKEYDOWN   |  0x0104  |
     * |  WM_SYSKEYUP     |  0x0105  |
     * |  WM_UNICHAR      |  0x0109  |
     * @memberof RawKeyboard
     * @instance
     */
    Message => NumGet(this, this.OffsetMessage, 'uint')
    ExtraInformation => NumGet(this, this.OffsetExtraInformation, 'uint')
}

class RawInputBase {
    static __New() {
        this.DeleteProp('__New')
        this.Prototype.cbSizeHeader :=
        4 +         ; DWORD      dwType     0
        4 +         ; DWORD      dwSize     4
        A_PtrSize + ; HANDLE     hDevice    8
        A_PtrSize   ; WPARAM     wParam     8 + A_PtrSize
    }
    static Call(lParam) {
        pcbSize := this.cbSize
        rawInputDevice := { Buffer: Buffer(pcbSize) }
        if DllCall(
            'GetRawInputData'
          , 'ptr', lParam
          , 'uint', 0x10000003 ; RID_INPUT
          , 'ptr', rawInputDevice.Buffer
          , 'uint*', &pcbSize
          , 'uint', this.cbSizeHeader
          , 'uint'
        ) == 4294967295 {
            if A_LastError {
                throw OSError()
            } else {
                throw OSError('``GetRawInputData`` failed.', -1)
            }
        }
        if this.TypeId == NumGet(rawInputDevice.Buffer, 0, 'uint') {
            ObjSetBase(rawInputDevice, this.Prototype)
            return rawInputDevice
        }
    }
    static FromPtr(Ptr) {
        rawInputDevice := { Ptr: Ptr, Size: NumGet(Ptr, 4, 'uint') }
        ObjSetBase(rawInputDevice, this.Prototype)
        return rawInputDevice
    }

    static cbSizeHeader => this.Prototype.cbSizeHeader
    static cbSize => this.Prototype.cbSize

    dwSize => NumGet(this, 4, 'uint')
    Handle => NumGet(this, 8, 'ptr')
    /**
     * |  Value               |  Meaning                                                              |
     * |  --------------------|---------------------------------------------------------------------  |
     * |  RIM_TYPEMOUSE 0     |  Raw input comes from the mouse.                                      |
     * |  RIM_TYPEKEYBOARD 1  |  Raw input comes from the keyboard.                                   |
     * |  RIM_TYPEHID 2       |  Raw input comes from some device that is not a keyboard or a mouse.  |
     * @memberof RawInputHeader
     * @instance
     */
    Type => NumGet(this, 0, 'uint')
    wParam => NumGet(this, 8 + A_PtrSize, 'ptr')
    Size => this.Buffer.Size
    Ptr => this.Buffer.Ptr
}

/**
 * @classdesc -
 * For information see {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-rawkeyboard}.

class RawHid extends RawInputBase {
    static __New() {
        this.DeleteProp('__New')
        cbSizeHeader := RawInputBase.HeaderSize
        ; The size is variable
        ; DWORD     dwSizeHid
        ; DWORD     dwCount
        ; BYTE      bRawData[1]
        Proto := this.Prototype
        Proto.OffsetSizeHid := cbSizeHeader
        Proto.OffsetCount := Proto.OffsetSizeHid + 4
        Proto.OffsetRawData := Proto.OffsetCount + 4
        this.TypeId := 2
    }
    __New(Buf) {
        this.Buffer := Buf
    }
    SizeHid => NumGet(this, this.OffsetSizeHid, 'uint')
    Count => NumGet(this, this.OffsetCount, 'uint')
}
