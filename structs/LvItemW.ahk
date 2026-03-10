
class LvItemW {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.size :=
        ; Size      Type        Symbol        Offset                Padding
        4 +         ; UINT      mask          0
        4 +         ; int       iItem         4
        4 +         ; int       iSubItem      8
        4 +         ; UINT      state         12
        A_PtrSize + ; UINT      stateMask     16                    +4 on x64 only
        A_PtrSize + ; LPWSTR    pszText       16 + A_PtrSize * 1
        4 +         ; int       cchTextMax    16 + A_PtrSize * 2
        4 +         ; int       iImage        20 + A_PtrSize * 2
        A_PtrSize + ; LPARAM    lParam        24 + A_PtrSize * 2
        4 +         ; int       iIndent       24 + A_PtrSize * 3
        4 +         ; int       iGroupId      28 + A_PtrSize * 3
        A_PtrSize + ; UINT      cColumns      32 + A_PtrSize * 3    +4 on x64 only
        A_PtrSize + ; PUINT     puColumns     32 + A_PtrSize * 4
        4 +         ; int       *piColFmt     32 + A_PtrSize * 5
        4           ; int       iGroup        36 + A_PtrSize * 5
        proto.offset_mask        := 0
        proto.offset_iItem       := 4
        proto.offset_iSubItem    := 8
        proto.offset_state       := 12
        proto.offset_stateMask   := 16
        proto.offset_pszText     := 16 + A_PtrSize * 1
        proto.offset_cchTextMax  := 16 + A_PtrSize * 2
        proto.offset_iImage      := 20 + A_PtrSize * 2
        proto.offset_lParam      := 24 + A_PtrSize * 2
        proto.offset_iIndent     := 24 + A_PtrSize * 3
        proto.offset_iGroupId    := 28 + A_PtrSize * 3
        proto.offset_cColumns    := 32 + A_PtrSize * 3
        proto.offset_puColumns   := 32 + A_PtrSize * 4
        proto.offset_piColFmt    := 32 + A_PtrSize * 5
        proto.offset_iGroup      := 36 + A_PtrSize * 5
    }
    /**
     * @classdesc - A wrapper around the
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-lvitemw LVITEMW}
     * structure.
     *
     * Below is an example of how to get an {@link LVITEMW} object from the `lParam` value in a
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nc-commctrl-subclassproc subclass procedure}.
     *
     * `lParam` is a pointer to a
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-nmlvdispinfoa NMLVDISPINFO}
     * structure. NMLVDISPINFO has two members, `hdr` and `item`. The `item` member is the LVITEMW
     * structure.
     *
     * The conditional `if hdr.code_int = -176` is referring to LVN_ENDLABELEDIT for the example, but
     * other notifications use the LVITEMW structure as well, so the same pattern applies, just replace
     * `-176` with whatever notification you are targeting.
     *
     * The class `Nmhdr` seen in the example is defined
     * {@link https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/structs/Nmhdr.ahk here}.
     *
     * @example
     * SubclassProc(HwndSubclass, uMsg, wParam, lParam, uIdSubclass, dwRefData) {
     *     Critical(-1)
     *     switch uMsg {
     *     case 0x004E: ; WM_NOTIFY
     *         hdr := Nmhdr(lParam)
     *         if hdr.code_int = -176 { ; LVN_ENDLABELEDIT
     *             item := LvItemW(hdr.ptr + hdr.size)
     *             ; do work
     *         }
     *     }
     *     return DllCall(
     *         'comctl32\DefSubclassProc'
     *       , 'ptr', HwndSubclass
     *       , 'uint', uMsg
     *       , 'uptr', wParam
     *       , 'ptr', lParam
     *       , 'ptr'
     *     )
     * }
     * @
     */
    __New(ptr) {
        this.ptr := ptr
    }
    mask {
        Get => NumGet(this.ptr, this.offset_mask, 'uint')
        Set {
            NumPut('uint', Value, this.ptr, this.offset_mask)
        }
    }
    iItem {
        Get => NumGet(this.ptr, this.offset_iItem, 'int')
        Set {
            NumPut('int', Value, this.ptr, this.offset_iItem)
        }
    }
    iSubItem {
        Get => NumGet(this.ptr, this.offset_iSubItem, 'int')
        Set {
            NumPut('int', Value, this.ptr, this.offset_iSubItem)
        }
    }
    state {
        Get => NumGet(this.ptr, this.offset_state, 'uint')
        Set {
            NumPut('uint', Value, this.ptr, this.offset_state)
        }
    }
    stateMask {
        Get => NumGet(this.ptr, this.offset_stateMask, 'uint')
        Set {
            NumPut('uint', Value, this.ptr, this.offset_stateMask)
        }
    }
    pszText {
        Get {
            Value := NumGet(this.ptr, this.offset_pszText, 'ptr')
            if Value > 0 {
                return StrGet(Value, 'cp1200')
            } else {
                return Value
            }
        }
        Set {
            if Type(Value) = 'String' {
                if !this.HasOwnProp('__pszText')
                || (this.__pszText is Buffer && this.__pszText.Size < StrPut(Value, 'cp1200')) {
                    this.__pszText := Buffer(StrPut(Value, 'cp1200'))
                    NumPut('ptr', this.__pszText.Ptr, this.ptr, this.offset_pszText)
                }
                StrPut(Value, this.__pszText, 'cp1200')
            } else if Value is Buffer {
                this.__pszText := Value
                NumPut('ptr', this.__pszText.Ptr, this.ptr, this.offset_pszText)
            } else {
                this.__pszText := Value
                NumPut('ptr', this.__pszText, this.ptr, this.offset_pszText)
            }
        }
    }
    cchTextMax {
        Get => NumGet(this.ptr, this.offset_cchTextMax, 'int')
        Set {
            NumPut('int', Value, this.ptr, this.offset_cchTextMax)
        }
    }
    iImage {
        Get => NumGet(this.ptr, this.offset_iImage, 'int')
        Set {
            NumPut('int', Value, this.ptr, this.offset_iImage)
        }
    }
    lParam {
        Get => NumGet(this.ptr, this.offset_lParam, 'ptr')
        Set {
            NumPut('ptr', Value, this.ptr, this.offset_lParam)
        }
    }
    iIndent {
        Get => NumGet(this.ptr, this.offset_iIndent, 'int')
        Set {
            NumPut('int', Value, this.ptr, this.offset_iIndent)
        }
    }
    iGroupId {
        Get => NumGet(this.ptr, this.offset_iGroupId, 'int')
        Set {
            NumPut('int', Value, this.ptr, this.offset_iGroupId)
        }
    }
    cColumns {
        Get => NumGet(this.ptr, this.offset_cColumns, 'uint')
        Set {
            NumPut('uint', Value, this.ptr, this.offset_cColumns)
        }
    }
    puColumns {
        Get => NumGet(this.ptr, this.offset_puColumns, 'ptr')
        Set {
            NumPut('ptr', Value, this.ptr, this.offset_puColumns)
        }
    }
    piColFmt {
        Get => NumGet(this.ptr, this.offset_piColFmt, 'int')
        Set {
            NumPut('int', Value, this.ptr, this.offset_piColFmt)
        }
    }
    iGroup {
        Get => NumGet(this.ptr, this.offset_iGroup, 'int')
        Set {
            NumPut('int', Value, this.ptr, this.offset_iGroup)
        }
    }
}
