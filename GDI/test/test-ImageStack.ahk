
#include ..\ImageStack.ahk

test()
test.GetAspectRatio()

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

        imgStack := this.ImageStack := ImageStack(paths.Get('20'))
        imgStack.LoadImage()
        imgStack.Sort() ; ensure there's no issues if all images are the same size
        imgStack.GetHBitmap()
        for i in imgStack {
            if i.Width != 20 || i.Height != 20 {
                throw ValueError('Incorrect dimension. Expected: 20x20.', -1, 'Width: ' i.Width '; Height: ' i.Height)
            }
            if !i.pBitmap || !i.hBitmap {
                throw ValueError('Missing value.', -1, 'pBitmap: ' i.pBitmap '; hBitmap: ' i.hBitmap)
            }
        }
        for i in imgStack {
            i.DeleteHBitmap()
            i.DeleteBitmap()
            if i.pBitmap || i.hBitmap {
                throw ValueError('``' i.Dispose.Name '`` failed to clear all values.', -1, 'pBitmap: ' i.pBitmap '; hBitmap: ' i.hBitmap)
            }
        }
        imgStack.Dispose()

        mixPaths := this.MixPaths := [ paths.Get('20')[1], paths.Get('40')[1], paths.Get('30')[1], paths.Get('30')[2], paths.Get('40')[2] ]
        mixImgStack_sortWidth := this.MixImageStack_SortWidth := ImageStack(mixPaths)
        mixImgStack_sortWidth.GetBitmapFromFile()
        mixImgStack_sortWidth.Sort()
        previous := mixImgStack_sortWidth[1].Width
        loop mixImgStack_sortWidth.Length - 1 {
            w := mixImgStack_sortWidth[A_Index + 1].Width
            if w < previous {
                throw ValueError('Out of order widths.', -1, 'Previous: ' previous '; Current: ' w)
            }
            previous := w
        }
        mixImgStack_sortWidth.Sort(, -1)
        previous := mixImgStack_sortWidth[1].Width
        loop mixImgStack_sortWidth.Length - 1 {
            w := mixImgStack_sortWidth[A_Index + 1].Width
            if w > previous {
                throw ValueError('Out of order widths.', -1, 'Previous: ' previous '; Current: ' w)
            }
            previous := w
        }

        mixImgStack_sortHeight := this.MixImageStack_SortHeight := ImageStack(mixPaths)
        mixImgStack_sortHeight.GetBitmapFromFile()
        mixImgStack_sortHeight.Sort('Height')
        previous := mixImgStack_sortHeight[1].Height
        loop mixImgStack_sortHeight.Length - 1 {
            h := mixImgStack_sortHeight[A_Index + 1].Height
            if h < previous {
                throw ValueError('Out of order heights.', -1, 'Previous: ' previous '; Current: ' h)
            }
            previous := h
        }

        GdipBitmap.FreeLibrary()
        flag := 0
        try {
            mixImgStack_sortWidth[1].Width
            flag := 1
        }
        if flag {
            throw Error('Function succeeded when it should have failed.', -1)
        }
    }
    static GetAspectRatio() {
        GdipBitmap.LoadLibrary()
        paths := this.paths
        imgStack := this.ImageStack := ImageStack(paths.Get('20'), true)
        for i in imgStack {
            ar := i.GetAspectRatio(, &w, &h)
            if ar != '1:1' || w != 1 || h != 1 {
                throw ValueError('Invalid value.', -1, 'ar: ' ar '; w: ' w '; h: ' h)
            }
        }
    }
}
