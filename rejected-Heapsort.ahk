
; Don't use this function, it performs about 50% worse than Heapsort. See Heapsort.ahk
Heapsort_kary(arr, compare := (a, b) => a - b, k := 4) {
    if k < 2 {
        throw ValueError('``k`` must be >= 2', -1, k)
    }
    n := arr.Length
    if n <= 16 {
        if n == 2 {
            if compare(arr[1], arr[2]) > 0 {
                t := arr[1]
                arr[1] := arr[2]
                arr[2] := t
            }
            return arr
        } else if n > 2 {
            i := 1
            loop n - 1 {
                j := i
                t := arr[++i]
                loop j {
                    if compare(arr[j], t) < 0 {
                        break
                    }
                    arr[j + 1] := arr[j--]
                }
                arr[j + 1] := t
            }
        }
        return arr
    }

    ; ---- Build heap ----
    i := Floor((n - 2) / k) + 1
    while i >= 1 {
        __siftDown_kary(arr, i, n, k, compare)
        i -= 1
    }

    ; ---- Extract max to end ----
    i := n
    while i > 1 {
        t := arr[1]
        arr[1] := arr[i]
        arr[i] := t
        i -= 1
        __siftDown_kary(arr, 1, i, k, compare)
    }
    return arr
}

; Sift-down for k-ary heap (1-based), with a cheap early-guard.
__siftDown_kary(arr, i, heapSize, k, compare) {
    ; Comparator path
    x := arr[i]
    base := (i - 1) * k + 2
    if base > heapSize {
        return
    }

    j := base
    end := base + k - 1
    if end > heapSize {
        end := heapSize
    }
    c := j + 1
    while c <= end {
        if compare(arr[c], arr[j]) > 0 {
            j := c
        }
        c += 1
    }
    if compare(arr[j], x) <= 0 {
        return
    }

    while base <= heapSize {
        j := base
        end := base + k - 1
        if end > heapSize {
            end := heapSize
        }

        c := j + 1
        while c <= end {
            if compare(arr[c], arr[j]) > 0 {
                j := c
            }
            c += 1
        }

        if compare(arr[j], x) <= 0 {
            break
        }
        arr[i] := arr[j]
        i := j
        base := (i - 1) * k + 2
    }

    while i > 1 {
        p := Floor((i - 2) / k) + 1
        if compare(arr[p], x) >= 0 {
            break
        }
        arr[i] := arr[p]
        i := p
    }
    arr[i] := x
}


/**
 * Don't use this function. It performs about 50% worse than Heapsort. See Heapsort.ahk in this same
 * directory.
 */
Heapsort_Original(arr, compare := (a, b) => a - b) {
    n := arr.Length
    if n <= 16 {
        if n == 2 {
            if compare(arr[1], arr[2]) > 0 {
                t := arr[1]
                arr[1] := arr[2]
                arr[2] := t
            }
            return arr
        } else if n > 2 {
            i := 1
            loop n - 1 {
                j := i
                t := arr[++i]
                loop j {
                    if compare(arr[j], t) < 0 {
                        break
                    }
                    arr[j + 1] := arr[j--]
                }
                arr[j + 1] := t
            }
        }
        return arr
    }

    i := Floor(n / 2)
    while i >= 1 {
        _Proc(arr, n, i, compare)
        i--
    }

    i := n
    while i > 1 {
        ; swap arr[1] <-> arr[i]
        t := arr[1]
        arr[1] := arr[i]
        arr[i] := t
        i--
        _Proc(arr, i, 1, compare)
    }
    return arr

    _Proc(arr, n, i, compare) {
        extreme := i
        loop {
            left  := i * 2
            right := i * 2 + 1

            if left  <= n && compare(arr[left],  arr[extreme]) > 0
                extreme := left
            if right <= n && compare(arr[right], arr[extreme]) > 0
                extreme := right

            if extreme = i {
                break
            }

            ; swap arr[i] <-> arr[extreme]
            t := arr[i]
            arr[i] := arr[extreme]
            arr[extreme] := t
            i := extreme
        }
    }
}
