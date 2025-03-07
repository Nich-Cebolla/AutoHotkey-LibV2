/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/FillStr.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

/**
 * @class
 * In this documentation an instance of `FillStr` is referred to as `Filler`.
 * FillStr constructs strings of the requested length out of the provided filler string. Multiple
 * `Filler` objects can be active at any time. It would technically be possible to use a single
 * `Filler` object and swap out the substrings on the property `Filler.Str`, but this is not
 * recommended because FillStr caches some substrings for efficiency, so you may not get the expected
 * result after swapping out the `Str` property.
 *
 * Internally, FillStr works by deconstructing the input integer into its base 10 components. It
 * constructs then caches the strings for components that are divisible by 10, then adds on the
 * remainder. This offers a balance between efficiency, flexibility, and memory usage.
 *
 * Since this is expected to be most frequently used to pad strings with surrounding whitespace,
 * the `FillStr` object is instantiated with an instance of itself using a single space character
 * as the filler string. This is available on the property `FillStr.S`, and can also be utilized using
 * `FillStr[Qty]` to output a string of Qty space characters.
 */
class FillStr {
    static __New() {
        this.S := FillStr(' ')
    }
    static __Item[Qty] {
        Get => this.S[Qty]
        Set => this.S.Cache.Set(Qty, value)
    }

    /**
     * @description - Constructs the offset string according to the input parameters.
     * @param {Integer} Len - The length of the output string.
     * @param {Integer} TruncateAction - Controls how the filler string `Filler.Str` is truncated when
     * `Len` is not evenly divisible by `Filler.Len`. The options are:
     * - 0: Does not truncate the filler string, and allows the width of the output string to exceed
     * `Len`.
     * - 1: Does not truncate the filler string, and does not allow the width of the output string to
     * exceed `Len`, sometimes resulting in the width being less than `Len`.
     * - 2: Does not truncate the filler string, and does not allow the width of the output string to
     * exceed `Len`, and adds space characters to fill the remaining space. The space characters are
     * added to the left side of the output string.
     * - 3: Does not truncate the filler string, and does not allow the width of the output string to
     * exceed `Len`, and adds space characters to fill the remaining space. The space characters are
     * added to the right side of the output string.
     * - 4: Truncates the filler string, and the truncated portion is on the left side of the output
     * string.
     * - 5: Truncates the filler string, and the truncated portion is on the right side of the output
     * string.
     */
    static GetOffsetStr(Len, TruncateAction, self) {
        Out := self[Floor(Len / self.Len)]
        if R := Mod(Len, self.Len) {
            switch TruncateAction {
                case 0: Out .= self[1]
                case 2: Out := FillStr[R] Out
                case 3: Out .= FillStr[R]
                case 4: Out := SubStr(self[1], self.Len - R + 1) Out
                case 5: Out .= SubStr(self[1], 1, R)
            }
        }
        return Out
    }

    /**
     * @description - Creates a new FillStr object, referred to as `Filler` in this documentation.
     * Use the FillStr instance to generate strings of repeating characters. For general usage,
     * see {@link FillStr#__Item}.
     * @param {String} Str - The string to repeat.
     * @example
        Filler := FillStr('-')
        Filler[10] ; ----------
        Filler.LeftAlign('Hello, world!', 26)       ; Hello, world!-------------
        Filler.LeftAlign('Hello, world!', 26, 5)    ; -----Hello, world!--------
        Filler.CenterAlign('Hello, world!', 26)     ; -------Hello, world!------
        Filler.CenterAlign('Hello, world!', 26, 1)  ; -------Hello, world!------
        Filler.CenterAlign('Hello, world!', 26, 2)  ; ------Hello, world!-------
        Filler.CenterAlign('Hello, world!', 26, 3)  ; -------Hello, world!-------
        Filler.CenterAlign('Hello, world!', 26, 4)  ; ------Hello, world!------
        Filler.RightAlign('Hello, world!', 26)      ; -------------Hello, world!
        Filler.RightAlign('Hello, world!', 26, 5)   ; --------Hello, world!-----
     * @
     * @returns {FillStr} - A new FillStr object.
     */
    __New(Str) {
        this.Str := Str
        Loop 10
            Out .= Str
        this[10] := Out
        this.Len := StrLen(Str)
    }
    Cache := Map()
    __Item[Qty] {
        /**
         * @description - Returns the string of the specified number of repetitions. The `Qty`
         * parameter does not represent string length, it represents number of repetitions of
         * `Filler.Str`, which is the same as string length only when the length of `Filler.Str` == 1.
         * @param {Integer} Qty - The number of repetitions.
         * @returns {String} - The string of the specified number of repetitions.
         */
        Get {
            if !Qty
                return ''
            Out := ''
            if this.Cache.Has(Number(Qty))
                return this.Cache[Number(Qty)]
            r := Mod(Qty, 10)
            Loop r
                Out .= this.Str
            Qty -= r
            if Qty {
                Split := StrSplit(Qty)
                for n in Split {
                    if n = 0
                        continue
                    Tens := 1
                    Loop StrLen(Qty) - A_Index
                        Tens := Tens * 10
                    if this.Cache.Has(Tens) {
                        Loop n
                            Out .= this.Cache.Get(Tens)
                    } else {
                        Loop n
                            Out .= _Process(Tens)
                    }
                }
            }
            return Out

            _Process(Qty) {
                local Out
                ; if !RegExMatch(Qty, '^10+$')
                ;     throw Error('Logical error in _Process function call.', -1)
                Tenth := Integer(Qty / 10)
                if this.Cache.Has(Tenth) {
                    Loop 10
                        Out .= this.Cache.Get(Tenth)
                } else
                    Out := _Process(Tenth)
                this.Cache.Set(Number(Qty), Out)
                return Out
            }
        }
        /**
         * @description - Sets the cache value of the indicated `Qty`. This can be useful in a
         * situation where you know you will be using a string of X length often, but X is not
         * divisible by 10. `FillStr` instances do not cache lengths unless they are divisible by
         * 10 to avoid memory bloat, but will still return a cached value if the input Qty exists in
         * the cache.
         */
        Set {
            this.Cache.Set(Number(Qty), value)
        }
    }

