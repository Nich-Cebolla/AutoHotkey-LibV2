#include ..\CompareObjects.ahk


test()

test() {
    obj1 := {}
    obj2 := {}
    depth := 0
    _Recurse(obj1, obj2, 5, &depth)
    CompareObjects(obj1, obj2)

    _Recurse(obj1, obj2, MaxDepth, &depth) {
        if depth + 1 > MaxDepth {
            return
        }
        depth++
        loop 7 {
            switch Random(1, 10) {
                case 1,2,3:
                    _Set({}, {})
                case 4,5,6:
                    _Set([], [])
                case 7,8:
                    s := _GetString()
                    _Set(s, s)
                case 9,10:
                    n := Random(-50000, 50000)
                    _Set(n, n)
            }
        }
        depth--

        _GetString() {
            local s := ''
            loop Random(1, 15) {
                s .= Chr(Random(65, 90))
            }
            return s
        }
        _Set(val1, val2) {
            if obj1 is Array {
                obj1.Push(val1)
                obj2.Push(val2)
                if IsObject(val1) {
                    _Recurse(val1, val2, MaxDepth, &depth)
                }
            } else {
                name := _GetString()
                obj1.%name% := val1
                obj2.%name% := val2
                if IsObject(val1) {
                    _Recurse(val1, val2, MaxDepth, &depth)
                }
            }
        }
    }
}
