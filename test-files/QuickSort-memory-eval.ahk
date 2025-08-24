

class test {
    static __New() {
        this.DeleteProp('__New')
        this.Reset()
    }
    static Add(name, capacity) {
        this.capacity_sum += capacity
        this.stack.Set(name, capacity)
        if this.capacity_sum > this.capacity_max {
            this.capacity_max := this.capacity_sum
        }
    }
    static GetId() {
        return ++this.Index
    }
    static Call(arr?) {
        if !IsSet(arr) {
            arr := []
            loop arr.Capacity := 1000 {
                arr.Push(Random(-100000, 100000))
            }
            sorted := QuickSort(arr)
        }
        QuickSort(arr)
        OutputDebug('max depth: ' this.depth_max '`nmax sum capacity: ' this.capacity_max '`n')
    }
    static IncDepth() {
        this.depth++
        if this.depth > this.depth_max {
            this.depth_max := this.depth
        }
    }
    static GetAverage() {
        n := 0
        loop 25 {
            this()
            n += this.capacity_max
            this.Reset()
        }
        OutputDebug('sum: ' n '`naverage: ' (n / 25) '`n')
    }
    static Remove(name) {
        item := this.stack.Get(name)
        this.stack.Delete(name)
        this.capacity_sum -= item
    }
    static Reset() {
        this.capacity_sum := this.capacity_max := this.depth := this.depth_max := this.Index := 0
        this.stack := Map()
    }
}


QuickSort(Arr, CompareFn := (a, b) => a - b, ArrSizeThreshold := 17, PivotCandidates := 7) {
    if PivotCandidates <= 1 {
        throw ValueError('``PivotCandidates`` must be an integer greater than one.', -1, PivotCandidates)
    }
    halfPivotCandidates := Ceil(PivotCandidates / 2)
    test.Add('original', arr.Capacity)
    result := _Proc(Arr)

    return result

    _Proc(Arr) {
        test.IncDepth()
        id := test.GetId()
        if Arr.Length <= ArrSizeThreshold {
            if Arr.Length == 2 {
                if CompareFn(Arr[1], Arr[2]) > 0 {
                    test.Add(id '-2', 2)
                    test.Remove(id '-2')
                    test.depth--
                    return [Arr[2], Arr[1]]
                }
            } else if Arr.Length > 1 {
                ; Insertion sort.
                i := 1
                loop Arr.Length - 1 {
                    j := i
                    current := Arr[++i]
                    loop j {
                        if CompareFn(Arr[j], current) < 0 {
                            break
                        }
                        Arr[j + 1] := Arr[j--]
                    }
                    Arr[j + 1] := current
                }
            }
            test.depth--
            return Arr
        }
        candidates := []
        loop candidates.Capacity := PivotCandidates {
            candidates.Push(Random(1, Arr.Length))
        }
        test.Add(id ' - pivot candidates', PivotCandidates)
        i := 1
        loop candidates.Length - 1 {
            j := i
            Current := candidates[++i]
            value := Arr[Current]
            loop j {
                if CompareFn(Arr[candidates[j]], value) < 0 {
                    break
                }
                candidates[j + 1] := candidates[j--]
            }
            candidates[j + 1] := Current
        }
        pivot := Arr[candidates[halfPivotCandidates]]
        left := []
        right := []
        left.Capacity := right.Capacity := Arr.Length
        test.Add(id ' - left', left.Capacity)
        test.Add(id ' - right', right.Capacity)
        for item in Arr {
            if CompareFn(item, pivot) < 0 {
                left.Push(item)
            } else {
                right.Push(item)
            }
        }
        result := _Proc(left)
        test.Add(id ' - result 1', result.Capacity)
        result.Push(_Proc(right)*)
        test.Remove(id ' - result 1')
        test.Add(id ' - result 2', result.Capacity)
        test.Remove(id ' - result 2')
        test.Remove(id ' - right')
        test.Remove(id ' - left')
        test.Remove(id ' - pivot candidates')

        test.depth--
        return result
    }
}
