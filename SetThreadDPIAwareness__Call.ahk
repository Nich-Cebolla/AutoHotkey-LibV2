
; Define DPI_AWARENESS_CONTEXT_DEFAULT somewhere in your code

SetThreadDpiAwareness__Call(Obj, Name, Params) {
    Split := StrSplit(Name, '_')
    if Split.Length == 2 && Obj.HasMethod(Split[1]) && SubStr(Split[2], 1, 1) = 'S' {
        if StrLen(Split[2]) == 2 {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', -SubStr(Split[2], 2, 1), 'ptr')
        } else {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', HasProp(Obj, 'DpiAwarenessContext') ? Obj.DpiAwarenessContext : DPI_AWARENESS_CONTEXT_DEFAULT ?? -4, 'ptr')
        }
        if Params.Length {
            return Obj.%Split[1]%(Params*)
        } else {
            return Obj.%Split[1]%()
        }
    } else {
        throw PropertyError('Property not found.', -1, Name)
    }
}

