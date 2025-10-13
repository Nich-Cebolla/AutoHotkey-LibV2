/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GDI/ImageList.ahk
    Author: Nich-Cebolla
    License: MIT
*/

; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GDI/ImageStack.ahk
#include <ImageStack>

class ImageList extends ImageStack {
    static __New() {
        global GDIPBITMAP_DEFAULT_ENCODING
        this.DeleteProp('__New')
        if !IsSet(ILC_COLOR32) {
            this.__SetConstants()
        }
        this.LibToken := 0
        this.__InitializeProcedureVars()
        this.LoadLibrary()
        proto := this.Prototype
        protoImageStack := ImageStack.Prototype
        for prop in ['AddFromBitmap', 'AddFromPath', 'AddListFromBitmap', 'AddListFromPath'] {
            proto.DefineProp('__' prop, protoImageStack.GetOwnPropDesc(prop))
        }
        proto.Handle := 0
    }
    static LoadLibrary() {
        if !this.LibToken {
            this.LibToken := LibraryManager(Map(
                'comctl32'
              , [
                    'ImageList_Create'
                  , 'ImageList_Destroy'
                ;   , 'ImageList_GetImageCount'
                ;   , 'ImageList_SetImageCount'
                  , 'ImageList_Add'
                ;   , 'ImageList_ReplaceIcon'
                ;   , 'ImageList_SetBkColor'
                ;   , 'ImageList_GetBkColor'
                ;   , 'ImageList_SetOverlayImage'
                ;   , 'ImageList_Draw'
                ;   , 'ImageList_Replace'
                ;   , 'ImageList_AddMasked'
                ;   , 'ImageList_DrawEx'
                ;   , 'ImageList_DrawIndirect'
                  , 'ImageList_Remove'
                ;   , 'ImageList_GetIcon'
                ;   , 'ImageList_LoadImageA'
                ;   , 'ImageList_LoadImageW'
                ;   , 'ImageList_Copy'
                ;   , 'ImageList_BeginDrag'
                ;   , 'ImageList_EndDrag'
                ;   , 'ImageList_DragEnter'
                ;   , 'ImageList_DragLeave'
                ;   , 'ImageList_DragMove'
                ;   , 'ImageList_SetDragCursorImage'
                ;   , 'ImageList_DragShowNolock'
                ;   , 'ImageList_Read'
                ;   , 'ImageList_Write'
                ;   , 'ImageList_ReadEx'
                ;   , 'ImageList_WriteEx'
                ;   , 'ImageList_Merge'
                ;   , 'ImageList_Duplicate'
                ]
            ))
        }
    }
    static FreeLibrary() {
        this.LibToken.Free()
        this.LibToken := 0
    }
    static __InitializeProcedureVars() {
        global g_comctl32_ImageList_Create
        , g_comctl32_ImageList_Destroy
        ; , g_comctl32_ImageList_GetImageCount
        ; , g_comctl32_ImageList_SetImageCount
        , g_comctl32_ImageList_Add
        ; , g_comctl32_ImageList_ReplaceIcon
        ; , g_comctl32_ImageList_SetBkColor
        ; , g_comctl32_ImageList_GetBkColor
        ; , g_comctl32_ImageList_SetOverlayImage
        ; , g_comctl32_ImageList_Draw
        ; , g_comctl32_ImageList_Replace
        ; , g_comctl32_ImageList_AddMasked
        ; , g_comctl32_ImageList_DrawEx
        ; , g_comctl32_ImageList_DrawIndirect
        , g_comctl32_ImageList_Remove
        ; , g_comctl32_ImageList_GetIcon
        ; , g_comctl32_ImageList_LoadImageA
        ; , g_comctl32_ImageList_LoadImageW
        ; , g_comctl32_ImageList_Copy
        ; , g_comctl32_ImageList_BeginDrag
        ; , g_comctl32_ImageList_EndDrag
        ; , g_comctl32_ImageList_DragEnter
        ; , g_comctl32_ImageList_DragLeave
        ; , g_comctl32_ImageList_DragMove
        ; , g_comctl32_ImageList_SetDragCursorImage
        ; , g_comctl32_ImageList_DragShowNolock
        ; , g_comctl32_ImageList_Read
        ; , g_comctl32_ImageList_Write
        ; , g_comctl32_ImageList_ReadEx
        ; , g_comctl32_ImageList_WriteEx
        ; , g_comctl32_ImageList_Merge
        ; , g_comctl32_ImageList_Duplicate
        if !IsSet(g_comctl32_ImageList_Create) {
            g_comctl32_ImageList_Create := 0
        }
        if !IsSet(g_comctl32_ImageList_Destroy) {
            g_comctl32_ImageList_Destroy := 0
        }
        ; if !IsSet(g_comctl32_ImageList_GetImageCount) {
        ;     g_comctl32_ImageList_GetImageCount := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_SetImageCount) {
        ;     g_comctl32_ImageList_SetImageCount := 0
        ; }
        if !IsSet(g_comctl32_ImageList_Add) {
            g_comctl32_ImageList_Add := 0
        }
        ; if !IsSet(g_comctl32_ImageList_ReplaceIcon) {
        ;     g_comctl32_ImageList_ReplaceIcon := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_SetBkColor) {
        ;     g_comctl32_ImageList_SetBkColor := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_GetBkColor) {
        ;     g_comctl32_ImageList_GetBkColor := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_SetOverlayImage) {
        ;     g_comctl32_ImageList_SetOverlayImage := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_Draw) {
        ;     g_comctl32_ImageList_Draw := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_Replace) {
        ;     g_comctl32_ImageList_Replace := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_AddMasked) {
        ;     g_comctl32_ImageList_AddMasked := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_DrawEx) {
        ;     g_comctl32_ImageList_DrawEx := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_DrawIndirect) {
        ;     g_comctl32_ImageList_DrawIndirect := 0
        ; }
        if !IsSet(g_comctl32_ImageList_Remove) {
            g_comctl32_ImageList_Remove := 0
        }
        ; if !IsSet(g_comctl32_ImageList_GetIcon) {
        ;     g_comctl32_ImageList_GetIcon := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_LoadImageA) {
        ;     g_comctl32_ImageList_LoadImageA := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_LoadImageW) {
        ;     g_comctl32_ImageList_LoadImageW := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_Copy) {
        ;     g_comctl32_ImageList_Copy := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_BeginDrag) {
        ;     g_comctl32_ImageList_BeginDrag := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_EndDrag) {
        ;     g_comctl32_ImageList_EndDrag := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_DragEnter) {
        ;     g_comctl32_ImageList_DragEnter := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_DragLeave) {
        ;     g_comctl32_ImageList_DragLeave := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_DragMove) {
        ;     g_comctl32_ImageList_DragMove := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_SetDragCursorImage) {
        ;     g_comctl32_ImageList_SetDragCursorImage := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_DragShowNolock) {
        ;     g_comctl32_ImageList_DragShowNolock := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_Read) {
        ;     g_comctl32_ImageList_Read := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_Write) {
        ;     g_comctl32_ImageList_Write := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_ReadEx) {
        ;     g_comctl32_ImageList_ReadEx := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_WriteEx) {
        ;     g_comctl32_ImageList_WriteEx := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_Merge) {
        ;     g_comctl32_ImageList_Merge := 0
        ; }
        ; if !IsSet(g_comctl32_ImageList_Duplicate) {
        ;     g_comctl32_ImageList_Duplicate := 0
        ; }

    }
    static __SetConstants() {
        global
        ILC_MASK              := 0x00000001  ; Use a mask. The image list contains two bitmaps, one of
                                             ; which is a monochrome bitmap used as a mask. If this
                                             ; value is not included, the image list contains only one
                                             ; bitmap.
        ILC_COLOR             := 0x00000000  ; Use the default behavior if none of the other
                                             ; ILC_COLORx flags is specified. Typically, the default
                                             ; is ILC_COLOR4, but for older display drivers, the
                                             ; default is ILC_COLORDDB.
        ILC_COLORDDB          := 0x000000FE  ; Use a device-dependent bitmap.
        ILC_COLOR4            := 0x00000004  ; Use a 4-bit (16-color) device-independent bitmap (DIB)
                                             ; section as the bitmap for the image list.
        ILC_COLOR8            := 0x00000008  ; Use an 8-bit DIB section. The colors used for the color
                                             ; table are the same colors as the halftone palette.
        ILC_COLOR16           := 0x00000010  ; Use a 16-bit (32/64k-color) DIB section.
        ILC_COLOR24           := 0x00000018  ; Use a 24-bit DIB section.
        ILC_COLOR32           := 0x00000020  ; Use a 32-bit DIB section.
        ; ILC_PALETTE           := 0x00000800  ; Not implemented.
        ILC_MIRROR            := 0x00002000  ; Mirror the icons contained, if the process is mirrored.
        ILC_PERITEMMIRROR     := 0x00008000  ; Causes the mirroring code to mirror each item when
                                             ; inserting a set of images, versus the whole strip.
        ILC_ORIGINALSIZE      := 0x00010000  ; Windows Vista and later. Imagelist should accept
                                             ; smaller than set images and apply original size based
                                             ; on image added.
        ; ILC_HIGHQUALITYSCALE  := 0x00020000  ; Windows Vista and later. Reserved.
    }
    /**
     * @param {String[]|Integer[]} List - An array of values to use to construct the {@link GdipBitmap}
     * objects. The type of values in the array depend on the value of parameter `ItemType`.
     *
     * @param {Integer} [ItemType = 1] - One of the following:
     * - 1: The values in `List` are file paths as string.
     * - 2: The values in `List` are pointers to bitmap objects as integers.
     *
     * @param {Object} [Options] - An object with zero or more options as property : value pairs.
     * @param {Integer} [Options.Background = 0xFFFFFFFF] - A COLORREF value to pass to
     * {@link GdipBitmap.Prototype.GetHBitmap} which calls `GdipCreateHBITMAPFromBitmap`.
     * @param {Integer} [Options.Flags = ILC_COLOR32] - One or more of the image list creation
     * flags. See {@link ImageList.__SetConstants} or
     * {@link https://learn.microsoft.com/en-us/windows/desktop/Controls/ilc-constants}.
     * @param {Integer} [Options.GrowCount = 1] - The number of images by which the image list can
     * grow when the system needs to make room for new images. This parameter represents the number
     * of new images that the resized image list can contain.
     *
     */
    __New(List, ItemType := 1, Options?) {
        options := ImageList.Options(Options ?? unset)
        this.Background := options.Background
        switch ItemType, 0 {
            case 1: this.__AddListFromPath(List)
            case 2: this.__AddListFromBitmap(List)
        }
        this.Handle := DllCall(
            g_comctl32_ImageList_Create
          , 'int', this[1].Width
          , 'int', this[1].Height
          , 'uint', options.Flags
          , 'int', this.Length
          , 'int', options.GrowCount
          , 'ptr'
        )
        hbmMask := options.hbmMask
        switch ItemType, 0 {
            case 1:
                for img in this {
                    hBitmap := img.GetHBitmap(this.Background)
                    result := DllCall(g_comctl32_ImageList_Add, 'ptr', this.Handle, 'ptr', hBitmap, 'ptr', hbmMask, 'int')
                    if result == -1 {
                        throw Error('Failed to load image.', -1, 'path: ' img.Path)
                    }
                    img.DeleteBitmap()
                    img.DeleteHBitmap()
                }
            case 2:
                for img in this {
                    hBitmap := img.GetHBitmap(this.Background)
                    result := DllCall(g_comctl32_ImageList_Add, 'ptr', this.Handle, 'ptr', hBitmap, 'ptr', hbmMask, 'int')
                    if result == -1 {
                        throw Error('Failed to load image.', -1, 'pBitmap: ' img.pBitmap)
                    }
                    img.DeleteHBitmap()
                }
        }
    }
    AddFromBitmap(pBitmap, hbmMask := 0, Background?) {
        img := this.__AddFromBitmap(pBitmap)
        hBitmap := img.GetHBitmap(Background ?? this.Background)
        result := DllCall(g_comctl32_ImageList_Add, 'ptr', this.Handle, 'ptr', hBitmap, 'ptr', hbmMask, 'int')
        if result == -1 {
            this.Pop()
        }
        img.DeleteHBitmap()
        return result
    }
    AddListFromBitmap(List, hbmMask := 0, Background?, FailureAction := 1) {
        for pBitmap in List {
            result := this.AddFromBitmap(pBitmap, hbmMask, Background ?? unset)
            if result == -1 {
                switch FailureAction, 0 {
                    case 1: throw Error('Failed to add image to image list.', -1, 'pBitmap: ' pBitmap)
                    case 2: return -1
                    case 3: continue
                    default: throw ValueError('Invalid ``FailureAction``.', -1, FailureAction)
                }
            }
        }
    }
    AddListFromPath(List, hbmMask := 0, Background?, FailureAction := 1) {
        for path in List {
            result := this.AddFromPath(path, hbmMask, Background ?? unset)
            if result == -1 {
                switch FailureAction, 0 {
                    case 1: throw Error('Failed to add image to image list.', -1, 'path: ' path)
                    case 2: return -1
                    case 3: continue
                    default: throw ValueError('Invalid ``FailureAction``.', -1, FailureAction)
                }
            }
        }
    }
    AddFromPath(ImagePath, hbmMask := 0, Background?) {
        img := this.__AddFromPath(ImagePath, false)
        hBitmap := img.GetHBitmap(Background ?? this.Background)
        result := DllCall(g_comctl32_ImageList_Add, 'ptr', this.Handle, 'ptr', hBitmap, 'ptr', hbmMask, 'int')
        if result == -1 {
            this.Pop()
        }
        img.DeleteHBitmap()
        img.DeleteBitmap()
        return result
    }
    Dispose(ClearArray := false) {
        if ClearArray {
            this.Length := 0
        }
        if this.Handle {
            Handle := this.Handle
            this.Handle := 0
            return DllCall(g_comctl32_ImageList_Destroy, 'ptr', Handle, 'int')
        } else {
            return -1
        }
    }
    /**
     * @param {Integer} Index - The 1-based index of the image to remove.
     * @returns {GdipBitmap} - The {@link GdipBitmap} object if it was successfully removed. If
     * `ImageList_Remove` failed, returns an empty string.
     */
    Remove(Index) {
        img := this[Index]
        if result := DllCall(g_comctl32_ImageList_Remove, 'ptr', this.Handle, 'int', Index - 1, 'int') {
            this.RemoveAt(Index)
            return img
        }
    }
    RemoveAll(ClearArray := false) {
        if ClearArray {
            this.Length := 0
        }
        return DllCall(g_comctl32_ImageList_Remove, 'ptr', this.Handle, 'int', -1, 'int')
    }
    __Delete() {
        if this.Handle {
            DllCall(g_comctl32_ImageList_Destroy, 'ptr', this.Handle, 'int')
        }
    }

    class Options {
        static __New() {
            this.DeleteProp('__New')
            if !IsSet(ILC_COLOR32) {
                ImageList.__SetConstants()
            }
            this.Default := {
                Background: 0xFFFFFFFF
              , Flags: ILC_COLOR32
              , GrowCount: 1
              , hbmMask: 0
            }
        }
        static Call(Options?) {
            if IsSet(Options) {
                o := {}
                d := this.Default
                for prop in d.OwnProps() {
                    o.%prop% := HasProp(Options, prop) ? Options.%prop% : d.%prop%
                }
                return o
            } else {
                return this.Default.Clone()
            }
        }
    }
}

