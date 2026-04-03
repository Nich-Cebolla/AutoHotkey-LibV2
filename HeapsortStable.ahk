/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/HeapsortStable.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @desc - Characteristics of {@link HeapsortStable}:
 * - In-place sorting (mutates the input array).
 * - Stable (Preserves original order of equal elements).
 *
 * @param {Array} arr - The input array to sort. The array is mutated in-place.
 *
 * @param {*} [compare = (a, b) => a - b] - A `Func` or callable object that compares two values.
 *
 * Parameters:
 * 1. **{*}** - A value to be compared.
 * 2. **{*}** - A value to be compared.
 *
 * Returns **{Number}** - A number to one of the following effects:
 * - If the number is less than zero it indicates the first parameter is less than the second parameter.
 * - If the number is zero it indicates the two parameters are equal.
 * - If the number is greater than zero it indicates the first parameter is greater than the second parameter.
 *
 * @returns {Array} - The input array.
 */
HeapsortStable(arr, compare := (a, b) => a - b) {
    n := arr.length
    ; create list of indices
    indices := []
    loop indices.length := n {
        indices[A_Index] := A_Index
    }
    ; build heap
    i := Floor(n / 2)
    while i >= 1 {
        x := arr[i]
        _x := indices[i]
        k := i
        if k * 2 <= n {
            left  := k * 2
            right := left + 1
            j := left
            if right <= n {
                if z := compare(arr[right], arr[left]) {
                    if z > 0 {
                        j := right
                    }
                } else if indices[right] > indices[left] {
                    j := right
                }
            }
            if z := compare(arr[j], x) {
                if z < 0 {
                    i--
                    continue
                }
            } else if indices[j] < _x {
                i--
                continue
            }
        } else {
            i--
            continue
        }

        while k * 2 <= n {
            j := k * 2
            if j + 1 <= n {
                if z := compare(arr[j + 1], arr[j]) {
                    if z > 0 {
                        j++
                    }
                } else if indices[j + 1] > indices[j] {
                    j++
                }
            }
            arr[k] := arr[j]
            indices[k] := indices[j]
            k := j
        }
        while k > 1 {
            p := Floor(k / 2)
            if z := compare(arr[p], x) {
                if z > 0 {
                    arr[k] := x
                    indices[k] := _x
                    i--
                    continue 2
                }
            } else if indices[p] > _x {
                arr[k] := x
                indices[k] := _x
                i--
                continue 2
            }
            arr[k] := arr[p]
            indices[k] := indices[p]
            k := p
        }
    }

    ; Repeatedly move max to end
    i := n
    while i > 1 {
        t := arr[1]
        _t := indices[1]
        arr[1] := arr[i]
        indices[1] := indices[i]
        arr[i] := t
        indices[i] := _t
        i--

        x := arr[1]
        _x := indices[1]
        k := 1
        if k * 2 <= i {
            left  := k * 2
            right := left + 1
            j := left
            if right <= i {
                if z := compare(arr[right], arr[left]) {
                    if z > 0 {
                        j := right
                    }
                } else if indices[right] > indices[left] {
                    j := right
                }
            }
            if z := compare(arr[j], x) {
                if z < 0 {
                    continue
                }
            } else if indices[j] < _x {
                continue
            }
        } else {
            continue
        }

        while k * 2 <= i {
            j := k * 2
            if j + 1 <= i {
                if z := compare(arr[j + 1], arr[j]) {
                    if z > 0 {
                        j++
                    }
                } else if indices[j + 1] > indices[j] {
                    j++
                }
            }
            arr[k] := arr[j]
            indices[k] := indices[j]
            k := j
        }
        while k > 1 {
            p := Floor(k / 2)
            if z := compare(arr[p], x) {
                if z > 0 {
                    arr[k] := x
                    indices[k] := _x
                    continue 2
                }
            } else if indices[p] > _x {
                arr[k] := x
                indices[k] := _x
                continue 2
            }
            arr[k] := arr[p]
            indices[k] := indices[p]
            k := p
        }
    }
    return arr
}
