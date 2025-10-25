/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/PathObj.ahk
    Author: Nich-Cebolla
    Version: 1.1.2
    License: MIT
*/

/**
 * @classdesc - This is a solution for tracking object paths using strings.
 * @example
 *  ; Say we are processing this object and need to keep track of the object path somehow.
 *  Obj := {
 *      Prop1: {
 *          NestedProp1: {
 *              NestedMap: Map(
 *                  'Key1 `r`n"`t``', Map(
 *                      'Key2', 'Val1'
 *                  )
 *              )
 *          }
 *        , NestedProp2: [ 1, 2, { Prop: 'Val' }, 4 ]
 *      }
 *  }
 *  ; Get an instance of `PathObj`
 *  Root := PathObj('Obj')
 *  ; Process the properties / items
 *  O1 := Root.MakeProp('Prop1')
 *  O2 := O1.MakeProp('NestedProp1')
 *  O3 := O2.MakeProp('NestedMap')
 *  O4 := O3.MakeItem('Key1 `r`n"`t``')
 *  O5 := O4.MakeItem('Key2')
 *
 *  ; Calling the object produces a path that will apply AHK escape sequences using the backtick as needed.
 *  OutputDebug(O5() '`n') ; Obj.Prop1.NestedProp1.NestedMap["Key1 `r`n`"`t``"]["Key2"]
 *
 *  ; You can start another branch
 *  B1 := O1.MakeProp('NestedProp2')
 *  B2 := B1.MakeItem(3)
 *  B3 := B2.MakeProp('Prop')
 *  OutputDebug(B3() '`n') ; Obj.Prop1.NestedProp2[3].Prop
 *
 *  ; Some operations don't benefit from having the keys escaped. Save processing time by calling
 *  ; the "Unescaped" method.
 *  OutputDebug(O5.Unescaped() '`n')
 *  ; Obj.Prop1.NestedProp1.NestedMap["Key1
 *  ; "	   `"]["Key2"]
 *
 *  ; Normally you would use `PathObj` in some type of recursive loop.
 *  Recurse(obj, PathObj('obj'))
 *  Recurse(obj, path) {
 *      OutputDebug(path() '`n')
 *      for p, v in obj.OwnProps() {
 *          if IsObject(v) {
 *              Recurse(v, path.MakeProp(p))
 *          }
 *      }
 *      if HasMethod(obj, '__Enum') {
 *          for k, v in obj {
 *              if IsObject(v) {
 *                  Recurse(v, path.MakeItem(k))
 *              }
 *          }
 *      }
 *  }
 * @
 */
