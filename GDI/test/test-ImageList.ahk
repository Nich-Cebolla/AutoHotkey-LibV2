
#include ..\ImageList.ahk

test()

class test {
    static PathIcons := 'icons'
    static __New() {
        this.DeleteProp('__New')
        paths := this.paths := Map('20', [], '25', [], '30', [], '35', [], '40', [])
        loop Files this.PathIcons '\*.ico' {
            if RegExMatch(A_LoopFileName, '^\d+', &match) {
                paths.Get(match[0]).Push(A_LoopFileFullPath)
            }
        }
    }
    static Call() {
        paths := this.paths
        listPath := paths.Get('20')
        path := listPath.Pop()
        imgList1 := this.ImageList1 := ImageList(listPath)
        index := imgList1.AddFromPath(path)
        imgList1.Remove(index)
        imgList1.RemoveAll()
        imgList1.Dispose()

        imgStack := ImageStack(listPath)
        imgStack.AddFromPath(path)
        imgStack.GetBitmapFromFile()
        listBitmap := []
        for img in imgStack {
            listBitmap.Push(img.pBitmap)
        }
        pBitmap := listBitmap.Pop()
        imgList2 := this.ImageList2 := ImageList(listBitmap, 2)
        index := imgList2.AddFromBitmap(pBitmap)
        imgList2.Remove(index)
        imgList2.RemoveAll()
        imgList2.Dispose()
    }
}
