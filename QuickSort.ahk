/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/QuickSort.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * Characteristics of {@link Quicksort}:
 * - Does not mutate the input array.
 * - Unstable (does not preserve original order of equal elements).
 * - Can sort either ascending or descending - adjust the comparator appropriately.
 * - There's a built-in cutoff to use insertion sort for small arrays (16).
 * - Makes liberal usage of system memory.
 *
 * If you need a comparable function that sorts in-place, see
 * {@link https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Heapsort.ahk Heapsort}
 * in this same repo.
 *
 * @param {array} arr - The array to be sorted.
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
 * @param {Integer} [arrSizeThreshold = 8] - Sets a threshold at which insertion sort is used to
 * sort the array instead of the core procedure. The default value of 8 was determine by testing
 * various distributions of numbers. `arrSizeThreshold` generally should be left at 8.
 *
 * @returns {array} - The sorted array.
 */
QuickSort(arr, compare := (a, b) => a - b, arrSizeThreshold := 8) {
    if arr.Length <= 16 {
        if arr.Length == 2 {
            if compare(arr[1], arr[2]) > 0 {
                return [arr[2], arr[1]]
            }
            return arr.Clone()
        } else if arr.Length > 1 {
            arr := arr.Clone()
            ; Insertion sort.
            i := 1
            loop arr.Length - 1 {
                j := i
                current := arr[++i]
                loop j {
                    if compare(arr[j], current) < 0 {
                        break
                    }
                    arr[j + 1] := arr[j--]
                }
                arr[j + 1] := current
            }
            return arr
        } else {
            return arr.Clone()
        }
    }
    candidates := []
    candidates.Length := 3
    stack := []
    loop 3 {
        candidates[A_Index] := arr[Random(1, arr.Length)]
    }
    i := 1
    loop 2 {
        j := i
        current := candidates[++i]
        loop j {
            if compare(candidates[j], current) < 0 {
                break
            }
            candidates[j + 1] := candidates[j--]
        }
        candidates[j + 1] := current
    }
    pivot := candidates[2]
    left := []
    right := []
    left.Capacity := right.Capacity := arr.Length
    for item in arr {
        if compare(item, pivot) < 0 {
            left.Push(item)
        } else {
            right.Push(item)
        }
    }
    stack.Push([ left, right, 1 ])
    _arr := stack[-1][stack[-1][3]]
    loop {
        if _arr.Length <= arrSizeThreshold {
            if _arr.Length == 2 {
                if compare(_arr[1], _arr[2]) > 0 {
                    stack[-1][stack[-1][3]] := [_arr[2], _arr[1]]
                }
            } else if _arr.Length > 1 {
                ; Insertion sort.
                i := 1
                loop _arr.Length - 1 {
                    j := i
                    current := _arr[++i]
                    loop j {
                        if compare(_arr[j], current) < 0 {
                            break
                        }
                        _arr[j + 1] := _arr[j--]
                    }
                    _arr[j + 1] := current
                }
            }
            while stack[-1][3] == 2 {
                complete := stack.Pop()
                complete[1].Push(complete[2]*)
                if !stack.Length {
                    return complete[1]
                }
                stack[-1][stack[-1][3]] := complete[1]
            }
            stack[-1][3]++
            _arr := stack[-1][2]
            continue
        }

        loop 3 {
            candidates[A_Index] := _arr[Random(1, _arr.Length)]
        }
        i := 1
        loop 2 {
            j := i
            current := candidates[++i]
            loop j {
                if compare(candidates[j], current) < 0 {
                    break
                }
                candidates[j + 1] := candidates[j--]
            }
            candidates[j + 1] := current
        }
        pivot := candidates[2]
        left := []
        right := []
        left.Capacity := right.Capacity := _arr.Length
        for item in _arr {
            if compare(item, pivot) < 0 {
                left.Push(item)
            } else {
                right.Push(item)
            }
        }
        if left.Length {
            _arr := left
            if right.Length {
                stack.Push([ left, right, 1 ])
                continue
            }
        } else if right.Length {
            _arr := right
        }
        if _arr.Length == 2 {
            if compare(_arr[1], _arr[2]) > 0 {
                stack[-1][stack[-1][3]] := [_arr[2], _arr[1]]
            }
        } else if _arr.Length > 1 {
            ; Insertion sort.
            i := 1
            loop _arr.Length - 1 {
                j := i
                current := _arr[++i]
                loop j {
                    if compare(_arr[j], current) < 0 {
                        break
                    }
                    _arr[j + 1] := _arr[j--]
                }
                _arr[j + 1] := current
            }
        }
        stack[-1][stack[-1][3]] := _arr
        while stack[-1][3] == 2 {
            complete := stack.Pop()
            complete[1].Push(complete[2]*)
            if !stack.Length {
                return complete[1]
            }
            stack[-1][stack[-1][3]] := complete[1]
        }
        stack[-1][3]++
        _arr := stack[-1][2]
    }
}