class PathObj {
    static InitialBufferSize := 256
    static __New() {
        this.DeleteProp('__New')
        PathObj_SetConstants()
        proto := this.Prototype
        proto.propdesc := this.Prototype.GetOwnPropDesc('__GetPathSegmentProp_U')
        proto.Type := PATHOBJ_TYPE_ROOT
    }
    /**
     * An instance of `PathObj` should be used as the root object of the path is being constructed.
     * All child segments should be created by calling `PathObj.Prototype.MakeProp` or
     * `PathObj.Prototype.MakeItem`.
     *
     * @param {String} [Name = "$"] - The name to assign the object.
     * @param {Boolean} [EscapePropNames = false] - If true, calling `PathObj.Prototype.Call` will
     * apply AHK escape sequences to property names using the backtick where appropriate. In AHK
     * syntax, there are no characters which have AHK escape sequences that can be used within a
     * property name, and so this should generally be left `false` to save processing time.
     * `PathObj.Prototype.Unescaped` is unaffected by this option.
     * @param {String} [QuoteChar = "`""] - The quote character to use for item keys.
     */
    __New(Name := '$', EscapePropNames := false, QuoteChar := '"') {
        static desc := PathObj.Prototype.GetOwnPropDesc('__GetPathSegmentRoot1')
        , desc_u := PathObj.Prototype.GetOwnPropDesc('__GetPathSegmentRoot_U')
        , propdesc := PathObj.Prototype.GetOwnPropDesc('__GetPathSegmentProp1')
        this.Name := Name
        this.QuoteChar := QuoteChar
        this.DefineProp('GetPathSegment', desc)
        this.DefineProp('GetPathSegment_U', desc_u)
        if EscapePropNames {
            this.DefineProp('propdesc', { Value: propdesc })
        }
        this.Index := 1
    }
    Call(*) {
        if !this.HasOwnProp('__Path') {
            o := this
            buf := Buffer(PathObj.InitialBufferSize)
            offset := PathObj.InitialBufferSize - 2
            NumPut('ushort', 0, buf, offset) ; null terminator
            loop {
                if o.GetPathSegment(buf, &offset) {
                    break
                }
                o := o.Base
            }
            this.DefineProp('__Path', { Value: StrGet(buf.Ptr + offset) })
        }
        return this.__Path
    }
    MakeProp(Name) {
        static desc_u := PathObj.Prototype.GetOwnPropDesc('__GetPathSegmentProp_U')
        ObjSetBase(Segment := { Name: Name, Index: this.Index + 1, Type: PATHOBJ_TYPE_PROP }, this)
        Segment.DefineProp('GetPathSegment', this.propdesc)
        Segment.DefineProp('GetPathSegment_U', desc_u)
        return Segment
    }
    MakeItem(Name) {
        static descNumber := PathObj.Prototype.GetOwnPropDesc('__GetPathSegmentItem_Number')
        , descString := PathObj.Prototype.GetOwnPropDesc('__GetPathSegmentItem_String1')
        , descString_u := PathObj.Prototype.GetOwnPropDesc('__GetPathSegmentItem_String_U1')
        ObjSetBase(Segment := { Name: Name, Index: this.Index + 1, Type: PATHOBJ_TYPE_ITEM }, this)
        if IsNumber(Name) {
            Segment.DefineProp('GetPathSegment', descNumber)
            Segment.DefineProp('GetPathSegment_U', descNumber)
        } else {
            Segment.DefineProp('GetPathSegment', descString)
            Segment.DefineProp('GetPathSegment_U', descString_u)
        }
        return Segment
    }
    Unescaped(*) {
        if !this.HasOwnProp('__Path_U') {
            o := this
            buf := Buffer(PathObj.InitialBufferSize)
            offset := PathObj.InitialBufferSize - 2
            NumPut('ushort', 0, buf, offset) ; null terminator
            loop {
                if o.GetPathSegment_U(buf, &offset) {
                    break
                }
                o := o.Base
            }
            this.DefineProp('__Path_U', { Value: StrGet(buf.Ptr + offset) })
        }
        return this.__Path_U
    }
    __GetPathSegmentItem_Number(buf, &offset) {
        bytes := StrPut(this.Name) + 2 ; -2 for null terminator, then +4 for the brackets
        if bytes > offset {
            count := buf.Size - offset
            while bytes > offset {
                PathObj.InitialBufferSize *= 2
                buf.Size *= 2
                DllCall(
                    g_msvcrt_memmove
                  , 'ptr', buf.Ptr + buf.Size - count
                  , 'ptr', buf.Ptr + offset
                  , 'int', count
                  , 'ptr'
                )
                offset := buf.Size - count
            }
        }
        offset -= bytes
        StrPut('[' this.Name ']', buf.Ptr + offset, bytes / 2)
    }

