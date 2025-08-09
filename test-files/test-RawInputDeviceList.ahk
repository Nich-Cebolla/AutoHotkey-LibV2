
#include ..\Win32\RawInputDeviceList.ahk

test()

class test {
    static Call() {
        ; Get an instance of `ArrayRawInputDeviceList`
        _arrayRawInputDeviceList := ArrayRawInputDeviceList()
        ; Call "GetInfo"
        _arrayRawInputDeviceList.GetInfo()

        ; The rest of this is making the gui
        this.Categories := ['Keyboard', 'Mouse', 'Other']
        g := this.Gui := Gui('+Resize')
        columnsKeyboard := ['Name', 'DataType', 'Type', 'SubType', 'KeyboardMode', 'NumberOfFunctionKeys', 'NumberOfIndicators', 'NumberOfKeysTotal']
        columnsMouse := ['Name', 'DataType', 'Id', 'Buttons', 'SampleRate', 'HasHorizontalWheel']
        columnsOther := ['Name', 'DataType', 'VendorId', 'ProductId', 'VersionNumber', 'UsagePage', 'Usage']
        for item in this.Categories {
            columns := columns%item%
            list := _arrayRawInputDeviceList.%item%Info
            lv := g.Lv%item% := g.Add('ListView', 'w800 r' (list.Length + 1) ' vLv' item, columns)
            for deviceInfo in list {
                values := []
                values.Capacity := columns.Length
                for prop in columns {
                    values.Push(deviceInfo.%prop%)
                }
                lv.Add(, values*)
            }
            loop columns.Length {
                lv.ModifyCol(A_Index, 'autohdr')
            }
        }
        g.OnEvent('Size', _Size)
        g.Show()

        _Size(G, MinMax, Width, Height) {
            switch MinMax {
                case -1: return
                case 0, 1:
                    w := width - g.MarginX * 2
                    g.LvKeyboard.Move(, , w)
                    g.LvMouse.Move(, , w)
                    g.LvOther.Move(, , w)
            }
        }
    }
}
