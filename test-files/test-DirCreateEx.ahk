#include ..\DirCreateEx.ahk

test()

test() {
    path := 'test-DirCreateEx\test\test\test'
    result := DirCreateEx(path)
    if result.Result {
        result.ShowGui()
        return
    }
    if !DirExist(path) {
        result.ShowGui()
        return
    }
    DirDelete('test-DirCreateEx', true)
}
