class SystemTime {
    static __New() {
        this.DeleteProp('__New')
        SystemTime_SetConstants()
        proto := this.Prototype
        proto.cbSizeInstance :=
        ; SizeType      Symbol           OffsetPadding
        2 +   ; WORD    wYear            0
        2 +   ; WORD    wMonth           2
        2 +   ; WORD    wDayOfWeek       4
        2 +   ; WORD    wDay             6
        2 +   ; WORD    wHour            8
        2 +   ; WORD    wMinute          10
        2 +   ; WORD    wSecond          12
        2     ; WORD    wMilliseconds    14
        proto.offset_wYear          := 0
        proto.offset_wMonth         := 2
        proto.offset_wDayOfWeek     := 4
        proto.offset_wDay           := 6
        proto.offset_wHour          := 8
        proto.offset_wMinute        := 10
        proto.offset_wSecond        := 12
        proto.offset_wMilliseconds  := 14
    }
    /**
     * @classdesc - An AHK wrapper around the SYSTEMTIME structure.
     *
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/minwinbase/ns-minwinbase-systemtime}
     *
     * @param {Boolean} [GetSystemTime = true] - If true, calls `GetSystemTime` to fill the structure.
     */
    __New(GetSystemTime := true) {
        this.Buffer := Buffer(this.cbSizeInstance)
        if GetSystemTime {
            this()
        }
    }
    /**
     * @description - Calls `GetSystemTime`.
     *
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/sysinfoapi/nf-sysinfoapi-getsystemtime}
     */
    Call() {
        DllCall(g_kernel32_GetSystemTime, 'ptr', this)
    }
    /**
     * @description - Converts the SYSTEMTIME structure to a FILETIME structure.
     *
     * @param {Buffer|FileTime} [target] - If set, the `Buffer` or {@link FileTime} object to receive
     * the FILETIME structure. If unset, a {@link FileTime} object is created.
     *
     * @returns {FileTime}
     */
    ToFileTime(target?) {
        if !IsSet(target) {
            target := FileTime()
        }
        if !DllCall(
            g_kernel32_SystemTimeToFileTime
          , 'ptr', this
          , 'ptr', target
          , 'int'
        ) {
            throw OSError()
        }
        return target
    }
    wYear {
        Get => NumGet(this.Buffer, this.offset_wYear, 'ushort')
        Set {
            NumPut('ushort', Value, this.Buffer, this.offset_wYear)
        }
    }
    wMonth {
        Get => NumGet(this.Buffer, this.offset_wMonth, 'ushort')
        Set {
            NumPut('ushort', Value, this.Buffer, this.offset_wMonth)
        }
    }
    wDayOfWeek {
        Get => NumGet(this.Buffer, this.offset_wDayOfWeek, 'ushort')
        Set {
            NumPut('ushort', Value, this.Buffer, this.offset_wDayOfWeek)
        }
    }
    wDay {
        Get => NumGet(this.Buffer, this.offset_wDay, 'ushort')
        Set {
            NumPut('ushort', Value, this.Buffer, this.offset_wDay)
        }
    }
    wHour {
        Get => NumGet(this.Buffer, this.offset_wHour, 'ushort')
        Set {
            NumPut('ushort', Value, this.Buffer, this.offset_wHour)
        }
    }
    wMinute {
        Get => NumGet(this.Buffer, this.offset_wMinute, 'ushort')
        Set {
            NumPut('ushort', Value, this.Buffer, this.offset_wMinute)
        }
    }
    wSecond {
        Get => NumGet(this.Buffer, this.offset_wSecond, 'ushort')
        Set {
            NumPut('ushort', Value, this.Buffer, this.offset_wSecond)
        }
    }
    wMilliseconds {
        Get => NumGet(this.Buffer, this.offset_wMilliseconds, 'ushort')
        Set {
            NumPut('ushort', Value, this.Buffer, this.offset_wMilliseconds)
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
    Timestamp => Format('{}{:02}{:02}{:02}{:02}{:02}', this.wYear, this.wMonth, this.wDay, this.wHour, this.wMinute, this.wSecond)
}

class FileTime {
    static __New() {
        this.DeleteProp('__New')
        SystemTime_SetConstants()
        proto := this.Prototype
        proto.cbSizeInstance :=
        ; SizeType       Symbol            OffsetPadding
        4 +   ; DWORD    dwLowDateTime     0
        4     ; DWORD    dwHighDateTime    4
        proto.offset_dwLowDateTime   := 0
        proto.offset_dwHighDateTime  := 4
    }
    /**
     * @classdesc - An AHK wrapper around the FILETIME structure.
     *
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/minwinbase/ns-minwinbase-filetime}
     */
    __New() {
        this.Buffer := Buffer(this.cbSizeInstance)
    }
    /**
     * @description - Converts the FILETIME value to a string representation of the uint64, which
     * is a 64-bit value representing the number of 100-nanosecond intervals since January 1, 1601 (UTC).
     */
    Call() {
        buf := Buffer(40, 0)
        DllCall(
            g_msvcrt__ui64tow
          , 'uint64', (this.dwHighDateTime << 32) | this.dwLowDateTime
          , 'ptr', buf
          , 'uint', 10
          , 'cdecl'
        )
        return StrGet(buf)
    }
    /**
     * @description - Converts the FILETIME structure to a SYSTEMTIME structure.
     * @param {Buffer|SystemTime} [target] - Either a `Buffer` or {@link SystemTime}
     * object to receive the SYSTEMTIME structure. If unset, a {@link SystemTime} object
     * is created.
     * @returns {SystemTime}
     */
    ToSystemTime(target?) {
        if !IsSet(target) {
            target := SystemTime()
        }
        if !DllCall(
            g_kernel32_FileTimeToSystemTime
          , 'ptr', this
          , 'ptr', target
          , 'int'
        ) {
            throw OSError()
        }
        return target
    }
    dwLowDateTime {
        Get => NumGet(this.Buffer, this.offset_dwLowDateTime, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_dwLowDateTime)
        }
    }
    dwHighDateTime {
        Get => NumGet(this.Buffer, this.offset_dwHighDateTime, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_dwHighDateTime)
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}

SystemTime_SetConstants(force := false) {
    global
    if IsSet(SystemTime_constants_set) && !force {
        return
    }

    local hMod := DllCall('GetModuleHandleW', 'wstr', 'kernel32', 'ptr')
    g_kernel32_FileTimeToSystemTime := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'FileTimeToSystemTime', 'ptr')
    g_kernel32_GetSystemTime := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'GetSystemTime', 'ptr')
    g_kernel32_SystemTimeToFileTime := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'SystemTimeToFileTime', 'ptr')
    g_msvcrt__ui64tow := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandleW', 'wstr', 'msvcrt', 'ptr'), 'astr', '_ui64tow', 'ptr')

    SystemTime_constants_set := true
}