    ;@region Escaped
    __GetPathSegmentItem_String1(buf, &offset) {
        static desc2 := PathObj.Prototype.GetOwnPropDesc('__GetPathSegmentItem_String2')
        this.DefineProp('NameEscaped', { Value: StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(this.Name, '``', '````'), '`n', '``n'), '`r', '``r'), this.QuoteChar, '``' this.QuoteChar), '`t', '``t') })
        this.DefineProp('GetPathSegment', desc2)
        this.GetPathSegment(buf, &offset)
    }
    __GetPathSegmentItem_String2(buf, &offset) {
        bytes := StrPut(this.NameEscaped) + 6 ; -2 for null terminator, then +4 for the brackets and +4 for the quotes
        if bytes > offset {
            count := buf.Size - offset
            while bytes > offset {
                PathObj.InitialBufferSize *= 2
                buf.Size *= 2
                DllCall(
                    g_msvcrt_memmove
                  , 'ptr', buf.Ptr + buf.Size - count
                  , 'ptr', buf.Ptr + offset
                  , 'int', count
                  , 'ptr'
                )
                offset := buf.Size - count
            }
        }
        offset -= bytes
        StrPut('[' this.QuoteChar this.NameEscaped this.QuoteChar ']', buf.Ptr + offset, bytes / 2)
    }
    __GetPathSegmentProp1(buf, &offset) {
        static desc2 := PathObj.Prototype.GetOwnPropDesc('__GetPathSegmentProp2')
        this.DefineProp('NameEscaped', { Value: StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(this.Name, '``', '````'), '`n', '``n'), '`r', '``r'), this.QuoteChar, '``' this.QuoteChar), '`t', '``t') })
        this.DefineProp('GetPathSegment', desc2)
        this.GetPathSegment(buf, &offset)
    }
    __GetPathSegmentProp2(buf, &offset) {
        bytes := StrPut(this.NameEscaped) ; -2 for null terminator, then +2 for the period
        if bytes > offset {
            count := buf.Size - offset
            while bytes > offset {
                PathObj.InitialBufferSize *= 2
                buf.Size *= 2
                DllCall(
                    g_msvcrt_memmove
                  , 'ptr', buf.Ptr + buf.Size - count
                  , 'ptr', buf.Ptr + offset
                  , 'int', count
                  , 'ptr'
                )
                offset := buf.Size - count
            }
        }
        offset -= bytes
        StrPut('.' this.NameEscaped, buf.Ptr + offset, bytes / 2)
    }
    __GetPathSegmentRoot1(buf, &offset) {
        static desc2 := PathObj.Prototype.GetOwnPropDesc('__GetPathSegmentRoot2')
        this.DefineProp('NameEscaped', { Value: StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(this.Name, '``', '````'), '`n', '``n'), '`r', '``r'), this.QuoteChar, '``' this.QuoteChar), '`t', '``t') })
        this.DefineProp('GetPathSegment', desc2)
        return this.GetPathSegment(buf, &offset)
    }
    __GetPathSegmentRoot2(buf, &offset) {
        bytes := StrPut(this.NameEscaped) - 2 ; -2 for null terminator
        if bytes > offset {
            count := buf.Size - offset
            while bytes > offset {
                PathObj.InitialBufferSize *= 2
                buf.Size *= 2
                DllCall(
                    g_msvcrt_memmove
                  , 'ptr', buf.Ptr + buf.Size - count
                  , 'ptr', buf.Ptr + offset
                  , 'int', count
                  , 'ptr'
                )
                offset := buf.Size - count
            }
        }
        offset -= bytes
        StrPut(this.NameEscaped, buf.Ptr + offset, bytes / 2)
        return 1
    }
    ;@endregion

    ;@region Unescaped
    __GetPathSegmentItem_String_U1(buf, &offset) {
        static desc2 := PathObj.Prototype.GetOwnPropDesc('__GetPathSegmentItem_String_U2')
        this.DefineProp('__NamePartialEscaped', { Value: StrReplace(this.Name, this.QuoteChar, '``' this.QuoteChar) })
        this.DefineProp('GetPathSegment', desc2)
        this.GetPathSegment(buf, &offset)
    }
    __GetPathSegmentItem_String_U2(buf, &offset) {
        bytes := StrPut(this.__NamePartialEscaped) + 6 ; -2 for null terminator, then +4 for the brackets and +4 for the quotes
        if bytes > offset {
            count := buf.Size - offset
            while bytes > offset {
                PathObj.InitialBufferSize *= 2
                buf.Size *= 2
                DllCall(
                    g_msvcrt_memmove
                  , 'ptr', buf.Ptr + buf.Size - count
                  , 'ptr', buf.Ptr + offset
                  , 'int', count
                  , 'ptr'
                )
                offset := buf.Size - count
            }
        }
        offset -= bytes
        StrPut('[' this.QuoteChar this.__NamePartialEscaped this.QuoteChar ']', buf.Ptr + offset, bytes / 2)
    }
    __GetPathSegmentProp_U(buf, &offset) {
        bytes := StrPut(this.Name) ; -2 for null terminator, then +2 for the period
        if bytes > offset {
            count := buf.Size - offset
            while bytes > offset {
                PathObj.InitialBufferSize *= 2
                buf.Size *= 2
                DllCall(
                    g_msvcrt_memmove
                  , 'ptr', buf.Ptr + buf.Size - count
                  , 'ptr', buf.Ptr + offset
                  , 'int', count
                  , 'ptr'
                )
                offset := buf.Size - count
            }
        }
        offset -= bytes
        StrPut('.' this.Name, buf.Ptr + offset, bytes / 2)
    }
    __GetPathSegmentRoot_U(buf, &offset) {
        bytes := StrPut(this.Name) - 2 ; -2 for null terminator
        if bytes > offset {
            count := buf.Size - offset
            while bytes > offset {
                PathObj.InitialBufferSize *= 2
                buf.Size *= 2
                DllCall(
                    g_msvcrt_memmove
                  , 'ptr', buf.Ptr + buf.Size - count
                  , 'ptr', buf.Ptr + offset
                  , 'int', count
                  , 'ptr'
                )
                offset := buf.Size - count
            }
        }
        offset -= bytes
        StrPut(this.Name, buf.Ptr + offset, bytes / 2)
        return 1
    }
    ;@endregion

    Path => this()
    PathUnescaped => this.Unescaped()
}

PathObj_SetConstants(force := false) {
    global
    if !force && IsSet(g_PathObj_constants_set) {
        return
    }
    local hModule := DllCall('LoadLibrary', 'Str', 'msvcrt.dll', 'Ptr')
    g_msvcrt_memmove := DllCall('GetProcAddress', 'Ptr', hModule, 'AStr', 'memmove', 'Ptr')

    local i := 0
    PATHOBJ_TYPE_ITEM := ++i
    PATHOBJ_TYPE_PROP := ++i
    PATHOBJ_TYPE_ROOT := ++i
    PATHOBJ_TYPE_END := i

    g_PathObj_constants_set := 1
}
