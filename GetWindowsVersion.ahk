
GetWindowsVersion(&outMajor, &outMinor) {
    ver := DllCall('GetVersion', 'UInt')

    outMajor := ver & 0xFF
    outMinor := (ver >> 8) & 0xFF
}
