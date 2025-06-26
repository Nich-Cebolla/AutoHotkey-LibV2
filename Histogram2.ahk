
/**
 * @description - Generates a histogram from an array of numbers.
 * @param {Array} Data - An array of values. If not numbers, the function `ValueCallback` should
 * return a number.
 * @param {Integer} BinStart - The value of the lowest bin.
 * @param {Integer} BinEnd - The value of the highest bin.
 * @param {Integer} BinInterval - The range of each bin.
 * @param {Integer} [MaxSymbols] - If set, the number of symbols applied to each bin is a proportional
 * value of this number. If unset, the number of symbols applied to each bin is the same as the number
 * of items that fit in the bin.
 * @param {String} [Symbol='*'] - The symbol to use in the histogram.
 * @param {String} [Newline='`r`n'] - The newline character to use.
 * @param {Integer} [Digits=3] - The number of digits to round the bin values to.
 * @param {Func} [ValueCallback] - A function to calculate the values' numeric value. The function
 * can accept up to three parameters in this order:
 * - The value
 * - The index
 * - The array object
 * @returns {String} - The histogram.
 */
Histogram2(Data, BinStart, BinEnd, BinInterval, MaxSymbols?, Symbol := '*', Newline := '`r`n', Digits := 3, ValueCallback?) {
    local Counts, Index, LargestCount, LargestLen, FormatStr, Start, End, Str, Bins
    if IsSet(ValueCallback) {
        Temp := Data
        Data := []
        Data.Capacity := Temp.Length
        for Item in Temp {
            Data.Push(ValueCallback(Item, A_Index, Temp))
        }
    }
    BinRange := BinEnd - BinStart
    Bins :=  Ceil(BinRange / BinInterval)
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
    Padding := StrLen(Round(BinInterval*Bins, Digits))
    FormatStr := '{1:' Padding '} - {2:-' Padding '} : {3:-' LargestLen '}  {4}' Newline
    Start := End := BinStart
    if IsSet(MaxSymbols) {
        Loop Bins
            _AddSegment(A_Index)
    } else {
        Loop Bins
            _AddSegmentExact(A_Index)
    }
    return str

    _AddSegment(Index) {
        End += BinInterval
        Symbols := ''
        Loop Round(Counts[Index] / LargestCount * MaxSymbols, 0)
            Symbols .= Symbol
        Str .= Format(FormatStr, Round(Start, Digits), Round(End, Digits), Counts[Index], Symbols)
        Start := End
    }
    _AddSegmentExact(Index) {
        End += BinInterval
        Symbols := ''
        Loop Counts[Index]
            Symbols .= Symbol
        Str .= Format(FormatStr, Round(Start, Digits), Round(End, Digits), Counts[Index], Symbols)
        Start := End
    }
    _FindBin(Value, Index) {
        return Value > BinInterval * (Index - 1) + BinStart && Value <= BinInterval * Index + BinStart
    }
}
