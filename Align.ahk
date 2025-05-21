/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Align.ahk
    Author: Nich-Cebolla
    Version: 1.2.0
    License: MIT
*/
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/RectHighlight.ahk
#include RectHighlight.ahk


class Align {
    static DPI_AWARENESS_CONTEXT := -3

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
        Params := [{ Y: Y, M: W / 2, hWnd: List[-1].hWnd }]
        Params.Capacity := List.Length
        R := L + W
        loop List.Length - 1 {
            List[A_Index].GetPos(&X, &Y, &W)
            Params.Push({ Y: Y, M: W / 2, hWnd: List[A_Index].hWnd })
            if X < L
                L := X
            if X + W > R
                R := X + W
        }
        Center := (R - L) / 2 + L
        for ps in Params {
            if !(hDwp := DllCall('DeferWindowPos'
                , 'ptr', hDwp
                , 'ptr', ps.hWnd
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
        Params := [{ X: X, M: H / 2, hWnd: List[-1].hWnd }]
        Params.Capacity := List.Length
        B := T + H
        loop List.Length - 1 {
            List[A_Index].GetPos(&X, &Y, , &H)
            Params.Push({ X: X, M: H / 2, hWnd: List[A_Index].hWnd })
            if Y < T
                T := Y
            if Y + H > B
                B := Y + H
        }
        Center := (B - T) / 2 + T
        for ps in Params {
            if !(hDwp := DllCall('DeferWindowPos'
                , 'ptr', hDwp
                , 'ptr', ps.hWnd
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
     * @description - Arranges controls using a string diagram.
     * - Rows are separated by newline characters.
     * - Columns are separated by spaces or tabs.
     *
     * - Use controls' names to represent their relative position.
     *   - If a control's name contains spaces or tabs, or if a control's name is completely numeric,
     * enclose the name in double quotes.
     *   - If a control's name contains carriage returns, line feeds, double quotes, or a backslash,
     * escape them with a backslash (e.g. \r \n \" \\).
     *   - If the names of the controls in the `Gui` object's collection are long or otherwise cause
     * arranging them by name to be problematic or hard to read, `Align.DiagramFromSymbols` might be
     * a better alternative.
     *
     * - By default, the distance between the controls will be the value of `PaddingX` and `PaddingY`
     * for their respective dimensions.
     *   - You can add additional space in-between controls along the X axis by including a number
     * that represents the number of pixels to add to the padding.
     *   - You can add additional space in-between rows of controls by including a single number
     * in-between two diagram rows.
     *
     * In the below example, the top-left coordinates of `BtnGo` are (60, 100). The distance between
     * the bottom of `EdtInput` and the top of `LVData` is `105`.
     * @example
     *  Diagram := '
     *  (
     *     10 BtnGo 10 BtnExit
     *     EdtInput
     *     5
     *     30 LVData
     *  )'
     *  ; Assume `MyGui` is already created
     *  Align.Diagram(MyGui, Diagram, 50, 100)
     * @
     * @param {Gui} GuiObj - The `Gui` object that contains the controls to be arranged.
     * @param {String} Diagram - The string diagram that describes the arrangement of the controls.
     * @param {Number} [StartX] - The X coordinate used for the beginning of each row. If unset,
     * the X coordinate of the first control in the first row will be used.
     * @param {Number} [StartY] - The Y coordinate used for the controls in the top row. If unset,
     * the Y coordinate of the first control in the first row will be used.
     * @param {Number} [PaddingX] - The amount of padding to leave between controls on the X-axis.
     * If unset, the value of `GuiObj.MarginX` will be used.
     * @param {Number} [PaddingY] - The amount of padding to leave between controls on the Y-axis.
     * If unset, the value of `GuiObj.MarginY` will be used.
     * @return {Object} - An object with the following properties:
     * - **Left**: The leftmost X coordinate of the arranged controls.
     * - **Top**: The topmost Y coordinate of the arranged controls.
     * - **Right**: The rightmost X coordinate of the arranged controls.
     * - **Bottom**: The bottommost Y coordinate of the arranged controls.
     * - **Rows**: An array of objects representing each row in the diagram. Each object has the following properties:
     *   - **Left**: The leftmost X coordinate of the row.
     *   - **Top**: The topmost Y coordinate of the row.
     *   - **Right**: The rightmost X coordinate of the row.
     *   - **Bottom**: The bottommost Y coordinate of the row.
     *   - **Controls**: An array of controls in the row.
     * @throws {ValueError} - If the diagram string is invalid.
     */
    static Diagram(GuiObj, Diagram, StartX?, StartY?, PaddingX?, PaddingY?) {
        rci := 0xFFFD ; Replacment character
        ch := Chr(rci)
        while InStr(Diagram, ch) {
            ch := Chr(--rci)
        }
        if InStr(Diagram, '"') {
            Names := Map()
            Index := 0
            Pos := 1
            loop {
                if !RegExMatch(Diagram, '(?<=\s|^)"(?<text>.*?)(?<!\\)(?:\\\\)*+"', &Match, Pos) {
                    break
                }
                Pos := Match.Pos
                Names.Set(ch (++Index) ch, Match)
                Diagram := StrReplace(Diagram, Match[0], ch Index ch)
            }
        }
        Rows := StrSplit(RegExReplace(RegExReplace(Trim(Diagram, '`s`t`r`n'), '\R+', '`n'), '[`s`t]+', '`s'), '`n')
        loop Rows.Length {
            Rows[A_Index] := StrSplit(Trim(Rows[A_Index], '`s'), '`s')
        }
        if !IsSet(StartX) || !IsSet(StartY) {
            for Row in Rows {
                i := A_Index
                for Value in Row {
                    k := A_Index
                    if !IsNumber(Value) {
                        Name := Value
                        break 2
                    }
                }
            }
            if !IsSet(Name) {
                throw ValueError('Invalid diagram string input.', -1)
            }
            if i > 1 {
                throw ValueError('The first row in the diagram cannot contain only numbers.', -1)
            }
            _ProcValue(&Name)
            GuiObj[Name].GetPos(&cx, &cy)
            if !IsSet(StartX) {
                if k > 1 {
                    throw ValueError('The input diagram options does not include a ``StartX`` value,'
                    ' and the diagram string includes leading numbers on the top row, which is invalid.', -1)
                }
                StartX := cx
            }
            if !IsSet(StartY) {
                StartY := cy
            }
        }
        if !IsSet(PaddingX) {
            PaddingX := GuiObj.MarginX
        }
        if !IsSet(PaddingY) {
            PaddingY := GuiObj.MarginY
        }
        Output := { Left: X := StartX, Top: Y := StartY, Right: 0, Bottom: 0, Rows: _rows := [] }
        Right := 0
        for Row in Rows {
            if IsNumber(Row[1]) && Row.Length == 1 {
                Y += Row[1]
                continue
            }
            X := StartX
            while IsNumber(Row[1]) {
                X += Row.RemoveAt(1)
                if !Row.Length {
                    throw ValueError('It is invalid for a row to contain only numbers if the row contains'
                    ' more than one number.', -1)
                }
            }
            _rows.Push(row_info := { Left: X, Top: Y, Right: 0, Bottom: 0, Controls: [] })
            Height := 0
            for Value in Row {
                if IsNumber(Value) {
                    X += Value
                } else {
                    _ProcValue(&Value)
                    Ctrl := GuiObj[Value]
                    Ctrl.Move(X, Y)
                    Ctrl.GetPos(&ctrlx, , &ctrlw, &ctrlh)
                    X += ctrlw + PaddingX
                    Height := Max(Height, ctrlh)
                    row_info.Controls.Push(Ctrl)
                }
            }
            Right := Max(row_info.Right := ctrlx + ctrlw, Right)
            row_info.Bottom := row_info.Top + Height
            Y += Height + PaddingY
        }
        Output.Right := Right
        Output.Bottom := row_info.Bottom

        return Output

        _ProcValue(&Value) {
            if InStr(Value, ch) {
                Value := Names.Get(Value)['text']
            }
            Value := StrReplace(StrReplace(StrReplace(StrReplace(Value, '\\', '\')
                , '\r', '`r'), '\n', '`n'), '\"', '"')
        }
    }

    /**
     * @description - Arranges controls using a string diagram. You can use arbitrary symbols to
     * indicate a control in the diagram. Associate the symbols with the correct control using
     * a `Map` object.
     * - Rows are separated by newline characters.
     * - Columns are separated by spaces or tabs.
     * - Symbols cannot contain space, tab, carriage return, or line feed characters.
     * - Symbols cannot be completely numeric.
     * @example
     *  G := Gui()
     *  Symbols := Map()
     *  for Text in ['Back', 'Forward', 'Stop', 'Exit'] {
     *      btn := G.Add('Button', (A_Index == 1 ? 'Section' : 'ys'), Text)
     *      btn.Name := GetArbitraryName()
     *      Symbols.Set('@' A_Index, btn)
     *  }
     *  Diagram := '
     *  (
     *      @1 50 @2
     *      @2 50 @4
     *  )'
     *  Result := Align.DiagramFromSymbols(G, Diagram, Symbols)
     *  G.Show()
     *  ; account for non-client area
     *  G.GetPos(, , &w1, &h1)
     *  G.GetClientPos(, , &w2, &h2)
     *  G.Move(, , Result.Right + w1 - w2, Result.Bottom + h1 - h2)
     *
     *  GetArbitraryName() {
     *      s := ''
     *      loop 100 {
     *          s .= Chr(Random(1,1000))
     *      }
     *      return s
     *  }
     * @
     * @param {Gui} GuiObj - The `Gui` object that contains the controls to be arranged.
     * @param {String} Diagram - The string diagram that describes the arrangement of the controls.
     * @param {Map} Symbols - A `Map` object that associates symbols with controls. The values
     * should be `Gui.Control` objects (not control names).
     * @param {Number} [StartX] - The X coordinate used for the beginning of each row. If unset,
     * the X coordinate of the first control in the first row will be used.
     * @param {Number} [StartY] - The Y coordinate used for the controls in the top row. If unset,
     * the Y coordinate of the first control in the first row will be used.
     * @param {Number} [PaddingX] - The amount of padding to leave between controls on the X-axis.
     * If unset, the value of `GuiObj.MarginX` will be used.
     * @param {Number} [PaddingY] - The amount of padding to leave between controls on the Y-axis.
     * If unset, the value of `GuiObj.MarginY` will be used.
     * @return {Object} - An object with the following properties:
     * - **Left**: The leftmost X coordinate of the arranged controls.
     * - **Top**: The topmost Y coordinate of the arranged controls.
     * - **Right**: The rightmost X coordinate of the arranged controls.
     * - **Bottom**: The bottommost Y coordinate of the arranged controls.
     * - **Rows**: An array of objects representing each row in the diagram. Each object has the following properties:
     *   - **Left**: The leftmost X coordinate of the row.
     *   - **Top**: The topmost Y coordinate of the row.
     *   - **Right**: The rightmost X coordinate of the row.
     *   - **Bottom**: The bottommost Y coordinate of the row.
     *   - **Controls**: An array of controls in the row.
     * @throws {ValueError} - If the diagram string is invalid.
     */
    static DiagramFromSymbols(GuiObj, Diagram, Symbols, StartX?, StartY?, PaddingX?, PaddingY?) {
        Rows := StrSplit(RegExReplace(RegExReplace(Trim(Diagram, '`s`t`r`n'), '\R+', '`n'), '[`s`t]+', '`s'), '`n')
        loop Rows.Length {
            Rows[A_Index] := StrSplit(Trim(Rows[A_Index], '`s'), '`s')
        }
        if !IsSet(StartX) || !IsSet(StartY) {
            for Row in Rows {
                i := A_Index
                for Value in Row {
                    k := A_Index
                    if !IsNumber(Value) {
                        Name := Value
                        break 2
                    }
                }
            }
            if !IsSet(Name) {
                throw ValueError('Invalid diagram string input.', -1)
            }
            if i > 1 {
                throw ValueError('The first row in the diagram cannot contain only numbers.', -1)
            }
            Symbols.Get(Name).GetPos(&cx, &cy)
            if !IsSet(StartX) {
                if k > 1 {
                    throw ValueError('The input diagram options does not include a ``StartX`` value,'
                    ' and the diagram string includes leading numbers on the top row, which is invalid.', -1)
                }
                StartX := cx
            }
            if !IsSet(StartY) {
                StartY := cy
            }
        }
        if !IsSet(PaddingX) {
            PaddingX := GuiObj.MarginX
        }
        if !IsSet(PaddingY) {
            PaddingY := GuiObj.MarginY
        }
        Output := { Left: X := StartX, Top: Y := StartY, Right: 0, Bottom: 0, Rows: _rows := [] }
        Right := 0
        for Row in Rows {
            if IsNumber(Row[1]) && Row.Length == 1 {
                Y += Row[1]
                continue
            }
            X := StartX
            while IsNumber(Row[1]) {
                X += Row.RemoveAt(1)
                if !Row.Length {
                    throw ValueError('It is invalid for a row to contain only numbers if the row contains'
                    ' more than one number.', -1)
                }
            }
            _rows.Push(row_info := { Left: X, Top: Y, Right: 0, Bottom: 0, Controls: [] })
            Height := 0
            for Value in Row {
                if IsNumber(Value) {
                    X += Value
                } else {
                    Ctrl := Symbols.Get(Value)
                    Ctrl.Move(X, Y)
                    Ctrl.GetPos(&ctrlx, , &ctrlw, &ctrlh)
                    X += ctrlw + PaddingX
                    Height := Max(Height, ctrlh)
                    row_info.Controls.Push(Ctrl)
                }
            }
            Right := Max(row_info.Right := ctrlx + ctrlw, Right)
            row_info.Bottom := row_info.Top + Height
            Y += Height + PaddingY
        }
        Output.Right := Right
        Output.Bottom := row_info.Bottom
        return Output
    }

    static GetCenterHPos(Subject, Target) {
        Subject.GetPos(&X1, &Y1, &W1)
        Target.GetPos(&X2, , &W2)
        return X2 + W2 / 2 - W1 / 2
    }

    static GetCenterVPos(Subject, Target) {
        Subject.GetPos(&X1, &Y1, , &H1)
        Target.GetPos( , &Y2, , &H2)
        return Y2 + H2 / 2 - H1 / 2
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
        Params := [{ H: H, hWnd: List[-1].hWnd }]
        Params.Capacity := List.Length
        loop List.Length - 1 {
            List[A_Index].GetPos(, , &W, &H)
            Params.Push({ H: H, hWnd: List[A_Index].hWnd })
            if W > GW
                GW := W
        }
        for ps in Params {
            if !(hDwp := DllCall('DeferWindowPos'
                , 'ptr', hDwp
                , 'ptr', ps.hWnd
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

    static GroupWidthCb(G, Callback, ApproxCount := 2) {
        if !(hDwp := DllCall('BeginDeferWindowPos', 'int', ApproxCount, 'ptr')) {
            throw Error('``BeginDeferWindowPos`` failed.', -1)
        }
        GW := -99999
        Params := []
        Params.Capacity := ApproxCount
        for Ctrl in G {
            Ctrl.GetPos(, , &W, &H)
            if Callback(&GW, W, Ctrl) {
                Params.Push({ H: H, hWnd: Ctrl.hWnd })
                break
            }
        }
        for ps in Params {
            if !(hDwp := DllCall('DeferWindowPos'
                , 'ptr', hDwp
                , 'ptr', ps.hWnd
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

    /**
     * @description - Standardizes a group's height to the largest height in the group.
     * @param {Array} List - An array of windows to be standardized. This function assumes there are
     * no unset indices.
     */
    static GroupHeight(List) {
        if !(hDwp := DllCall('BeginDeferWindowPos', 'int', List.Length, 'ptr')) {
            throw Error('``BeginDeferWindowPos`` failed.', -1)
        }
        List[-1].GetPos(, , &W, &GH)
        Params := [{ W: W, hWnd: List[-1].hWnd }]
        Params.Capacity := List.Length
        loop List.Length - 1 {
            List[A_Index].GetPos(, , &W, &H)
            Params.Push({ W: W, hWnd: List[A_Index].hWnd })
            if H > GH
                GH := H
        }
        for ps in Params {
            if !(hDwp := DllCall('DeferWindowPos'
                , 'ptr', hDwp
                , 'ptr', ps.hWnd
                , 'ptr', 0
                , 'int', 0
                , 'int', 0
                , 'int', ps.W
                , 'int', GH
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

    static GroupHeightCb(G, Callback, ApproxCount := 2) {
        if !(hDwp := DllCall('BeginDeferWindowPos', 'int', ApproxCount, 'ptr')) {
            throw Error('``BeginDeferWindowPos`` failed.', -1)
        }
        GH := -99999
        Params := []
        Params.Capacity := ApproxCount
        for Ctrl in G {
            Ctrl.GetPos(, , &W, &H)
            if Callback(&GH, H, Ctrl) {
                Params.Push({ W: W, hWnd: Ctrl.hWnd })
                break
            }
        }
        for ps in Params {
            if !(hDwp := DllCall('DeferWindowPos'
                , 'ptr', hDwp
                , 'ptr', ps.hWnd
                , 'ptr', 0
                , 'int', 0
                , 'int', 0
                , 'int', ps.W
                , 'int', GH
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

    /**
     * @description - Moves a window (`Subject`) adjacent to another window (`Target`) while
     * ensuring that `Subject` stays within the monitor's work area. `Align.MoveAdjacent` compares
     * the size of `Subject` with the amount of space between `Target` and the edges of the monitor.
     * If `Subject` can fit within the available space, `Align.MoveAdjacent` moves the window into
     * the empty space and aligns the opposite axis with `Subject` so their midpoints align.
     *
     * `Align.MoveAdjacent` searches in this order: Left, Top, Right, Bottom.
     *
     * If `Align.MoveAdjacent` does not find a large enough empty area to move `Target` into,
     * it usess the `DefaultX` and `DefaultY` values instead. `Align.MoveAdjacent` also returns
     * `1` whenever it fails to find a viable space into which to move the window.
     *
     * If you prefer to keep it dynamic, you can set `DefaultX` with a callable object that expects
     * an object as its only parameter. The function should move `Subject`, and optionally return
     * a value. The object will have the following properties:
     * - **Subject, Target, PaddingX, PaddingY, DefaultX,** and **DefaultY** are all included.
     * - **Mon**: The `QuickMon` object that is generated by the function.
     * - **SubjectDimensions** and **TargetDimensions**, both objects with { X, Y, W, H } properties
     * which are the position and size of the windows.
     *
     * The return value from the function is returned by `Align.MoveAdjacent` to the caller.
     *
     * Set `DefaultX` with zero or an empty string to direct `Align.MoveAdjacent` to skip moving
     * `Subject` if no viable space is found. `Align.MoveAdjacent` will still return `1`, but without
     * calling `Subject.Move`.
     *
     * `Align.MoveAdjacent` will also return `1` if the call to `MonitorFromWindow` fails, which
     * would likely be caused by `Target` having an invalid window handle, or if `Target` is not within
     * the visible area of any monitor.
     * @param {*} Subject - The object associated with the window that will be moved.
     * @param {*} Target - The object associated with the window that will be used as a reference.
     * @param {Number} PaddingX - The amount of padding to leave between `Subject` and `Target` on the X-axis.
     * @param {Number} PaddingY - The amount of padding to leave between `Subject` and `Target` on the Y-axis.
     * @param {Number|Func|Object} DefaultX - The X coordinate to move `Subject` to if no viable space is found,
     * or a callable object that will be called with the parameters described above in the function
     * description. Set to zero or an empty string to skip moving `Subject` if no viable space is found.
     * @param {Number} DefaultY - The Y coordinate to move `Subject` to if no viable space is found.
     * @returns {Integer} - Returns `1` if no viable space is found, or the return value of the callable object
     * if one is provided. Returns an empty string if the function is successful.
     */
    static MoveAdjacent(Subject, Target, PaddingX := 20, PaddingY := 20, DefaultX := 100, DefaultY := 100) {
        if hMon := DllCall('User32.dll\MonitorFromWindow', 'ptr', Target.hWnd, 'int', 0, 'ptr') {
            Mon := QuickMon(hMon)
            Target.GetPos(&tarX, &tarY, &tarW, &tarH)
            Subject.GetPos(&subX, &subY, &subW, &subH)
            if tarX - subW - PaddingX >= Mon.LW {
                Subject.Move(tarX - subW - PaddingX)
                _SetY()
            } else if tarY - subH - PaddingY >= Mon.TW {
                Subject.Move(, tarY - subH - PaddingY)
                _SetX()
            } else if tarX + tarW + PaddingX + subW <= Mon.RW {
                Subject.Move(tarX + tarW + PaddingX)
                _SetY()
            } else if tarY + tarH + PaddingY + subH <= Mon.BW {
                Subject.Move(, tarY + tarH + PaddingY)
                _SetX()
            } else {
                return _Default()
            }
        } else {
            return _Default()
        }

        _Default() {
            if DefaultX {
                if IsObject(DefaultX) {
                    return DefaultX({ Subject: Subject, Target: Target, PaddingX: PaddingX, PaddingY: PaddingY
                    , DefaultX: DefaultX, DefaultY: DefaultY, Mon: Mon, SubjectDimensions: { X: subX
                    , Y: subY, W: subW, H: subH }, TargetDimensions: { X: tarX, Y: tarY, W: tarW, H: tarH } })
                } else {
                    Subject.Move(DefaultX, DefaultY)
                }
            }
            return 1
        }
        _SetX() {
            x := this.GetCenterHPos(Subject, Target)
            if x < Mon.LW {
                x := Mon.LW
            } else if x + subW > Mon.RW {
                x := Mon.RW - subW
            }
            Subject.Move(x)
        }
        _SetY() {
            y := this.GetCenterVPos(Subject, Target)
            if y < Mon.TW {
                y := Mon.TW
            } else if y + subH > Mon.BW {
                y := Mon.BW - subH
            }
            Subject.Move(, y)
        }
    }

    /**
     * @description - Allows the usage of the `_S` suffix for each function call. When you include
     * `_S` at the end of any function call, the function will call `SetThreadDpiAwarenessContext`
     * prior to executing the function. The value used will be `Align.DPI_AWARENESS_CONTEXT`, which
     * is initialized at `-4`, but you can change it to any value.
     * @example
        Align.DPI_AWARENESS_CONTEXT := -5
     * @
     */
    static __Call(Name, Params) {
        Split := StrSplit(Name, '_')
        if this.HasMethod(Split[1]) && Split[2] = 'S' {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', this.DPI_AWARENESS_CONTEXT, 'ptr')
            if Params.Length {
                return this.%Split[1]%(Params*)
            } else {
                return this.%Split[1]%()
            }
        } else {
            throw PropertyError('Property not found.', -1, Name)
        }
    }
    ; static __New() {
    ;     if this.Prototype.__Class == 'Align' {
    ;         this.DefineProp('SelectControlsHelperCollection', { Value: Map() })
    ;         this.SelectControlsHelperCollection.CaseSense := false
    ;         this.DefineProp('SelectControlsDefault', { Value: {
    ;             Capacity: 100
    ;           , ExcludeNames: ''
    ;           , ExcludeTypes: ''
    ;           , InfoWindowMessage: ''
    ;           , InfoWindowTitle: 'SelectControls'
    ;           , RectHighlightOpt: ''
    ;         } })
    ;     }
    ; }

    /**
     * @description - Creates a proxy for non-AHK windows.
     * @param {hWnd} hWnd - The handle of the window to be proxied.
     */
    __New(hWnd) {
        this.hWnd := hWnd
    }

    GetPos(&X?, &Y?, &W?, &H?) {
        WinGetPos(&X, &Y, &W, &H, this.hWnd)
    }

    Move(X?, Y?, W?, H?) {
        WinMove(X ?? unset, Y ?? unset, W ?? unset, H ?? unset, this.hWnd)
    }

    __Call(Name, Params) {
        Split := StrSplit(Name, '_')
        if this.HasMethod(Split[1]) && Split[2] = 'S' {
            DllCall('SetThreadDpiAwarenessContext', 'ptr', Align.DPI_AWARENESS_CONTEXT, 'ptr')
            if Params.Length {
                return this.%Split[1]%(Params*)
            } else {
                return this.%Split[1]%()
            }
        } else {
            throw PropertyError('Property not found.', -1, Name)
        }
    }
}

/**
 * @classdesc - This is a simplified version of a class from another script I'm working on.
 * `QuickMon` is a buffer object that is intended to be passed to `GetMonitorInfo`. `QuickMon`
 * contains additional properties to simplify usage of the resulting values.
 */
class QuickMon extends Buffer {
    __New(hMon?) {
        this.Size := 40
        NumPut('int', 40, this)
        if IsSet(hMon) {
            this.hMon := hMon
            if !DllCall('user32\GetMonitorInfo', 'ptr', hMon, 'ptr', this, 'int') {
                throw OSError()
            }
        }
    }

    Dpi {
        Get {
            if !DllCall('Shcore\GetDpiForMonitor'
              , 'ptr', this.hMon
              , 'UInt', 0
              , 'UInt*', &DpiX := 0
              , 'UInt*', &DpiY := 0
              , 'UInt'
            ) {
                return DpiX
            } else {
                throw OSError()
            }
        }
    }

    ; Top left coordinate
    TL => { L: this.L, T: this.T }
    ; Bottom right coordinate
    BR => { R: this.R, B: this.B }
    ; Left
    L => NumGet(this, 4, 'Int')
    ; X, same as L
    X => NumGet(this, 4, 'Int')
    ; Top
    T => NumGet(this, 8, 'Int')
    ; Y, same as T
    Y => NumGet(this, 8, 'Int')
    ; Right
    R => NumGet(this, 12, 'Int')
    ; Bottom
    B => NumGet(this, 16, 'Int')
    ; Width
    W => this.R - this.L
    ; Height
    H => this.B - this.T
    ; The window's midpoint along the X-axis relative to the screen
    MidX => (this.R - this.L) / 2
    ; The window's midpoint along the Y-axis relative to the screen
    MidY => (this.B - this.T) / 2
    ; Returns nonzero if the monitor associated with this object is the primary monitor
    Primary => NumGet(this, 36, 'Uint')

    ; The below properties are the same as the above but for the monitor's "work area".
    TLW => { L: this.LW, T: this.TW }
    BRW => { R: this.RW, B: this.BW }
    LW => NumGet(this, 20, 'int')
    XW => NumGet(this, 20, 'Int')
    TW => NumGet(this, 24, 'int')
    YW => NumGet(this, 24, 'Int')
    RW => NumGet(this, 28, 'int')
    BW => NumGet(this, 32, 'int')
    WW => this.RW - this.LW
    HW => this.BW - this.TW
    MidXW => (this.RW - this.LW) / 2
    MidYW => (this.BW - this.TW) / 2
}
