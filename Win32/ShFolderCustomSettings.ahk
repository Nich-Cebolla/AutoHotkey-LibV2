
class ShFolderCustomSettings {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.cbSizeInstance :=
        ; Size      Type             Symbol                       Offset                 Padding
        4 +         ; DWORD          dwSize                       0
        4 +         ; DWORD          dwMask                       4
        A_PtrSize + ; SHELLVIEWID    *pvid                        8
        A_PtrSize + ; LPWSTR         pszWebViewTemplate           8 + A_PtrSize * 1
        A_PtrSize + ; DWORD          cchWebViewTemplate           8 + A_PtrSize * 2      +4 on x64 only
        A_PtrSize + ; LPWSTR         pszWebViewTemplateVersion    8 + A_PtrSize * 3
        A_PtrSize + ; LPWSTR         pszInfoTip                   8 + A_PtrSize * 4
        A_PtrSize + ; DWORD          cchInfoTip                   8 + A_PtrSize * 5      +4 on x64 only
        A_PtrSize + ; CLSID          *pclsid                      8 + A_PtrSize * 6
        A_PtrSize + ; DWORD          dwFlags                      8 + A_PtrSize * 7      +4 on x64 only
        A_PtrSize + ; LPWSTR         pszIconFile                  8 + A_PtrSize * 8
        4 +         ; DWORD          cchIconFile                  8 + A_PtrSize * 9
        4 +         ; int            iIconIndex                   12 + A_PtrSize * 9
        A_PtrSize + ; LPWSTR         pszLogo                      16 + A_PtrSize * 9
        A_PtrSize   ; DWORD          cchLogo                      16 + A_PtrSize * 10    +4 on x64 only
        proto.offset_dwSize                     := 0
        proto.offset_dwMask                     := 4
        proto.offset_*pvid                      := 8
        proto.offset_pszWebViewTemplate         := 8 + A_PtrSize * 1
        proto.offset_cchWebViewTemplate         := 8 + A_PtrSize * 2
        proto.offset_pszWebViewTemplateVersion  := 8 + A_PtrSize * 3
        proto.offset_pszInfoTip                 := 8 + A_PtrSize * 4
        proto.offset_cchInfoTip                 := 8 + A_PtrSize * 5
        proto.offset_*pclsid                    := 8 + A_PtrSize * 6
        proto.offset_dwFlags                    := 8 + A_PtrSize * 7
        proto.offset_pszIconFile                := 8 + A_PtrSize * 8
        proto.offset_cchIconFile                := 8 + A_PtrSize * 9
        proto.offset_iIconIndex                 := 12 + A_PtrSize * 9
        proto.offset_pszLogo                    := 16 + A_PtrSize * 9
        proto.offset_cchLogo                    := 16 + A_PtrSize * 10
    }
    /**
     * @description - A wrapper around the
     * {@link https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/ns-shlobj_core-shfoldercustomsettings SHFOLDERCUSTOMSETTINGS structure}.
     *
     * For members that are a pointer to a string, you can define the value as either the raw pointer (integer)
     * or as the string itself. When defined as the string, the property setter will create a buffer
     * containing the string and cache a reference to the buffer as a property on the object. Changing
     * the value by setting the member property with a new value will also update the value in the
     * buffer.
     *
     * Said in more simple terms, for the following params / properties, it is ok to define them
     * with the string path directly:
     * - pszWebViewTemplate
     * - pszIconFile
     * - pszLogo
     *
     * @example
     * shfcs := ShFolderCustomSettings()
     * shfcs.pszWebViewTemplate := "C:\path\to\web-view-template.htt"
     * shfcs.pszIconFile := "C:\path\to\icons.ico"
     * shfcs.pszLogo := "C:\path\to\logo
     * @
     *
     * @param {Integer} [dwMask] - A DWORD value specifying which folder attributes to read or write from this structure. Use one or more of the following values to indicate which structure members are valid:
     *
     * FCSM_VIEWID
     * Deprecated. pvid contains the folder's GUID.
     *
     * FCSM_WEBVIEWTEMPLATE
     * Deprecated. pszWebViewTemplate contains a pointer to a buffer containing the path to the folder's WebView template.
     *
     * FCSM_INFOTIP
     * pszInfoTip contains a pointer to a buffer containing the folder's info tip.
     *
     * FCSM_CLSID
     * pclsid contains the folder's CLSID.
     *
     * FCSM_ICONFILE
     * pszIconFile contains the path to the file containing the folder's icon.
     *
     * FCSM_LOGO
     * pszLogo contains the path to the file containing the folder's thumbnail icon.
     *
     * FCSM_FLAGS
     * Not used.
     *
     * @param {Integer} [pvid] - Pointer to the folder's GUID. Use
     * {@link https://github.com/Nich-Cebolla/AutoHotkey-Interprocess-Communication/blob/main/src/CLSID.ahk}
     * to convert a string to GUID easily.
     *
     * @param {Integer} [pszWebViewTemplate] - A pointer to a null-terminated string containing the
     * path to the folder's WebView template.
     *
     * @param {Integer} [cchWebViewTemplate = 0] - If the SHGetSetFolderCustomSettings parameter
     * dwReadWrite is FCS_READ, this is the size of the pszWebViewTemplate buffer, in characters.
     * If not, this is the number of characters to write from that buffer. Set this parameter to 0
     * to write the entire string.
     *
     * @param {Integer} [pszWebViewTemplateVersion] - A pointer to a null-terminated buffer
     * containing the WebView template version.
     *
     * @param {Integer} [pszInfoTip] - A pointer to a null-terminated buffer containing
     * the text of the folder's infotip.
     *
     * @param {Integer} [cchInfoTip = 0] - If the SHGetSetFolderCustomSettings parameter dwReadWrite is
     * FCS_READ, this is the size of the pszInfoTip buffer, in characters. If not, this is the number
     * of characters to write from that buffer. Set this parameter to 0 to write the entire string.
     *
     * @param {Integer} [pclsid] - A pointer to a CLSID used to identify the folder in the Windows
     * registry. Further folder information is stored in the registry under that CLSID entry. Use
     * {@link https://github.com/Nich-Cebolla/AutoHotkey-Interprocess-Communication/blob/main/src/CLSID.ahk}
     * to convert a string to CLSID easily.
     *
     * @param {Integer} [pszIconFile] - A pointer to a null-terminated buffer containing the path to
     * file containing the folder's icon. Use
     * {@link https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GDI/ImageList.ahk} to
     * create an icon list from an array of file paths (strings) easily.
     *
     * @param {Integer} [cchIconFile = 0] - If the SHGetSetFolderCustomSettings parameter dwReadWrite
     * is FCS_READ, this is the size of the pszIconFile buffer, in characters. If not, this is the
     * number of characters to write from that buffer. Set this parameter to 0 to write the entire
     * string.
     *
     * @param {Integer} [iIconIndex] - The index of the icon within the file named in pszIconFile.
     *
     * @param {Integer} [pszLogo] - A pointer to a null-terminated buffer containing the path to the
     * file containing the folder's logo image. This is the image used in thumbnail views.
     *
     * @param {Integer} [cchLogo] - If the SHGetSetFolderCustomSettings parameter dwReadWrite is
     * FCS_READ, this is the size of the pszLogo buffer, in characters. If not, this is the number
     * of characters to write from that buffer. Set this parameter to 0 to write the entire string.
     */
    __New(dwMask?, pvid?, pszWebViewTemplate?, cchWebViewTemplate := 0, pszWebViewTemplateVersion?, pszInfoTip?, cchInfoTip := 0, pclsid?, pszIconFile?, cchIconFile := 0, iIconIndex?, pszLogo?, cchLogo := 0) {
        this.Buffer := Buffer(this.cbSizeInstance, 0)
        this.dwSize := this.cbSizeInstance
        if IsSet(dwMask) {
            this.dwMask := dwMask
        }
        if IsSet(pvid) {
            this.pvid := pvid
        }
        if IsSet(pszWebViewTemplate) {
            this.pszWebViewTemplate := pszWebViewTemplate
        }
        this.cchWebViewTemplate := cchWebViewTemplate
        if IsSet(pszWebViewTemplateVersion) {
            this.pszWebViewTemplateVersion := pszWebViewTemplateVersion
        }
        if IsSet(pszInfoTip) {
            this.pszInfoTip := pszInfoTip
        }
        this.cchInfoTip := cchInfoTip
        if IsSet(pclsid) {
            this.pclsid := pclsid
        }
        if IsSet(pszIconFile) {
            this.pszIconFile := pszIconFile
        }
        this.cchIconFile := cchIconFile
        if IsSet(iIconIndex) {
            this.iIconIndex := iIconIndex
        }
        if IsSet(pszLogo) {
            this.pszLogo := pszLogo
        }
        this.cchLogo := cchLogo
    }
    dwSize {
        Get => NumGet(this.Buffer, this.offset_dwSize, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_dwSize)
        }
    }
    dwMask {
        Get => NumGet(this.Buffer, this.offset_dwMask, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_dwMask)
        }
    }
    pvid {
        Get => NumGet(this.Buffer, this.offset_pvid, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_pvid)
        }
    }
    pszWebViewTemplate {
        Get {
            Value := NumGet(this.Buffer, this.offset_pszWebViewTemplate, 'ptr')
            if Value > 0 {
                return StrGet(Value, 'cp1200')
            } else {
                return Value
            }
        }
        Set {
            if Type(Value) = 'String' {
                if !this.HasOwnProp('__pszWebViewTemplate')
                || (this.__pszWebViewTemplate is Buffer && this.__pszWebViewTemplate.Size < StrPut(Value, 'cp1200')) {
                    this.__pszWebViewTemplate := Buffer(StrPut(Value, 'cp1200'))
                    NumPut('ptr', this.__pszWebViewTemplate.Ptr, this.Buffer, this.offset_pszWebViewTemplate)
                }
                StrPut(Value, this.__pszWebViewTemplate, 'cp1200')
            } else if Value is Buffer {
                this.__pszWebViewTemplate := Value
                NumPut('ptr', this.__pszWebViewTemplate.Ptr, this.Buffer, this.offset_pszWebViewTemplate)
            } else {
                this.__pszWebViewTemplate := Value
                NumPut('ptr', this.__pszWebViewTemplate, this.Buffer, this.offset_pszWebViewTemplate)
            }
        }
    }
    cchWebViewTemplate {
        Get => NumGet(this.Buffer, this.offset_cchWebViewTemplate, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_cchWebViewTemplate)
        }
    }
    pszWebViewTemplateVersion {
        Get {
            Value := NumGet(this.Buffer, this.offset_pszWebViewTemplateVersion, 'ptr')
            if Value > 0 {
                return StrGet(Value, 'cp1200')
            } else {
                return Value
            }
        }
        Set {
            if Type(Value) = 'String' {
                if !this.HasOwnProp('__pszWebViewTemplateVersion')
                || (this.__pszWebViewTemplateVersion is Buffer && this.__pszWebViewTemplateVersion.Size < StrPut(Value, 'cp1200')) {
                    this.__pszWebViewTemplateVersion := Buffer(StrPut(Value, 'cp1200'))
                    NumPut('ptr', this.__pszWebViewTemplateVersion.Ptr, this.Buffer, this.offset_pszWebViewTemplateVersion)
                }
                StrPut(Value, this.__pszWebViewTemplateVersion, 'cp1200')
            } else if Value is Buffer {
                this.__pszWebViewTemplateVersion := Value
                NumPut('ptr', this.__pszWebViewTemplateVersion.Ptr, this.Buffer, this.offset_pszWebViewTemplateVersion)
            } else {
                this.__pszWebViewTemplateVersion := Value
                NumPut('ptr', this.__pszWebViewTemplateVersion, this.Buffer, this.offset_pszWebViewTemplateVersion)
            }
        }
    }
    pszInfoTip {
        Get {
            Value := NumGet(this.Buffer, this.offset_pszInfoTip, 'ptr')
            if Value > 0 {
                return StrGet(Value, 'cp1200')
            } else {
                return Value
            }
        }
        Set {
            if Type(Value) = 'String' {
                if !this.HasOwnProp('__pszInfoTip')
                || (this.__pszInfoTip is Buffer && this.__pszInfoTip.Size < StrPut(Value, 'cp1200')) {
                    this.__pszInfoTip := Buffer(StrPut(Value, 'cp1200'))
                    NumPut('ptr', this.__pszInfoTip.Ptr, this.Buffer, this.offset_pszInfoTip)
                }
                StrPut(Value, this.__pszInfoTip, 'cp1200')
            } else if Value is Buffer {
                this.__pszInfoTip := Value
                NumPut('ptr', this.__pszInfoTip.Ptr, this.Buffer, this.offset_pszInfoTip)
            } else {
                this.__pszInfoTip := Value
                NumPut('ptr', this.__pszInfoTip, this.Buffer, this.offset_pszInfoTip)
            }
        }
    }
    cchInfoTip {
        Get => NumGet(this.Buffer, this.offset_cchInfoTip, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_cchInfoTip)
        }
    }
    pclsid {
        Get => NumGet(this.Buffer, this.offset_pclsid, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_pclsid)
        }
    }
    dwFlags {
        Get => NumGet(this.Buffer, this.offset_dwFlags, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_dwFlags)
        }
    }
    pszIconFile {
        Get {
            Value := NumGet(this.Buffer, this.offset_pszIconFile, 'ptr')
            if Value > 0 {
                return StrGet(Value, 'cp1200')
            } else {
                return Value
            }
        }
        Set {
            if Type(Value) = 'String' {
                if !this.HasOwnProp('__pszIconFile')
                || (this.__pszIconFile is Buffer && this.__pszIconFile.Size < StrPut(Value, 'cp1200')) {
                    this.__pszIconFile := Buffer(StrPut(Value, 'cp1200'))
                    NumPut('ptr', this.__pszIconFile.Ptr, this.Buffer, this.offset_pszIconFile)
                }
                StrPut(Value, this.__pszIconFile, 'cp1200')
            } else if Value is Buffer {
                this.__pszIconFile := Value
                NumPut('ptr', this.__pszIconFile.Ptr, this.Buffer, this.offset_pszIconFile)
            } else {
                this.__pszIconFile := Value
                NumPut('ptr', this.__pszIconFile, this.Buffer, this.offset_pszIconFile)
            }
        }
    }
    cchIconFile {
        Get => NumGet(this.Buffer, this.offset_cchIconFile, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_cchIconFile)
        }
    }
    iIconIndex {
        Get => NumGet(this.Buffer, this.offset_iIconIndex, 'int')
        Set {
            NumPut('int', Value, this.Buffer, this.offset_iIconIndex)
        }
    }
    pszLogo {
        Get {
            Value := NumGet(this.Buffer, this.offset_pszLogo, 'ptr')
            if Value > 0 {
                return StrGet(Value, 'cp1200')
            } else {
                return Value
            }
        }
        Set {
            if Type(Value) = 'String' {
                if !this.HasOwnProp('__pszLogo')
                || (this.__pszLogo is Buffer && this.__pszLogo.Size < StrPut(Value, 'cp1200')) {
                    this.__pszLogo := Buffer(StrPut(Value, 'cp1200'))
                    NumPut('ptr', this.__pszLogo.Ptr, this.Buffer, this.offset_pszLogo)
                }
                StrPut(Value, this.__pszLogo, 'cp1200')
            } else if Value is Buffer {
                this.__pszLogo := Value
                NumPut('ptr', this.__pszLogo.Ptr, this.Buffer, this.offset_pszLogo)
            } else {
                this.__pszLogo := Value
                NumPut('ptr', this.__pszLogo, this.Buffer, this.offset_pszLogo)
            }
        }
    }
    cchLogo {
        Get => NumGet(this.Buffer, this.offset_cchLogo, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_cchLogo)
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}
