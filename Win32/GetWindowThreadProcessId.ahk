/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/GetWindowThreadProcessId.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @param {Integer} [Hwnd] - The handle to the window for which to get the thread process id.
 * If unset, the thread process id for `A_ScriptHwnd` is retrieved.
 * @param {VarRef} [OutProcId] - A variable that will receive the process id for the process that created the window.
 * @returns {Integer}
 * @throws {OSError}
 */
GetWindowThreadProcessId(Hwnd?, &OutProcId?) {
    OutProcId := 0
    if result := DllCall('GetWindowThreadProcessId', 'ptr', Hwnd ?? A_ScriptHwnd, 'ptr*', &OutProcId, 'int') {
        return result
    } else {
        throw OSError()
    }
}
