
#include ..\QuickStringify.ahk
#include ..\QuickStringifyProps.ahk
#include ..\MaxStringify.ahk
#include ..\PrettyStringify.ahk
#include ..\PrettyStringifyProps.ahk
#include ..\QuickStringify2.ahk
#include ..\QuickStringifyProps2.ahk
#include ..\MaxStringify2.ahk
#include ..\PrettyStringify2.ahk
#include ..\PrettyStringifyProps2.ahk
#include *i <JSON>
#include ..\..\QuickParse.ahk

test()

class test {
    static Call() {
        ProcessSetPriority('High')
        list := []
        obj := QuickParse(, 'test.json')
        loop 1000 {
            list.Push(obj)
        }
        o1 := MaxStringify()
        t1 := A_TickCount
        loop 10 {
            o1(list, &str)
        }
        s .= 'MaxStringify: ' (A_TickCount - t1) / 1000 '`n'

        o2 := MaxStringify2()
        t2 := A_TickCount
        loop 10 {
            o2(list, &str)
        }
        s .= 'MaxStringify2: ' (A_TickCount - t2) / 1000 '`n'

        o3 := PrettyStringify()
        t3 := A_TickCount
        loop 10 {
            o3(list, &str)
        }
        s .= 'PrettyStringify: ' (A_TickCount - t3) / 1000 '`n'

        o4 := PrettyStringify2()
        t4 := A_TickCount
        loop 10 {
            o4(list, &str)
        }
        s .= 'PrettyStringify2: ' (A_TickCount - t4) / 1000 '`n'

        o5 := PrettyStringifyProps()
        t5 := A_TickCount
        loop 10 {
            o5(list, &str)
        }
        s .= 'PrettyStringifyProps: ' (A_TickCount - t5) / 1000 '`n'

        o6 := PrettyStringifyProps2()
        t6 := A_TickCount
        loop 10 {
            o6(list, &str)
        }
        s .= 'PrettyStringifyProps2: ' (A_TickCount - t6) / 1000 '`n'

        o7 := QuickStringify()
        t7 := A_TickCount
        loop 10 {
            o7(list, &str)
        }
        s .= 'QuickStringify: ' (A_TickCount - t7) / 1000 '`n'

        o8 := QuickStringify2()
        t8 := A_TickCount
        loop 10 {
            o8(list, &str)
        }
        s .= 'QuickStringify2: ' (A_TickCount - t8) / 1000 '`n'

        o9 := QuickStringifyProps()
        t9 := A_TickCount
        loop 10 {
            o9(list, &str)
        }
        s .= 'QuickStringifyProps: ' (A_TickCount - t9) / 1000 '`n'

        o10 := QuickStringifyProps2()
        t10 := A_TickCount
        loop 10 {
            o10(list, &str)
        }
        s .= 'QuickStringifyProps2: ' (A_TickCount - t10) / 1000 '`n'

        if IsSet(JSON) {
            t11 := A_TickCount
            loop 10 {
                JSON.stringify(list)
            }
            s .= 'JSON.stringify: ' (A_TickCount - t11) / 1000
        }

        A_Clipboard := s
        MsgBox(s)
    }
}
