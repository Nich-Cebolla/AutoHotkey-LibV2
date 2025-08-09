
/**
 * {@link https://learn.microsoft.com/en-us/windows/win32/api/wow64apiset/nf-wow64apiset-iswow64process}
 *
 * @returns {Integer} - 1 if the current process is running on the WOW64 subsystem. Else, 0.
 */
IsWow64Process() {
    Wow64Process := 0
    if address := DllCall('GetProcAddress', 'ptr', DllCall('GetModuleHandle', 'str', 'Kernel32', 'ptr'), 'astr', 'IsWow64Process', 'ptr') {
        if !DllCall(
            address
          , 'ptr', DllCall('GetCurrentProcess', 'ptr')
          , 'int*', &Wow64Process
          , 'int'
        ) {
            throw OSError()
        }
    }
    return Wow64Process
}
