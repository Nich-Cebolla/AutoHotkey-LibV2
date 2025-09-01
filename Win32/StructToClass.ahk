
; https://github.com/Nich-Cebolla/ParseCsv-AutoHotkey/blob/main/ParseWin32HeaderFile.ahk
#include ..\ParseWin32HeaderFile.ahk
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Win32/MakeTable.ahk
#include ..\MakeTable.ahk

; Copy a structure to the clipboard then run this file and the clipboard will be replaced
; with the class (assuming the function succeeds).
if A_LineFile == A_ScriptFullPath {
    A_Clipboard := StructToClass()
}

/**
 * This is not fully tested.
 *
 * `StructToClass` is intended to be a helper for programmatically converting a struct definition
 * into an AHK class. The output is not guaranteed to be correct, and should be visually inspected.
 *
 * If the structure has one or more members that is a structure, the output will only be partially
 * complete. It will still be usable, but the offsets will need to be filled in manually. You can
 * overcome this limitation by manually replacing the internal structure with its members, like this:
 *
 * ```
 * typedef struct tagDRAWITEMSTRUCT {
 *   UINT      CtlType;
 *   UINT      CtlID;
 *   UINT      itemID;
 *   UINT      itemAction;
 *   UINT      itemState;
 *   HWND      hwndItem;
 *   HDC       hDC;
 *   RECT      rcItem;
 *   ULONG_PTR itemData;
 * } DRAWITEMSTRUCT, *PDRAWITEMSTRUCT, *LPDRAWITEMSTRUCT;
 * ```
 *
 * Change the above to:
 * ```
 * typedef struct tagDRAWITEMSTRUCT {
 *   UINT      CtlType;
 *   UINT      CtlID;
 *   UINT      itemID;
 *   UINT      itemAction;
 *   UINT      itemState;
 *   HWND      hwndItem;
 *   HDC       hDC;
 *   INT       left;
 *   INT       top;
 *   INT       right;
 *   INT       bottom;
 *   ULONG_PTR itemData;
 * } DRAWITEMSTRUCT, *PDRAWITEMSTRUCT, *LPDRAWITEMSTRUCT;
 * ```
 *
 * The first string will result in a partially formed class that has placeholders where offset /
 * size values should be. The second string will be fully formed.
 *
 * I want to emphasize the point that this is not guaranteed to produce correct output, but the
 * output will be nonetheless useful for quickly creating a class definition from a structure
 * definition in a win32 header file or a structure definition from learn.microsoft.com.
 *
 */
