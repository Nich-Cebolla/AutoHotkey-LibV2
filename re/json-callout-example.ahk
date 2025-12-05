
; This function parses an entire JSON string in a single RegExMatch call. It's about 30%
; slower than QuickParse.ahk, so this is here only as an example of a complex regex pattern
; that uses callouts to incrementally parse a string. Also I think it's pretty neat.

; The \K escape sequences are included to reduce the amount of characters that get copied every
; time a callout function is called. The pattern would work without them, so don't focus
; on them too much.

class JsonCalloutExample {
    static __New() {
        this.DeleteProp('__New')
        Next := '\s*+,?+\s*+'
        ArrayFalse := 'false\K(?COnArrayFalse)'
        ArrayNull := 'null\K(?COnArrayNull)'
        ArrayNumber := '(?<an>-?+\d++(?:\.\d++)?(?:[eE][+-]?+\d++)?+)\K(?COnArrayNumber)'
        ArrayEmptyQuote := '""\K(?COnArrayEmptyQuote)'
        ArrayString := '"(?<as>(?:\\\\|.+?(?<!\\)(?:\\\\)*+))"\K(?COnArrayString)'
        ArrayTrue := 'true\K(?COnArrayTrue)'
        ObjectFalse := 'false\K(?COnObjectFalse)'
        ObjectNull := 'null\K(?COnObjectNull)'
        ObjectNumber := '(?<on>-?+\d++(?:\.\d++)?+(?:[eE][+-]?+\d++)?)\K(?COnObjectNumber)'
        ObjectPropName := '"(?<name>(?:\\\\|.+?(?<!\\)(?:\\\\)*+))"\s*+:\s*+'
        ObjectEmptyQuote := '""\K(?COnObjectEmptyQuote)'
        ObjectString := '"(?<os>(?:\\\\|.+?(?<!\\)(?:\\\\)*+))"\K(?COnObjectString)'
        ObjectTrue := 'true\K(?COnObjectTrue)'
        pObject := (
            '(?<object>'
                '\{'
                '(*COMMIT)'
                '\s*+'
                '\K(?COnOpenCurly)'
                '(?:'
                    ObjectPropName
                    ''
                    '(?:'
                        ObjectEmptyQuote
                    '|'
                        ObjectString
                    '|'
                        ObjectNumber
                    '|'
                        '(?&object)'
                    '|'
                        '(?&array)'
                    '|'
                        ObjectFalse
                    '|'
                        ObjectNull
                    '|'
                        ObjectTrue
                    ')'
                    Next
                ')*+'
                '\}'
                '\K(?COnClose)'
            ')'
        )
        pArray := (
            '(?<array>'
                '\['
                '(*COMMIT)'
                '\s*+'
                '\K(?COnOpenSquare)'
                '(?:'
                    '(?:'
                        ArrayEmptyQuote
                    '|'
                        ArrayString
                    '|'
                        ArrayNumber
                    '|'
                        '(?&object)'
                    '|'
                        '(?&array)'
                    '|'
                        ArrayFalse
                    '|'
                        ArrayNull
                    '|'
                        ArrayTrue
                    ')'
                    Next
                ')*+'
                '\]'
                '\K(?COnClose)'
            ')'
        )
        this.Pattern := 'S)' pObject '|' pArray
    }
    /**
     * @descrpition - Parses a JSON string into an AHK object. This parser is designed for simplicity and
     * speed.
     * - JSON objects are parsed into instances of either `Object` or `Map`, depending on the value of
     * the parameter `AsMap`.
     * - JSON arrays are parsed into instances of `Array`.
     * - `false` is represented as `0`.
     * - `true` is represented as `1`.
     * - For arrays, `null` JSON values cause `QuickParse` to call `Obj.Push(unset)` where `Obj` is the
     *   active object being constructed at that time.
     * - For objects, `null` JSON values cause `QuickParse` to set the property with an empty string
     *   value.
     * - Unquoted numeric values are processed through `Number()` before setting the value.
     * - Quoted numbers are processed as strings.
     * - Escape sequences are un-escaped and external quotations are removed from JSON string values.
     *
     * Only one of `Str` or `Path` are needed. If `Str` is set, `Path` is ignored. If both `Str` and
     * `Path` are unset, the clipboard's contents are used.
     * @class
     *
     * @param {String} [Str] - The string to parse.
     * @param {String} [Path] - The path to the file that contains the JSON content to parse.
     * @param {String} [Encoding] - The file encoding to use if calling `QuickParse` with `Path`.
     * @param {*} [Root] - If set, the root object onto which properties are assigned will be
     * `Root`, and `QuickParse` will return the modified `Root` at the end of the function.
     * - If `AsMap` is true and the first open bracket in the JSON string is a curly bracket, `Root`
     *   must have a method `Set`.
     * - If the first open bracket in the JSON string is a square bracket, `Root` must have methods
     *   `Push`.
     * @param {Boolean} [AsMap = false] - If true, JSON objects are converted into AHK `Map` objects.
     * @param {Boolean} [MapCaseSense = false] - The value set to the `MapObj.CaseSense` property.
     * `MapCaseSense` is ignored when `AsMap` is false.
     * @returns {*}
     */
    static Call(Str?, Path?, Encoding?, Root?, AsMap := false, MapCaseSense := false) {
        local obj
        if !IsSet(Str) {
            If IsSet(Path) {
                Str := FileRead(Path, Encoding ?? unset)
            } else {
                Str := A_Clipboard
            }
        }
        if AsMap {
            Constructor := MapCaseSense ? Map : _GetObj
            OnObjectEmptyQuote := OnObjectEmptyQuote_1
            OnObjectFalse := OnObjectFalse_1
            OnObjectNull := OnObjectNull_1
            OnObjectNumber := OnObjectNumber_1
            OnObjectString := OnObjectString_1
            OnObjectTrue := OnObjectTrue_1
        } else {
            Constructor := Object
            OnObjectEmptyQuote := OnObjectEmptyQuote_2
            OnObjectFalse := OnObjectFalse_2
            OnObjectNull := OnObjectNull_2
            OnObjectNumber := OnObjectNumber_2
            OnObjectString := OnObjectString_2
            OnObjectTrue := OnObjectTrue_2
        }
        OnOpenCurly := OnOpenCurly_1
        OnOpenSquare := OnOpenSquare_1
        stack := ['']
        if !RegExMatch(Str, this.Pattern) || stack.Length {
            throw Error('Invalid json.')
        }

        return Root

        _GetObj() {
            m := Map()
            m.CaseSense := false
            return m
        }
        OnArrayEmptyQuote(match, *) {
            obj.Push('')
        }
        OnArrayFalse(match, *) {
            obj.Push(0)
        }
        OnArrayNull(match, *) {
            obj.Push(unset)
        }
        OnArrayNumber(match, *) {
            obj.Push(Number(match['an']))
        }
        OnArrayString(match, *) {
            obj.Push(match['as'])
        }
        OnArrayTrue(match, *) {
            obj.Push(1)
        }
        OnObjectEmptyQuote_1(match, *) {
            obj.Set(match['name'], '')
        }
        OnObjectFalse_1(match, *) {
            obj.Set(match['name'], 0)
        }
        OnObjectNull_1(match, *) {
            obj.Set(match['name'], '')
        }
        OnObjectNumber_1(match, *) {
            obj.Set(match['name'], Number(match['on']))
        }
        OnObjectString_1(match, *) {
            obj.Set(match['name'], match['os'])
        }
        OnObjectTrue_1(match, *) {
            obj.Set(match['name'], 1)
        }
        OnObjectEmptyQuote_2(match, *) {
            obj.%match['name']% := ''
        }
        OnObjectFalse_2(match, *) {
            obj.%match['name']% := 0
        }
        OnObjectNull_2(match, *) {
            obj.%match['name']% := ''
        }
        OnObjectNumber_2(match, *) {
            obj.%match['name']% := Number(match['on'])
        }
        OnObjectString_2(match, *) {
            obj.%match['name']% := match['os']
        }
        OnObjectTrue_2(match, *) {
            obj.%match['name']% := 1
        }
        OnOpenSquare_1(match, *) {
            if AsMap {
                OnOpenCurly := OnOpenCurly_2
                OnOpenSquare := OnOpenSquare_2
            } else {
                OnOpenCurly := OnOpenCurly_3
                OnOpenSquare := OnOpenSquare_3
            }
            if IsSet(Root) {
                obj := Root
            } else {
                obj := Root := Array()
            }
        }
        OnOpenCurly_1(match, *) {
            if AsMap {
                OnOpenCurly := OnOpenCurly_2
                OnOpenSquare := OnOpenSquare_2
            } else {
                OnOpenCurly := OnOpenCurly_3
                OnOpenSquare := OnOpenSquare_3
            }
            if IsSet(Root) {
                obj := Root
            } else {
                obj := Root := Constructor()
            }
        }
        OnOpenSquare_2(match, *) {
            stack.Push(obj)
            obj := Array()
            if stack[-1].__Class = 'Array' {
                stack[-1].Push(obj)
            } else {
                stack[-1].Set(match['name'], obj)
            }
        }
        OnOpenCurly_2(match, *) {
            stack.Push(obj)
            obj := Constructor()
            if stack[-1].__Class = 'Array' {
                stack[-1].Push(obj)
            } else {
                stack[-1].Set(match['name'], obj)
            }
        }
        OnOpenSquare_3(match, *) {
            stack.Push(obj)
            obj := Array()
            if stack[-1].__Class = 'Array' {
                stack[-1].Push(obj)
            } else {
                stack[-1].%match['name']% := obj
            }
        }
        OnOpenCurly_3(match, *) {
            stack.Push(obj)
            obj := Constructor()
            if stack[-1].__Class = 'Array' {
                stack[-1].Push(obj)
            } else {
                stack[-1].%match['name']% := obj
            }
        }
        OnClose(match, *) {
            obj := stack.Pop()
        }
    }
}
