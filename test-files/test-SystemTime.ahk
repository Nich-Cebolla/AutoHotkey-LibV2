
#SingleInstance force
#include ..\Win32\SystemTime.ahk

test()

class test {
    static Call() {
        st := SystemTime()
        outputdebug(st.timestamp '`n')
        ft := st.ToFileTime()
        outputdebug(ft() '`n')
        st2 := ft.ToSystemTime()
        outputdebug(st2.timestamp '`n')
        if st.timestamp != st2.timestamp {
            throw Error('invalid timestamp.')
        }
    }
}
