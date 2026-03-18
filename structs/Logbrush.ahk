
class Logbrush {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.cbSizeInstance :=
        ; Size    Type           Symbol     Offset  Padding
        4 +       ; UINT         lbStyle    0
        4 +       ; COLORREF     lbColor    4
        A_PtrSize ; ULONG_PTR    lbHatch    8
        proto.offset_lbStyle  := 0
        proto.offset_lbColor  := 4
        proto.offset_lbHatch  := 8
    }
    static FromPtr(ptr) {
        lb := { ptr: ptr, size: this.cbSizeInstance }
        lb.base := this.Prototype
        return lb
    }
    __New() {
        this.Buffer := Buffer(this.cbSizeInstance)
    }
    lbStyle {
        Get => NumGet(this.ptr, this.offset_lbStyle, 'uint')
        Set {
            NumPut('uint', Value, this.ptr, this.offset_lbStyle)
        }
    }
    lbColor {
        Get => NumGet(this.ptr, this.offset_lbColor, 'uint')
        Set {
            NumPut('uint', Value, this.ptr, this.offset_lbColor)
        }
    }
    lbHatch {
        Get => NumGet(this.ptr, this.offset_lbHatch, 'ptr')
        Set {
            NumPut('ptr', Value, this.ptr, this.offset_lbHatch)
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}
