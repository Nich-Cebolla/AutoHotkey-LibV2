
/**
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
 */
class DRAWITEMSTRUCT {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.cbSize :=
        ; Size      Type           Symbol        Offset                Padding
        4 +         ; UINT         CtlType       0
        4 +         ; UINT         CtlID         4
        4 +         ; UINT         itemID        8
        4 +         ; UINT         itemAction    12
        A_PtrSize + ; UINT         itemState     16                    +4 on x64 only
        A_PtrSize + ; HWND         hwndItem      16 + A_PtrSize * 1
        A_PtrSize + ; HDC          hDC           16 + A_PtrSize * 2
        4 +         ; INT          left          16 + A_PtrSize * 3
        4 +         ; INT          top           20 + A_PtrSize * 3
        4 +         ; INT          right         24 + A_PtrSize * 3
        4 +         ; INT          bottom        28 + A_PtrSize * 3
        A_PtrSize   ; ULONG_PTR    itemData      32 + A_PtrSize * 3
        proto.offset_CtlType := 0
        proto.offset_CtlID := 4
        proto.offset_itemID := 8
        proto.offset_itemAction := 12
        proto.offset_itemState := 16
        proto.offset_hwndItem := 16 + A_PtrSize * 1
        proto.offset_hDC := 16 + A_PtrSize * 2
        proto.offset_left := 16 + A_PtrSize * 3
        proto.offset_top := 20 + A_PtrSize * 3
        proto.offset_right := 24 + A_PtrSize * 3
        proto.offset_bottom := 28 + A_PtrSize * 3
        proto.offset_itemData := 32 + A_PtrSize * 3
    }
    __New(CtlType?, CtlID?, itemID?, itemAction?, itemState?, hwndItem?, hDC?, left?, top?, right?, bottom?, itemData?) {
        this.Buffer := Buffer(this.cbSize)
        if IsSet(CtlType) {
            this.CtlType := CtlType
        }
        if IsSet(CtlID) {
            this.CtlID := CtlID
        }
        if IsSet(itemID) {
            this.itemID := itemID
        }
        if IsSet(itemAction) {
            this.itemAction := itemAction
        }
        if IsSet(itemState) {
            this.itemState := itemState
        }
        if IsSet(hwndItem) {
            this.hwndItem := hwndItem
        }
        if IsSet(hDC) {
            this.hDC := hDC
        }
        if IsSet(left) {
            this.left := left
        }
        if IsSet(top) {
            this.top := top
        }
        if IsSet(right) {
            this.right := right
        }
        if IsSet(bottom) {
            this.bottom := bottom
        }
        if IsSet(itemData) {
            this.itemData := itemData
        }
    }
    CtlType {
        Get => NumGet(this.Buffer, this.offset_CtlType, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_CtlType)
        }
    }
    CtlID {
        Get => NumGet(this.Buffer, this.offset_CtlID, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_CtlID)
        }
    }
    itemID {
        Get => NumGet(this.Buffer, this.offset_itemID, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_itemID)
        }
    }
    itemAction {
        Get => NumGet(this.Buffer, this.offset_itemAction, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_itemAction)
        }
    }
    itemState {
        Get => NumGet(this.Buffer, this.offset_itemState, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_itemState)
        }
    }
    hwndItem {
        Get => NumGet(this.Buffer, this.offset_hwndItem, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_hwndItem)
        }
    }
    hDC {
        Get => NumGet(this.Buffer, this.offset_hDC, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_hDC)
        }
    }
    left {
        Get => NumGet(this.Buffer, this.offset_left, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_left)
        }
    }
    top {
        Get => NumGet(this.Buffer, this.offset_top, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_top)
        }
    }
    right {
        Get => NumGet(this.Buffer, this.offset_right, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_right)
        }
    }
    bottom {
        Get => NumGet(this.Buffer, this.offset_bottom, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_bottom)
        }
    }
    itemData {
        Get => NumGet(this.Buffer, this.offset_itemData, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_itemData)
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}
