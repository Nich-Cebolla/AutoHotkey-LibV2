/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Heapsort.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * Characteristics of {@link Heapsort}:
 * - In-place sorting (mutates the input array).
 * - Unstable (does not preserve original order of equal elements).
 * - Can sort either ascending or descending - adjust the comparator appropriately.
 * - There's a built-in cutoff to use insertion sort for small arrays (16).
 *
 * If memory isn't an issue, `QuickSort` performs about 30% faster. It is located in this same repo:
 * {@link https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Quicksort.ahk Quicksort}.
 *
 * @param {Array} arr - The input array to sort. The array is mutated in-place.
 *
 * @param {*} [compare = (a, b) => a - b] - A `Func` or callable object that compares two values.
 *
 * Parameters:
 * 1. A value to be compared.
 * 2. A value to be compared.
 *
 * Returns {Number} - A number to one of the following effects:
 * - If the number is less than zero it indicates the first parameter is less than the second parameter.
 * - If the number is zero it indicates the two parameters are equal.
 * - If the number is greater than zero it indicates the first parameter is greater than the second parameter.
 *
 * Reverse the return value to sort in descending order.
 *
 * @returns {Array} - The sorted input array.
 */
Heapsort(arr, compare := (a, b) => a - b) {
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

    ; Build heap
    i := Floor(n / 2)
    while i >= 1 {
        x := arr[i]
        k := i
        if k * 2 <= n {
            left  := k * 2
            right := left + 1
            j := left
            if right <= n && compare(arr[right], arr[left]) > 0 {
                j := right
            }
            if compare(arr[j], x) <= 0 {
                i--
                continue
            }
        } else {
            i--
            continue
        }

        while k * 2 <= n {
            j := k * 2
            if j + 1 <= n && compare(arr[j + 1], arr[j]) > 0 {
                j++
            }
            arr[k] := arr[j]
            k := j
        }
        while k > 1 {
            p := Floor(k / 2)
            if compare(arr[p], x) >= 0 {
                arr[k] := x
                i--
                continue 2
            }
            arr[k] := arr[p]
            k := p
        }
    }

    ; Repeatedly move max to end
    i := n
    while i > 1 {
        t := arr[1]
        arr[1] := arr[i]
        arr[i] := t
        i--

        x := arr[1]
        k := 1
        if k * 2 <= i {
            left  := k * 2
            right := left + 1
            j := left
            if right <= i && compare(arr[right], arr[left]) > 0 {
                j := right
            }
            if compare(arr[j], x) <= 0 {
                continue
            }
        } else {
            continue
        }

        while k * 2 <= i {
            j := k * 2
            if j + 1 <= i && compare(arr[j + 1], arr[j]) > 0 {
                j++
            }
            arr[k] := arr[j]
            k := j
        }
        while k > 1 {
            p := Floor(k / 2)
            if compare(arr[p], x) >= 0 {
                arr[k] := x
                continue 2
            }
            arr[k] := arr[p]
            k := p
        }
    }
    return arr
}
