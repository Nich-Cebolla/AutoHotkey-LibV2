#Include ..\StackTraceReader.ahk

; make container
global StackResults := []
; set `OnError`
OnError(OnErrorCallback)

OnErrorCallback(Thrown, Mode) {
	global StackResults
	StackResults.Push(StackTraceReader.FromError(Thrown, 5, 5))
}

ThrowErrorTest() {
    err := UnsetItemError('error 1', -1)
    err.Show('Return')
}
ThrowErrorTest2() {
    err := UnsetItemError('error 2', -1)
    err.Show('Return')
}
i := 0
!t:: {
    global i
    if !i {
        i := 1
        ThrowErrorTest()
    } else {
        i := 0
        ThrowErrorTest2()
    }
}
!y:: {
    global StackResults
    for StackResult in StackResults {
        for obj in StackResult {
            str .= '`n' obj.Value
        }
    }
    msgbox(str)
}