class StructToClass {
    static __New() {
        this.DeleteProp('__New')
        this.DefaultOptions := {
            Encoding: ''
          , LineEnding: '`n'
          , Indent: 4
          , InitialIndent: 0
          , Quote: '`''
        }
        this.MakeTableOpt := {
            AddHeaderSeparator: false
          , ColumnPadding: ''
          , InputColumnSeparator: '`t'
          , InputRowSeparator: '\R'
        ;   , LinePrefix: ''
          , LineSuffix: ''
          , MaxWidths: ''
          , OutputColumnSeparator: ''
          , OutputLineBetweenRows: false
        ;   , OutputRowSeparator: '`n'
          , TrimCharacters: ''
        }
    }
    static Call(Name?, Str?, Path?, Options?) {
        opt := StructToClass.DefaultOptions.Clone()
        if IsSet(Options) {
            for prop, val in Options.OwnProps() {
                opt.%prop% := val
            }
        }
        parsed := ParseWinuserHeaderFile(Str ?? unset, Path ?? unset, opt.Encoding || unset)
        s := ''
        le := opt.LineEnding
        initialIndent := opt.InitialIndent
        indent := opt.Indent
        q := opt.Quote
        makeTableOpt := this.MakeTableOpt
        makeTableOpt.LinePrefix := ind(2)
        makeTableOpt.OutputRowSeparator := le
        tableHeaders := '; Size`tType`tSymbol`tOffset`tPadding'
        if IsSet(Name) {
            for struct in parsed.Structs {
                if (SubStr(struct.Symbol, 1, 3) = 'tag' && SubStr(struct.Symbol, 4) = Name) || struct.Symbol = Name {
                    _Proc(struct)
                }
            }
        } else {
            for struct in parsed.Structs {
                _Proc(struct)
            }
        }

        return s

        _Proc(struct) {
            membersStr := tableHeaders '`n'
            members := struct.Members
            params := ''
            body := ''
            properties := ''
            offsets := ''
            if struct.CalculateOffsets() {
                ; couldn't calculate offsets
                loop members.Length - 1 {
                    member := members[A_Index]
                    membersStr .= member.Size ' + `t; ' member.Type '    `t' member.Symbol '    `t0`t`n'
                    _ProcessMember1(member)
                    offsets .= ind(2) 'proto.offset_' member.Symbol ' := 00' le
                }
                member := members[-1]
                membersStr .= member.Size ' `t; ' member.Type '    `t' member.Symbol '    `t0`t`n'
                _ProcessMember2(member)
                offsets .= ind(2) 'proto.offset_' member.Symbol ' := 00' le
            } else {
                ; all offsets were calculated
                loop members.Length - 1 {
                    member := members[A_Index]
                    membersStr .= member.EffectiveSize ' + `t; ' member.Type '    `t' member.Symbol '    `t' member.Offset '    `t' member.Padding '`n'
                    _ProcessMember1(member)
                    offsets .= ind(2) 'proto.offset_' member.Symbol ' := ' member.Offset le
                }
                member := members[-1]
                membersStr .= member.EffectiveSize ' `t; ' member.Type '    `t' member.Symbol '    `t' member.Offset '    `t' member.Padding '`n'
                _ProcessMember2(member)
                offsets .= ind(2) 'proto.offset_' member.Symbol ' := ' member.Offset le
            }
            s .= (
                ind(0) 'class ' RegExReplace(struct.Symbol, '^tag', '') ' {' le
                ind(1) 'static __New() {' le
                ind(2) 'this.DeleteProp(' q '__New' q ')' le
                ind(2) 'proto := this.Prototype' le
                ind(2) 'proto.cbSize := ' le
                MakeTable(SubStr(membersStr, 1, -1), makeTableOpt) le
                offsets
                ind(1) '}' le
                ind(1) '__New(' params ') {' le
                ind(2) 'this.Buffer := Buffer(this.cbSize)' le
                body
                ind(1) '}' le
                properties
                ind(1) 'Ptr => this.Buffer.Ptr' le
                ind(1) 'Size => this.Buffer.Size' le
                ind(0) '}' le
            )

            return

            _ProcessMember1(member) {
                params .= member.Symbol '?, '
                _ProcessMember3(member)
            }
            _ProcessMember2(member) {
                params .= member.Symbol '?'
                _ProcessMember3(member)
            }
            _ProcessMember3(member) {
                body .= (
                    ind(2) 'if IsSet(' member.Symbol ') {' le
                    ind(3) 'this.' member.Symbol ' := ' member.Symbol le
                    ind(2) '}' le
                )
                switch member.Type, 0 {
                    case 'LPWSTR', 'LPCWSTR', 'LPCSTR':
                        properties .= (
                            ind(1) member.Symbol ' {' le
                            ; get
                            ind(2) 'Get => StrGet(this.__' member.Symbol ', ' q 'UTF-16' q ')' le
                            ; set
                            ind(2) 'Set {' le
                            ind(3) 'if this.HasOwnProp(' q '__' member.Symbol q ') {' le
                            ind(4) 'bytes := StrPut(Value, ' q 'UTF-16' q ')' le
                            ind(4) 'if this.__' member.Symbol '.Size < bytes {' le
                            ind(5) 'this.__' member.Symbol '.Size := bytes' le
                            ind(5) 'NumPut(' q 'ptr' q ', this.__' member.Symbol '.Ptr, this.Buffer, this.offset_' member.Symbol ')' le
                            ind(4) '}' le
                            ind(3) '} else {' le
                            ind(4) 'this.__' member.Symbol ' := Buffer(StrPut(Value, ' q 'UTF-16' q '))' le
                            ind(4) 'NumPut(' q 'ptr' q ', this.__' member.Symbol '.Ptr, this.Buffer, this.offset_' member.Symbol ')' le
                            ind(3) '}' le
                            ind(3) 'StrPut(Value, this.__' member.Symbol ', ' q 'UTF-16' q ')' le
                            ind(2) '}' le
                            ind(1) '}' le
                        )
                    default:
                        properties .= (
                            ind(1) member.Symbol ' {' le
                            ; get
                            ind(2) 'Get => NumGet(this.Buffer, this.offset_' member.Symbol ', ' q member.AhkType q ')' le
                            ; set
                            ind(2) 'Set {' le
                            ind(3) 'NumPut(' q member.AhkType q ', Value, this.Buffer, this.offset_' member.Symbol ')' le
                            ind(2) '}' le
                            ind(1) '}' le
                        )
                }
            }
        }
        ind(n) {
            return FillStr[(initialIndent + n) * indent]
        }
    }

}
