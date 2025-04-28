#Include ..\Indexer.ahk

result1 := test_Indexer(test_Indexer.Items1, test_Indexer.Make1)
result2 := test_Indexer(test_Indexer.Items2, test_Indexer.Make2)

str := ''
if result1 {
    for p in result1 {
        str .= p '`n'
    }
}
if result2 {
    for p in result2 {
        str .= p '`n'
    }
}
if str {
    G := Gui()
    G.Add('Text', 'w400', str)
    G.Show()
}


class test_Indexer {
    static Items1 := [ { Prop: 'one' }, { Prop: 'two' }, { Prop: 'three' }, { Prop: 'four' } ]
    static Items2 := [ 'one', 'two', 'three', 'four' ]
    static Make1 := ObjBindMethod(this, '__Make1')
    static __Make1(n) {
        return Indexer(n, NameCallback)

        NameCallback(Item) {
            return Item.Prop
        }
    }
    static Make2 := ObjBindMethod(this, '__Make2')
    static __Make2(n) {
        return Indexer(n)
    }

    static Call(List, Make) {
        Problems := []
        n := List.Length
        I := Make(n)
        for Item in List {
            I(Item)
        }
        if I.List.Length !== I.Count || I.List.Length !== n {
            Problems.Push(A_LineNumber ': test 1.01')
        }
        for Item in List {
            if I(Item) !== A_Index {
                Problems.Push(A_LineNumber ': test 1.02')
            }
        }
        if I.List.Length !== I.Count || I.List.Length !== n {
            Problems.Push(A_LineNumber ': test 1.03')
        }
        for Item in List {
            if I.IndexToName(A_Index) !== _GetName(A_Index) {
                Problems.Push(A_LineNumber ': test 1.04')
            }
            if IsObject(Item) {
                if ObjPtr(Item) !== ObjPtr(I.IndexToItem(A_Index)) {
                    Problems.Push(A_LineNumber ': test 1.05')
                }
            } else {
                if Item !== I.IndexToItem(A_Index) {
                    Problems.Push(A_LineNumber ': test 1.05')
                }
            }
            if I.NameToIndex(_GetName(A_Index)) !== A_Index {
                Problems.Push(A_LineNumber ': test 1.06')
            }
            if IsObject(Item) {
                if ObjPtr(Item) !== ObjPtr(I.NameToItem(_GetName(A_Index))) {
                    Problems.Push(A_LineNumber ': test 1.07')
                }
            }
            if I.ItemToIndex(Item) !== A_Index {
                Problems.Push(A_LineNumber ': test 1.08')
            }
        }
        for Method in [_DeleteIndex, _DeleteName, _DeleteItem] {
            I := Make(n)
            for Item in List {
                I(Item)
            }
            Method(I)
            I.Dispose()
            if ObjOwnPropCount(I) > 1 {
                Problems.Push(A_LineNumber ': test 1.12')
            }
        }

        return Problems.Length ? Problems : ''

        NameCallback(Item) {
            return Item.Prop
        }
        _GetName(Index) {
            switch Index {
                case 1: return 'one'
                case 2: return 'two'
                case 3: return 'three'
                case 4: return 'four'
            }
        }
        _DeleteIndex(I) {
            loop n {
                I.DeleteIndex(A_Index)
            }
            if I.Count {
                Problems.Push(A_LineNumber ': test 1.09')
            } else {
                for Item in I.List {
                    if IsSet(Item) {
                        Problems.Push(A_LineNumber ': test 1.09')
                        break
                    }
                }
            }
        }
        _DeleteName(I) {
            loop n {
                I.DeleteName(_GetName(A_Index))
            }
            if I.Count {
                Problems.Push(A_LineNumber ': test 1.10')
            } else {
                for Item in I.List {
                    if IsSet(Item) {
                        Problems.Push(A_LineNumber ': test 1.10')
                        break
                    }
                }
            }
            if I.List.Length || I.Count {
            }
        }
        _DeleteItem(I) {
            for Item in List {
                I.DeleteItem(Item)
            }
            if I.Count {
                Problems.Push(A_LineNumber ': test 1.11')
            } else {
                for Item in I.List {
                    if IsSet(Item) {
                        Problems.Push(A_LineNumber ': test 1.11')
                        break
                    }
                }
            }
        }
    }
}
