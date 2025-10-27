
class CopyDataStruct {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.cbSizeInstance :=
        ; Size      Type           Symbol    Offset               Padding
        A_PtrSize + ; ULONG_PTR    dwData    0
        A_PtrSize + ; DWORD        cbData    A_PtrSize * 1        +4 on x64 only
        A_PtrSize   ; PVOID        lpData    A_PtrSize * 2
        proto.offset_dwData  := 0
        proto.offset_cbData  := A_PtrSize * 1
        proto.offset_lpData  := A_PtrSize * 2

        global WM_COPYDATA := 0x004A
    }
    static FromPtr(ptr) {
        cds := { Buffer: { Ptr: ptr, Size: this.Prototype.cbSizeInstance } }
        ObjSetBase(cds, this.Prototype)
        return cds
    }
    /**
     * @example
     * data := "Hello, world!"
     * bytes := StrPut(data, "cp1200")
     * ptr := StrPtr(data)
     * cds := CopyDataStruct(0, bytes, ptr)
     * ; Assume this was launched from the command line
     * if IsNumber(A_Args[1]) {
     *     SendMessage(WM_COPYDATA, 0, cds, , A_Args[1])
     * }
     * @
     *
     * @param {Integer} [dwData] - Application-defined value specifying the type of data.
     * @param {Integer} [cbData] - The number of bytes of the data pointed to by `lpData`.
     * @param {Integer} [lpData] - A pointer to the data.
     */
    __New(dwData?, cbData?, lpData?) {
        this.Buffer := Buffer(this.cbSizeInstance, 0)
        if IsSet(dwData) {
            this.dwData := dwData
        }
        if IsSet(cbData) {
            this.cbData := cbData
        }
        if IsSet(lpData) {
            this.lpData := lpData
        }
    }
    dwData {
        Get => NumGet(this.Buffer, this.offset_dwData, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_dwData)
        }
    }
    cbData {
        Get => NumGet(this.Buffer, this.offset_cbData, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_cbData)
        }
    }
    lpData {
        Get => NumGet(this.Buffer, this.offset_lpData, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_lpData)
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}
