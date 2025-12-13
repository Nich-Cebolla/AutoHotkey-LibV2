/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/tree/main/stringify
    Author: Nich-Cebolla
    License: MIT
*/

class QuickStringifyProps {
    /**
     * @description - Creates the function object.
     *
     * This function also includes an option to provide a callback function that returns a list of
     * property names to stringify. This enables your code to stringify inherited properties, which
     * are otherwise invisible to `QuickStringify` and `PrettyStringify`.
     *
     * - Map objects are represented as `[["key",val]]`.
     * - This does not work with objects that inherit from `ComValue`.
     * - This does not check for reference cycles.
     * - For Array and Map objects, only the enumerator is processed.
     * - For other object types, if `Options.CallbackProps` returns an array, only the
     *   properties in the array are processed. If `Options.CallbackProps` returns zero or an empty
     *   string, the own properties are processed. If `Options.CallbackProps` returns `-1`, the
     *   object is skipped (it is represented as an empty object).
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
     * - If the function returns an array, an array of property names as strings. Those properties
     *   will be the only properties processed for that object.
     * - If the function returns zero or an empty string, the object's own properties are processed.
     * - If the function returns `-1`, the object is skipped completely (it is represented as an empty
     *   object).
     *   - Arrays: "[]"
     *   - Maps: "[[]]"
     *   - Others: "{}"
     *
     * @param {String} [Options.Eol = "`n"] - The end of line character(s) to use when building
     * the JSON string.
     * @param {String} [Options.IndentChar = "`s"] - The character used for indentation.
     * @param {Integer} [Options.IndentLen = 2] - The number of `Options.IndentChar` to use for one
     * level of indentation.
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
     * strfy := QuickStringifyProps({ CallbackProps: CallbackProps })
     * strfy(obj, &str)
     * OutputDebug(str "`n")
     * @
     *
     * The example code yields the following output:
     * <pre>
     * {
     *   "Array": [
     *     {
     *       "prop": "val"
     *     },
     *     [
     *       [
     *         "key",
     *         "val"
     *       ]
     *     ],
     *     [
     *       "val"
     *     ]
     *   ],
     *   "Object": {
     *     "arr": [
     *       "val"
     *     ],
     *     "map": [
     *       [
     *         "key",
     *         "val"
     *       ]
     *     ],
     *     "obj": {
     *       "prop": "val"
     *     }
     *   },
     *   "Map": [
     *     [
     *       "arr",
     *       [
     *         "val"
     *       ]
     *     ],
     *     [
     *       "map",
     *       [
     *         [
     *           "key",
     *           "val"
     *         ]
     *       ]
     *     ],
     *     [
     *       "obj",
     *       {
     *         "prop": "val"
     *       }
     *     ]
     *   ]
     * }
     * </pre>
     */
    __New(Options?) {
        options := QuickStringifyProps.Options(Options ?? unset)
        this.Eol := options.Eol
        this.Indent := QuickStringifyProps_IndentHelper(options.IndentLen, options.IndentChar)
        this.CallbackProps := options.CallbackProps
    }
    /**
     * @param {*} Obj - The object to stringify.
     * @param {VarRef} OutStr - The variable that will receive the JSON string.
     * @param {Integer} [InitialIndent = 0] - The initial indentation level. All lines except the
     * first line (the opening brace) will minimally have this indentation level. The reason the first
     * line does not is to make it easier to use the output as a value in another JSON string.
     */
    Call(Obj, &OutStr, InitialIndent := 0) {
        OutStr := ''
        VarSetStrCapacity(&OutStr, 65536)
        eol := this.Eol
        ind := this.Indent
        CallbackProps := this.CallbackProps
        _Proc(Obj, InitialIndent)
        VarSetStrCapacity(&OutStr, -1)

        return

        _Proc(Obj, indent) {
            c := ''
            switch Obj.__Class {
                case 'Array':
                    if Obj.Length {
                        OutStr .= '['
                        indent++
                        for val in Obj {
                            if IsSet(val) {
                                if IsObject(val) {
                                    OutStr .= c eol ind[indent]
                                    _Proc(val, indent)
                                } else if IsNumber(val) {
                                    OutStr .= c eol ind[indent] val
                                } else {
                                    OutStr .= c eol ind[indent] '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(val, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
                                }
                            } else {
                                OutStr .= c eol ind[indent] 'null'
                            }
                            c := ','
                        }
                        indent--
                        OutStr .= eol ind[indent] ']'
                    } else {
                        OutStr .= '[]'
                    }
                case 'Map':
                    if Obj.Count {
                        OutStr .= '['
                        indent++
                        for key, val in Obj {
                            OutStr .= c eol ind[indent] '['
                            c := ','
                            indent++
                            if IsObject(key) {
                                if key.HasOwnProp('Prototype') {
                                    OutStr .= eol ind[indent] '"{ ' key.__Class ' : ' key.Prototype.__Class ' }"'
                                } else if key.HasOwnProp('__Class') {
                                    OutStr .= eol ind[indent] '"{ Prototype : ' key.__Class ' }"'
                                } else {
                                    OutStr .= eol ind[indent] '"{ ' key.__Class ' }"'
                                }
                            } else if IsNumber(key) {
                                OutStr .= eol ind[indent] key
                            } else {
                                OutStr .= eol ind[indent] '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(key, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
                            }
                            if IsObject(val) {
                                OutStr .= ',' eol ind[indent]
                                _Proc(val, indent)
                            } else if IsNumber(val) {
                                OutStr .= ',' eol ind[indent] val
                            } else {
                                OutStr .= ',' eol ind[indent] '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(val, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
                            }
                            indent--
                            OutStr .= eol ind[indent] ']'
                        }
                        indent--
                        OutStr .= eol ind[indent] ']'
                    } else {
                        OutStr .= '[[]]'
                    }
                default:
                    value := CallbackProps(Obj)
                    if IsObject(value) {
                        OutStr .= '{'
                        indent++
                        for prop in value {
                            if HasProp(Obj, prop) {
                                OutStr .= c eol ind[indent] '"' prop '": '
                                c := ','
                                val := Obj.%prop%
                                if IsObject(val) {
                                    _Proc(val, indent)
                                } else if IsNumber(val) {
                                    OutStr .= val
                                } else {
                                    OutStr .= '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(val, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
                                }
                            }
                        }
                        indent--
                        OutStr .= eol ind[indent] '}'
                    } else if !value && ObjOwnPropcount(Obj) {
                        OutStr .= '{'
                        indent++
                        for prop, val in Obj.OwnProps() {
                            OutStr .= c eol ind[indent] '"' prop '": '
                            c := ','
                            if IsObject(val) {
                                _Proc(val, indent)
                            } else if IsNumber(val) {
                                OutStr .= val
                            } else {
                                OutStr .= '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(val, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
                            }
                        }
                        indent--
                        OutStr .= eol ind[indent] '}'
                    } else {
                        OutStr .= '{}'
                    }
            }
        }
    }
    class Options {
        static __New() {
            this.DeleteProp('__New')
            proto := this.Prototype
            proto.CallbackProps := (*) => ''
            proto.Eol := '`n'
            proto.IndentChar := '`s'
            proto.IndentLen := 2
        }

        __New(options?) {
            if IsSet(options) {
                for prop in QuickStringifyProps.Options.Prototype.OwnProps() {
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

class QuickStringifyProps_IndentHelper extends Array {
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
