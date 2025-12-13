
#include ..\QuickParse.ahk
#include ..\JsonToAhk.ahk

test()

class test {
    static Call() {
        A_Clipboard := JsonToAhk(, 'example.json', , 'obj', '`'', '`n')
    }
}
