
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
#include ..\..\QuickParse.ahk

test()

class test {
    static Call() {
        ProcessSetPriority('High')
        list := []
        obj := QuickParse(, 'test.json')
        list.Push(obj)
        o1 := MaxStringify()
        o1(list, &str)

        o2 := MaxStringify2()
        o2(list, &str)

        o3 := PrettyStringify()
        o3(list, &str)

        o4 := PrettyStringify2()
        o4(list, &str)

        o5 := PrettyStringifyProps()
        o5(list, &str)

        o6 := PrettyStringifyProps2()
        o6(list, &str)

        o7 := QuickStringify()
        o7(list, &str)

        o8 := QuickStringify2()
        o8(list, &str)

        o9 := QuickStringifyProps()
        o9(list, &str)

        o10 := QuickStringifyProps2()
        o10(list, &str)
        OutputDebug(A_ScriptName ': done`n')
    }
}
