
#include ..\Win32\RawInputDevice.ahk

test()

class test {
    static Call() {
        this.Params := [
            { UsagePage: 0x0001, UsageId: 0x0002, Flags: 0x00000100, Hwnd: A_ScriptHwnd }
          , { UsagePage: 0x0001, UsageId: 0x0006, Flags: 0x00000100, Hwnd: A_ScriptHwnd }
          , { UsagePage: 0x000D, UsageId: 0x0004, Flags: 0x00000100, Hwnd: A_ScriptHwnd }
        ]
        _arrayRawInputDevices := this.ArrayRawInputDevices := ArrayRawInputDevices(this.Params)
        this.AddParams := [
            { UsagePage: 0x0001, UsageId: 0x0080, Flags: 0x00000100, Hwnd: A_ScriptHwnd }
          , { UsagePage: 0x000D, UsageId: 0x0005, Flags: 0x00000100, Hwnd: A_ScriptHwnd }
        ]
        _arrayRawInputDevices.Add(this.AddParams)
        retrievedArrayRawInputDevices := ArrayRawInputDevices.Retrieve()
        list := _arrayRawInputDevices.List
        retrieved := retrievedArrayRawInputDevices.Map
        loop list.Length {
            if !retrieved.Has(list[A_Index].UsageId) {
                throw Error('Missing usage id.', -1)
            }
        }
        _arrayRawInputDevices.Delete(3, 2)
        _arrayRawInputDevices.Dispose()
    }
}
