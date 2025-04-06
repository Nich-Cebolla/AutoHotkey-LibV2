
class Align {
    static DPI_AWARENESS_CONTEXT := -4

    /**
     * @description - Centers the Subject window horizontally with respect to the Target window.
     * @param {Gui|Gui.Control|Align} Subject - The window to be centered.
     * @param {Gui|Gui.Control|Align} Target - The reference window.
     */
    static CenterH(Subject, Target) {
        Subject.GetPos(&X1, &Y1, &W1)
        Target.GetPos(&X2, , &W2)
        Subject.Move(X2 + W2 / 2 - W1 / 2, Y1)
    }

    /**
     * @description - Centers the two windows horizontally with one another, splitting the difference
     * between them.
     * @param {Gui|Gui.Control|Align} Win1 - The first window to be centered.
     * @param {Gui|Gui.Control|Align} Win2 - The second window to be centered.
     */
    static CenterHSplit(Win1, Win2) {
        Win1.GetPos(&X1, &Y1, &W1)
        Win2.GetPos(&X2, &Y2, &W2)
        diff := X1 + 0.5 * W1 - X2 - 0.5 * W2
        X1 -= diff * 0.5
        X2 += diff * 0.5
        Win1.Move(X1, Y1)
        Win2.Move(X2, Y2)
    }

    /**
     * @description - Centers the Subject window vertically with respect to the Target window.
     * @param {Gui|Gui.Control|Align} Subject - The window to be centered.
     * @param {Gui|Gui.Control|Align} Target - The reference window.
     */
    static CenterV(Subject, Target) {
        Subject.GetPos(&X1, &Y1, , &H1)
        Target.GetPos( , &Y2, , &H2)
        Subject.Move(X1, Y2 + H2 / 2 - H1 / 2)
    }

    /**
     * @description - Centers the two windows vertically with one another, splitting the difference
     * between them.
     * @param {Gui|Gui.Control|Align} Win1 - The first window to be centered.
     * @param {Gui|Gui.Control|Align} Win2 - The second window to be centered.
     */
    static CenterVSplit(Win1, Win2) {
        Win1.GetPos(&X1, &Y1, , &H1)
        Win2.GetPos(&X2, &Y2, , &H2)
        diff := Y1 + 0.5 * H1 - Y2 - 0.5 * H2
        Y1 -= diff * 0.5
        Y2 += diff * 0.5
        Win1.Move(X1, Y1)
        Win2.Move(X2, Y2)
    }

    /**
     * @description - Centers a list of windows horizontally with respect to one another, splitting
     * the difference between them. The center of each window will be the midpoint between the least
     * and greatest X coordinates of the windows.
     * @param {Array} List - An array of windows to be centered. This function assumes there are
     * no unset indices.
     */
    static CenterHList(List) {
        if !(hDwp := DllCall('BeginDeferWindowPos', 'int', List.Length, 'ptr')) {
            throw Error('``BeginDeferWindowPos`` failed.', -1)
        }
        List[-1].GetPos(&L, &Y, &W)
        Params := [{ Y: Y, M: W / 2, Hwnd: List[-1].Hwnd }]
        Params.Capacity := List.Length
        R := L + W
        loop List.Length - 1 {
            List[A_Index].GetPos(&X, &Y, &W)
            Params.Push({ Y: Y, M: W / 2, Hwnd: List[A_Index].Hwnd })
            if X < L
                L := X
            if X + W > R
                R := X + W
        }
        Center := (R - L) / 2 + L
        for ps in Params {
            if !(hDwp := DllCall('DeferWindowPos'
                , 'ptr', hDwp
                , 'ptr', ps.Hwnd
                , 'ptr', 0
                , 'int', Center - ps.M
                , 'int', ps.Y
                , 'int', 0
                , 'int', 0
                , 'uint', 0x0001 | 0x0004 | 0x0010 ; SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE
                , 'ptr'
            )) {
                throw Error('``DeferWindowPos`` failed.', -1)
            }
        }
        if !DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr') {
            throw Error('``EndDeferWindowPos`` failed.', -1)
        }
        return
    }

    /**
     * @description - Centers a list of windows vertically with respect to one another, splitting
     * the difference between them. The center of each window will be the midpoint between the least
     * and greatest Y coordinates of the windows.
     * @param {Array} List - An array of windows to be centered. This function assumes there are
     * no unset indices.
     */
    static CenterVList(List) {
        if !(hDwp := DllCall('BeginDeferWindowPos', 'int', List.Length, 'ptr')) {
            throw Error('``BeginDeferWindowPos`` failed.', -1)
        }
        List[-1].GetPos(&X, &T, , &H)
        Params := [{ X: X, M: H / 2, Hwnd: List[-1].Hwnd }]
        Params.Capacity := List.Length
        B := T + H
        loop List.Length - 1 {
            List[A_Index].GetPos(&X, &Y, , &H)
            Params.Push({ X: X, M: H / 2, Hwnd: List[A_Index].Hwnd })
            if Y < T
                T := Y
            if Y + H > B
                B := Y + H
        }
        Center := (B - T) / 2 + T
        for ps in Params {
            if !(hDwp := DllCall('DeferWindowPos'
                , 'ptr', hDwp
                , 'ptr', ps.Hwnd
                , 'ptr', 0
                , 'int', ps.X
                , 'int', Center - ps.M
                , 'int', 0
                , 'int', 0
                , 'uint', 0x0001 | 0x0004 | 0x0010 ; SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE
                , 'ptr'
            )) {
                throw Error('``DeferWindowPos`` failed.', -1)
            }
        }
        if !DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr') {
            throw Error('``EndDeferWindowPos`` failed.', -1)
        }
        return
    }

    /**
     * @description - Standardizes a group's width to the largest width in the group.
     * @param {Array} List - An array of windows to be standardized. This function assumes there are
     * no unset indices.
     */
    static GroupWidth(List) {
        if !(hDwp := DllCall('BeginDeferWindowPos', 'int', List.Length, 'ptr')) {
            throw Error('``BeginDeferWindowPos`` failed.', -1)
        }
        List[-1].GetPos(, , &GW, &H)
        Params := [{ H: H, Hwnd: List[-1].Hwnd }]
        Params.Capacity := List.Length
        loop List.Length - 1 {
            List[A_Index].GetPos(, , &W, &H)
            Params.Push({ H: H, Hwnd: List[A_Index].Hwnd })
            if W > GW
                GW := W
        }
        for ps in Params {
            if !(hDwp := DllCall('DeferWindowPos'
                , 'ptr', hDwp
                , 'ptr', ps.Hwnd
                , 'ptr', 0
                , 'int', 0
                , 'int', 0
                , 'int', GW
                , 'int', ps.H
                , 'uint', 0x0002 | 0x0004 | 0x0010 ; SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE
                , 'ptr'
            )) {
                throw Error('``DeferWindowPos`` failed.', -1)
            }
        }
        if !DllCall('EndDeferWindowPos', 'ptr', hDwp, 'ptr') {
            throw Error('``EndDeferWindowPos`` failed.', -1)
        }
        return
    }
}
