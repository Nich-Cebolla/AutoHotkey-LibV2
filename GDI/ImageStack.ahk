/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GDI/ImageStack.ahk
    Author: Nich-Cebolla
    License: MIT
*/

; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GDI/GdipBitmap.ahk
#include <GdipBitmap>

class ImageStack extends Array {
    /**
     * @param {String[]|Integer[]} List - An array of values to use to construct the {@link GdipBitmap}
     * objects. The type of values in the array depend on the value of parameter `ItemType`.
     *
     * @param {Integer} [ItemType = 1] - One of the following:
     * - 1: The values in `List` are file paths as string.
     * - 2: The values in `List` are pointers to bitmap objects as integers.
     *
     * @param {Boolean} [Load = true] - `Load` is passed to the second parameter
     * of {@link ImageStack.Prototype.AddListFromPath} if `ItemType == 1`, and is ignored in all
     * other cases.
     */
    __New(List, ItemType := 1, Load := true) {
        switch ItemType, 0 {
            case 1: this.AddListFromPath(List, Load)
            case 2: this.AddListFromBitmap(List)
        }
    }
    AddFromBitmap(pBitmap) {
        this.Push(GdipBitmap.FromBitmap(pBitmap))
        return this[-1]
    }
    AddListFromBitmap(List) {
        for pBitmap in List {
            this.Push(GdipBitmap.FromBitmap(pBitmap))
        }
    }
    AddListFromPath(List, Load := true) {
        for path in List {
            this.Push(GdipBitmap(path, Load))
        }
    }
    AddFromPath(ImagePath, Load := false) {
        this.Push(GdipBitmap(ImagePath, Load))
        return this[-1]
    }
    DeleteBitmap() {
        for i in this {
            i.DeleteBitmap()
        }
    }
    DeleteHBitmap() {
        for i in this {
            i.DeleteHBitmap()
        }
    }
    /**
     * @param {String|Integer} Value - The value used to find the object to delete.
     * @param {Integer} [ItemType = 1] - One of the following:
     * - 1: `Value` is the file path.
     * - 2: `Value` is the pointer to the bitmap object ("pBitmap").
     * - 3: `Value` is the HBITMAP ("hBitmap").
     * @returns {GdipBitmap} - The deleted {@link GdipBitmap} object.
     */
    DeleteObject(Value, ItemType := 1) {
        switch ItemType, 0 {
            case 1:
                for i in this {
                    if i.Path = Value {
                        this.RemoveAt(A_Index)
                        return i
                    }
                }
            case 2:
                for i in this {
                    if i.pBitmap = Value {
                        this.RemoveAt(A_Index)
                        return i
                    }
                }
            case 3:
                for i in this {
                    if i.hBitmap = Value {
                        this.RemoveAt(A_Index)
                        return i
                    }
                }
        }
    }
    Dispose() {
        this.FreeResources()
        this.Length := 0
    }
    FreeResources() {
        for i in this {
            i.Dispose()
        }
    }
    GetBitmapFromFile() {
        for i in this {
            i.GetBitmapFromFile()
        }
    }
    GetHBitmap(Background := 0xFFFFFFFF) {
        for i in this {
            i.GetHBitmap(Background)
        }
    }
    LoadImage() {
        for i in this {
            i.LoadImage()
        }
    }
    /**
     * Sorts the images by one dimension.
     * @param {String} [Dimension = "Width"] - Either "Width" or "Height".
     * @param {Integer} [Direction = 1] - One of the following:
     * - 1: Sorts in ascending order (index 1 is the smallest length).
     * - -1: Sorts in descending order (index 1 is the greatest length).
     */
    Sort(Dimension := 'Width', Direction := 1) {
        i := 1
        loop this.Length - 1 {
            current := this[++i]
            j := i - 1
            loop j {
                if (this[j].%Dimension% - current.%Dimension%) * Direction < 0 {
                    break
                }
                this[j + 1] := this[j--]
            }
            this[j + 1] := Current
        }
    }
    __Delete() {
        this.Dispose()
    }
}
