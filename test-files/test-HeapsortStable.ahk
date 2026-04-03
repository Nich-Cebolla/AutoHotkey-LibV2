
#include ..\HeapsortStable.ahk

test()

class test {
    static Call() {
        len := 1000

        list := []
        loop list.capacity := len {
            list.Push(Random(-1 * (2 ** 32 - 1), 2 ** 32 - 1) + Random())
        }
        listClone := list.Clone()

        HeapsortStable(list)

        ; validate order
        loop len - 1 {
            if list[A_Index] > list[A_Index + 1] {
                throw Error('Out of order.', , 'list[' A_Index '] = ' list[A_Index] '; list[' (A_Index + 1) '] = ' list[A_Index + 1])
            }
        }

        ; validate no lost items
        for n in listClone {
            IndexStart := 1
            IndexEnd := list.length
            while IndexEnd - IndexStart > 4 {
                i := IndexEnd - Ceil((IndexEnd - IndexStart) * 0.5)
                x := n - list[i]
                if x {
                    if x > 0 {
                        IndexStart := i
                    } else {
                        IndexEnd := i
                    }
                } else {
                    list.RemoveAt(i)
                    continue 2
                }
            }
            i := IndexStart
            loop IndexEnd - i + 1 {
                x := n - list[i]
                if x {
                    ++i
                } else {
                    list.RemoveAt(i)
                    continue 2
                }
            }

            throw Error('Missing item.', , n)
        }

        list := []
        _len := len - Mod(len, 3)
        list.length := _len
        third := _len / 3
        loop third {
            value := Random(-1 * (2 ** 32 - 1), 2 ** 32 - 1) + Random()
            list[A_Index] := { value: value, index: A_Index }
            list[third + A_Index] := { value: value, index: third + A_Index }
            list[third * 2 + A_Index] := { value: value, index: third * 2 + A_Index }
        }
        listClone := list.Clone()

        HeapsortStable(list, (a, b) => a.value - b.value)

        ; validate order
        loop third - 1 {
            i := A_Index * 3 - 2
            if list[i].value != list[i + 1].value
            || list[i].value != list[i + 2].value {
                throw Error('Out of order.', , 'list[' i '] = ' list[i].value '; list[' (i + 1) '] = ' list[i + 1].value '; list[' (i + 2) '] = ' list[i + 2].value)
            }
            if list[i].index > list[i + 1].index
            || list[i].index > list[i + 2].index
            || list[i + 1].index > list[i + 2].index {
                throw Error('Unstable.', , 'For objects at ' i ', ' (i + 1) ', and ' (i + 2) ', the original indices were ' list[i].index ', ' list[i + 1].index ', ' list[i + 2].index)
            }
            if list[i].value > list[i + 3].value {
                throw Error('Out of order.', , 'list[' i '] = ' list[i].value '; list[' (i + 3) '] = ' list[i + 3].value)
            }
        }
        i := _len - 2
        if list[i].value != list[i + 1].value
        || list[i].value != list[i + 2].value {
            throw Error('Out of order.', , 'list[' i '] = ' list[i].value '; list[' (i + 1) '] = ' list[i + 1].value '; list[' (i + 2) '] = ' list[i + 2].value)
        }
        if list[i].index > list[i + 1].index
        || list[i].index > list[i + 2].index
        || list[i + 1].index > list[i + 2].index {
            throw Error('Unstable.', , 'For objects at ' i ', ' (i + 1) ', and ' (i + 2) ', the original indices were ' list[i].index ', ' list[i + 1].index ', ' list[i + 2].index)
        }

        ; validate no lost items
        for o in listClone {
            IndexStart := 1
            IndexEnd := list.length
            while IndexEnd - IndexStart > 4 {
                i := IndexEnd - Ceil((IndexEnd - IndexStart) * 0.5)
                x := o.value - list[i].value
                if !x {
                    x := o.index - list[i].index
                }
                if x {
                    if x > 0 {
                        IndexStart := i
                    } else {
                        IndexEnd := i
                    }
                } else {
                    list.RemoveAt(i)
                    continue 2
                }
            }
            i := IndexStart
            loop IndexEnd - i + 1 {
                x := o.value - list[i].value
                if !x {
                    x := o.index - list[i].index
                }
                if x {
                    ++i
                } else {
                    list.RemoveAt(i)
                    continue 2
                }
            }

            throw Error('Missing item.', , o.value)
        }

        sleep 1
    }
}
