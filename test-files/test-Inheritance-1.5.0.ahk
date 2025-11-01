
#include ..\inheritance\inheritance.ahk

test()

class test {
    static Call() {
        options := PropsInfo.Options()
        propsInfoObj1 := GetPropsInfoEx(PropsInfo.Prototype, options)
        propsInfoObj2 := GetPropsInfoEx(PropsInfo, options)
        propsInfoObj3 := GetPropsInfoEx(propsInfoObj1, options)
        sleep 1
    }
}
