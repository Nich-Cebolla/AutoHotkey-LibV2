
; This tests the `PropsInfo.Prototype` functions `Add`, `Delete`, and `Refresh`. This is separate
; from "test-Inheritance.ahk" because it uses code that I haven't released yet. I will merge them
; after releasing the "ScriptParser" library.
#include <ScriptParserConfig>
; https://github.com/Nich-Cebolla/StringifyAll/blob/main/src/StringifyAll.ahk
#include <StringifyAll>

#include ..\inheritance\Inheritance.ahk

if result := test_Inheritance() {
    PropsTypeMap := Map('Array', 0)
    PropsTypeMap.Default := 1
    OutputDebug(StringifyAll(result, { PropsTypeMap: PropsTypeMap }))
}


class test_Inheritance {
    static __New() {
        this.DeleteProp('__New')
        this.Result := []
    }
    static Call() {
        parent_func := A_ThisFunc
        condition_has := '(else) if B.Has(Prop)'
        loopCount := 15
        this.Result.Push({ Test: A_ThisFunc, Result: Result := [] })
        Obj := M2()
        Baseline := GetPropsInfo(Obj)
        _GetNames(&s1, &s2, &s3)
        PropsInfoObj := GetPropsInfo(Obj, , s1)
        PropsInfoObjCopy := GetPropsInfo(Obj, , s1)

        result1 := _Compare(PropsInfoObj, PropsInfoObjCopy)
        if result1.Length {
            Result.Push({ Result: result1, Line: A_LineNumber, Obj: PropsInfoObj, Copy: PropsInfoObjCopy, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
        }
        result2 := _Compare(Baseline, PropsInfoObj)
        if result2.Length {
            for item in result2 {
                if item.Condition !== condition_has || !InStr(s1, ',' item.Prop ',') {
                    Result.Push({ Item: item, Result: result2, Line: A_LineNumber, Obj: PropsInfoObj, Copy: PropsInfoObjCopy, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
                }
            }
        } else {
            Result.Push({ Item: item, Result: result2, Line: A_LineNumber, Obj: PropsInfoObj, Copy: PropsInfoObjCopy, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
        }

        PropsInfoObj.Add(s2)
        result3 := _Compare(PropsInfoObj, PropsInfoObjCopy)
        if result3.Length {
            for item in result3 {
                if item.Condition !== condition_has || !InStr(s2, ',' item.Prop ',') {
                    Result.Push({ Item: item, Result: result3, Line: A_LineNumber, Obj: PropsInfoObj, Copy: PropsInfoObjCopy, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
                }
            }
        } else {
            Result.Push({ Item: item, Result: result3, Line: A_LineNumber, Obj: PropsInfoObj, Copy: PropsInfoObjCopy, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
        }
        result4 := _Compare(Baseline, PropsInfoObj)
        if result4.Length {
            for item in result4 {
                if item.Condition !== condition_has || !InStr(s3, ',' item.Prop ',') {
                    Result.Push({ Item: item, Result: result4, Line: A_LineNumber, Obj: PropsInfoObj, Copy: PropsInfoObjCopy, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
                }
            }
        } else {
            Result.Push({ Item: item, Result: result4, Line: A_LineNumber, Obj: PropsInfoObj, Copy: PropsInfoObjCopy, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
        }
        PropsInfoObjCopy.Add(s2)

        PropsInfoObj.Add(s3)
        result5 := _Compare(PropsInfoObj, PropsInfoObjCopy)
        if result5.Length {
            for item in result5 {
                if item.Condition !== condition_has || !InStr(s3, ',' item.Prop ',') {
                    Result.Push({ Item: item, Result: result5, Line: A_LineNumber, Obj: PropsInfoObj, Copy: PropsInfoObjCopy, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
                }
            }
        } else {
            Result.Push({ Item: item, Result: result5, Line: A_LineNumber, Obj: PropsInfoObj, Copy: PropsInfoObjCopy, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
        }
        result6 := _Compare(Baseline, PropsInfoObj)
        if result6.Length {
            Result.Push({ Result: result6, Line: A_LineNumber, Obj: PropsInfoObj, Copy: PropsInfoObjCopy, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
        }
        PropsInfoObjCopy.Add(s3)

        PropsInfoObj.Delete(s2)
        result7 := _Compare(PropsInfoObjCopy, PropsInfoObj)
        if result7.Length {
            for item in result7 {
                if item.Condition !== condition_has || !InStr(s2, ',' item.Prop ',') {
                    Result.Push({ Item: item, Result: result7, Line: A_LineNumber, Obj: PropsInfoObjCopy, Copy: PropsInfoObj, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
                }
            }
        } else {
            Result.Push({ Item: item, Result: result7, Line: A_LineNumber, Obj: PropsInfoObjCopy, Copy: PropsInfoObj, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
        }
        result8 := _Compare(Baseline, PropsInfoObj)
        if result8.Length {
            for item in result8 {
                if item.Condition !== condition_has || !InStr(s2, ',' item.Prop ',') {
                    Result.Push({ Item: item, Result: result8, Line: A_LineNumber, Obj: PropsInfoObjCopy, Copy: PropsInfoObj, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
                }
            }
        } else {
            Result.Push({ Item: item, Result: result8, Line: A_LineNumber, Obj: PropsInfoObjCopy, Copy: PropsInfoObj, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
        }
        PropsInfoObjCopy.Delete(s2)

        PropsInfoObj.Refresh()
        result9 := _Compare(PropsInfoObj, PropsInfoObjCopy)
        if result9.Length {
            for item in result9 {
                if item.Condition !== condition_has || !InStr(s2, ',' item.Prop ',') {
                    Result.Push({ Item: item, Result: result9, Line: A_LineNumber, Obj: PropsInfoObjCopy, Copy: PropsInfoObj, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
                }
            }
        } else {
            Result.Push({ Item: item, Result: result9, Line: A_LineNumber, Obj: PropsInfoObjCopy, Copy: PropsInfoObj, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
        }
        result10 := _Compare(Baseline, PropsInfoObj)
        if result10.Length {
            Result.Push({ Result: result10, Line: A_LineNumber, Obj: PropsInfoObjCopy, Copy: PropsInfoObj, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
        }

        m.Prototype.DeleteProp('Prop2')
        Map.Prototype.DefineProp('Prop2', { Value: 'Map.Prototype.Prop2' })
        PropsInfoObjCopy.Get('Prop2').TestProp := 1
        PropsInfoObjCopy.Refresh()
        result11 := _Compare(Baseline, PropsInfoObjCopy)
        if result11.Length == 1 {
            Obj := result11[1]
            if Obj.AltInfoItemCopy.Index !== 3 {
                Result.Push({ AltInfoItem: Obj.AltInfoItem, AltInfoItemCopy: Obj.AltInfoItemCopy, Result: result11, Line: A_LineNumber, Obj: PropsInfoObjCopy, Copy: PropsInfoObj, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
            }
            if Obj.AltInfoItem.Index !== 2 {
                Result.Push({ AltInfoItem: Obj.AltInfoItem, AltInfoItemCopy: Obj.AltInfoItemCopy, Result: result11, Line: A_LineNumber, Obj: PropsInfoObjCopy, Copy: PropsInfoObj, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
            }
            if !Obj.Copy.Get('Prop2').HasOwnProp('TestProp') {
                Result.Push({ AltInfoItem: Obj.AltInfoItem, AltInfoItemCopy: Obj.AltInfoItemCopy, Result: result11, Line: A_LineNumber, Obj: PropsInfoObjCopy, Copy: PropsInfoObj, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
            }
        } else {
            Result.Push({ Result: result11, Line: A_LineNumber, Obj: PropsInfoObjCopy, Copy: PropsInfoObj, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
        }

        PropsInfoObj.Refresh(,, false)
        result12 := _Compare(Baseline, PropsInfoObj)
        if result12.Length {
            if result12[1].Condition !== condition_has || Result12[1].Prop !== 'Base' {
                Result.Push({ Result: result12, Line: A_LineNumber, Obj: PropsInfoObjCopy, Copy: PropsInfoObj, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
            }
            if result12[2].Condition !== 'if AltInfoItem.Index !== AltInfoItemCopy.Index' || result12[2].Prop !== 'Prop2' {
                Result.Push({ Result: result12, Line: A_LineNumber, Obj: PropsInfoObjCopy, Copy: PropsInfoObj, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
            }
        } else {
            Result.Push({ Result: result12, Line: A_LineNumber, Obj: PropsInfoObjCopy, Copy: PropsInfoObj, s1: s1, s2: s2, s3: s3, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
        }

        return Result.Length ? Result : ''

        _Compare(A, B) {
            unit_result := []
            i := 0
            for Prop, InfoItem in A {
                i++
                if B.Has(Prop) {
                    InfoItemCopy := B.Get(Prop)
                    if InfoItem.Index !== InfoItemCopy.Index {
                        unit_result.Push({ Line: A_LineNumber, Prop: Prop, Obj: A, Copy: B, InfoItem: InfoItem, InfoItemCopy: InfoItemCopy, s1: s1, s2: s2, s3: s3, i: i, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
                    }
                    if InfoItem.HasOwnProp('Alt') {
                        Alt := InfoItem.Alt
                        if InfoItemCopy.HasOwnProp('Alt') {
                            AltCopy := InfoItemCopy.Alt
                            if Alt.Length !== AltCopy.Length {
                                unit_result.Push({ Alt: Alt, AltCopy: AltCopy, Line: A_LineNumber, Prop: Prop, Obj: A, Copy: B, InfoItem: InfoItem, InfoItemCopy: InfoItemCopy, s1: s1, s2: s2, s3: s3, i: i, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
                            }
                            loop Alt.Length {
                                AltInfoItem := Alt[A_Index]
                                if A_Index <= AltCopy.Length {
                                    AltInfoItemCopy := AltCopy[A_Index]
                                    if AltInfoItem.Index !== AltInfoItemCopy.Index {
                                        unit_result.Push({ AltInfoItem: AltInfoItem, AltInfoItemCopy: AltInfoItemCopy, Line: A_LineNumber, Prop: Prop, Obj: A, Copy: B, InfoItem: InfoItem, InfoItemCopy: InfoItemCopy, s1: s1, s2: s2, s3: s3, i: i, InnerLoopIndex: A_Index, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
                                    }
                                } else {
                                    unit_result.Push({ Alt: Alt, AltCopy: AltCopy, Line: A_LineNumber, Prop: Prop, Obj: A, Copy: B, InfoItem: InfoItem, InfoItemCopy: InfoItemCopy, s1: s1, s2: s2, s3: s3, i: i, InnerLoopIndex: A_Index, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
                                }
                            }
                        } else {
                            unit_result.Push({ Line: A_LineNumber, Prop: Prop, Obj: A, Copy: B, InfoItem: InfoItem, InfoItemCopy: InfoItemCopy, s1: s1, s2: s2, s3: s3, i: i, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
                        }
                    } else if InfoItemCopy.HasOwnProp('Alt') {
                        unit_result.Push({ Line: A_LineNumber, Prop: Prop, Obj: A, Copy: B, InfoItem: InfoItem, InfoItemCopy: InfoItemCopy, s1: s1, s2: s2, s3: s3, i: i, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
                    }
                } else {
                    unit_result.Push({ Line: A_LineNumber, Prop: Prop, Obj: A, Copy: B, InfoItem: InfoItem, s1: s1, s2: s2, s3: s3, i: i, Condition: this.GetCondition(A_LineNumber, A_LineFile, parent_func, &RemovedResult, &Split, &LenIndent) })
                }
            }
            return unit_result
        }
        _GetNames(&s1, &s2, &s3) {
            s1 := s2 := s3 := ','
            loop loopCount {
                str := Baseline.Get(A_Index).Name
                s1 .= str ','
                if Mod(A_Index, 2) {
                    s2 .= str ','
                } else {
                    s3 .= str ','
                }
            }
        }
    }

    static GetCondition(LineNumber, Path, Fn, &Script, &Split, &LenIndent) {
        if !IsSet(Script) {
            Script := ScriptParser(A_ScriptFullPath)
            Script.Process()
        }
        if InStr(Fn, this.Prototype.__Class) {
            Method := Script.GetCollection('StaticMethod').Get(Fn)
        } else {
            throw Error('Unexpected function value', -1, Fn)
        }
        if !IsSet(Split) {
            Split := StrSplit(Method.TextFull, Script.LineEnding)
        }
        if !IsSet(LenIndent) {
            LenIndent := this.GetIndentLength(Split)
        }
        LineDiff := LineNumber - Method.LineStart
        PreviousLine := Split[LineDiff]
        if RegExMatch(PreviousLine, 'JS)^[ \t]*(?<condition>if.+?) *\{|\} +(?<condition>else if.+?) *\{', &MatchCondition)  {
            return MatchCondition['condition']
        }
        RegExMatch(PreviousLine, '^[ \t]*', &Match)
        Indent := Match.Len
        loop LineDiff {
            RegExMatch(Split[--LineDiff], '^[ \t]*', &Match)
            if Match && Match.Len == Indent {
                break
            }
        }
        if LineDiff {
            if !RegExMatch(Split[LineDiff], 'JS)^[ \t]*(?<condition>if.+?) *\{|\} +(?<condition>else if.+?) *\{', &MatchCondition)  {
                throw Error('The found line does not match a conditional statement.', -1, Split[LineDiff])
            }
            return '(else) ' MatchCondition['condition']
        } else {
            throw Error('Failed to identify the conditional statement.', -1)
        }
    }

    static GetIndentLength(Split) {
        lengths := ','
        for line in Split {
            RegExMatch(line, '^[ \t]*', &Match)
            if !InStr(lengths, ',' Match.Len ',') {
                lengths .= Match.Len ','
            }
        }
        lengths := StrSplit(Trim(lengths, ','), ',')
        ; minimum := 9223372036854775807
        k := 9
        loop {
            --k
            flag := true
            i := 0
            for length in lengths {
                if Mod(length, k) {
                    flag := false
                    break
                }
                ; if length < minimum {
                ;     minimum := length
                ; }
            }
            if flag {
                break
            }
        }
        return k
    }
}

;@region classes
class A extends A.base {

    Prop2 := '$.Prop2' ; "$" is to indicate that its a value property on the instance object, and not an accessor on the prototype

    Method2() {
        return 'A.Prototype.method2'
    }

    class base extends Array {
        method() {
            return 'A.base.Prototype.method'
        }
        method2() {
            return 'A.base.Prototype.method2'
        }

        Prop {
            Get => 'A.base.Prototype.Prop.Get'
            Set => 'A.base.Prototype.Prop.Set'
        }

        Prop2 {
            Get => 'A.base.Prototype.Prop2.Get'
            Set => 'A.base.Prototype.Prop2.Set'
        }
    }
}


class m extends map {

    static method() {
        return 'm.method'
    }

    static method2() {
        return 'm.method2'
    }

    static prop {
        get => 'm.prop.get'
        set => 'm.prop.set'
    }

    static prop2 {
        get => 'm.prop2.get'
        set => 'm.prop2.set'
    }

    method() {
        return 'm.Prototype.method'
    }
    method2() {
        return 'm.Prototype.method2'
    }

    Prop {
        Get => 'm.Prototype.Prop.Get'
        Set => 'm.Prototype.Prop.Set'
    }

    Prop2 {
        Get => 'm.Prototype.Prop2.Get'
        Set => 'm.Prototype.Prop2.Set'
    }
}

class m2 extends m {
    static prop2 {
        get => 'm2.prop2.get'
        set => 'm2.prop2.set'
    }
    static method2() {
        return 'm2.method2'
    }

    Prop2 => '$.Prop2'

    Method2() {
        return 'm2.Prototype.Method2'
    }
}
;@endregion
