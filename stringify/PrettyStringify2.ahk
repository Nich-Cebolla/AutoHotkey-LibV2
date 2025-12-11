/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/tree/main/stringify
    Author: Nich-Cebolla
    License: MIT
*/

class PrettyStringify2 {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.CharThresholdArray :=
        proto.CharThresholdItem :=
        proto.CharThresholdMap :=
        proto.CharThresholdObject :=
        4294967295
    }
    /**
     * @description - Creates the function object.
     *
     * This function includes an option to format objects' string representations as single lines
     * instead of having a line break between each value.
     *
     * The option is a threshold. If the number of characters of an object's string representation
     * is less than the threshold, the object is represented as a single line with a single space
     * character separating the brackets and values. If the number of characters of an object's string
     * representation is greater than the threshold, then there is a line break between the brackets
     * and each value. This also applies to map key-value pairs. See the example code for an example
     * of what the output looks like.
     *
     * The example code yields the following output:
     * <pre>
     * {
     *   "Array": [ { "prop": "val" }, { "key": "val" }, [ "val" ] ],
     *   "Map": { "arr": [ "val" ]"map": { "key": "val" }"obj": { "prop": "val" } },
     *   "Object": { "arr": [ "val" ], "map": { "key": "val" }, "obj": { "prop": "val" } }
     * }
     * </pre>
     *
     * - Map objects are represented as `{ "key": val }`.
     * - This does not work with objects that inherit from `ComValue`.
     * - This does not check for reference cycles.
     * - For Array and Map objects, only the enumerator is processed.
     * - For other object types, only the own properties are processed.
     * - Unset array indices are represented as *null* JSON value.
     *
     * @param {Object} [Options] - An object with options as property : value pairs.
     * @param {Integer} [Options.CharThreshold = 200] - If an object's string representation is
     * less than or equal to `Options.CharThreshold`, that object is represented as a single line.
     * If an object's string representation is greater than `Options.CharThreshold`, that object
     * is represented with a line break separating each value. The calculation does not include
     * indentation and end of line characters.
     *
     * This value applies to all object types and all map key-value pairs, unless the individual
     * threshold options is set. The individual options supercede this option.
     * @param {Integer} [Options.CharThresholdArray] - If set, and if an array's string representation is
     * less than or equal to `Options.CharThresholdArray`, that array is represented as a single line.
     * If an array's string representation is greater than `Options.CharThresholdArray`, that array
     * is represented with a line break separating each value. The calculation does not include
     * indentation and end of line characters.
     * @param {Integer} [Options.CharThresholdMap] - If set, and if an Map's string representation is
     * less than or equal to `Options.CharThresholdMap`, that Map is represented as a single line.
     * If an Map's string representation is greater than `Options.CharThresholdMap`, that Map
     * is represented with a line break separating each value. The calculation does not include
     * indentation and end of line characters.
     * @param {Integer} [Options.CharThresholdObject] - If set, and if an Object's string representation is
     * less than or equal to `Options.CharThresholdObject`, that Object is represented as a single line.
     * If an Object's string representation is greater than `Options.CharThresholdObject`, that Object
     * is represented with a line break separating each value. The calculation does not include
     * indentation and end of line characters.
     * @param {String} [Options.Eol = "`n"] - The end of line character(s) to use when building
     * the JSON string.
     * @param {String} [Options.IndentChar = "`s"] - The character used for indentation.
     * @param {Integer} [Options.IndentLen = 2] - The number of `Options.IndentChar` to use for one
     * level of indentation.
     *
     * @example
     * obj := {
     *     Map: Map("obj", { prop: "val" }, "arr", [ "val" ], "map", Map("key", "val"))
     *   , Array: [ { prop: "val", }, Map("key", "val"), [ "val" ] ]
     *   , Object: { obj: { prop: "val" }, map: Map("key", "val"), arr: [ "val" ] }
     * }
     * strfy := PrettyStringify2()
     * strfy(obj, &str)
     * OutputDebug(str "`n")
     * @
     */
    __New(Options?) {
        options := PrettyStringify2.Options(Options ?? unset)
        this.Eol := options.Eol
        this.Indent := PrettyStringify2_IndentHelper(options.IndentLen, options.IndentChar)
        if IsNumber(options.CharThreshold) {
            this.CharThresholdArray := IsNumber(options.CharThresholdArray) ? options.CharThresholdArray : options.CharThreshold
            this.CharThresholdMap := IsNumber(options.CharThresholdMap) ? options.CharThresholdMap : options.CharThreshold
            this.CharThresholdObject := IsNumber(options.CharThresholdObject) ? options.CharThresholdObject : options.CharThreshold
        } else {
            if IsNumber(options.CharThresholdArray) {
                this.CharThresholdArray := options.CharThresholdArray
            }
            if IsNumber(options.CharThresholdMap) {
                this.CharThresholdMap := options.CharThresholdMap
            }
            if IsNumber(options.CharThresholdObject) {
                this.CharThresholdObject := options.CharThresholdObject
            }
        }
        this.MaxDepth := options.MaxDepth
    }

    /**
     * @param {*} Obj - The object to stringify.
     * @param {VarRef} OutStr - The variable that will receive the JSON string.
     * @param {Integer} [InitialIndent = 0] - The initial indentation level. All lines except the
     * first line (the opening brace) will minimally have this indentation level. The reason the first
     * line does not is to make it easier to use the output as a value in another JSON string.
     * @param {Integer} [ApproxGreatestDepth = 10] - `ApproxGreatestDepth` is used to approximate
     * the size of each substring to avoid needing to frequently expand the string.
     */
    Call(Obj, &OutStr, InitialIndent := 0, ApproxGreatestDepth := 10) {
        OutStr := ''
        VarSetStrCapacity(&OutStr, 64 * 2 ** ApproxGreatestDepth)
        eol := this.Eol
        ind := this.Indent
        thresholdArray := this.CharThresholdArray
        thresholdMap := this.CharThresholdMap
        thresholdObject := this.CharThresholdObject
        lenInd := StrLen(ind[1])
        lenEol := StrLen(eol)
        ws := depth := 0
        _Proc(Obj, InitialIndent, &OutStr)
        OutStr := RegExReplace(OutStr, ' +(?=\n|$)', '')
        VarSetStrCapacity(&OutStr, -1)

        return

        _Proc(Obj, indent, &str) {
            depth++
            c := s := ''
            VarSetStrCapacity(&s, 64 * 2 ** (ApproxGreatestDepth - depth))
            switch Obj.__Class {
                case 'Array':
                    if Obj.Length {
                        _ws := ws
                        s .= '[ '
                        indent++
                        for val in Obj {
                            if IsSet(val) {
                                if IsObject(val) {
                                    s .= c eol ind[indent]
                                    _Proc(val, indent, &s)
                                } else if IsNumber(val) {
                                    s .= c eol ind[indent] val
                                } else {
                                    s .= c eol ind[indent] '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(val, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
                                }
                            } else {
                                s .= c eol ind[indent] 'null'
                            }
                            ws += lenInd * indent + lenEol
                            c := ', '
                        }
                        indent--
                        if StrLen(s) - ws + _ws + 1 <= thresholdArray {
                            ws := _ws
                            str .= RegExReplace(s, '\R *(?![\]}])', '') ' ]'
                        } else {
                            str .= s eol ind[indent] ']'
                        }
                    } else {
                        str .= '[]'
                    }
                case 'Map':
                    if Obj.Count {
                        _ws := ws
                        s .= '{ '
                        indent++
                        for key, val in Obj {
                            if IsObject(key) {
                                if key.HasOwnProp('Prototype') {
                                    s .= eol ind[indent] '"{ ' key.__Class ' : ' key.Prototype.__Class ' }": '
                                } else if key.HasOwnProp('__Class') {
                                    s .= eol ind[indent] '"{ Prototype : ' key.__Class ' }": '
                                } else {
                                    s .= eol ind[indent] '"{ ' key.__Class ' }": '
                                }
                            } else if IsNumber(key) {
                                s .= eol ind[indent] '"' key '": '
                            } else {
                                s .= eol ind[indent] '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(key, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '": '
                            }
                            ws += lenInd * indent + lenEol
                            c := ', '
                            if IsObject(val) {
                                _Proc(val, indent, &s)
                            } else if IsNumber(val) {
                                s .= val
                            } else {
                                s .= '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(val, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
                            }
                        }
                        indent--
                        if StrLen(s) - ws + _ws + 1 <= thresholdMap {
                            ws := _ws
                            str .= RegExReplace(s, '\R *(?![\]}])', '') ' }'
                        } else {
                            str .= s eol ind[indent] '}'
                        }
                    } else {
                        str .= '{}'
                        indent--
                    }
                default:
                    if ObjOwnPropCount(Obj) {
                        _ws := ws
                        s .= '{ '
                        indent++
                        for prop, val in Obj.OwnProps() {
                            s .= c eol ind[indent] '"' prop '": '
                            ws += lenInd * indent + lenEol
                            c := ', '
                            if IsObject(val) {
                                _Proc(val, indent, &s)
                            } else if IsNumber(val) {
                                s .= val
                            } else {
                                s .= '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(val, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
                            }
                        }
                        indent--
                        if StrLen(s) - ws + _ws + 1 <= thresholdObject {
                            ws := _ws
                            str .= RegExReplace(s, '\R *(?![\]}])', '') ' }'
                        } else {
                            str .= s eol ind[indent] '}'
                        }
                    } else {
                        str .= '{}'
                        indent--
                    }
            }
            depth--
        }
    }
    class Options {
        static __New() {
            this.DeleteProp('__New')
            proto := this.Prototype
            proto.CharThreshold := 200
            proto.Eol := '`n'
            proto.IndentChar := '`s'
            proto.IndentLen := 2
            proto.MaxDepth := 4294967295
            proto.CharThresholdArray :=
            proto.CharThresholdMap :=
            proto.CharThresholdObject :=
            ''
        }

        __New(options?) {
            if IsSet(options) {
                for prop in PrettyStringify2.Options.Prototype.OwnProps() {
                    if HasProp(options, prop) {
                        this.%prop% := options.%prop%
                    }
                }
                if this.HasOwnProp('__Class') {
                    this.DeleteProp('__Class')
                }
            }
        }
    }

}

