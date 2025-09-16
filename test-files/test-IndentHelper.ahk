
#include ..\IndentHelper.ahk

test()

class test {
    static Call() {
        for len, c in Map(4, '-', 6, '@', 1, '#') {
            ind := IndentHelper(len, c)
            for n in [ 1, -1, 2, -2, 5, -5, 100, -100 ] {
                _Check(n, len, c)
            }
            OutputDebug(StrLen(ind[0]) '`n')
        }

        _Check(n, len, c) {
            s := ind[n]
            if RegExMatch(s, '[^' c ']') {
                throw Error('Invalid char')
            }
            if n > 0 && StrLen(s) !== len * n {
                throw Error('Invalid count')
            }
            outputdebug(s '`n')
        }
    }
}
