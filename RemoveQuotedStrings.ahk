
class RemoveQuotedStrings extends Array {
    __New(Str, Quote := '"', Escape := '\', Replacement?) {
        this.Quote := Quote
        if IsSet(Replacement) {
            this.Replacement := Replacement
        } else {
            Replacement := 0xFFFD
            while InStr(Str, Chr(Replacement)) {
                ++Replacement
            }
            Replacement := this.Replacement := Chr(Replacement)
        }
        pos := 1
        s := ''
        VarSetStrCapacity(&s, StrLen(Str))
        RegExMatch(Str, Format('S)(?:[^{1}]++\K(?CA))?(?:({1}.+?(?<!{2})(?:{2}{2})*{1})\K(?CB)(?:[^{1}]+\K(?CA))?)*', Quote, StrReplace(Escape, '\', '\\')))
        this.Value := &s
        this.Len := StrLen(Str) - StrLen(s)

        return


        A(M, *) {
            s .= SubStr(Str, pos, M.Pos - pos)
            pos := M.Pos
        }
        B(M, *) {
            this.Push(M)
            s .= Replacement this.Length
            pos := M.Pos
        }
    }
    Call(Str, &OutStr) {
        pos := 1
        OutStr := ''
        VarSetStrCapacity(&OutStr, StrLen(Str) + this.Len)
        RegExMatch(Str, Format('S)(?:[^{1}]+\K(?CA))?(?:{1}(\d+)\K(?CB)(?:[^{1}]+\K(?CA))?)*', StrReplace(this.Replacement, '\', '\\')))

        return

        A(M, *) {
            OutStr .= SubStr(Str, pos, M.Pos - pos)
            pos := M.Pos
        }
        B(M, *) {
            OutStr .= this[M[1]][1]
            pos := M.Pos[1] + M.Len[1]
        }
    }
    Str => %this.Value%
}
