/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/QuickSort.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * Sorts an array. The returned array is a new array; the original array is not modified.
 *
 * The process used by `QuickSort` makes liberal usage of the system's memory. The script
 * test-files\QuickSort-memory-eval.ahk can be used to evaluate the amount of memory used by
 * `QuickSort` during execution. My tests demonstrated an average memory consumption of over 9x
 * the capacity of the input array. These tests were performed using input arrays with 1000
 * numbers across an even distribution.
 *
 * @param {Array} Arr - The array to be sorted.
 *
 * @param {*} [CompareFn = (a, b) => a - b] - A `Func` or callable object that compares two values.
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
 * @param {Integer} [ArrSizeThreshold = 17] - Sets a threshold at which insertion sort is used to
 * sort the array instead of the core procedure. The default value of 17 was decided by testing various
 * values, but currently more testing is needed to evaluate arrays of various kinds of distributions.
 *
 * @param {Integer} [PivotCandidates = 7] - Note that `PivotCandidates` must be an integer greater
 * than 1.
 *
 * Defines the sample size used when selecting a pivot from a random sample. This seeks to avoid the
 * efficiency cost associated with selecting a low quality pivot. By choosing from a random sample,
 * it is expected that, on average, the number of comparisons required to evaluate the middle pivot
 * in the sample is significantly less than the number of comparisons avoided due to selecting a low
 * quality pivot.
 *
 * The default value of 7 was decided by testing various values. More testing is needed to evaluate
 * arrays of various kinds of distributions.
 *
 * @returns {Array} - The sorted array.
 *
 * @throws {ValueError} - "`PivotCandidates` must be an integer greater than one."
 */
QuickSort(Arr, CompareFn := (a, b) => a - b, ArrSizeThreshold := 17, PivotCandidates := 7) {
    if PivotCandidates <= 1 {
        throw ValueError('``PivotCandidates`` must be an integer greater than one.', -1, PivotCandidates)
    }
    halfPivotCandidates := Ceil(PivotCandidates / 2)
    if Arr.Length <= ArrSizeThreshold {
        if Arr.Length == 2 {
            if CompareFn(Arr[1], Arr[2]) > 0 {
                return [Arr[2], Arr[1]]
            }
            return Arr.Clone()
        } else if arr.Length > 1 {
            arr := Arr.Clone()
            ; Insertion sort.
            i := 1
            loop arr.Length - 1 {
                j := i
                current := arr[++i]
                loop j {
                    if CompareFn(arr[j], current) < 0 {
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

    return _Proc(Arr)

    _Proc(Arr) {
        if Arr.Length <= ArrSizeThreshold {
            if Arr.Length == 2 {
                if CompareFn(Arr[1], Arr[2]) > 0 {
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
            return Arr
        }
        candidates := []
        loop candidates.Capacity := PivotCandidates {
            candidates.Push(Random(1, Arr.Length))
        }
        i := 1
        loop candidates.Length - 1 {
            j := i
            current := candidates[++i]
            value := Arr[Current]
            loop j {
                if CompareFn(Arr[candidates[j]], value) < 0 {
                    break
                }
                candidates[j + 1] := candidates[j--]
            }
            candidates[j + 1] := current
        }
        pivot := Arr[candidates[halfPivotCandidates]]
        left := []
        right := []
        left.Capacity := right.Capacity := Arr.Length
        for item in Arr {
            if CompareFn(item, pivot) < 0 {
                left.Push(item)
            } else {
                right.Push(item)
            }
        }
        result := _Proc(left)
        result.Push(_Proc(right)*)

        return result
    }
}