class PrettyStringify2_IndentHelper extends Array {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.__IndentLen := ''
        proto.DefineProp('ItemHelper', { Call: Array.Prototype.GetOwnPropDesc('__Item').Get })
    }
    __New(IndentLen, IndentChar := '`s') {
        this.__IndentChar := IndentChar
        this.SetIndentLen(IndentLen)
    }
    Expand(Index) {
        s := this[1]
        loop Index - this.Length {
            this.Push(this[-1] s)
        }
    }
    Initialize() {
        c := this.__IndentChar
        this.Length := 1
        s := ''
        loop this.__IndentLen {
            s .= c
        }
        this[1] := s
        this.Expand(4)
    }
    SetIndentChar(IndentChar) {
        this.__IndentChar := IndentChar
        this.Initialize()
    }
    SetIndentLen(IndentLen) {
        this.__IndentLen := IndentLen
        this.Initialize()
    }

    __Item[Index] {
        Get {
            if Index {
                if Abs(Index) > this.Length {
                    this.Expand(Abs(Index))
                }
                return this.ItemHelper(Index)
            } else {
                return ''
            }
        }
    }
    IndentChar {
        Get => this.__IndentChar
        Set => this.SetIndentChar(Value)
    }
    IndentLen {
        Get => this.__IndentLen
        Set => this.SetIndentLen(Value)
    }
}
