
#include ..\QuickSort.ahk

test()

class test {
    static __New() {
        this.DeleteProp('__New')
        this.Pivots := []
    }
    static Call() {
        loop 5 {
            arr := []
            loop arr.Capacity := 1000 {
                arr.Push(Random(-100000, 100000))
            }
            sorted := QuickSort(arr)
            _n := n2 := sorted.RemoveAt(1)
            for n in sorted {
                if n2 > n {
                    throw Error('Out of order.', -1, 'Index: ' A_Index '; n: ' n '; n2: ' n2)
                }
                n2 := n
            }
            sorted.Push(_n)
            for n in arr {
                for _n in sorted {
                    if _n == n {
                        sorted.RemoveAt(A_Index)
                        continue 2
                    }
                }
                throw Error('Missing value.', -1, 'n: ' n)
            }
        }
    }
}