    /**
     * @description - Center aligns the string within a specified width. This method is compatible
     * with filler strings of any length.
     * @param {String} Str - The string to center align.
     * @param {Integer} Width - The width of the output string in number of characters.
     * @param {Number} [RemainderAction=1] - The action to take when the difference between the width
     * and the string length is not evenly divisible by 2.
     * - 0: Exclude the remainder.
     * - 1: Add the remainder to the left side.
     * - 2: Add the remainder to the right side.
     * - 3: Add the remainder to both sides.
     */
    CenterAlign(Str, Width, RemainderAction := 1, Padding := ' ', TruncateActionLeft := 1, TruncateActionRight := 2) {
        Space := Width - StrLen(Str) - (LenPadding := StrLen(Padding) * 2)
        if Space < 1
            return Str
        Split := Floor(Space / 2)
        if R := Mod(Space, 2) {
            switch RemainderAction {
                case 0: LeftOffset := RightOffset := Split
                case 1: LeftOffset := Split + R, RightOffset := Split
                case 2: LeftOffset := Split, RightOffset := Split + R
                case 3: LeftOffset := RightOffset := Split + R
                default:
                    throw MethodError('Invalid RemainderAction.', -1, 'RemainderAction: ' RemainderAction)
            }
        } else
            LeftOffset := RightOffset := Split
        return FillStr.GetOffsetStr(LeftOffset, TruncateActionLeft, this) Padding Str Padding FillStr.GetOffsetStr(RightOffset, TruncateActionRight, this)
    }

    /**
     * @description - Center aligns a string within a specified width. This method is only compatible
     * with filler strings that are 1 character in length.
     * @param {String} Str - The string to center align.
     * @param {Number} Width - The width of the output string.
     * @param {Number} [RemainderAction=1] - The action to take when the difference between the width
     * and the string length is not evenly divisible by 2.
     * - 0: Exclude the remainder.
     * - 1: Add the remainder to the left side.
     * - 2: Add the remainder to the right side.
     * - 3: Add the remainder to both sides.
     * @returns {String} - The center aligned string.
     */
    CenterAlignA(Str, Width, RemainderAction := 1) {
        Space := Width - StrLen(Str)
        r := Mod(Space, 2)
        Split := (Space - r) / 2
        switch RemainderAction {
            case 0: return this[Split] Str this[Split]
            case 1: return this[Split + r] Str this[Split]
            case 2: return this[Split] Str this[Split + r]
            case 3: return this[Split + r] Str this[Split + r]
            default:
                throw MethodError('Invalid RemainderAction.', -1, 'RemainderAction: ' RemainderAction)
        }
    }

    /** @description - Clears the cache. */
    ClearCache() => this.Cache.Clear()

