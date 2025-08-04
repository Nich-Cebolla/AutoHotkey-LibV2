
GetWindowThreadProcessId(Hwnd, &OutProcId?) {
    OutProcId := 0
    if result := DllCall('GetWindowThreadProcessId', 'ptr', Hwnd, 'ptr*', &OutProcId, 'int') {
        return result
    } else {
        throw OSError()
    }
}
