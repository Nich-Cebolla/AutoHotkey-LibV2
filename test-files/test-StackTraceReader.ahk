#Include ..\StackTraceReader.ahk

SomeOperation() {
    a := 1
    b := 2
    c := a + b
    return test(a,b,c)
}

test(a,b,c) {
    throw Error('Test failed.', -1)
}

RunTest1() {
    try {
        SomeOperation()
    } catch Error as err {
        StackLines := StackTraceReader.FromError(err, 5, 5)
        for Line in StackLines {
            str .= Line.Value '`n'
        }
        MsgBox(str)
    }
}
RunTest1()

RunTest2() {
    Input := [
        "25 3 3 test-content_StackTraceReader.ahk"
        , "103 - 1 utf-8 test-content_StackTraceReader.ahk"
        , "55 " A_ScriptDir "\test-content_StackTraceReader.ahk"
    ]
    StackLines := StackTraceReader.Read(Input, 5, 5)
    for Line in StackLines {
        str .= Line.Value '`n'
    }
    MsgBox(str)
}
RunTest2()
