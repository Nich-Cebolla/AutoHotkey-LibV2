Uint64ToStringW(val) {
    buf := Buffer(40, 0)
    if DllCall(
        'strsafe\StringCchPrintfW'
      , 'ptr', buf
      , 'uint', 20
      , 'str', '%I64u'
      , 'uint64', val
      , 'uint'
    ) {
        throw Error('``StringCchPrintfW`` encountered an error.')
    }
    return StrGet(buf)
}
