/**
 * @description - Generates a histogram from an array of numbers.
 * @param {Array} Data - An array of values. If not numbers, the function `ValueCallback` should
 * return a number.
 * @param {Integer} [Bins=20] - The number of bins to divide the data into.
 * @param {Integer} [MaxSymbols=20] - The maximum number of symbols to use in the histogram.
 * @param {String} [Symbol='*'] - The symbol to use in the histogram.
 * @param {String} [Newline='`r`n'] - The newline character to use.
 * @param {Integer} [Digits=3] - The number of digits to round the bin values to.
 * @param {Func} [ValueCallback] - A function to calculate the values' numeric value. The function
 * can accept up to three parameters in this order:
 * - The value
 * - The index
 * - The array object
 * @returns {String} - The histogram.
 *  @example
 *      ; Assume an array of numbers, `Data`, has been defined.
 *      OutputDebug(Histogram(Data))
 *  ;      0.000 - 49.927  : 43  **************
 *  ;     49.927 - 99.853  : 46  ***************
 *  ;     99.853 - 149.780 : 49  ****************
 *  ;    149.780 - 199.707 : 43  **************
 *  ;    199.707 - 249.633 : 54  ******************
 *  ;    249.633 - 299.560 : 48  ****************
 *  ;    299.560 - 349.486 : 55  ******************
 *  ;    349.486 - 399.413 : 53  *****************
 *  ;    399.413 - 449.340 : 57  *******************
 *  ;    449.340 - 499.266 : 43  **************
 *  ;    499.266 - 549.193 : 58  *******************
 *  ;    549.193 - 599.120 : 44  **************
 *  ;    599.120 - 649.046 : 61  ********************
 *  ;    649.046 - 698.973 : 47  ***************
 *  ;    698.973 - 748.900 : 49  ****************
 *  ;    748.900 - 798.826 : 57  *******************
 *  ;    798.826 - 848.753 : 51  *****************
 *  ;    848.753 - 898.679 : 46  ***************
 *  ;    898.679 - 948.606 : 52  *****************
 *  ;    948.606 - 998.533 : 44  **************
 *  @
 */
Histogram(Data, Bins := 20, MaxSymbols := 20, Symbol := '*', Newline := '`r`n', Digits := 3, ValueCallback?) {
    local BinSize, Lowest, Counts, Index, LargestCount, LargestLen, FormatStr, Start, End, Str
    if IsSet(ValueCallback) {
        Temp := Data
        Data := []
        Data.Capacity := Temp.Length
        for Item in Temp {
            Data.Push(ValueCallback(Item, A_Index, Temp))
        }
    }
    BinSize := ((Highest := Max(Data*)) - (Lowest := Min(Data*)) + 1) / Bins
    Counts := []
    Counts.Length := Bins
    Loop Bins
        Counts[A_Index] := 0
    Loop Data.Length {
        i := A_Index
        Loop Bins {
            if _FindBin(Data[i], A_Index) {
                j := A_Index
                break
            }
        }
        Counts[j]++
    }
    LargestCount := Max(Counts*)
    LargestLen := StrLen(LargestCount)
    Padding := StrLen(Round(BinSize*Bins, Digits))
    FormatStr := '{1:' Padding '} - {2:-' Padding '} : {3:-' LargestLen '}  {4}' Newline
    Start := End := Lowest
    Loop Bins
        _AddSegment(A_Index)
    return str

    _AddSegment(Index) {
        End += BinSize
        Symbols := ''
        Loop Round(Counts[Index] / LargestCount * MaxSymbols, 0)
            Symbols .= Symbol
        Str .= Format(FormatStr, Round(Start, Digits), Round(End, Digits), Counts[Index], Symbols)
        Start := End
    }
    _FindBin(Value, Index) {
        return Value > BinSize * (Index - 1) + Lowest && Value <= BinSize * Index + Lowest
    }
}