    /**
     * @description - Left aligns a string within a specified width. This method is compatible with
     * filler strings of any length.
     * @param {String} Str - The string to left align.
     * @param {Integer} Width - The width of the output string in number of characters.
     * @param {Integer} [LeftOffset=0] - The offset from the left side in number of characters. The
     * offset is constructed by using the filler string (`Filler.Str`) value and repeating
     * it until the offset length is reached.
     * @param {String} [Padding=' '] - The `Padding` value is added to the left and right side of
     * `Str` to create space between the string and the filler characters. To not use padding, set
     * it to an empty string.
     * @param {Integer} [TruncateActionLeft=1] - This parameter controls how the filler string
     * `Filler.Str` is truncated when the LeftOffset is not evenly divisible by the length of
     * `Filler.Str`. For a full explanation, see {@link FillStr.GetOffsetStr}.
     * @param {Integer} [TruncateActionRight=2] - This parameter controls how the filler string
     * `Filler.Str` is truncated when the remaining character count on the right side of the output
     * string is not evenly divisible by the length of `Filler.Str`. For a full explanation, see
     * {@link FillStr.GetOffsetStr}.
     */
    LeftAlign(Str, Width, LeftOffset := 0, Padding := ' ', TruncateActionLeft := 1, TruncateActionRight := 2) {
        if LeftOffset + (LenStr := StrLen(Str)) + (LenPadding := StrLen(Padding) * 2) > Width
            LeftOffset := Width - LenStr - LenPadding
        if LeftOffset > 0
            Out .= FillStr.GetOffsetStr(LeftOffset, TruncateActionLeft, this)
        Out .= Padding Str Padding
        if (Remainder := Width - StrLen(Out))
            Out .= FillStr.GetOffsetStr(Remainder, TruncateActionRight, this)
        return Out
    }

    /**
     * @description - Left aligns a string within a specified width. This method is only compatible
     * with filler strings that are 1 character in length.
     * @param {String} Str - The string to left align.
     * @param {Number} Width - The width of the output string.
     * @param {Number} [LeftOffset=0] - The offset from the left side.
     * @returns {String} - The left aligned string.
     */
    LeftAlignA(Str, Width, LeftOffset := 0) {
        if LeftOffset {
            if LeftOffset + StrLen(Str) > Width
                LeftOffset := Width - StrLen(Str)
            return this[LeftOffset] Str this[Width - StrLen(Str) - LeftOffset]
        }
        return Str this[Width - StrLen(Str)]
    }

    /**
     * @description - Right aligns a string within a specified width. This method is compatible with
     * filler strings of any length.
     * @param {String} Str - The string to right align.
     * @param {Integer} Width - The width of the output string in number of characters.
     * @param {Integer} [RightOffset=0] - The offset from the right side in number of characters. The
     * offset is constructed by using the filler string (`Filler.Str`) value and repeating
     * it until the offset length is reached.
     * @param {String} [Padding=' '] - The `Padding` value is added to the left and right side of
     * `Str` to create space between the string and the filler characters. To not use padding, set
     * it to an empty string.
     * @param {Integer} [TruncateActionLeft=1] - This parameter controls how the filler string
     * `Filler.Str` is truncated when the remaining character count on the left side of the output
     * string is not evenly divisible by the length of `Filler.Str`. For a full explanation, see
     * {@link FillStr.GetOffsetStr}.
     * @param {Integer} [TruncateActionRight=2] - This parameter controls how the filler string
     * `Filler.Str` is truncated when the RightOffset is not evenly divisible by the length of
     * `Filler.Str`. For a full explanation, see {@link FillStr.GetOffsetStr}.
     * @returns {String} - The right aligned string.
     */
    RightAlign(Str, Width, RightOffset := 0, Padding := ' ', TruncateActionLeft := 1, TruncateActionRight := 2) {
        if RightOffset + (LenStr := StrLen(Str)) + (LenPadding := StrLen(Padding) * 2) > Width
            RightOffset := Width - LenStr - LenPadding
        Out := Padding Str Padding
        if (Remainder := Width - StrLen(Out) - RightOffset)
            Out := FillStr.GetOffsetStr(Remainder, TruncateActionRight, this) Out
        if RightOffset > 0
            Out := FillStr.GetOffsetStr(RightOffset, TruncateActionLeft, this) Out
        return Out
    }

    /**
     * @description - Right aligns a string within a specified width. This method is only compatible
     * with filler strings that are 1 character in length.
     * @param {String} Str - The string to right align.
     * @param {Number} Width - The width of the output string.
     * @param {Number} [RightOffset=0] - The offset from the right side.
     * @returns {String} - The right aligned string.
     */
    RightAlignA(Str, Width, RightOffset := 0) {
        if RightOffset {
            if RightOffset + StrLen(Str) > Width
                RightOffset := Width - StrLen(Str)
            return this[Width - StrLen(Str) - RightOffset] Str this[RightOffset]
        }
        return this[Width - StrLen(Str)] Str
    }
}
