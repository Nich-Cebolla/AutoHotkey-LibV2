
; Source: https://www.reddit.com/r/AutoHotkey/comments/1paamqm/is_there_any_way_to_determine_if_a_script_is/
IsDebugActive() {
    if !IsSet(cl) {
        static cl := DllCall('GetCommandLine', 'str')
    }
    return InStr(cl, '/Debug') < InStr(cl, A_ScriptName)
}
