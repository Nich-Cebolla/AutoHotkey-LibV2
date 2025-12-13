/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/tree/main/stringify
    Author: Nich-Cebolla
    License: MIT
*/

class PrettyStringifyProps4 {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.CharThresholdArray :=
        proto.CharThresholdMap :=
        proto.CharThresholdObject :=
        4294967295
    }
    /**
     * @description - Creates the function object. This function converts an object to a string
     * representation of an AHK object. The string can be used as AHK code to reproduce the object.
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
     * This function also includes an option to provide a callback function that returns a list of
     * property names to stringify. This enables your code to stringify inherited properties, which
     * are otherwise invisible to `QuickStringify` and `PrettyStringify`.
     *
     * The example code yields the following output:
     * <pre>
     * {
     *   Array: [ { prop: "val" }, { key: "val" }, [ "val" ] ],
     *   Object: { arr: [ "val" ], map: { key: "val" }, obj: { prop: val } },
     *   Map: { arr: [ "val" ], map: { key: "val" }, obj: { prop: "val" } }
     * }
     * </pre>
     *
     * - Map objects are represented as `{ key: val }`. The keys must be valid as AHK property names,
     *   or an error occurs.
     * - This does not work with objects that inherit from `ComValue`.
     * - This does not check for reference cycles.
     * - For Array and Map objects, only the enumerator is processed.
     * - For Map objects and other object types, if `Options.CallbackProps` returns an array, only the
     *   properties/keys in the array are processed. If `Options.CallbackProps` returns zero or an empty
     *   string, for objects only the own properties are processed, for maps the enumerator is processed.
     *   If `Options.CallbackProps` returns `-1`, the object is skipped (it is represented as an empty
     *   object).
     * - Unset array indices are represented as *null* JSON value.
     *
     * @param {Object} [Options] - An object with options as property : value pairs.
     * @param {*} [Options.CallbackProps = (*) => ""] - A `Func` or callable object that returns a
     * list of property names to include in the JSON string. `Array` and `Map` objects do not get
     * passed to the function; their properties are never processed.
     *
     * Parameters:
     * 1. The object being processed.
     *
     * Returns **{String[]|Integer}**
     * - If the function returns an array, an array of property names or keys as strings. Those properties
     *   will be the only properties processed for that object.
     * - If the function returns zero or an empty string, for objects only the own properties are
     *   processed, for maps the enumerator is processed.
     * - If the function returns `-1`, the object is skipped completely (it is represented as an empty
     *   object).
     *   - Arrays: "[]"
     *   - Maps: "{}"
     *   - Others: "{}"
     *
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
     * @param {Integer} [Options.IndentLen = 4] - The number of `Options.IndentChar` to use for one
     * level of indentation.
     * @param {String} [Options.Quote = "`""] - The qoute character to use for quoted strings.
     *
     * @example
     * class MyClass {
     *     __New(param) {
     *         this.param := param
     *     }
     *     Array => [ { prop: "val" }, Map("key", "val"), [ "val" ] ]
     *     Object => { obj: { prop: "val" }, map: Map("key", "val"), arr: [ "val" ] }
     *     Map => Map("obj", { prop: "val" }, "map", Map("key", "val"), "arr", [ "val" ])
     * }
     *
     * CallbackProps(obj) {
     *     switch obj.__Class {
     *         case "MyClass": return [ "Array", "Object", "Map" ]
     *     }
     * }
     * obj := MyClass("value")
     * strfy := PrettyStringifyProps4({ CallbackProps: CallbackProps })
     * strfy(obj, &str)
     * OutputDebug(str "`n")
     * @
     */
    __New(Options?) {
        options := PrettyStringifyProps4.Options(Options ?? unset)
        this.Eol := options.Eol
        this.Indent := PrettyStringifyProps4_IndentHelper(options.IndentLen, options.IndentChar)
        this.Quote := options.Quote
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
        this.CallbackProps := options.CallbackProps
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
        CallbackProps := this.CallbackProps
        q := this.Quote
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
                                    s .= c eol ind[indent] q StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(val, '``', '````'), '`n', '``n'), '`r', '``r'), q, '``' q), '`t', '``t') q
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
                    value := CallbackProps(Obj)
                    if IsObject(value) && Obj.Count {
                        _ws := ws
                        s .= '{ '
                        indent++
                        for key in value {
                            if Obj.Has(key) {
                                s .= c eol ind[indent] key ': '
                                ws += lenInd * indent + lenEol
                                c := ', '
                                val := Obj.Get(key)
                                if IsObject(val) {
                                    _Proc(val, indent, &s)
                                } else if IsNumber(val) {
                                    s .= val
                                } else {
                                    s .= q StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(val, '``', '````'), '`n', '``n'), '`r', '``r'), q, '``' q), '`t', '``t') q
                                }
                            }
                        }
                        indent--
                        if StrLen(s) - ws + _ws + 1 <= thresholdMap {
                            ws := _ws
                            str .= RegExReplace(s, '\R *(?![\]}])', '') ' }'
                        } else {
                            str .= s eol ind[indent] '}'
                        }
                    } else if !value && Obj.Count {
                        _ws := ws
                        s .= '{ '
                        indent++
                        for key, val in Obj {
                            s .= c eol ind[indent] key ': '
                            ws += lenInd * indent + lenEol
                            c := ', '
                            if IsObject(val) {
                                _Proc(val, indent, &s)
                            } else if IsNumber(val) {
                                s .= val
                            } else {
                                s .= q StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(val, '``', '````'), '`n', '``n'), '`r', '``r'), q, '``' q), '`t', '``t') q
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
                    }
                default:
                    value := CallbackProps(Obj)
                    if IsObject(value) && ObjOwnPropcount(Obj) {
                        _ws := ws
                        s .= '{ '
                        indent++
                        for prop in value {
                            if HasProp(Obj, prop) {
                                s .= c eol ind[indent] prop ': '
                                ws += lenInd * indent + lenEol
                                c := ', '
                                val := Obj.%prop%
                                if IsObject(val) {
                                    _Proc(val, indent, &s)
                                } else if IsNumber(val) {
                                    s .= val
                                } else {
                                    s .= q StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(val, '``', '````'), '`n', '``n'), '`r', '``r'), q, '``' q), '`t', '``t') q
                                }
                            }
                        }
                        indent--
                        if StrLen(s) - ws + _ws + 1 <= thresholdObject {
                            ws := _ws
                            str .= RegExReplace(s, '\R *(?![\]}])', '') ' }'
                        } else {
                            str .= s eol ind[indent] '}'
                        }
                    } else if !value && ObjOwnPropcount(Obj) {
                        _ws := ws
                        s .= '{ '
                        indent++
                        for prop, val in Obj.OwnProps() {
                            s .= c eol ind[indent] prop ': '
                            ws += lenInd * indent + lenEol
                            c := ', '
                            if IsObject(val) {
                                _Proc(val, indent, &s)
                            } else if IsNumber(val) {
                                s .= val
                            } else {
                                s .= q StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(val, '``', '````'), '`n', '``n'), '`r', '``r'), q, '``' q), '`t', '``t') q
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
                    }
            }
            depth--
        }
    }
    class Options {
        static __New() {
            this.DeleteProp('__New')
            proto := this.Prototype
            proto.CallbackProps := (*) => ''
            proto.CharThreshold := 200
            proto.Eol := '`n'
            proto.Quote := '"'
            proto.IndentChar := '`s'
            proto.IndentLen := 4
            proto.CharThresholdArray :=
            proto.CharThresholdMap :=
            proto.CharThresholdObject :=
            ''
        }

        __New(options?) {
            if IsSet(options) {
                for prop in PrettyStringifyProps4.Options.Prototype.OwnProps() {
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

class PrettyStringifyProps4_IndentHelper extends Array {
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
