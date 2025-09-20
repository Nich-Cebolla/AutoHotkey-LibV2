
#include ..\Heapsort.ahk
#include ..\rejected-Heapsort.ahk
#include ..\Quicksort.ahk


Array.Prototype.DefineProp('Find', { Call: TestSort_Array_FInd })
Array.Prototype.DefineProp('Reduce', { Call: TestSort_Array_Reduce })
Array.Prototype.DefineProp('ForEach', { Call: TestSort_Array_ForEach })

class test {
    static __New() {
        this.DeleteProp('__New')
        hMod := DllCall('GetModuleHandleW', 'wstr', 'user32', 'ptr')
        global g_proc_user32_BeginDeferWindowPos := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'BeginDeferWindowPos', 'ptr')
        , g_proc_user32_DeferWindowPos := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'DeferWindowPos', 'ptr')
        , g_proc_user32_EndDeferWindowPos := DllCall('GetProcAddress', 'ptr', hMod, 'astr', 'EndDeferWindowPos', 'ptr')
        , g_TestSort_swp_flags := 0x0002 | 0x0010 | 0x0200 | 0x0004 ; SWP_NOMOVE | SWP_NOACTIVATE | SWP_NOOWNERZORDER | SWP_NOZORDER
        , ObjGetOwnPropDesc := Object.Prototype.GetOwnPropDesc
        this.Tabs := [ 'Even', 'Exponential', 'Gaussian', 'Weighted', 'Quicksort', 'Heapsort_kary' ]
        this.OptTab := ' w800'
        this.Inputs := Map()
        this.Inputs.CaseSense := false
        this.Inputs.Set(
            'Weighted', [ 'Input', 'Length' ]
          , 'Gaussian', [ 'Mean', 'StdDev', 'Length' ]
          , 'Exponential', [ 'Lambda', 'Lower', 'Upper', 'Length' ]
          , 'Even', [ 'Min', 'Max', 'Length', 'AsIntegers', 'Digits' ]
          , 'Quicksort', [ 'ArrSizeThreshold' ]
          , 'Heapsort_kary', [ 'k' ]
        )
        this.OptFont := 's11 q5'
        this.FontFamily := GetFirstFont('Consolas,Cascadia Mono,Lucida Console,Terminal')
        this.OptListView := ' Checked'
        this.OptMakeInputControlGroup :=  {
            getButton: false
          , editWidth: 150
          , paddingX: 5
          , paddingY: 3
          , setButton: false
          , startX: '' ; set in Call
          , startY: ''
        }
        this.FunctionCheckboxes := [ 'Heapsort', 'Heapsort_Original', 'Heapsort_kary', 'Quicksort' ]
        this.CheckboxPaddingY := 2
        this.OptIgEdit := ' r10'
        this.OptIgError := ' r10 +HScroll -Wrap'
        this.OptEditOutput := ' r15 -Wrap +Hscroll'
        this.OptItemScroller := {
            CallbackClear: TestSort_CallbackClear
          , NormalizeButtonWidths: false
          , paddingX: 5
          , paddingY: 3
          , startX: ''
          , startY: ''
        }
        this.OptItemScroller.AllFontFamily := this.FontFamily
        this.OptItemScroller.AllFontOpt := this.OptFont
        this.History := []
        this.OptEditIterations := ' w75'
        this.CheckboxPadding := 3
        this.ContextMenu := TestSort_ListviewMenu(Menu())
        this.Buttons := [ 'Save params', 'Make input', 'Make series', 'Call' ]
        this.MenuBar := TestSort_MenuBar(MenuBar())
        this.PathConfig := this.PathExport := ''
        this.TimeFormat := 'yyyy-MM-dd HH:mm:ss'
        this.MaxHistory := 10000
        optStringifyAll := {
            CorrectFloatingPoint: true
          , EnumTypeMap: TestSort_SA_MapHelper(false, 2, 'Array', 1)
          , PropsTypeMap: TestSort_SA_MapHelper(false, 1)
          , StopAtTypeMap: TestSort_SA_MapHelper(false, '-Object', 'Class', '-Class', 'Array', '-Array', 'Map', '-Map')
          , ExcludeProps: '__Init,Prototype'
          , NewlineDepthLimit: 3
          , Newline: '`r`n'
        }
        optStringifyAllOnScroll := {
            ExcludeProps: 'linearTickTotal,all,linearComparisonsTotal'
        }
        ObjSetBase(optStringifyAllOnScroll, optStringifyAll)
        this.OptStringifyAllOnScroll := TestSort_StringifyAll.Options(optStringifyAllOnScroll)
        this.OptStringifyAll := TestSort_StringifyAll.Options(optStringifyAll)
        this.FunctionsWithParams := 'Quicksort,Heapsort_kary'
        this.OptionCheckbox := [ 'Save config on exit', 'Validate values' ]
        this.OptionField := Map('Show top', 20)
        this.OptEditOptionField := ' w75'
    }
    static Call(PathConfig?, Encoding := 'utf-8') {
        this.Encoding := Encoding
        g := this.g := Gui('+Resize', , this)
        g.OnEvent('Close', 'HCloseGui')
        g.MenuBar := this.MenuBar.Menu
        ctrl := g.ctrl := {}
        lv := ctrl.lv := Map()
        g.SetFont(this.OptFont, this.FontFamily || 'Mono')
        tab := ctrl.tab := g.Add('Tab2', this.OptTab, this.Tabs)
        tab.UseTab(this.Tabs[1])
        txt := g.Add('Text')
        txt.GetPos(&txtx, &txty)
        optMakeInputControlGroup := this.OptMakeInputControlGroup
        tab.x := optMakeInputControlGroup.startX := txtx
        tab.y := optMakeInputControlGroup.startY := txty
        paddingX := optMakeInputControlGroup.paddingX
        checkboxPaddingY := this.CheckboxPaddingY

        ; Adding the listview controls and evaluating the height of the tab control
        tab.GetPos(&tabx, &taby, &tabw)
        tabMarginX := txtx - tabx
        mostElements := 0
        mostElementsDistributionType := 0
        for distributionType, arr in this.Inputs {
            tab.UseTab(distributionType)
            optMakeInputControlGroup.nameSuffix := distributionType
            ctrl.%distributionType% := MakeInputControlGroup(g, arr, optMakeInputControlGroup)
            if arr.Length > mostElements {
                mostElements := arr.Length
                mostElementsDistributionType := distributionType
            }
            _len := 0
            _name := ''
            for name in arr {
                if StrLen(name) > _len {
                    _len := Max(StrLen(name), _len)
                    _name := name
                }
            }
            ctrl.%distributionType%.Get(_name).Edit.GetPos(&x, , &w)
            lvx := x + w + paddingX
            _lv := ctrl.%distributionType%.lv := g.Add('ListView', 'x' lvx ' y' txty ' w' (tabw - lvx - tabMarginX * 2) this.OptListView, arr)
            lv.Set(distributionType, _lv)
            loop arr.Length {
                _lv.ModifyCol(A_Index, 'AutoHdr')
            }
            _lv.OnEvent('ContextMenu', this.ContextMenu)
        }
        bottom := 0
        for distributionType, row in ctrl.%mostElementsDistributionType% {
            row.Edit.GetPos(, &y, , &h)
            bottom := Max(y + h, bottom)
        }
        tabh := bottom + g.MarginY
        tab.Move(, , tabw, bottom + g.MarginY)

        tab.UseTab()

        ctrl.btnSave := g.Add('Button', 'x' tabx ' y' (tabh + g.MarginY * 2) ' Section', 'Save params')
        ctrl.btnSave.OnEvent('Click', 'HClickButtonSaveParams')
        ctrl.btnMakeInput := g.Add('Button', 'ys', 'Make input')
        ctrl.btnMakeInput.OnEvent('Click', 'HClickButtonMakeInput')
        ctrl.btnCall := g.Add('Button', 'ys', 'Call')
        ctrl.btnCall.OnEvent('Click', 'HClickButtonCall')
        ctrl.edtIterations := g.Add('Edit', 'ys' this.OptEditIterations, '1')
        ctrl.edtIterations.OnEvent('Change', 'HChangeEditIterations')
        functionCheckbox := ctrl.functionCheckbox := {}
        functionCheckboxNames := Heapsort(this.FunctionCheckboxes, (a, b) => StrLen(a) - StrLen(b))
        name := this.FunctionCheckboxes[1]
        functionCheckbox.%name% := g.Add('Checkbox', 'Section ys', name)
        functionCheckbox.%name%.OnEvent('Click', 'HClickFunctionCheckbox')
        functionCheckbox.%name%.GetPos(&chkx1, &chky1, &chkw1, &chkh1)
        functionCheckbox.%name%.name := name
        y1 := chky1
        y2 := chky1 + chkh1 + checkboxPaddingY
        name := this.FunctionCheckboxes[2]
        functionCheckbox.%name% := g.Add('Checkbox', 'x' chkx1 ' y' y2, name)
        functionCheckbox.%name%.OnEvent('Click', 'HClickFunctionCheckbox')
        functionCheckbox.%name%.GetPos(, , &chkw2)
        functionCheckbox.%name%.name := name
        i := 1
        x := chkx1 + Max(chkw2, chkw1) + g.MarginX
        loop this.FunctionCheckboxes.Length - 2 {
            name := this.FunctionCheckboxes[A_Index + 2]
            if i == 1 {
                i := 2
                functionCheckbox.%name% := g.Add('Checkbox', 'x' x ' y' y1, name)
                functionCheckbox.%name%.GetPos(, , &chkw1)
            } else {
                i := 1
                functionCheckbox.%name% := g.Add('Checkbox', 'x' x ' y' y2, name)
                functionCheckbox.%name%.GetPos(, , &chkw2)
                x += Max(chkw2, chkw1) + g.MarginX
            }
            functionCheckbox.%name%.OnEvent('Click', 'HClickFunctionCheckbox')
            functionCheckbox.%name%.name := name
        }

        ctrl.btnSave.GetPos(, &btny, , &btnh)
        y := startY := btny + btnh + g.MarginY
        x := g.MarginX
        optionCheckbox := ctrl.optionCheckbox := {}
        width := 0
        for name in this.OptionCheckbox {
            optionCheckbox.%name% := g.Add('Checkbox', 'x' x ' y' y, name)
            optionCheckbox.%name%.GetPos(, , &w, &h)
            width := Max(width, w)
            y += h + checkboxPaddingY
        }
        y += checkboxPaddingY
        optionField := ctrl.optionField := {}
        labelWidth := 0
        for name in this.OptionField {
            optionField.%name% := { label: g.Add('Text', 'x' x ' y' Round(y, 0), name) }
            optionField.%name%.label.GetPos(, , &w, &h)
            labelWidth := Max(labelWidth, w)
            y += h + g.MarginY * 0.5
        }
        edtx := x + labelWidth + g.MarginX
        for name, default in this.OptionField {
            optionField.%name%.label.GetPos(, &lbly)
            optionField.%name%.edit := g.Add('Edit', 'x' edtx ' y' lbly this.OptEditOptionField, default)
        }
        for name in this.OptionField {
            optionField.%name%.edit.GetPos(, , &edtw)
        }
        x := Max(edtx + edtw, x + width) + g.MarginX
        ctrl.output := g.Add('Edit', 'x' x ' y' startY this.OptEditOutput)
        ctrl.output.GetPos(, , , &edth)
        optItemScroller := this.OptItemScroller
        optItemScroller.startX := x
        optItemScroller.startY := startY + edth + g.MarginY
        ctrl.Scroller := TestSort_ItemScroller(g, 0, TestSort_OnScroll, optItemScroller)
        bottom := 0
        for _ctrl in ctrl.Scroller {
            _ctrl.GetPos(, &y, , &h)
            bottom := Max(bottom, y + h)
        }

        if IsSet(PathConfig) {
            this.LoadConfig(PathConfig)
        }

        g.Show('h' (bottom + g.MarginY))

        g.GetClientPos(, , &gw, &gh)
        ctrl.output.Move(, , gw - g.MarginX * 2 - x)
        onSizeControlsBoth := g.OnSizeControlsBoth := []
        onSizeControlsX := g.OnSizeControlsX := [tab]
        ; onSizeControlsY := g.OnSizeControlsY := []
        for distributionType, _lv in lv {
            onSizeControlsX.Push(_lv)
        }
        for _ctrl in onSizeControlsX {
            _ctrl.GetPos(, , &w, &h)
            _ctrl.DiffX := gw - w
            _ctrl.H := h
        }
        onSizeControlsBoth.Push(ctrl.output)
        for _ctrl in onSizeControlsBoth {
            _ctrl.GetPos(, , &w, &h)
            _ctrl.DiffY := gh - h
            _ctrl.DiffX := gw - w
        }
        g.OnEvent('Size', 'HSize')
    }
    static ShowHistogram(row, bins?) {
        g := this.g
        ctrl := g.ctrl
        tab := ctrl.tab
        distributionType := tab.text
        params := this.GetInputFromListview(row)
        arr := Generate%distributionType%Distribution(params*)
        if !IsSet(bins) {
            response := InputBox('How many bins?')
            if response.Result == 'Cancel' {
                return
            }
            bins := response.Value
        }
        arr := Generate%distributionType%Distribution(params*)
        ctrl.output.Text := TestSort_Histogram(arr, bins, 30)
    }

    static HClickButtonCall(btn, *) {
        g := btn.Gui
        ctrl := g.ctrl
        output := ctrl.output
        tab := ctrl.tab
        distributionType := tab.Text
        group := ctrl.%distributionType%
        _lv := group.lv
        n := ctrl.edtIterations.Text
        if !IsNumber(n) {
            n := ctrl.edtIterations.Text := RegExReplace(n, '\D', '')
            if !IsNumber(n) {
                if !ctrl.edtIterations.HasOwnProp('Highlight') {
                    ctrl.edtIterations.Highlight := RectHighlight(ctrl.edtIterations, { Duration: 0 }, false)
                }
                ctrl.edtIterations.Highlight.Call()
                MsgBox('Enter the number of iterations to perform in the box.')
                return
            }
        }
        result := {
            distributionType: distributionType
          , series: n
          , totalTick: 0
          , totalComparisons: 0
          , all: []
        }
        row := _lv.GetNext(, 'C')
        if row {
            paramsDistribution := result.paramsDistribution := this.GetInputFromListview(row)
        } else {
            if _lv.GetCount() == 0 {
                paramsDistribution := result.paramsDistribution := this.GetInput()
            } else if _lv.GetCount() == 1 {
                paramsDistribution := result.paramsDistribution := this.GetInputFromListview(1)
                _lv.Modify(1, '+Check')
            } else {
                MsgBox('Select an array item in the listview')
                return
            }
        }
        fn := this.GetFunc(&compare)
        if !fn {
            MsgBox('Select a function by checking one of the checkboxes.')
            return
        }
        result.function := fn.Name
        if InStr(',' this.FunctionsWithParams ',', ',' fn.Name ',') {
            paramsFunction := result.paramsFunction := this.GetparamsFunction(fn.Name)
            this.GetParamText(&paramTextFunction, fn.Name, paramsFunction)
            result.paramTextFunction := paramTextFunction
        } else {
            paramsFunction := result.paramsFunction := []
            result.paramTextFunction := ''
        }
        this.GetParamText(&paramTextDistribution, distributionType, paramsDistribution)
        if IsSet(Generate%distributionType%Distribution) {
            distributionsFn := Generate%distributionType%Distribution
        } else {
            MsgBox('Switch the tab to one of the distribution tabs to indicate which distribution to use.')
            return
        }
        result.paramTextDistribution := paramTextDistribution

        ; Check the params to set if any are step params
        stepParams := []
        for param in paramsDistribution {
            if !IsObject(param) && SubStr(param, 1, 1) == '*' {
                stepParams.Push({ param: param, index: A_Index, isDistribution: true })
            }
        }
        stepParams.distributionEnd := stepParams.Length
        for param in paramsFunction {
            if !IsObject(param) && SubStr(param, 1, 1) == '*' {
                stepParams.Push({ param: param, index: A_Index, isDistribution: false })
            }
        }
        pattern_step := 'iS){}[^-.\d]*([-.\d]+)'
        for param in stepParams {
            for detail in [ 'step', 'start', 'end' ] {
                if !RegExMatch(param.param, Format(pattern_step, detail), &match) {
                    MsgBox('The step parameter definition must contain "step", "start", and "end" followed by a number in any order.')
                    return
                }
                param.%detail% := Number(match[1])
            }
        }
        flag_validateValues := ctrl.optionCheckbox.%'Validate values'%.Value
        ProcessSetPriority('H')
        result.startTime := A_Now
        result.start := A_TickCount
        if stepParams.Length {
            result.stepParams := stepParams
            result.iterations := _CountIterations()
            this.GetStepParams(stepParams, paramsDistribution, paramsFunction, &currentDistribution, &currentFunction)
            i := k := 0
            seriesResults := result.seriesResults := []
            linearTickTotal := result.linearTickTotal := []
            linearComparisonsTotal := result.linearComparisonsTotal := []
            linearTickTotal.Capacity := linearComparisonsTotal.Capacity := result.iterations
            loop result.iterations {
                linearTickTotal.Push(0)
                linearComparisonsTotal.Push(0)
            }
            result.header := (
                'Distribution type: ' distributionType '`r`n'
                'Start time: ' FormatTime(result.startTime, this.TimeFormat) '`r`n'
                'Function: ' fn.Name '`r`n'
                'Total series: ' n '`r`n'
                'Iterations per series: ' result.iterations '`r`n'
                'Total iterations: ' (n * result.iterations) '`r`n'
                'Current series: {1}`r`n'
                'Current series iteration: {2}`r`n'
                'Current iteration overall: {3}`r`n`r`n'
                'Status: {4}'
            )
            loop n {
                ++i
                seriesResults.Push({
                    starttime: A_Now
                  , start: A_TickCount
                  , series: i
                  , tickTotal: 0
                  , comparisonsTotal: 0
                })
                loop result.iterations {
                    ++k
                    compare.comparisons := 0
                    output.Text := Format(result.header, i, A_Index, k, 'Generating array')
                    arr := distributionsFn(currentDistribution*)
                    len := arr.Length
                    if flag_validateValues {
                        clone := arr.Clone()
                    }
                    output.Text := Format(result.header, i, A_Index, k, 'Calling ' fn.Name)
                    start := A_TickCount
                    arr := fn(arr, compare, currentFunction*)
                    end := A_TickCount
                    output.Text := Format(result.header, i, A_Index, k, 'Validating output')
                    if arr.Length !== len {
                        output.Text := A_Index ': Validating array failed, result array length was incorrect. Operation ended'
                        return
                    }
                    if this.ValidateArray(arr) {
                        output.Text := A_Index ': Validating array failed, values were out of order. Operation ended'
                        return
                    }
                    if flag_validateValues {
                        if this.ValidateValues(clone, arr) {
                            output.Text := A_Index ': Validating values failed, not all values were present in the result array. Operation ended'
                            return
                        }
                    }
                    result.totalTick += end - start
                    result.totalComparisons += compare.Comparisons
                    linearTickTotal[A_Index] += end - start
                    linearComparisonsTotal[A_Index] += compare.Comparisons
                    seriesResults[i].tickTotal += end - start
                    seriesResults[i].comparisonsTotal += compare.Comparisons
                    result.all.Push({
                        comparisons: compare.Comparisons
                      , overallIteration: k
                      , series: i
                      , seriesIteration: A_Index
                      , tick: end - start
                    })
                    switch this.ProcessStepParams(stepParams, currentDistribution, 1, stepParams.distributionEnd) {
                        case 1: ; do nothing
                        case 2: break
                        case 3:
                            switch this.ProcessStepParams(stepParams, currentFunction, stepParams.distributionEnd + 1, stepParams.Length) {
                                case 1: ; do nothing
                                case 2: break
                                case 3: throw Error('``_ProcessStepParams`` should not return 3 here.', -1)
                            }
                    }
                }
                seriesResults[i].end := A_TickCount
                seriesResults[i].endTime := A_Now
            }
        } else {
            result.stepParams := false
            result.header := (
                'Distribution type: ' distributionType '`r`n'
                'Start time: ' FormatTime(result.startTime, this.TimeFormat) '`r`n'
                'Function: ' fn.Name '`r`n'
                'Total iterations: ' n '`r`n'
                'Current series: {1}`r`n'
                'Status: {2}'
            )
            loop n {
                compare.comparisons := 0
                output.Text := Format(result.header, A_Index, 'Generating array')
                arr := distributionsFn(paramsDistribution*)
                len := arr.Length
                if flag_validateValues {
                    clone := arr.Clone()
                }
                output.Text := Format(result.header, A_Index, 'Calling ' fn.Name)
                start := A_TickCount
                arr := fn(arr, compare, paramsFunction*)
                end := A_TickCount
                output.Text := Format(result.header, A_Index, 'Validating output')
                if arr.Length !== len {
                    output.Text := A_Index ': Validating array failed, result array length was incorrect. Operation ended'
                    return
                }
                if this.ValidateArray(arr) {
                    output.Text := A_Index ': Validating array failed, values were out of order. Operation ended'
                    return
                }
                if flag_validateValues {
                    if this.ValidateValues(clone, arr) {
                        output.Text := A_Index ': Validating values failed, not all values were present in the result array. Operation ended'
                        return
                    }
                }
                result.totalTick += end - start
                result.totalComparisons += compare.Comparisons
                result.all.Push({
                    comparisons: compare.Comparisons
                  , series: A_Index
                  , tick: end - start
                })
            }
        }
        result.end := A_TickCount
        result.endTime := A_Now
        ProcessSetPriority('N')
        this.HistoryAdd(result)

        return

        _CountIterations() {
            this.GetStepParams(stepParams, paramsDistribution, paramsFunction, &currentDistribution, &currentFunction)
            k := 0
            loop {
                ++k
                switch this.ProcessStepParams(stepParams, currentDistribution, 1, stepParams.distributionEnd) {
                    case 1: ; do nothing
                    case 2: break
                    case 3:
                        switch this.ProcessStepParams(stepParams, currentFunction, stepParams.distributionEnd + 1, stepParams.Length) {
                            case 1: ; do nothing
                            case 2: break
                            case 3: throw Error('``_ProcessStepParams`` should not return 3 here.', -1)
                        }
                }
            }
            return k
        }
    }
    static ValidateValues(clone, arr) {
        qf := TestSort_QuickFind_Equality(arr)
        for item in clone {
            if i := qf.Find(item) {
                arr.RemoveAt(i)
            } else {
                return 1
            }
        }
    }

    static HCloseGui(g, *) {
        ctrl := g.ctrl
        if ctrl.optionCheckbox.%'Save config on exit'%.Value && this.PathConfig {
            this.SaveConfig(false)
        }
        g.Destroy()
        ExitApp()
    }

    static ProcessStepParams(stepParams, currentParams, indexStart, indexEnd) {
        loop indexEnd - indexStart + 1 {
            param := stepParams[indexStart]
            if currentParams[param.index] >= param.end {
                if A_Index == stepParams.Length {
                    return 2
                }
                currentParams[param.index] := param.start
                indexStart++
            } else {
                currentParams[param.index] += param.step
                return 1
            }
        }
        return 3
    }

    static GetParamsFromIterationIndex(result, listIndex) {
        stepParams := result.stepParams
        paramsDistribution := result.paramsDistribution
        paramsFunction := result.paramsFunction
        this.GetStepParams(stepParams, paramsDistribution, paramsFunction, &currentDistribution, &currentFunction)
        list := []
        list.Capacity := listIndex.Length
        i := 1
        if stepParams.distributionEnd {
            loop listIndex[-1] {
                if listIndex[i] = A_Index {
                    ++i
                    list.Push({ distribution: currentDistribution.Clone(), function: currentFunction.Clone() })
                }
                switch this.ProcessStepParams(stepParams, currentDistribution, 1, stepParams.distributionEnd) {
                    case 1: ; do nothing
                    case 2: break
                    case 3:
                        switch this.ProcessStepParams(stepParams, currentFunction, stepParams.distributionEnd + 1, stepParams.Length) {
                            case 1: ; do nothing
                            case 2: break
                            case 3: throw Error('``_ProcessStepParams`` should not return 3 here.', -1)
                        }
                }
            }
        } else {
            loop listIndex[-1]  {
                if listIndex[i] = A_Index {
                    ++i
                    list.Push({ distribution: currentDistribution.Clone(), function: currentFunction.Clone() })
                }
                switch this.ProcessStepParams(stepParams, currentFunction, 1, stepParams.Length) {
                    case 1: ; do nothing
                    case 2: break
                    case 3: throw Error('``_ProcessStepParams`` should not return 3 here.', -1)
                }
            }
        }
        return list
    }

    static GetStepParams(stepParams, paramsDistribution, paramsFunction, &OutCurrentDistribution, &OutCurrentFunction) {
        OutCurrentDistribution := []
        local i := 1
        for param in paramsDistribution {
            if i <= stepParams.Length && stepParams[i].isDistribution && A_Index = stepParams[i].index {
                OutCurrentDistribution.Push(stepParams[i].start)
                ++i
            } else {
                OutCurrentDistribution.Push(param)
            }
        }
        OutCurrentFunction := []
        for param in paramsFunction {
            if i <= stepParams.Length && !stepParams[i].isDistribution && A_Index = stepParams[i].index {
                OutCurrentFunction.Push(stepParams[i].start)
                ++i
            } else {
                OutCurrentFunction.Push(param)
            }
        }
    }

    static GetParamText(&paramText, tabName, params) {
        paramText := ''
        if this.Inputs.Has(tabName) {
            paramNames := this.Inputs.Get(tabName)
        } else {
            return
        }
        for paramName in paramNames {
            val := params[A_Index]
            if IsSet(val) {
                if IsObject(val) {
                    paramText .= paramName ':`r`n' TestSort_StringifyAll(val, this.OptStringifyAll) '`r`n'
                } else {
                    paramText .= paramName ': ' val '`r`n'
                }
            } else {
                paramText .= paramNames ': unset`r`n'
            }
        }
    }

    static LoadValuesIntoFields(row) {
        g := this.g
        ctrl := g.ctrl
        group := ctrl.%ctrl.tab.Text%
        _lv := group.lv
        loop _lv.GetCount('Col') {
            group.Get(_lv.GetText(0, A_Index)).Edit.Text := _lv.GetText(row, A_Index)
        }
    }

    static ValidateArray(arr) {
        i := 2
        while arr[1] = arr[i] {
            ++i
        }
        if arr[1] > arr[i] {
            compare := (left, right) => right > left
        } else if arr[1] < arr[i] {
            compare := (left, right) => right < left
        } else {
            MsgBox('Failed to validate the array; all elements are equal.')
            return 1
        }
        loop arr.Length - 1 {
            if compare(arr[A_Index], arr[A_Index + 1]) {
                MsgBox('Failed to validate the array; items are out-of-order at index ' A_Index ' (' arr[A_Index] ') and ' (A_Index + 1) ' (' arr[A_Index + 1] ').')
                return
            }
        }
    }

    static HistoryAdd(item) {
        this.History.Push(item)
        if this.History.Length > this.MaxHistory {
            this.History.Length -= this.History.Length * 0.05
        }
        this.g.ctrl.scroller.UpdatePages(this.History.Length)
        this.OnScroll(this.History.Length)
    }

    static HClickButtonMakeInput(btn, *) {
        g := btn.Gui
        ctrl := g.ctrl
        tab := ctrl.tab
        this.MakeInput(g, ctrl, tab)
    }

    static HClickButtonSaveParams(btn, *) {
        ctrl := btn.Gui.ctrl
        group := ctrl.%ctrl.tab.text%
        params := this.GetInput()
        for param in params {
            if param {
                row := group.lv.Add('Check', params*)
                this.UncheckRows(row)
                return
            }
        }
    }

    static GetInput() {
        g := this.g
        ctrl := g.ctrl
        tab := ctrl.tab
        distributionType := tab.Text
        group := ctrl.%distributionType%
        params := []
        paramNames := this.Inputs.Get(distributionType)
        params.Capacity := paramNames.Length
        for paramName in paramNames {
            params.Push(group.Get(paramName).Edit.Text)
        }
        return params
    }

    static GetInputFromListview(row?) {
        g := this.g
        ctrl := g.ctrl
        tab := ctrl.tab
        distributionType := tab.Text
        group := ctrl.%distributionType%
        _lv := group.lv
        params := []
        if !IsSet(row) {
            row := _lv.GetNext(0, 'C')
        }
        for paramName in this.Inputs.Get(distributionType) {
            if paramName = 'Input' {
                try {
                    text := _lv.GetText(row, A_Index)
                    params.Push(TestSort_QuickParse(text))
                } catch Error as err {
                    if MsgBox('An error occurred parsing the input.`nPress OK to throw the error or Cancel to exit the thread.', , 'OC') == 'Cancel' {
                        Exit()
                    }
                    throw err
                }
            } else {
                params.Push(_lv.GetText(row, A_Index))
            }
        }
        return params
    }

    static GetParamsFunction(name) {
        g := this.g
        ctrl := g.ctrl
        _lv := ctrl.%name%.lv
        if _lv.GetCount() {
            row := _lv.GetNext(0, 'C') || 1
            params := []
            loop _lv.GetCount('Col') {
                params.Push(_lv.GetText(row, A_Index))
            }
            return params
        } else {
            return []
        }
    }

    static UncheckRows(keepchecked := '') {
        g := this.g
        ctrl := g.ctrl
        _lv := ctrl.%ctrl.tab.Text%.lv
        row := 0
        loop {
            if row := _lv.GetNext(row, 'C') {
                if row != keepchecked {
                    _lv.Modify(row, '-Check')
                }
            } else {
                break
            }
        }
    }

    static HClickFunctionCheckbox(chk, *) {
        if chk.Value {
            g := chk.Gui
            ctrl := g.ctrl
            functionCheckbox := ctrl.functionCheckbox
            for name in this.FunctionCheckboxes {
                if chk.Name != name {
                    functionCheckbox.%name%.Value := 0
                }
            }
        }
    }

    static OnScroll(index, *) {
        result := this.History[index]
        ctrl := this.g.ctrl
        optionField := ctrl.optionField
        n := result.series
        text := (
            'Distribution type: ' result.distributionType '`r`n'
            'Function: ' result.function '`r`n`r`n'
        )
        if result.stepParams {
            list := []
            list.Capacity := result.linearComparisonsTotal.Length
            for comparisons in result.linearComparisonsTotal {
                list.Push( { totalComparisons: comparisons, index: A_Index, avgComparisons: comparisons / n, totalTick: result.linearTickTotal[A_Index], avgTick: result.linearTickTotal[A_Index] / n  })
            }
            Heapsort(list, (a, b) => a.totalComparisons - b.totalComparisons)
            stepParams := result.stepParams
            showTop := Min(optionField.%'Show top'%.Edit.Text, list.Length)
            listIndex := []
            listIndex.Capacity := showTop
            loop showTop {
                listIndex.Push(list[A_Index].index)
            }
            HeapSort(listIndex)
            listParams := this.GetParamsFromIterationIndex(result, listIndex)
            text .= 'The top ' showTop ' parameter configurations (least comparisons):`r`n`r`n'
            str := (
                'Series index: {1}`r`n'
                'Total comparisons: {2}`r`n'
                'Average comparisons: {3}`r`n'
                'Total ticks: {4}`r`n'
                'Average ticks: {5}`r`n`r`n'
                '{6}'
                '`r`n`r`n'
            )
            loop showTop {
                obj := list[A_Index]
                params := listParams[A_Index]
                this.GetParamText(&paramTextDistribution, result.distributionType, params.distribution)
                this.GetParamText(&paramTextFunction, result.function, params.function)
                text .= Format(
                    str
                  , obj.index
                  , obj.totalComparisons
                  , obj.avgComparisons
                  , obj.totalTick
                  , obj.avgTick
                  , 'Distribution params:`r`n' paramTextDistribution '`r`nFunction params:`r`n' Trim(paramTextFunction, '`r`n')
                )
            }
        } else {
            text .= Format(
                'Total comparisons: {1}`r`n'
                'Total ticks: {2}`r`n`r`n'
                '{3}'
                '`r`n`r`n'
              , result.totalComparisons
              , result.totalTick
              , 'Distribution params:`r`n' result.paramTextDistribution '`r`nFunction params:`r`n' Trim(result.paramTextFunction, '`r`n')
            )
        }
        this.g.ctrl.output.Text := text '`r`n`r`n' TestSort_StringifyAll(result, this.OptStringifyAllOnScroll, , true)
    }

    static MakeInput(g, ctrl, tab) {
        if g.HasOwnProp('Input') {
            try {
                _MoveWindow()
                g.Input.Show()
                return
            }
        }
        ig := g.Input := Gui('+Resize', 'TestSort - array input', this)
        ig.SetFont(this.OptFont, this.FontFamily)
        ig.OnEvent('Close', 'HCloseInput')
        igctrl := ig.ctrl := {}
        igctrl.CheckboxClustered := ig.Add('Checkbox', 'Section Checked', 'Clustered')
        igctrl.CheckboxWeighted := ig.Add('Checkbox', 'ys Checked', 'Weighted')

        igctrl.text := ig.Add('Text', 'xs', '
        (
            Define the input as a json array, except the square brackets are optional.
            [
                { "Start": 0, "End": 25, "Weight": 0.3 },
                { "Start": 25, "End": 50, "Weight": 0.2 },
                { "Start": 50, "End": 75, "Weight": 0.4 },
                { "Start": 75, "End": 100, "Weight": 0.1 }
            ]
        )')
        igctrl.text.GetPos(, , &w)
        igctrl.w := w
        igctrl.Edit := ig.Add('Edit', 'xs w' w this.OptIgEdit)
        igctrl.btnSave := ig.Add('Button', 'xs Section', 'Save')
        igctrl.btnSave.OnEvent('Click', 'HClickIgButtonSave')
        igctrl.btnInfo := ig.Add('Button', 'ys', 'Info')
        igctrl.btnInfo.OnEvent('Click', 'HClickIgButtonInfo')
        igctrl.btnInfo.GetPos(&btnx, , &btnw)
        igctrl.status := ig.Add('Text', 'w' (w - btnw - btnx - ig.MarginX) ' ys', 'Status: idle')

        ig.Show()
        _MoveWindow()

        return

        _MoveWindow() {
            g.GetPos(&gx, &gy, &gw, &gh)
            g.Input.GetPos( &igx, &igy, &igw, &igh)
            rc := { L: igx, T: igy, R: igx + igw, B: igy + igh }
            TestSort_RectMoveAdjacent(
                rc
              , { L: gx, T: gy, R: gx + gw, B: gy + gh }
              , , , , , 2
            )
            g.Input.Move(rc.L, rc.T, rc.R - rc.L, rc.B - rc.T)
        }
    }

    static HClickIgButtonSave(btn, *) {
        ig := btn.Gui
        igctrl := ig.ctrl
        text := Trim(igctrl.Edit.Text, '`s`t`r`n')
        if SubStr(text, 1, 1) !== '[' {
            text := '[' text ']'
        }
        try {
            obj := TestSort_QuickParse(text)
        } catch Error as err {
            if !igctrl.HasOwnProp('Error') {
                igctrl.Error := ig.Add('Edit', 'w' igctrl.w this.OptIgError)
                igctrl.Error.GetPos(&x, &y, &w, &h)
                igctrl.Show('w' (x + w + ig.MarginX) ' h' (y + h + ig.MarginY))
            }
            s := ''
            for prop, val in err.OwnProps() {
                s .= prop ':`r`n' RegExReplace(val, '\R', '`r`n') '`r`n'
            }
            igctrl.status.Text := 'Status: error'
            igctrl.Error.Text := s
            TestSort_SetUpdateStatusTimer(igctrl.status, 'Status: idle', 5000)
            return
        }
        obj.text := text
        g := this.g
        ctrl := g.ctrl
        if igctrl.CheckboxClustered.Value {
            _SetValue(ctrl.Clustered)
        }
        if igctrl.CheckboxWeighted.Value {
            _SetValue(ctrl.Weighted)
        }
        TestSort_SetUpdateStatusTimer(igctrl.status, 'Status: idle', 5000)

        _SetValue(group) {
            group.Get('Input').Edit.Text := text
            group.obj := obj
        }
    }

    static HCloseInput(g, *) {
        g.Hide()
    }

    static HSize(g, minmax, width, height) {
        ; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-deferwindowpos
        if !(hDwp := DllCall(
            g_proc_user32_BeginDeferWindowPos
          , 'int', g.OnSizeControlsX.Length + g.OnSizeControlsBoth.Length
          , 'ptr'
        )) {
            throw Error('``BeginDeferWindowPos`` failed.', -1)
        }
        for _ctrl in g.OnSizeControlsX {
            if !(hDwp := DllCall(g_proc_user32_DeferWindowPos
                , 'ptr', hDwp
                , 'ptr', _ctrl.Hwnd
                , 'ptr', 0                      ; hWndInsertAfter
                , 'int', 0                      ; X
                , 'int', 0                      ; Y
                , 'int', width - _ctrl.DiffX    ; W
                , 'int', _ctrl.H                ; H
                , 'uint', g_TestSort_swp_flags  ; flags
                , 'ptr'
            )) {
                throw OSError()
            }
        }
        for _ctrl in g.OnSizeControlsBoth {
            if !(hDwp := DllCall(g_proc_user32_DeferWindowPos
                , 'ptr', hDwp
                , 'ptr', _ctrl.Hwnd
                , 'ptr', 0                      ; hWndInsertAfter
                , 'int', 0                      ; X
                , 'int', 0                      ; Y
                , 'int', width - _ctrl.DiffX    ; W
                , 'int', height - _ctrl.DiffY   ; H
                , 'uint', g_TestSort_swp_flags  ; flags
                , 'ptr'
            )) {
                throw OSError()
            }
        }
        if !DllCall(g_proc_user32_EndDeferWindowPos, 'ptr', hDwp, 'ptr') {
            throw OSError()
        }
    }

    static HChangeEditIterations(edt, *) {
        edt.Text := RegExReplace(edt.Text, '\D', '')
        SendInput('{End}')
        if edt.HasOwnProp('Highlight') {
            edt.Highlight.Hide()
        }
    }

    static GetFunc(&compare) {
        functionCheckbox := this.g.ctrl.functionCheckbox
        for name in this.FunctionCheckboxes {
            if functionCheckbox.%name%.Value {
                compare := TestSort_Compare_%name%
                return %name%
            }
        }
    }

    static SaveConfig(ShowDialogue := false) {
        config := this.GetConfig()
        if ShowDialogue || !this.PathConfig {
            PathConfig := FileSelect('S 17', this.PathConfig || A_ScriptDir)
            if PathConfig {
                this.PathConfig := PathConfig
            } else {
                return
            }
        } else {
            PathConfig := this.PathConfig
        }
        SplitPath(PathConfig, , &dir)
        if !DirExist(dir) {
            DirCreate(dir)
        }
        f := FileOpen(PathConfig, 'w', this.Encoding)
        f.Write(TestSort_StringifyAll(config, this.OptStringifyAll) '`n')
        f.Close()
        this.PathConfig := PathConfig
    }

    static GetConfig() {
        config := {}
        g := this.g
        ctrl := g.ctrl
        for tabName, arr in this.Inputs {
            group := ctrl.%tabName%
            groupList := []
            groupObj := config.%tabName% := { List: groupList, Selection: 0 }
            _lv := group.lv
            if rows := _lv.GetCount() {
                groupObj.Selection := _lv.GetNext(0, 'C')
                cols := []
                loop _lv.GetCount('Col') {
                    cols.Push(_lv.GetText(0, A_Index))
                }
                row := 0
                loop rows {
                    row++
                    groupObj := {}
                    groupList.Push(groupObj)
                    for col in cols {
                        groupObj.%col% := _lv.GetText(row, A_Index)
                    }
                }
            }
        }
        functionCheckbox := ctrl.functionCheckbox
        configFunctionCheckbox := config.FunctionCheckbox := {}
        for chkName, chk in functionCheckbox.OwnProps() {
            configFunctionCheckbox.%chkName% := chk.Value
        }
        optionCheckbox := config.OptionCheckbox := {}
        for chkName, chk in ctrl.optionCheckbox.OwnProps() {
            optionCheckbox.%chkName% := chk.Value
        }
        optionField := config.optionField := {}
        for fieldName, group in ctrl.optionField.OwnProps() {
            optionField.%fieldName% := group.Edit.Text
        }
        return config
    }

    static LoadConfig(PathConfig?) {
        if !IsSet(PathConfig) {
            PathConfig := FileSelect(1, this.PathConfig || A_ScriptDir)
            if !PathConfig {
                return
            }
        }
        try {
            config := this.config := TestSort_QuickParse(, PathConfig, this.Encoding)
        } catch Error as err {
            if MsgBox('An error occurred parsing the configuration.`nPress OK to throw the error or Cancel to exit the thread.', , 'OC') == 'Cancel' {
                Exit()
            }
            throw err
        }
        this.PathConfig := PathConfig
        this.CopyConfig(config)
    }

    static CopyConfig(config) {
        g := this.g
        ctrl := g.ctrl
        functionCheckbox := ctrl.functionCheckbox
        optionCheckbox := ctrl.optionCheckbox
        optionField := ctrl.optionField
        for prop, val in config.OwnProps() {
            switch prop, 0 {
                case 'FunctionCheckbox':
                    for _prop, _val in val.OwnProps() {
                        functionCheckbox.%_prop%.Value := _val
                        if _val {
                            break
                        }
                    }
                case 'OptionCheckbox':
                    for _prop, _val in val.OwnProps() {
                        optionCheckbox.%_prop%.Value := _val
                    }
                case 'OptionField':
                    for _prop, _val in val.OwnProps() {
                        optionField.%_prop%.Edit.Text := _val
                    }
                default:
                    groupList := val.List
                    if groupList.Length {
                        group := ctrl.%prop%
                        cols := this.Inputs.Get(prop)
                        groupObj := groupList[1]
                        _lv := group.lv
                        for groupObj in groupList {
                            groupListues := []
                            groupListues.Capacity := cols.Length
                            for col in cols {
                                _groupList := groupObj.%col%
                                if InStr(_groupList, '.') && RegExMatch(_groupList, 'S)(?:0{3,}|9{3,})\d$', &match) {
                                    groupListues.Push(Round(_groupList, StrLen(_groupList) - InStr(_groupList, '.') - match.Len))
                                } else {
                                    groupListues.Push(_groupList)
                                }
                            }
                            _lv.Add(, groupListues*)
                        }
                        loop _lv.GetCount('Col') {
                            if cols[A_Index] != 'Input' {
                                _lv.ModifyCol(A_Index, 'AutoHdr')
                            }
                        }
                        if val.Selection {
                            _lv.Modify(val.Selection, '+Check')
                        }
                    }
            }
        }
    }

    static ExportHistory() {
        pathExport := FileSelect('S 17', this.PathExport || this.PathConfig || A_ScriptDir)
        if !pathExport {
            return
        }
        f := FileOpen(pathExport, 'w', this.Encoding)
        f.Write(TestSort_StringifyAll(this.History, this.OptStringifyAll))
        f.Close()
    }
}

TestSort_SetUpdateStatusTimer(ctrl, text, ms) {
    SetTimer(TestSort_UpdateStatus.Bind(ctrl, text), Abs(ms) * -1)
}

TestSort_UpdateStatus(ctrl, text) {
    ctrl.text := text
}

/**
 * @description - Creates an array of values that follow a weighted distribution.
 * @param {Array} Input - An object with the following properties:
 *  @example
 *  input :=  [
 *      { Start: 0, End: 25, Weight: 0.3 },
 *      { Start: 25, End: 50, Weight: 0.2 },
 *      { Start: 50, End: 75, Weight: 0.4 },
 *      { Start: 75, End: 100, Weight: 0.1 }
 *  ]
 *  arr := GenerateWeightedDistribution(input, 1000)
 *  @
 * @returns {Array} - An array of values that follow the weighted distribution.
 */
GenerateWeightedDistribution(Input, Length) {
    local Result := [], i := 0
    , CDF := [], Cumulative := 0, TotalWeight := Input.Reduce(_GetTotalWeight, 0)
    Result.Length := Length
    Input.ForEach(_GetCDFItem)
    loop Length
        Result[A_Index] := _GetNumber()
    return Result

    _GetTotalWeight(&Accumulator, Segment, *) {
        Accumulator += Segment.Weight * (Segment.End - Segment.Start)
    }
    _GetNumber() {
        SelectedSegment := CDF.Find(((n, Segment, *) => n <= Segment.Cumulative).Bind(Random()))
        return Random() * (SelectedSegment.End - SelectedSegment.Start) + SelectedSegment.Start
    }
    _GetCDFItem(Segment, *) {
        Cumulative += Segment.Weight * (Segment.End - Segment.Start) / TotalWeight
        CDF.Push({Start: Segment.Start, End: Segment.End, Weight: Segment.Weight, Cumulative: Cumulative})
    }
}

/**
 * @description - Generates an array containing values that follow a Gaussian distribution.
 * @param {Number} Mean - The mean of the Gaussian distribution.
 * @param {Number} StdDev - The standard deviation of the Gaussian distribution.
 * @param {Integer} Length - The length of the resulting array.
 * @returns {Array} - An array of values that follow the Gaussian distribution.
 *  @example
 *      ; For demonstration, this example uses the Histogram function
 *      #Include <Histogram>
 *      OutputDebug(Histogram(GenerateGaussianDistribution(50, 10, 10000)))
 *      ; 13.060 - 16.734 : 3
 *      ; 16.734 - 20.409 : 7
 *      ; 20.409 - 24.083 : 34
 *      ; 24.083 - 27.757 : 92    *
 *      ; 27.757 - 31.431 : 190   ***
 *      ; 31.431 - 35.106 : 375   *****
 *      ; 35.106 - 38.780 : 681   *********
 *      ; 38.780 - 42.454 : 947   *************
 *      ; 42.454 - 46.128 : 1216  *****************
 *      ; 46.128 - 49.803 : 1451  ********************
 *      ; 49.803 - 53.477 : 1402  *******************
 *      ; 53.477 - 57.151 : 1256  *****************
 *      ; 57.151 - 60.825 : 989   **************
 *      ; 60.825 - 64.499 : 611   ********
 *      ; 64.499 - 68.174 : 418   ******
 *      ; 68.174 - 71.848 : 199   ***
 *      ; 71.848 - 75.522 : 83    *
 *      ; 75.522 - 79.196 : 32
 *      ; 79.196 - 82.871 : 12
 *      ; 82.871 - 86.545 : 2
 *  @
 * {@link https://github.com/Nich-Cebolla/AutoHotkey-Distributions/blob/main/Histogram.ahk}
 */
GenerateGaussianDistribution(Mean, StdDev, Length) {
    Result := [], Result.Length := Length, i := 0
    loop Length
        Result[++i] := Mean + StdDev * Sqrt(-2 * Ln(Random())) * Cos(2 * 3.141592653589793 * Random())
    return Result
}

/**
 * @description - Creates an array of values that follow an exponential distribution.
 * @param {Float} Lambda - The rate parameter of the exponential distribution.
 * @param {Number} Lower - The lower limit of the exponential distribution.
 * @param {Number} Upper - The upper limit of the exponential distribution.
 *  @example
 *      ; For demonstration, this example uses the Histogram function
 *      #Include <Histogram>
 *      arr := CreateWeightedExponentialArray(0.03, 0, 1000, 1000)
 *      OutputDebug(Histogram(arr))
 *  ;      0.000 - 13.388  : 323  ********************
 *  ;     13.388 - 26.776  : 238  ***************
 *  ;     26.776 - 40.163  : 139  *********
 *  ;     40.163 - 53.551  : 95   ******
 *  ;     53.551 - 66.939  : 61   ****
 *  ;     66.939 - 80.327  : 43   ***
 *  ;     80.327 - 93.715  : 34   **
 *  ;     93.715 - 107.102 : 22   *
 *  ;    107.102 - 120.490 : 14   *
 *  ;    120.490 - 133.878 : 8
 *  ;    133.878 - 147.266 : 7
 *  ;    147.266 - 160.654 : 5
 *  ;    160.654 - 174.041 : 3
 *  ;    174.041 - 187.429 : 1
 *  ;    187.429 - 200.817 : 2
 *  ;    200.817 - 214.205 : 3
 *  ;    214.205 - 227.592 : 1
 *  ;    227.592 - 240.980 : 0
 *  ;    240.980 - 254.368 : 0
 *  ;    254.368 - 267.756 : 1
 *  @
 * {@link https://github.com/Nich-Cebolla/AutoHotkey-Distributions/blob/main/Histogram.ahk}
 */
GenerateExponentialDistribution(Lambda, Lower, Upper, Length) {
    Result := [], i := 0
    Result.Length := Length
    loop Length
        Result[A_Index] := Min(Max((Ln(1 - Random()) / Lambda * -1) + Lower, Lower), Upper)
    return Result
}

/**
 * @description - Generates an array of values that follow an even distribution.
 * @param {Number} MinValue - The minimum value of the distribution.
 * @param {Number} MaxValue - The maximum value of the distribution.
 * @param {Number} Length - The length of the resulting array.
 * @param {Boolean} AsIntegers - If true, the values will be integers.
 * @param {Integer} Digits - The number of decimal places to round to.
 * @returns {Array} - An array of values that follow the even distribution.
 */
GenerateEvenDistribution(MinValue, MaxValue, Length, AsIntegers := false, Digits := 5) {
    local Result := []
    Result.Length := Length
    if AsIntegers
        _Random := () => Random(MinValue, MaxValue)
    else
        MaxValue--, _Random := () => Random(MinValue, MaxValue) + (Digits ? Round(Random(), Digits) : Random())
    Loop Result.Length
        Result[A_Index] := _Random()
    return Result
}

/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/FontExist.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @param {Array|String} - If an array, an array of font typeface names. If a string, a comma-separated
 * list of font typeface names.
 */
GetFirstFont(FaceNames) {
    if !IsObject(FaceNames) {
        FaceNames := StrSplit(FaceNames, ',', '`s')
    }
    for faceName in FaceNames {
        if FontExist(faceName) {
            return faceName
        }
    }
}

/**
 * @description - Returns nonzero if the system's font collection contains a font with the
 * input typeface name.
 * @param {String} FaceName - The font typeface name.
 * @returns {Integer} - If the font is found, returns 1. Else 0.
 */
FontExist(FaceName) {
    static maxLen := 31
    LOGFONTW := Buffer(92, 0)  ; LOGFONTW struct size = 92 bytes
    if Min(StrLen(FaceName), maxLen) == maxLen {
        FaceName := SubStr(FaceName, 1, maxLen)
    }
    bytes := StrPut(FaceName, 'UTF-16')
    StrPut(FaceName, LOGFONTW.Ptr + 28, maxLen + 1, 'UTF-16')

    Found := false

    Callback := CallbackCreate(EnumFontProc)
    lParam := Buffer(A_PtrSize + 4)
    buf := Buffer(bytes)
    StrPut(FaceName, buf, bytes / 2, 'UTF-16')
    NumPut('ptr', buf.Ptr, lParam)
    NumPut('uint', 0, lParam, A_PtrSize)
    hdc := DllCall('GetDC', 'ptr', 0, 'ptr')
    DllCall('gdi32\EnumFontFamiliesExW', 'ptr', hdc, 'ptr', LOGFONTW, 'ptr', Callback, 'ptr', lParam.Ptr, 'uint', 0, 'uint')
    DllCall('ReleaseDC', 'ptr', 0, 'ptr', hdc)
    CallbackFree(Callback)

    return NumGet(lParam, A_PtrSize, 'uint')

    EnumFontProc(lpelfe, lpntme, FontType, lParam) {
        if StrGet(lpelfe + 28, maxLen, 'UTF-16') = StrGet(NumGet(lParam, 0, 'ptr'), maxLen, 'UTF-16') {
            NumPut('uint', 1, lParam, A_PtrSize)
            return 0
        }
        return 1
    }
}
/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/MakeInputControlGroup.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * `MakeInputControlGroup` is a function that creates a group of controls in a series of rows and
 * columns, where each row is associated with a particular input item from the parameter `LabelList`.
 * The types of controls that can be created are:
 * 1. Text control - a label indicating what value to input.
 * 2. Edit control - the edit that accepts input from the user.
 * 3. Button control - a button that says "Get".
 * 4. Button control - a button that says "Set".
 *
 * The buttons "Get" and "Set" are optional; that is, you can choose to have zero, one, or both
 * of each in each row. This function does not currently allow customizing the controls on an
 * individual-row basis; each row must have the same controls.
 *
 * You can customize how the controls are named to a degree, but ultimately the format for the
 * names is: `prefix RegExReplace(label, "\W", "")`. The `RegExReplace` expression removes all
 * non-word characters. For example, if the prefix for a control is "BtnGet", and the label for
 * the group is "Option 1", then that control's name is "BtnGetOption1".
 *
 * For a demo, see "test-files\demo-MakeInputControlGroup.ahk".
 *
 * @param {Gui} G - The Gui object.
 *
 * @param {String[]} LabelList - The list of labels for each control group.
 *
 * @param {Object} Options - Property:value pairs
 * @param {Integer} [Options.StartX] - The start X coordinate. If unset, `G.MarginX` is used.
 * @param {Integer} [Options.StartY] - The start Y coordinate. If unset, `G.MarginY` is used.
 * @param {Integer} [Options.MaxY] - A threshold at which a new column will be started.
 * @param {Boolean} [Options.GetButton = true] - If true, a button to the right of the edit control
 * with the text "Get" is included.
 * @param {Boolean} [Options.SetButton = true] - If true, a button to the right of the edit control
 * with the text "Set" is included.
 * @param {Integer} [Options.EditWidth = 250] - The width of the edit controls.
 * @param {Integer} [Options.ButtonWidth = 80] - The width of the button controls.
 * @param {Integer} [Options.PaddingX = 5] - The padding to add between controls along the X axis.
 * @param {Integer} [Options.PaddingY = 5] - The padding to add between rows.
 * @param {Boolean} [Options.LabelTestSort_Alignment = "Right"] - The TestSort_Alignment option to include with the
 * label controls.
 * @param {String} [Options.LabelPrefix = "Txt"] - The literal string that prefixes the labels.
 * @param {String} [Options.EditPrefix = "Edt"] - The literal string that prefixes the edit controls.
 * @param {String} [Options.GetButtonPrefix = "BtnGet"] - The literal string that prefixes the name
 * of the "Get" buttons.
 * @param {String} [Options.SetButtonPrefix = "BtnSet"] - The literal string that prefixes the name
 * of the "Set" buttons.
 * @param {String} [Options.NameSuffix = ""] - The literal string that will be appended to all
 * control names.
 */
MakeInputControlGroup(G, LabelList, Options?) {
    local maxY := getButton := setButton := editWidth := buttonWidth := paddingX := paddingY :=
    labelTestSort_Alignment := labelPrefix := editPrefix := getButtonPrefix := setButtonPrefix := nameSuffix := 0
    if !IsSet(Options) {
        Options := {}
    }
    x := HasProp(Options, 'StartX') ? Options.StartX : G.MarginX
    y := startY := HasProp(Options, 'StartY') ? Options.StartY : G.MarginY
    for prop, val in Map('maxY', '', 'getButton', true, 'setButton', true, 'editWidth', 250
    , 'buttonWidth', 80, 'paddingX', 5, 'paddingY', 5, 'labelTestSort_Alignment', 'Right'
    , 'labelPrefix', 'Txt', 'editPrefix', 'Edt', 'getButtonPrefix', 'BtnGet', 'setButtonPrefix', 'BtnSet'
    , 'nameSuffix', ''
    ) {
        if HasProp(Options, prop) {
            %prop% := Options.%prop%
        } else {
            %prop% := val
        }
    }
    controls := Map()
    controls.NameSuffix := nameSuffix
    width := 0
    for label in LabelList {
        _label := RegExReplace(label, '\W', '')
        controls.Set(
            label, group := {
                Label: G.Add('Text', 'x' x ' y' y ' ' labelTestSort_Alignment ' v' labelPrefix _label nameSuffix, label ':')
              , Edit: G.Add('Edit', 'x' x ' y' y ' w' editWidth ' v' editPrefix _label nameSuffix)
            }
        )
        if getButton {
            group.Get := G.Add('Button', 'x' x ' y' y ' w' buttonWidth ' v' getButtonPrefix _label nameSuffix, 'Get')
        }
        if setButton {
            group.Set := G.Add('Button', 'x' x ' y' y ' w' buttonWidth ' v' setButtonPrefix _label nameSuffix, 'Set')
        }
        group.Label.GetPos(, , &txtw)
        if txtw > width {
            width := txtw
        }
    }
    x2 := x + width + paddingX
    x3 := x2 + editWidth + paddingX
    x4 := x3 + buttonWidth + paddingX
    if getButton {
        controls.Get(LabelList[1]).Get.GetPos(, , , &rowh)
    } else if setButton {
        controls.Get(LabelList[1]).Set.GetPos(, , , &rowh)
    } else {
        controls.Get(LabelList[1]).Edit.GetPos(, , , &rowh)
    }
    controls.Get(LabelList[1]).Edit.GetPos(, , , &edth)
    controls.Get(LabelList[1]).Label.GetPos(, , , &txth)
    txtYOffset := (rowh - txth) / 2
    edtYOffset := (rowh - edth) / 2
    for label in LabelList {
        group := controls.Get(label)
        group.Label.Move(x, y + txtYOffset, width)
        group.Edit.Move(x2, y + edtYOffset)
        if getButton {
            group.Get.Move(x3, y)
            if setButton {
                group.Set.Move(x4, y)
            }
        } else if setButton {
            group.Set.Move(x3, y)
        }
        y += edth + paddingY
        if maxY && y + edth > maxY {
            y := startY
            if getButton {
                if setButton {
                    x := x4 + buttonWidth + paddingX
                } else {
                    x := x3 + buttonWidth + paddingX
                }
            } else if setButton {
                x := x3 + buttonWidth + paddingX
            } else {
                x := x2 + editWidth + paddingX
            }
            x2 := x + width + paddingX
            x3 := x2 + editWidth + paddingX
            x4 := x3 + buttonWidth + paddingX
        }
    }
    return controls
}

TestSort_EvaluateValueExpression(ti, Str) {
    Str := Trim(Str, '`r`n`s`t')
    switch SubStr(Str, 1, 1) {
        case '{', '[':
            return TestSort_QuickParse(Str)

        ; Internal quote characters don't need to be escaped with a backtick, but if a backtick
        ; is present before a quote character it is assumed the user was following AHK syntax
        ; and the backtick is removed.
        case "'":
            if SubStr(Str, -1, 1) !== "'" {
                throw ValueError('The input does not have a terminating quote character.', -1, Str)
            }
        case '"':
            if SubStr(Str, -1, 1) !== '"' {
                throw ValueError('The input does not have a terminating quote character.', -1, Str)
            }
            if InStr(Str, '``') {
                n := 0xFFFD
                while InStr(Str, Chr(n)) {
                    n++
                }
                return StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(SubStr(Str, 2, -1), '````', Chr(n)), '``n', '`n'), '``r', '`r'), '``"', '"'), '``t', '`t'), Chr(n), '``')
            } else {
                return SubStr(Str, 2, -1)
            }
        case '%':
            if SubStr(Str, -1, 1) !== '%' {
                throw ValueError('The input does not have a terminating dereference operator ("%").', -1, Str)
            }
            return ti.LvReferences.__Item.Get(SubStr(Str, 2, -1))
        default:
            if RegExMatch(Str, '^[\d.-]') {
                return Number(Str)
            }
            if RegExMatch(Str, '(?(DEFINE)(?<quote>(?<!``)(?:````)*+(["`'])(?<text>.*?)(?<!``)(?:````)*+\g{-2}))(?<body>\(((?&quote)|[^"`')(]++|(?&body))*\))', &Match) {
                obj := TestSort_GetObjectFromString(s := SubStr(Str, 1, Match.Pos - 1))
                if Match.Len > 2 {
                    params := TestSort_ParamsList(Match[0])
                    p := []
                    for param in params {
                        if param.default {
                            p.push(TestSort_EvaluateValueExpression(ti, param.default))
                        } else {
                            p.push(TestSort_EvaluateValueExpression(ti, param.symbol))
                        }
                    }
                    if RegExMatch(Str, 'i)^this') {
                        return obj(ti, p*)
                    } else {
                        return obj(p*)
                    }
                } else {
                    if RegExMatch(Str, 'i)^this') {
                        return obj(ti)
                    } else {
                        return obj()
                    }
                }
            }
            return TestSort_GetObjectFromString(Str)
    }

}

/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/QuickParse.ahk
    Author: Nich-Cebolla
    Version: 1.0.4
    License: MIT
*/

/**
 * @classdesc - Parses a JSON string into an AHK object. This parser is designed for simplicity and
 * speed.
 * - JSON objects are parsed into instances of either `Object` or `Map`, depending on the value of
 * the parameter `AsMap`.
 * - JSON arrays are parsed into instances of `Array`.
 * - `false` is represented as `0`.
 * - `true` is represented as `1`.
 * - For arrays, `null` JSON values cause `QuickParse` to call `Obj.Push(unset)` where `Obj` is the
 * active object being constructed at that time.
 * - For objects, `null` JSON values cause `QuickParse` to set the property with an empty string value.
 * - Unquoted numeric values are processed through `Number()` before setting the value.
 * - Quoted numbers are processed as strings.
 * - Escape sequences are un-escaped and external quotations are removed from JSON string values.
 */
class TestSort_QuickParse {
    /**
     * Only one of `Str` or `Path` are needed. If `Str` is set, `Path` is ignored. If both `Str`
     * and `Path` are unset, the clipboard's contents are used.
     * @param {String} [Str] - The string to parse.
     * @param {String} [Path] - The path to the file that contains the JSON content to parse.
     * @param {String} [Encoding] - The file encoding to use if calling `QuickParse` with `Path`.
     * @param {*} [Root] - If set, the root object onto which properties are assigned will be
     * `Root`, and `QuickParse` will return the modified `Root` at the end of the function.
     * - If `AsMap` is true and the first open bracket in the JSON string is a curly bracket, `Root`
     * must have a method `Set`.
     * - If the first open bracket in the JSON string is a square bracket, `Root` must have methods
     * `Push` and `Pop`.
     * @param {Boolean} [AsMap = false] - If true, JSON objects are converted into AHK `Map` objects.
     * @param {Boolean} [MapCaseSense = false] - The value set to the `MapObj.CaseSense` property.
     * `MapCaseSense` is ignored when `AsMap` is false.
     * @returns {Object|Array}
     */
    static Call(Str?, Path?, Encoding?, Root?, AsMap := false, MapCaseSense := false) {
        ;@region Initialization
        static ArrayItem := TestSort_QuickParse.Patterns.ArrayItem
        , ObjectPropName := TestSort_QuickParse.Patterns.ObjectPropName
        , ArrayNumber := TestSort_QuickParse.Patterns.ArrayNumber
        , ArrayString := TestSort_QuickParse.Patterns.ArrayString
        , ArrayFalse := TestSort_QuickParse.Patterns.ArrayFalse
        , ArrayTrue := TestSort_QuickParse.Patterns.ArrayTrue
        , ArrayNull := TestSort_QuickParse.Patterns.ArrayNull
        , ArrayNextChar := TestSort_QuickParse.Patterns.ArrayNextChar
        , ObjectNumber := TestSort_QuickParse.Patterns.ObjectNumber
        , ObjectString := TestSort_QuickParse.Patterns.ObjectString
        , ObjectFalse := TestSort_QuickParse.Patterns.ObjectFalse
        , ObjectTrue := TestSort_QuickParse.Patterns.ObjectTrue
        , ObjectNull := TestSort_QuickParse.Patterns.ObjectNull
        , ObjectNextChar := TestSort_QuickParse.Patterns.ObjectNextChar

        if !IsSet(Str) {
            If IsSet(Path) {
                Str := FileRead(Path, Encoding ?? unset)
            } else {
                Str := A_Clipboard
            }
        }

        if AsMap {
            CallbackConstructorObject := MapCaseSense ? Map : _GetObj
            CallbackSetterObject := _SetProp1
        } else {
            CallbackConstructorObject := Object
            CallbackSetterObject := _SetProp2
        }

        if !RegExMatch(Str, '\[|\{', &Match) {
            throw Error('Missing open bracket.', -1)
        }

        Pos := Match.Pos + 1

        if IsSet(Root) {
            if Match[0] == '[' {
                if !HasMethod(Root, 'Push') || !HasMethod(Root, 'Pop') {
                    throw ValueError('The value passed to the ``Root`` parameter is required to have'
                        ' methods ``Push`` and ``Pop`` when the opening bracket in the JSON is a square'
                        ' bracket.', -1)
                }
                Pattern := ArrayItem
            } else {
                if AsMap && !HasMethod(Root, 'Set') {
                    throw ValueError('The value passed to the ``Root`` parameter is required to have'
                        ' a ``Set`` method when ``AsMap`` is true.', -1)
                }
                Pattern := ObjectPropName
            }
        } else {
            if Match[0] == '[' {
                Root := []
                Pattern := ArrayItem
            } else {
                Root := CallbackConstructorObject()
                Pattern := ObjectPropName
            }
        }

        Controller := { Obj: Root, __Handler: (*) => }
        Stack := ['']
        Obj := Root
        ; Used when unescaping json escape sequences.
        charOrd := 0xFFFD
        while InStr(Str, Chr(charOrd)) {
            charOrd++
        }
        ;@endregion

        while RegExMatch(Str, Pattern, &Match, Pos) {
            continue
        }

        return Root

        ;@region Array Callbacks
        OnQuoteArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayString, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if InStr(MatchValue['value'], '\') {
                Obj.Push(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(MatchValue['value'], '\\', Chr(charOrd)), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), Chr(charOrd), '\'))
            } else if MatchValue['value'] !== '""' {
                Obj.Push(MatchValue['value'])
            } else {
                Obj.Push('')
            }
            _PrepareNextArr(MatchValue)
        }
        OnSquareOpenArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            _obj := []
            Obj.Push(_obj)
            if Match['close'] {
                _GetContextArray()
            } else {
                Controller.__Handler := _GetContextArray
                Stack.Push(Controller)
                Obj := _obj
                Controller := { Obj: Obj }
            }
        }
        OnCurlyOpenArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            _obj := CallbackConstructorObject()
            Obj.Push(_obj)
            if Match['close'] {
                _GetContextArray()
            } else {
                Controller.__Handler := _GetContextArray
                Stack.Push(Controller)
                Obj := _obj
                Controller := { Obj: Obj }
                Pattern := ObjectPropName
            }
        }
        OnFalseArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayFalse, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            Obj.Push(0)
            _PrepareNextArr(MatchValue)
        }
        OnTrueArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayTrue, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            Obj.Push(1)
            _PrepareNextArr(MatchValue)
        }
        OnNullArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayNull, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            Obj.Push(unset)
            _PrepareNextArr(MatchValue)
        }
        OnNumberArr(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ArrayNumber, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Match.Pos)
            }
            Obj.Push(Number(MatchValue['value']))
            _PrepareNextArr(MatchValue)
        }
        ;@endregion

        ;@region Object Callbacks
        OnQuoteObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectString, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            if InStr(MatchValue['value'], '\') {
                CallbackSetterObject(Match, StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(MatchValue['value'], '\\', Chr(charOrd)), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), Chr(charOrd), '\'))
            } else if MatchValue['value'] && MatchValue['value'] !== '""' {
                CallbackSetterObject(Match, MatchValue['value'])
            } else {
                CallbackSetterObject(Match, '')
            }
            _PrepareNextObj(MatchValue)
        }
        OnSquareOpenObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            _obj := []
            CallbackSetterObject(Match, _obj)
            if Match['close'] {
                _GetContextObject()
            } else {
                Controller.__Handler := _GetContextObject
                Stack.Push(Controller)
                Obj := _obj
                Controller := { Obj: Obj }
                Pattern := ArrayItem
            }
        }
        OnCurlyOpenObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len
            _obj :=  CallbackConstructorObject()
            CallbackSetterObject(Match, _obj)
            if Match['close'] {
                _GetContextObject()
            } else {
                Controller.__Handler := _GetContextObject
                Stack.Push(Controller)
                Obj := _obj
                Controller := { Obj: Obj }
            }
        }
        OnFalseObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectFalse, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            CallbackSetterObject(Match, 0)
            _PrepareNextObj(MatchValue)
        }
        OnTrueObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectTrue, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            CallbackSetterObject(Match, 1)
            _PrepareNextObj(MatchValue)
        }
        OnNullObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectNull, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Pos)
            }
            CallbackSetterObject(Match, '')
            _PrepareNextObj(MatchValue)
        }
        OnNumberObj(Match, *) {
            if Match.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := Match.Pos + Match.Len - 1
            if !RegExMatch(Str, ObjectNumber, &MatchValue, Pos) || MatchValue.Pos !== Pos {
                _Throw(1, Match.Pos)
            }
            CallbackSetterObject(Match, Number(MatchValue['value']))
            _PrepareNextObj(MatchValue)
        }
        ;@endregion

        ;@region Helper Funcs
        _GetContextArray() {
            if !RegExMatch(Str, ArrayNextChar, &MatchCheck, Pos) || MatchCheck.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := MatchCheck.Pos + MatchCheck.Len
            if MatchCheck['char'] == ']' {
                Controller := Stack.Pop()
                if !Controller {
                    return
                }
                Obj := Controller.Obj
                Controller.__Handler.Call()
            } else {
                Pattern := ArrayItem
            }
        }
        _GetContextObject() {
            if !RegExMatch(Str, ObjectNextChar, &MatchCheck, Pos) || MatchCheck.Pos !== Pos {
                _Throw(1, Pos)
            }
            Pos := MatchCheck.Pos + MatchCheck.Len
            if MatchCheck['char'] == '}' {
                Controller := Stack.Pop()
                if !Controller {
                    return
                }
                Obj := Controller.Obj
                Controller.__Handler.Call()
            } else {
                Pattern := ObjectPropName
            }
        }
        _GetObj() {
            m := Map()
            m.CaseSense := false
            return m
        }
        _PrepareNextArr(MatchValue) {
            Pos := MatchValue.Pos + MatchValue.Len
            if MatchValue['char'] == ']' {
                Controller := Stack.Pop()
                if !Controller {
                    return
                }
                Obj := Controller.Obj
                Controller.__Handler.Call()
            }
        }
        _PrepareNextObj(MatchValue) {
            Pos := MatchValue.Pos + MatchValue.Len
            if MatchValue['char'] == '}' {
                Controller := Stack.Pop()
                if !Controller {
                    return
                }
                Obj := Controller.Obj
                Controller.__Handler.Call()
            }
        }
        _SetProp1(MatchName, Value) {
            Obj.Set(MatchName['name'], Value)
        }
        _SetProp2(MatchName, Value) {
            Obj.DefineProp(MatchName['name'], { Value: Value })
        }
        _Throw(Code, Extra?, n := -2) {
            switch Code, 0 {
                case '1': throw Error('There is an error in the JSON string.', n, IsSet(Extra) ? 'Near pos: ' Extra : '')
            }
        }
        ;@endregion
    }

    static __New() {
        this.DeleteProp('__New')
        ; SignficantChars := '["{[ftn\d{}-]'
        ArrayNextChar := '\s*(?<char>,|\])'
        ObjectNextChar := '\s*(?<char>,|\})'
        SignificantChars := (
            '(?:'
                '(?<char>")(?COnQuote{1})'
                '|(?<char>\{)(?<close>\s*\})?(?COnCurlyOpen{1})'
                '|(?<char>\[)(?<close>\s*\])?(?COnSquareOpen{1})'
                '|(?<char>f)(?COnFalse{1})'
                '|(?<char>t)(?COnTrue{1})'
                '|(?<char>n)(?COnNull{1})'
                '|(?<char>[\d-])(?COnNumber{1})'
            ')'
        )
        this.Patterns := {
            ArrayItem: 'JS)\s*' Format(SignificantChars, 'Arr')
          , ArrayNumber: 'S)(?<value>(?<n>(?:-?\d++(?:\.\d++)?)(?:[eE][+-]?\d++)?))' ArrayNextChar
          , ArrayString: 'S)(?<=[,:[{\s])"(?<value>.*?(?<!\\)(?:\\\\)*+)"(*COMMIT)' ArrayNextChar
          , ArrayFalse: 'S)(?<value>false)' ArrayNextChar
          , ArrayTrue: 'S)(?<value>true)' ArrayNextChar
          , ArrayNull: 'S)(?<value>null)' ArrayNextChar
          , ArrayNextChar: 'S)' ArrayNextChar
          , ObjectPropName: 'JS)\s*"(?<name>.*?(?<!\\)(?:\\\\)*+)"(*COMMIT):\s*' Format(SignificantChars, 'Obj')
          , ObjectNumber: 'S)(?<value>(?<n>-?\d++(?:\.\d++)?)(?<e>[eE][+-]?\d++)?)' ObjectNextChar
          , ObjectString: 'S)(?<=[,:[{\s])"(?<value>.*?(?<!\\)(?:\\\\)*+)"(*COMMIT)' ObjectNextChar
          , ObjectFalse: 'S)(?<value>false)' ObjectNextChar
          , ObjectTrue: 'S)(?<value>true)' ObjectNextChar
          , ObjectNull: 'S)(?<value>null)' ObjectNextChar
          , ObjectNextChar: 'S)' ObjectNextChar
        }
    }
}

/*
    Github: https://github.com/Nich-Cebolla/ParseCsv-AutoHotkey/blob/main/ParamsList.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/
class TestSort_ParamsList extends Array {
    /**
     * @class - Parses the parameters of a function definition.
     * @param {String} Str - The string that contains the parameters.
     * @returns {ParamsList} - An array of `ParamsList.Param` objects with properties
     * { Optional, Default, Symbol, Variadic, VarRef }.
     */
    __New(Str) {
        static Brackets := ['{', '}', '[', ']', '(', ')']
        , Replacement := Chr(0xFFFD)
        Index := 0
        Replaced := []
        if SubStr(Str, 1, 1) == '(' {
            Str := SubStr(Str, 2, -1)
        }
        ; Extract all quoted strings and replace them with a unique identifier that will not interfere with pattern matching.
        while RegExMatch(Str, '(?<=[\s=:,&(.[?]|^)([`"`'])[\w\W]*?(?<!``)(?:````)*+\g{-1}', &Match) {
            Replaced.Push(Match)
            Str := StrReplace(Str, Match[0], _GetReplacement(), , , 1)
        }
        ; Extract bracketed text
        loop 3 {
            while RegExMatch(Str, Format('\{1}([^{1}\{2}]++|(?R))*\{2}', Brackets[A_Index * 2 - 1], Brackets[A_Index * 2]), &Match) {
                Replaced.Push(Match)
                Str := StrReplace(Str, Match[0], _GetReplacement(), , , 1)
            }
        }
        Split := StrSplit(Str, ',')
        this.Capacity := Split.Length
        for P in Split {
            this.Push(TestSort_ParamsList.Param(P))
            if this[-1].Default && RegExMatch(this[-1].Default, Replacement '(\d+)' Replacement, &Match) {
                this[-1].Default := Trim(Replaced[Match[1]][0], '`s`t`r`n')
            }
            if this[-1].Symbol && RegExMatch(this[-1].Symbol, Replacement '(\d+)' Replacement, &Match) {
                this[-1].Symbol := Trim(Replaced[Match[1]][0], '`s`r`r`n')
            }
        }

        return

        _GetReplacement() {
            return Replacement (++Index) Replacement
        }
    }

    class Param {
        static __New() {
            if this.Prototype.__Class == 'ParamsList.Param' {
                Proto := this.Prototype
                for Prop in ['Optional', 'Default', 'Variadic', 'VarRef'] {
                    Proto.DefineProp(Prop, { Value: false })
                }
            }
        }
        __New(Str) {
            if InStr(Str, '?') {
                this.Optional := true
                this.Symbol := Trim(SubStr(Str, 1, InStr(Str, '?') - 1), '`s`t`r`n')
            } else if InStr(Str, ':=') {
                this.Optional := true
                split := StrSplit(Str, ':=', '`s`t`r`n')
                this.Default := split[2]
                this.Symbol := split[1]
            } else if InStr(Str, '*') {
                this.Variadic := this.Optional := true
                this.Symbol := Trim(SubStr(Str, 1, InStr(Str, '*') - 1), '`s`t`r`n')
            } else {
                this.Symbol := Trim(Str, '`s`t`r`n')
            }
            if InStr(this.Symbol, '&') {
                this.VarRef := true
                this.Symbol := SubStr(this.Symbol, InStr(this.Symbol, '&') + 1)
            }
        }
    }
}

/**
 * @description - Converts a string path to an object reference. The object at the input path must
 * exist in the current scope of the function call.
 * @param {String} Str - The object path.
 * @param {Object} [InitialObj] - If set, the object path will be parsed as a property / item of
 * this object.
 * @returns {Object} - The object reference.
 * @example
 *  Obj := {
 *      Prop1: [1, 2, Map(
 *              'key1', 'value1',
 *              'key2', {prop2: 2, prop3: [3, 4]}
 *          )
 *      ]
 *  }
 *  Path := 'obj.prop1[3]["key2"].prop3'
 *  ObjReference := GetObjectFromString(Path)
 *  OutputDebug(ObjReference[2]) ; 4
 * @
 * This is compatible with class references.
 * @example
 *
 *  class Test {
 *      class NestedClass {
 *          InstanceProp {
 *              Get{
 *                  return ['Val1', { Prop: 'Hello, world!' }]
 *              }
 *          }
 *      }
 *  }
 *  Path := 'Test.NestedClass.Prototype.InstanceProp[2]'
 *  Obj := GetObjectFromString(Path)
 *  OutputDebug(Obj.Prop) ; Hello, world!
 * @
 * Using an initial object.
 * @example
 *  Obj := {
 *      Prop1: [1, 2, Map(
 *              'key1', 'value1',
 *              'key2', {prop2: 2, prop3: [3, 4]}
 *          )
 *      ]
 *  }
 *  Path := '[3]["key2"].prop3'
 *  Arr := Obj.Prop1
 *  InnerArr := GetObjectFromString(Path, Arr)
 *  OutputDebug(InnerArr[2]) ; 4
 * @
 *
 */
TestSort_GetObjectFromString(Str, InitialObj?) {
    static Pattern := '(?<=\.)[\w_\d]+(?COnProp)|\[\s*\K-?\d+(?COnIndex)|\[\s*(?<quote>[`'"])(?<key>.*?)(?<!``)(?:````)*\g{quote}(?COnKey)'
    if IsSet(InitialObj) {
        NewObj := InitialObj
        Pos := 1
        if SubStr(Str, 1, 1) !== '.' {
            Str := '.' Str
        }
    } else {
        RegExMatch(Str, '^[\w\d_]+', &InitialSegment)
        Pos := InitialSegment.Pos + InitialSegment.Len
        NewObj := %InitialSegment[0]%
    }
    while RegExMatch(Str, Pattern, &Match, Pos)
        Pos := Match.Pos + Match.Len

    return NewObj

    OnProp(Match, *) {
        NewObj := NewObj.%Match[0]%
    }
    OnIndex(Match, *) {
        NewObj := NewObj[Number(Match[0])]
    }
    OnKey(Match, *) {
        NewObj := NewObj[Match['key']]
    }
}

/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-Array/edit/main/Array.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/
/**
 * @description - Implements Javascript's `array.prototype.find` method in AutoHotkey.
 * @param {Array} Arr - The array to search. If calling this method from an array instance, skip
 * this parameter completely, don't leave a space for it.
 * @param {Func|BoundFunc|Closure} Callback - The function to execute on each element in the array.
 * The function should return a nonzero value when the condition is met. The function can accept
 * one to three parameters:
 * - The current element being processed in the array.
 * - [Optional] The index of the current element being processed in the array.
 * - [Optional] The array find was called upon.
 * @returns {Any} - The first element in the array that satisfies the condition.
    @example
        OutputDebug([1,2,3,4,5].Find((Item, *) => Item > 3)) ; 4
    @
 */
TestSort_Array_FInd(Arr, Callback) {
    for Item in Arr {
        if IsSet(Item) && Callback(Item, A_Index, Arr)
            return Item
    }
}


/**
 * @description - Calculates the optimal position to move one rectangle adjacent to another while
 * ensuring that the `Subject` rectangle stays within the monitor's work area. The properties
 * { L, T, R, B } of `Subject` are updated with the new values.
 *
 * @param {*} Subject - The object representing the rectangle that will be moved. This can be an
 * instance of `Rect` or any class that inherits from `Rect`, or any object with properties
 * { L, T, R, B }. Those four property values will be updated with the result of this function call.
 *
 * @param {*} [Target] - The object representing the rectangle that will be used as reference. This
 * can be an instance of `Rect` or any class that inherits from `Rect`, or any object with properties
 * { L, T, R, B }. If unset, the mouse's current position relative to the screen is used. To use
 * a point instead of a rectangle, set the properties "L" and "R" equivalent to one another, and
 * "T" and "B" equivalent to one another.
 *
 * @param {*} [ContainerRect] - If set, `ContainerRect` defines the boundaries which restrict
 * the area that the window is permitted to be moved within. The object must have poperties
 * { L, T, R, B } to be valid. If unset, the work area of the monitor with the greatest area of
 * intersection with `Target` is used.
 *
 * @param {String} [Dimension = "X"] - Either "X" or "Y", specifying if the window is to be moved
 * adjacent to `Target` on either the X or Y axis. If "X", `Subject` is moved to the left or right
 * of `Target`, and `Subject`'s vertical center is aligned with `Target`'s vertical center. If "Y",
 * `Subject` is moved to the top or bottom of `Target`, and `Subject`'s horizontal center is aligned
 * with `Target`'s horizontal center.
 *
 * @param {String} [Prefer = ""] - A character indicating a preferred side. If `Prefer` is an
 * empty string, the function will move the window to the side the has the greatest amount of
 * space between the monitor's border and `Target`. If `Prefer` is any of the following values,
 * the window will be moved to that side unless doing so would cause the the window to extend
 * outside of the monitor's work area.
 * - "L" - Prefers the left side.
 * - "T" - Prefers the top side.
 * - "R" - Prefers the right side.
 * - "B" - Prefes the bottom.
 *
 * @param {Number} [Padding = 0] - The amount of padding to leave between `Subject` and `Target`.
 *
 * @param {Integer} [InsufficientSpaceAction = 0] - Determines the action taken if there is
 * insufficient space to move the window adjacent to `Target` while also keeping the window
 * entirely within the monitor's work area. The function will always sacrifice some of the padding
 * if it will allow the window to stay within the monitor's work area. If the space is still
 * insufficient, the action can be one of the following:
 * - 0 : The function will not move the window.
 * - 1 : The function will move the window, allowing the window's area to extend into a non-visible
 *   region of the monitor.
 * - 2 : The function will move the window, keeping the window's area within the monitor's work
 *   area by allowing the window to overlap with `Target`.
 *
 * @returns {Integer} - If the insufficient space action was invoked, returns 1. Else, returns 0.
 */
TestSort_RectMoveAdjacent(Subject, Target?, ContainerRect?, Dimension := 'X', Prefer := '', Padding := 0, InsufficientSpaceAction := 0) {
    Result := 0
    if IsSet(Target) {
        tarL := Target.L
        tarT := Target.T
        tarR := Target.R
        tarB := Target.B
    } else {
        mode := CoordMode('Mouse', 'Screen')
        MouseGetPos(&tarL, &tarT)
        tarR := tarL
        tarB := tarT
        CoordMode('Mouse', mode)
    }
    tarW := tarR - tarL
    tarH := tarB - tarT
    if IsSet(ContainerRect) {
        monL := ContainerRect.L
        monT := ContainerRect.T
        monR := ContainerRect.R
        monB := ContainerRect.B
        monW := monR - monL
        monH := monB - monT
    } else {
        buf := Buffer(16)
        NumPut('int', tarL, 'int', tarT, 'int', tarR, 'int', tarB, buf)
        Hmon := DllCall('MonitorFromRect', 'ptr', buf, 'uint', 0x00000002, 'ptr')
        mon := Buffer(40)
        NumPut('int', 40, mon)
        if !DllCall('GetMonitorInfo', 'ptr', Hmon, 'ptr', mon, 'int') {
            throw OSError()
        }
        monL := NumGet(mon, 20, 'int')
        monT := NumGet(mon, 24, 'int')
        monR := NumGet(mon, 28, 'int')
        monB := NumGet(mon, 32, 'int')
        monW := monR - monL
        monH := monB - monT
    }
    subL := Subject.L
    subT := Subject.T
    subR := Subject.R
    subB := Subject.B
    subW := subR - subL
    subH := subB - subT
    if Dimension = 'X' {
        if Prefer = 'L' {
            if tarL - subW - Padding >= monL {
                X := tarL - subW - Padding
            } else if tarL - subW >= monL {
                X := monL - subW + subW
            }
        } else if Prefer = 'R' {
            if tarR + subW + Padding <= monR {
                X := tarR + Padding
            } else if tarR + subW <= monR {
                X := monR - tarR + subW
            }
        } else if Prefer {
            throw _ValueError('Prefer', Prefer)
        }
        if !IsSet(X) {
            flag_nomove := false
            X := _Proc(subW, subL, subR, tarW, tarL, tarR, monW, monL, monR, Prefer = 'L' ? 1 : Prefer = 'R' ? -1 : 0)
            if flag_nomove {
                return Result
            }
        }
        Y := tarT + tarH / 2 - subH / 2
        if Y + subH > monB {
            Y := monB - subH
        } else if Y < monT {
            Y := monT
        }
    } else if Dimension = 'Y' {
        if Prefer = 'T' {
            if tarT - subH - Padding >= monL {
                Y := tarT - subH - Padding
            } else if tarT - subH >= monL {
                Y := tarT - subH
            }
        } else if Prefer = 'B' {
            if tarB + subH + Padding <= monB {
                Y := tarB + Padding
            } else if tarB + subH <= monB {
                Y := monB - tarB + subH
            }
        } else if Prefer {
            throw _ValueError('Prefer', Prefer)
        }
        if !IsSet(Y) {
            flag_nomove := false
            Y := _Proc(subH, subT, subB, tarH, tarT, tarB, monH, monT, monB, Prefer = 'T' ? 1 : Prefer = 'B' ? -1 : 0)
            if flag_nomove {
                return Result
            }
        }
        X := tarL + tarW / 2 - subW / 2
        if X + subW > monR {
            X := monR - subW
        } else if X < monL {
            X := monL
        }
    } else {
        throw _ValueError('Dimension', Dimension)
    }
    Subject.L := X
    Subject.T := Y
    Subject.R := X + subW
    Subject.B := Y + subH

    return Result

    _Proc(SubLen, SubMainSide, SubAltSide, TarLen, TarMainSide, TarAltSide, MonLen, MonMainSide, MonAltSide, Prefer) {
        if TarMainSide - MonMainSide > MonAltSide - TarAltSide {
            if TarMainSide - SubLen - Padding >= MonMainSide {
                return TarMainSide - SubLen - Padding
            } else if TarMainSide - SubLen >= MonMainSide {
                return MonMainSide + TarMainSide - SubLen
            } else {
                Result := 1
                switch InsufficientSpaceAction, 0 {
                    case 0: flag_nomove := true
                    case 1: return TarMainSide - SubLen
                    case 2: return MonMainSide
                    default: throw _ValueError('InsufficientSpaceAction', InsufficientSpaceAction)
                }
            }
        } else if TarAltSide + SubLen + Padding <= MonAltSide {
            return TarAltSide + Padding
        } else if TarAltSide + SubLen <= MonAltSide {
            return MonAltSide - TarAltSide + SubLen
        } else {
            Result := 1
            switch InsufficientSpaceAction, 0 {
                case 0: flag_nomove := true
                case 1: return TarAltSide
                case 2: return MonAltSide - SubLen
                default: throw _ValueError('InsufficientSpaceAction', InsufficientSpaceAction)
            }
        }
    }
    _ValueError(name, Value) {
        if IsObject(Value) {
            return TypeError('Invalid type passed to ``' name '``.', -2)
        } else {
            return ValueError('Unexpected value passed to ``' name '``.', -2, Value)
        }
    }
}

/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/TestSort_ItemScroller.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @classdesc - This adds a content scroller to a Gui window.
 *
 * See file "test-files\test-TestSort_ItemScroller.ahk" for an interactive example. The test code itself
 * probably isn't very easy to follow, but the gui window shows what it looks like and allows you
 * to adjust the various properties to see the effect.
 *
 * There's 6 elements included, each set to a property on the instance object:
 * - `TestSort_ItemScrollerObj.CtrlPrevious` - Back button
 * - `TestSort_ItemScrollerObj.CtrlIndex` - An edit control that shows / changes the current item index
 * - `TestSort_ItemScrollerObj.CtrlOf` - A text control that says "Of"
 * - `TestSort_ItemScrollerObj.CtrlTotal` - A text control that displays the number of items in the
 * container array
 * - `TestSort_ItemScrollerObj.CtrlJump` - Jump button - when clicked, the current item index is changed to
 * whatever number is in the edit control
 * - `TestSort_ItemScrollerObj.CtrlNext` - Next button
 *
 * The gui passed to `GuiObj` has a value property "TestSort_ItemScroller" added with a value of the
 * `TestSort_ItemScroller` instance.
 *
 * ### Orientation
 *
 * The `Orientation` parameter can be defined in three ways.
 * - "H" for horizontal orientation. The order is: Back, Edit, Of, Total, Jump, Next
 * - "V" for vertical orientation. The order is the same as horizontal.
 * - Diagram: You can customize the relative position of the controls by creating a string diagram.
 * See the documentation for {@link TestSort_ItemScroller.Diagram} for details. The names of the controls are
 * customizable, but the defaults are:
 *
 * BtnPrevious EdtIndex TxtOf TxtTotal BtnJump BtnNext
 *
 * If you use the option "CtrlNameSuffix" don't forget to include that with the names.
 * The return object from `TestSort_ItemScroller.Diagram` is set to the property `TestSort_ItemScrollerObj.Diagram`.
 */
class TestSort_ItemScroller {

    /**
     * @description - Centers a list of windows horizontally with respect to one another, splitting
     * the difference between them. The center of each window will be the midpoint between the least
     * and greatest X coordinates of the windows.
     * @param {Gui.Control[]} List - An array of controls to be centered. This function assumes there
     * are no unset indices.
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
     * @param {Gui.Control[]} List - An array of windows to be centered. This function assumes there are
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
     * a better alternative. {@link https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Align.ahk}.
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
     *  TestSort_ItemScroller.Diagram(MyGui, Diagram, 50, 100)
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
            if InStr(Value, '\') {
                Value := StrReplace(StrReplace(StrReplace(StrReplace(Value, '\\', '\')
                    , '\r', '`r'), '\n', '`n'), '\"', '"')
            }
        }
    }

    /**
     * Adds controls to a gui that can be used to scroll through items or pages using a caller-defined
     * callback function.
     * @class
     * @param {Gui} GuiObj - The `Gui` to which the controls will be added.
     * @param {Integer} Pages - The number of pages to be represented by the scroller.
     * @param {*} Callback - A function or callable object that will be called whenever the user
     * clicks "Back", "Next", or "Jump". The function will receive:
     * 1. The new index value.
     * 2. The `TestSort_ItemScroller` object.
     * @param {Object} [Options] - An object with options as property : value pairs.
     * Commonly used options are `StartX` and `StartY`.
     * @see {@link TestSort_ItemScroller.Options}
     */
    __New(GuiObj, Pages, Callback, Options?) {
        local buttonFontOpt := buttonFontFamily := textFontOpt := textFontFamily := editFontOpt := editFontFamily :=
        textBackgroundColor := editBackgroundColor := ''
        Options := this.Options := TestSort_ItemScroller.Options(Options ?? unset)
        this.GuiHwnd := GuiObj.Hwnd
        this.Index := 0
        this.Callback := Callback
        this.__Item := Map()
        this.CallbackClear := options.CallbackClear
        List := this.List := []
        List.Length := ObjOwnPropCount(Options.Controls)
        suffix := Options.CtrlNameSuffix
        paddingX := Options.PaddingX
        paddingY := Options.PaddingY
        GreatestW := 0
        for str in [ 'button', 'text', 'edit' ] {
            %str%FontOpt := Options.%str%FontOpt || Options.AllFontOpt
            %str%FontFamily := Options.%str%FontFamily || Options.AllFontFamily
            if str != 'button' {
                %str%BackgroundColor := Options.%str%BackgroundColor || Options.AllBackgroundColor
            }
        }
        for Name, Obj in Options.Controls.OwnProps() {
            if name = 'Clear' && !Options.CallbackClear {
                continue
            }
            ; Set the font first so it is reflected in the width.
            GuiObj.SetFont()
            switch Obj.Type, 0 {
                case 'Button':
                    if buttonFontOpt {
                        GuiObj.SetFont(buttonFontOpt)
                    }
                    _SetFontFamily(buttonFontFamily)
                case 'Edit':
                    if editFontOpt {
                        GuiObj.SetFont(editFontOpt)
                    }
                    _SetFontFamily(editFontFamily)
                case 'Text':
                    if textFontOpt {
                        GuiObj.SetFont(textFontOpt)
                    }
                    _SetFontFamily(textFontFamily)
            }
            this.Ctrl%Name% := List[Obj.Index] := GuiObj.Add(
                Obj.Type
              , 'x10 y10 ' (Obj.Opt ? _GetParam(Obj, 'Opt') : '')
              , Obj.Text ? _GetParam(Obj, 'Text') : ''
            )
            List[Obj.Index].Name := Obj.Name suffix
            List[Obj.Index].Options := Obj
            if Obj.Type == 'Button' {
                List[Obj.Index].GetPos(, , &cw, &ch)
                if cw > GreatestW {
                    GreatestW := cw
                }
                List[Obj.Index].OnEvent('Click', HClickButton%Name%)
            }
        }
        this.UpdatePages(Pages)
        this.CtrlIndex.Move(, , Options.EditWidth)
        if Options.NormalizeButtonWidths {
            for ctrl in List {
                if ctrl.Type == 'Button' {
                    ctrl.Move(, , GreatestW)
                }
            }
        }
        if StrLen(editBackgroundColor) {
            this.CtrlIndex.Opt('Background' editBackgroundColor)
        }
        if StrLen(textBackgroundColor) {
            this.CtrlOf.Opt('Background' textBackgroundColor)
            this.CtrlTotal.Opt('Background' textBackgroundColor)
        }
        this.SetOrientation()
        if !GuiObj.HasOwnProp('TestSort_ItemScroller') {
            GuiObj.DefineProp('TestSort_ItemScroller', { Get: TestSort_ItemScroller_PropertyAccessorGet, Set: TestSort_ItemScroller_PropertyAccessorSet })
            GuiObj.DefineProp('__TestSort_ItemScroller', { Value: Map() })
        }
        i := 1
        while GuiObj.__TestSort_ItemScroller.Has(i) {
            ++i
        }
        GuiObj.__TestSort_ItemScroller.Set(i, this)
        this.__Key := i

        return

        HChangeEditIndex(Ctrl, *) {
            Ctrl.Text := RegExReplace(Ctrl.Text, '[^\d-]', '', &ReplaceCount)
            ControlSend('{End}', Ctrl)
        }

        HClickButtonClear(Ctrl, *) {
            Ctrl.Gui.__ItemScroller.Get(this.__Key).CallbackClear.Call(this)
        }

        HClickButtonPrevious(Ctrl, *) {
            Ctrl.Gui.__TestSort_ItemScroller.Get(this.__Key).IncIndex(-1)
        }

        HClickButtonNext(Ctrl, *) {
            Ctrl.Gui.__TestSort_ItemScroller.Get(this.__Key).IncIndex(1)
        }

        HClickButtonJump(Ctrl, *) {
            Ctrl.Gui.__TestSort_ItemScroller.Get(this.__Key).SetIndex(Ctrl.Gui.__TestSort_ItemScroller.Get(this.__Key).CtrlIndex.Text)
        }

        _GetParam(Obj, Prop) {
            if Obj.%Prop% is Func {
                fn := Obj.%Prop%
                return fn(Obj, List, GuiObj, this)
            }
            return Obj.%Prop%
        }
        _SetFontFamily(Options) {
            for s in StrSplit(Options, ',') {
                if s {
                    GuiObj.SetFont(, s)
                }
            }
        }
    }

    Dispose() {
        if this.HasOwnProp('GuiHwnd') {
            G := this.Gui
            if G.HasOwnProp('TestSort_ItemScroller') {
                G.DeleteProp('TestSort_ItemScroller')
            }
            this.DeleteProp('GuiHwnd')
        }
        list := []
        list.Capacity := ObjOwnPropCount(this)
        for prop, val in this.OwnProps() {
            if IsObject(val) {
                list.Push(prop)
            }
        }
        for prop in list {
            this.DeleteProp(prop)
        }
    }

    IncIndex(N) {
        if !this.Pages {
            return 1
        }
        this.SetIndex(this.Index + N)
    }

    /**
     * @param {String} Str - The string to measure. Multi-line strings are not valid.
     * @param {Gui.Control} Ctrl - The control to use for the device context. If unset, "CtrlTotal"
     * is used.
     * @param {VarRef} [OutHeight] - A variable that will receive the width of the string in pixels.
     * @param {VarRef} [OutHeight] - A variable that will receive the height of the string in pixels.
     */
    MeasureText(Str, Ctrl?, &OutWidth?, &OutHeight?) {
        buf := Buffer(StrPut(Str, 'UTF-16'))
        StrPut(str, buf, 'UTF-16')
        sz := Buffer(8)
        context := TestSort_ItemScrollerSelectFontIntoDc(IsSet(Ctrl) ? Ctrl.Hwnd : this.CtrlTotal.Hwnd)
        if DllCall(
            'Gdi32.dll\GetTextExtentPoint32'
          , 'Ptr', context.Hdc
          , 'Ptr', buf
          , 'Int', StrLen(str)
          , 'Ptr', sz
          , 'Int'
        ) {
            context()
            OutHeight := NumGet(sz, 4, 'int')
            OutWidth := NumGet(sz, 0, 'int')
        } else {
            context()
            throw OSError()
        }
    }

    /**
     * Adjusts a control's width and height as a function of the dimensions of its text content. Use
     * this to adjust a control's dimensions after updating the font size / font name. You might
     * want to call {@link TestSort_ItemScroller.Prototype.MeasureText} before and after changing the font
     * size, so you can use the ratio to multiply by the width and height to get evenly scaled
     * dimensions.
     * @param {String} Ctrl - The control to measure. The value returned by the control's "Text"
     * property is measured, using the control as the device context. The control's width and height
     * are updated using the text's dimensions to determine the width and height
     * @param {Integer} [WidthPadding = 0] - The number of pixels to add to the control's width.
     * @param {Integer} [HeightPadding = 0] - The number of pixels to add to the control's height.
     * @param {VarRef} [OutWidth] - A variable that will receive the control's new width.
     * @param {VarRef} [OutHeight] - A variable that will receive the control's new height.
     */
    ScaleControlText(Ctrl, FontOpt?, FontName?, WidthPadding := 0, HeightPadding := 0, &OutWidth?, &OutHeight?) {
        this.MeasureText(Ctrl.Text, Ctrl, &w1, &h1)
        Ctrl.SetFont(FontOpt ?? unset, FontName ?? unset)
        this.MeasureText(Ctrl.Text, Ctrl, &w2, &h2)
        Ctrl.GetPos(, , &w, &h)
        OutWidth := w * w2 / w1 + WidthPadding
        OutHeight := h * h2 / h1 + HeightPadding
        Ctrl.Move(, , OutWidth, OutHeight)
    }

    SetIndex(Value) {
        if !this.Pages {
            return 1
        }
        Value := Number(Value)
        if (Diff := Value - this.Pages) > 0 {
            this.Index := Diff
        } else if Value < 0 {
            this.Index := this.Pages + Value + 1
        } else if Value == 0 {
            this.Index := this.Pages
        } else if Value {
            this.Index := Value
        }
        this.CtrlIndex.Text := this.Index
        return this.Callback.Call(this.Index, this)
    }

    SetOrientation(Orientation?, StartX?, StartY?, PaddingX?, PaddingY?) {
        options := this.Options
        if IsSet(StartX) {
            options.StartX := StartX
        } else {
            StartX := options.StartX
        }
        if IsSet(StartY) {
            options.StartY := StartY
        } else {
            StartY := options.StartY
        }
        if IsSet(PaddingX) {
            options.PaddingX := PaddingX
        } else {
            PaddingX := options.PaddingX
        }
        if IsSet(PaddingY) {
            options.PaddingY := PaddingY
        } else {
            PaddingY := options.PaddingY
        }
        if IsSet(Orientation) {
            options.Orientation := Orientation
        } else {
            orientation := options.Orientation
        }
        if options.ButtonWidth {
            this.CtrlPrevious.Move(, , options.ButtonWidth)
            this.CtrlJump.Move(, , options.ButtonWidth)
            this.CtrlNext.Move(, , options.ButtonWidth)
        }
        if options.ButtonHeight {
            this.CtrlPrevious.Move(, , , options.ButtonHeight)
            this.CtrlJump.Move(, , , options.ButtonHeight)
            this.CtrlNext.Move(, , , options.ButtonHeight)
        }
        if options.EditWidth {
            this.CtrlIndex.Move(, , options.EditWidth)
        }
        if options.EditHeight {
            this.CtrlIndex.Move(, , , options.EditHeight)
        }
        if options.TextOfWidth {
            this.CtrlOf.Move(, , options.TextOfWidth)
        }
        if options.TextOfHeight {
            this.CtrlOf.Move(, , , options.TextOfHeight)
        }
        if options.TextTotalWidth {
            this.CtrlTotal.Move(, , options.TextTotalWidth)
        }
        if options.TextTotalHeight {
            this.CtrlTotal.Move(, , , options.TextTotalHeight)
        }
        switch this.Orientation, 0 {
            case 'H':
                maxH := 0
                for ctrl in this.List {
                    ctrl.GetPos(, , , &h)
                    if h > maxH {
                        maxH := h
                    }
                }
                X := StartX
                for ctrl in this.List {
                    ctrl.GetPos(, , &w, &h)
                    if h == maxH {
                        ctrl.Move(X, StartY)
                    } else {
                        ctrl.Move(X, StartY + 0.5 * (maxH - h))
                    }
                    X += w + PaddingX
                }
            case 'V':
                maxW := 0
                for ctrl in this.List {
                    ctrl.GetPos(, , &w)
                    if w > maxW {
                        maxW := w
                    }
                }
                Y := StartY
                for ctrl in this.List {
                    ctrl.GetPos(, , &w, &h)
                    if w == maxW {
                        ctrl.Move(StartX, Y)
                    } else {
                        ctrl.Move(StartX + 0.5 * (maxW - w), Y)
                    }
                    Y += h + PaddingY
                }
            default:
                this.Diagram := TestSort_ItemScroller.Diagram(this.Gui, orientation, StartX, StartY, PaddingX, PaddingY)
                for row in this.Diagram.Rows {
                    TestSort_ItemScroller.CenterVList(Row.Controls)
                }

        }
    }

    SetReferenceData(values*) {
        this.__Item.Set(values*)
    }

    UpdatePages(Pages?) {
        if IsSet(Pages) {
            this.__Pages := Pages
            this.CtrlTotal.Text := Pages
        }
        if this.CtrlIndex.Text > this.__Pages {
            this.CtrlIndex.Text := this.__Pages
        }
        this.CtrlTotal.Text := this.__Pages
        this.MeasureText(this.__Pages, , &w, &h)
        if !this.Options.TextTotalWidth {
            this.CtrlTotal.Move(, , w)
        }
        if !this.Options.TextTotalHeight {
            this.CtrlTotal.Move(, , , h)
        }
        this.SetOrientation()
    }

    __Enum(VarCount := 2) {
        list := [
            this.CtrlPrevious
          , this.CtrlIndex
          , this.CtrlOf
          , this.CtrlTotal
          , this.CtrlJump
          , this.CtrlNext
          , this.CtrlClear
        ]
        i := 0
        if VarCount = 1 {
            return _Enum1
        } else if VarCount = 2 {
            return _Enum2
        } else {
            throw ValueError('Invalid ``VarCount``.', -1, VarCount)
        }

        _Enum1(&ctrl) {
            if ++i <= list.Length {
                ctrl := list[i]
                return 1
            }
            return 0
        }
        _Enum2(&name, &ctrl) {
            if ++i <= list.Length {
                ctrl := list[i]
                name := ctrl.Name
                return 1
            }
            return 0
        }
    }

    Gui => GuiFromHwnd(this.GuiHwnd)

    Orientation {
        Get => this.Options.Orientation
        Set => this.SetOrientation(Value)
    }

    PaddingX {
        Get => this.Options.PaddingX
        Set => this.SetOrientation(, , , Value)
    }

    PaddingY {
        Get => this.Options.PaddingY
        Set => this.SetOrientation(, , , , Value)
    }

    Pages {
        Get => this.__Pages
        Set => this.UpdatePages(Value)
    }

    StartX {
        Get => this.Options.StartX
        Set => this.SetOrientation(, Value)
    }

    StartY {
        Get => this.Options.StartY
        Set => this.SetOrientation(, , Value)
    }

    /**
     * @class
     * @description - Handles the input options.
     */
    class Options {
        static Default := {
            ; "All" font options will apply to all three types of controls (text, edit, button)
            ; but can be superceded by the option for a specific type.
            AllFontFamily: ''
          , AllFontOpt: ''
          , AllBackgroundColor: ''
          , ButtonFontFamily: ''
          , ButtonFontOpt: ''
          , ButtonHeight: ''
          , ButtonWidth: ''
          , CallbackClear: ''
          , CtrlNameSuffix: ''
          , EditBackgroundColor: ''
          , EditFontFamily: ''
          , EditFontOpt: ''
          , EditHeight: ''
          , EditWidth: 30
          , NormalizeButtonWidths: true
          ; Orientation can be "H" for horizontal, "V" for vertical, or it can be a diagrammatic
          ; representation of the arrangement as described in the description of this class.
          , Orientation: 'H'
          , PaddingX: 5
          , PaddingY: 5
          , StartX: 10
          , StartY: 10
          , TextBackgroundColor: ''
          , TextFontFamily: ''
          , TextFontOpt: ''
          , TextOfHeight: ''
          , TextOfWidth: ''
          , TextTotalHeight: ''
          , TextTotalWidth: ''
          , Controls: {
                ; The "Type" cannot be altered, but you can change their name, opt, text, or index.
                ; If `Opt` or `Text` are function objects, the function will be called passing
                ; these values to the function:
                ; - The control options object (not the actual Gui.Control, but the object like the
                ; ones below).
                ; - The array that is being filled with these controls
                ; - The Gui object
                ; - The TestSort_ItemScroller instance object.
                ; The function should then return the string to be used for the options / text
                ; parameter. I don't recommend returning a size or position value, because this
                ; function handles that internally.
                Previous: { Name: 'BtnPrevious', Type: 'Button', Opt: '', Text: '<', Index: 1 }
              , Index: { Name: 'EdtIndex', Type: 'Edit', Opt: '', Text: '1', Index: 2 }
              , Of: { Name: 'TxtOf', Type: 'Text', Opt: '', Text: 'of', Index: 3 }
              , Total: { Name: 'TxtTotal', Type: 'Text', Opt: '', Text: '', Index: 4  }
              , Jump: { Name: 'BtnJump', Type: 'Button', Opt: '', Text: 'Jump', Index: 5 }
              , Next: { Name: 'BtnNext', Type: 'Button', Opt: '', Text: '>', Index: 6 }
              , Clear: { Name: 'BtnClear', Type: 'Button', Opt: '', Text: 'Clear', Index: 7 }
            }
        }

        /**
         * Handles processing the input options.
         * @param {Object} [Options] - The input object.
         * @return {Object}
         */
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

/**
 * @classdesc - Use this as a safe way to access a window's font object. This handles accessing and
 * releasing the device context and font object.
 */
class TestSort_ItemScrollerSelectFontIntoDc {

    __New(Hwnd) {
        this.Hwnd := Hwnd
        if !(this.Hdc := DllCall('GetDC', 'Ptr', Hwnd, 'ptr')) {
            throw OSError()
        }
        OnError(this.Callback := ObjBindMethod(this, '__ReleaseOnError'), 1)
        if !(this.Hfont := SendMessage(0x0031, 0, 0, , Hwnd)) { ; WM_GETFONT
            throw OSError()
        }
        if !(this.OldFont := DllCall('SelectObject', 'ptr', this.Hdc, 'ptr', this.Hfont, 'ptr')) {
            throw OSError()
        }
    }

    /**
     * @description - Selects the old font back into the device context, then releases the
     * device context.
     */
    Call() {
        if err := this.__Release() {
            throw err
        }
    }

    __ReleaseOnError(thrown, mode) {
        if err := this.__Release() {
            thrown.Message .= '; ' err.Message
        }
        throw thrown
    }

    __Release() {
        if this.OldFont {
            if !DllCall('SelectObject', 'ptr', this.Hdc, 'ptr', this.OldFont, 'int') {
                err := OSError()
            }
            this.DeleteProp('OldFont')
        }
        if this.Hdc {
            if !DllCall('ReleaseDC', 'ptr', this.Hwnd, 'ptr', this.Hdc, 'int') {
                if IsSet(err) {
                    err.Message .= '; Another error occurred: ' OSError().Message
                }
            }
            this.DeleteProp('Hdc')
        }
        OnError(this.Callback, 0)
        return err ?? ''
    }

    __Delete() => this()

    static __New() {
        if this.Prototype.__Class == 'SelectFontIntoDc' {
            Proto := this.Prototype
            Proto.DefineProp('Hdc', { Value: '' })
            Proto.DefineProp('Hfont', { Value: '' })
            Proto.DefineProp('OldFont', { Value: '' })
        }
    }
}

TestSort_ItemScroller_PropertyAccessorGet(Self, Index := 1) {
    return Self.__TestSort_ItemScroller[Index]
}
TestSort_ItemScroller_PropertyAccessorSet(Self, Value, Index := 1) {
    if !IsSet(Value) {
        return
    }
    Self.__TestSort_ItemScroller.Set(Index, Value)
}
/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/RectHighlight.ahk
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @classdesc -
 * Displays a the outline of a rectangle, and has methods for manipulating the rectangle.
 * Adapted from {@link https://github.com/Descolada/UIAutomation}
 */
class RectHighlight extends Gui {
    /**
     * @class
     * @param {*} [Obj] - The object around which the highlighted region will be drawn, or any object
     * that can provide the needed information. `RectHighlight` will attempt to get the dimensions
     * from the object in this order, stopping as soon as the dimensions have been defined:
     * - If the object has a `GetPos` method, `RectHighlight` will call `Obj.GetPos(&x, &y, &w, &h)`.
     * - If the object has an `hWnd` property, `RectHighlight` will call `WinGetPos(&x, &y, &w, &h, Obj.hWnd)`.
     * - If the object has neither of the above properties, the object may have any of the following
     * combinations of properties:
     *   - { L, T, R, B }
     *   - { Left, Top, Right, Bottom }
     *   - { X, Y, W, H }
     *   - { X, Y, Width, Height }
     * - If none of these are found, `RectHighlight` throws an error.
     *
     * @param {Object} [Options] - An object with zero or more of the following properties:
     * @param {Boolean} [Options.Blink=false] - `Options.Blink` changes the function used when
     * `Options.Duration > 0`. When `Options.Duration > 0`, and when the timer is activated, the
     * function associated with the timer is called every `Options.Duration` milliseconds. When
     * `Options.Blink` is nonzero, each time the function is called, the visibility of the rectangle
     * is toggled on / off. When `Options.Blink` is falsy, each time the function is called the
     * visibility of the rectangle is not cheanged; insteaad, the position and size of the rectangle
     * is updated using the `Obj` object's current position and size. When `Options.Duration <= 0`,
     * `Options.Blink` has no effect.
     * @param {Integer} [Options.Border=2] - The border thickness in pixels.
     * @param {String} [Options.Color='00e0fe'] - The color of the highlighting. The default value is
     * a light blue.
     * @param {Integer} [Options.Duration=-3000] - The duration (milliseconds) passed to `SetTimer`.
     * - See the description of `Options.Blink` for information about how `Options.Duration` is used
     * when it is a positive number.
     * - If `Options.Duration` is a negative number, the highlighted area will be visible for the
     * duration then will auto-hide after the duration passes.
     * - If zero, the highlighted area will be visible indefinitely.
     *
     * @see {@link RectHighlight#Call} for more information about toggling visibility and using the
     * timer.
     *
     * Use `Hide` or `Show` (built-in Gui methods) to toggle visibility independently from the timer.
     * @param {Integer} [Options.OffsetL=0] - Any number of pixels to offset the left side of the
     * highlighted region.
     * @param {Integer} [Options.OffsetT=0] - Any number of pixels to offset the top of the
     * highlighted region.
     * @param {Integer} [Options.OffsetR=0] - Any number of pixels to offset the right side of the
     * highlighted region.
     * @param {Integer} [Options.OffsetB=0] - Any number of pixels to offset the bottom of the
     * highlighted region.
     * @param {String} [Options.PositionFontOpt = "q5 c" Options.Color] - The font options for the coordinates,
     * if the coordinates are in use. If unset, or if the value does not contain a color option,
     * the color will be set to the same as `Options.Color`.
     * @param {String} [Options.PositionFontName = ""] - The name of the font for the
     * coodinates, if the coordinates are in use.
     * @param {String} [Options.Title = "Highlight"] - The title to assign to the window.
     *
     * @param {Boolean} [ShowImmediately=true] - Note that if `Obj` is unset, `ShowImmediately` is
     * ignored. If `ShowImmediately` is nonzero, the rectangle is displayed before `RectHighlght.Call`
     * returns. Additionally, if `Options.Duration` is nonzero, the timer is initiated. If `ShowImmediately`
     * is falsy, the object is created and returned but the window remains hidden.
     * @returns {RectHighlight}
     */
    static Call(Obj?, Options?, ShowImmediately := true) {
        Options := this.Options(Options ?? {})
        ObjSetBase(G := Gui('+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000', Options.Title), this.Prototype)
        G.Options := Options
        if IsSet(Obj) {
            Options.DefineProp('Obj', { Value: Obj })
        }
        G.Timer := false
        ; Some gui methods return incorrect values if the window was never shown.
        G.Show()
        G.Hide()
        G.L := G.T := G.W := G.H := 0
        G.SetTimerFunc('', 1)
        G.SetTimerFunc('', 2)
        if ShowImmediately && IsSet(Obj) {
            G(, G.Options)
        }
        return G
    }

    /**
     * @description - Toggles the timer, optionally toggling the visibility of the highlighted
     * rectangle. The way visibility is toggled depends on some conditions:
     * - If `RectHighlightObj.Timer` is nonzero at the start of the call, visibility is not toggled.
     * This is an explanation of why this design choice was made: `RectHighlightObj.Timer` is only
     * set with a nonzero value when `Options.Duration > 0`. When `Options.Duration > 0`, and when
     * `Options.Blink` is nonzero, the visibility of the rectangle will be toggled every time the
     * timer calls its function. Therefore, if `RectHighlightObj.Timer > 0`, the visibility is going
     * to be toggled anyway when the timer calls the function for the last time before disabling
     * itself.
     *
     * - If `Options.Blink` is falsy, visibility is never toggled. This is because the timer updates
     * the position and/or size of the rectangle instead of toggling visibility.
     *
     * You can specify a visibility status with the `Visibility` parameter; anything nonzero will
     * show the rectangle, and anything falsy will hide it. Adjusting the visibility using the
     * `Visibility` parameter does not invoke any callbacks you have set.
     *
     * In all other cases, these rules are applied:
     *
     * - If `Options.Duration > 0`, visibility is not toggled.
     * - If `Options.Duration` is falsy:
     *   - If `Visibility` is set, it takes precedence; `RectHighlight.Prototype.Call` will set the
     * visibility according to the value.
     *   - If `Visibility` is not set, visibility is toggled.
     * - If `Options.Duration < 0`, visibility is toggled only when `ReectHighlightObj.Visible` is
     * falsy (i.e. when the rectangle is not currently visible it will be toggled and made visible).
     * If `RectHighlight.Prototype.Call` is called when the rectangle is already visible, the timer
     * is refreshed to `Options.Duration` milliseconds. If you need to force the rectangle to hide,
     * pass zero to `Visibility`.
     * @param {*} [Obj] - This parameter has the same requirements as the `Obj` parameter of
     * `RectHighlight.Call`. When calling `RectHighlight.Prototype.Call`, you can optionally pass a
     * new object to change the characteristics of the highlighted rectangle. Passing an object is
     * unnecessary if you intend to use the same object used when the instance was created or when
     * `RectHighlight.Prototype.Call` was last called; the input object is cached on the `RectHighlight`
     * object.
     * @param {Object} [Options] - An object containing property : value pairs representing the options
     * to set on the `RectHighlight` object. The options are the same as the parameters of
     * `RectHighlight.Call` (except for `Obj` and `ShowImmediately`). Valid values are:
     * { Border, Color, Duration, OffsetL, OffsetT, OffsetR, OffsetB }.
     * @param {Boolean} [Visibility] - If set, the visibility of the highlighted rectangle will be set to
     * this value.
     */
    Call(Obj?, Options?, Visibility?) {
        if IsSet(Options) {
            this.HighlightSetOpt(Options)
        } else {
            this.BackColor := this.Color
        }
        if IsSet(Obj) {
            this.Options.DefineProp('Obj', { Value: Obj })
        } else if !this.Options.Obj {
            throw Error('``RectHighlight`` cannot calculate dimensions until a reference object has been provided.', -1)
        }
        if this.Timer {
            this.Timer := false
        } else {
            if this.Duration {
                if this.Duration > 0 {
                    this.SetRegion(false)
                    this.Timer := true
                    SetTimer(this.TimerFunc, this.Duration)
                } else {
                    this.SetRegion()
                    this.Timer := false
                    SetTimer(this.TimerFunc, this.Duration)
                }
            } else {
                this.Timer := false
                if IsSet(Visibility) {
                    _Proc()
                    return
                }
                if this.Visible {
                    this.TimerHide()
                } else {
                    if this.OnShowActive {
                        this.OnShow()
                    }
                    this.SetRegion()
                }
            }
        }
        if IsSet(Visibility) {
            _Proc()
        }

        _Proc() {
            if Visibility {
                this.SetRegion()
            } else {
                this.Hide()
            }
        }
    }

    ConstructPositionDisplay() {
        Options := this.Options
        G := this.PositionDisplay := Gui('+AlwaysOnTop -Caption +ToolWindow -DPIScale +Owner' this.Hwnd, Options.Title)
        WinSetTransparent(0, G.Hwnd)
        if Options.PositionFontOpt && RegExMatch(Options.PositionFontOpt, '\b[cC]') {
            G.SetFont(Options.PositionFontOpt, Options.PositionFontName || unset)
        } else {
            G.SetFont('c' Options.Color ' ' (Options.PositionFontOpt ? Options.PositionFontOpt : 'q5'), Options.PositionFontName || unset)
        }
        this.TopLeft := G.Add('Text', 'BackgroundTrans vTxtTL', '-00000, -00000')
        this.TopRight := G.Add('Text', 'BackgroundTrans Right vTxtTR', '-00000, -00000')
        this.BottomRight := G.Add('Text', 'BackgroundTrans Right vTxtBR', '-00000, -00000')
        this.BottomLeft := G.Add('Text', 'BackgroundTrans vTxtBL', '-00000, -00000')
        this.TopLeft.Text := this.TopRight.Text := this.BottomRight.Text := this.BottomLeft.Text := ''
        this.TopLeft.GetPos(, , &txtw, &txth)
        this.TopLeft.W := txtw
        this.TopLeft.H := txth
        G.Show()
    }

    /**
     * @description - Deletes the input `Obj` from the `Options` object, and calls `this.Destroy()`.
     */
    Dispose() {
        if this.HasOwnProp('Options') {
            if this.Options.HasOwnProp('Obj') {
                this.Options.DeleteProp('Obj')
            }
            this.DeleteProp('Options')
        }
        this.Destroy()
    }

    /**
     * @description - Returns a function object that can be set as an object method. The function
     * simply calls `RectHighlight.Prototype.Call`, but is compatible with being a method of
     * some other object. The function will forward parameters to `RectHighlight.Prototype.Call`.
     * @param {Boolean} [FirstParamOnly=false] - If true, the function will only forward the first
     * parameter to `RectHighlight.Prototype.Call`. This is useful if you want to use an event handler
     * with a Gui object. Since the first parameter will be the control or Gui object that triggered
     * the event, the object is forwarded to `RectHighlight.Prototype.Call` to highlight it.
     * If false, all parameters are forwarded to `RectHighlight.Prototype.Call`.
     * @returns {BoundFunc} - A function that can be set as an object method.
     *
     * @example
     *  EventHandler := {}
     *  G := Gui('+Resize', , EventHandler)
     *  loop 10 {
     *      G.Add('Button', , 'Button ' A_Index).OnEvent('Click', 'HClickButtonHighlight')
     *  }
     *  ; Call the constructor without an initial object.
     *  Highlighter := RectHighlight(, { Duration: -5000, OffsetR: 5, OffsetL: 5, OffsetT: 5, OffsetB: 5 })
     *  EventHandler.DefineProp('HClickButtonHighlight', { Call: Highlighter.GetFunc(true) })
     *  G.Show()
     *  ; Clicking the buttons should display a highlighted rectangle around the button.
     * @
     */
    GetFunc(FirstParamOnly := false) {
        return FirstParamOnly ? _Call1.Bind(this) : _Call2.Bind(this)
        _Call1(RectHighlightObj, Self, Params*) {
            return RectHighlightObj(Params[1])
        }
        _Call2(RectHighlightObj, Self, Params*) {
            return RectHighlightObj(Params*)
        }
    }

    /**
     * @description - Performs the calculations to get the position and dimensions from the input object.
     * This does not apply offsets.
     * @param {Object} Obj - The object from which to get the position and dimensions.
     * @throws {ValueError} - If the input object does not have the required properties for `RectHighlight`.
     */
    GetPos(Obj) {
        if HasMethod(Obj, 'GetPos') {
            Obj.GetPos(&x, &y, &w, &h)
            if Obj is Gui.Control {
                Obj.Gui.GetClientPos(&gx, &gy)
                x += gx
                y += gy
            }
        } else if HasProp(Obj, 'hWnd') {
            WinGetPos(&x, &y, &w, &h, Obj.hWnd)
            if Obj is Gui.Control {
                Obj.Gui.GetClientPos(&gx, &gy)
                x += gx
                y += gy
            }
        } else {
            for Arr in RectHighlight.__Properties {
                Flag := 1
                for Prop in Arr {
                    if !HasProp(Obj, Prop) {
                        Flag := 0
                        break
                    }
                }
                if Flag {
                    switch A_Index {
                        case 1, 2:
                            x := Obj.%Arr[1]%
                            y := Obj.%Arr[2]%
                            w := x + Obj.%Arr[3]%
                            h := y + Obj.%Arr[4]%
                        case 3, 4:
                            x := Obj.%Arr[1]%
                            y := Obj.%Arr[2]%
                            w := Obj.%Arr[3]%
                            h := Obj.%Arr[4]%
                    }
                    break
                }
            }
        }
        if IsSet(x) {
            result := x !== this.L || y !== this.T || w !== this.W || h !== this.H
            this.L := x
            this.T := y
            this.W := w
            this.H := h
            return result
        } else {
            throw ValueError('The input object dose not have the required properties for ``RectHighlight``.', -1, 'Type(Obj) == ' Type(Obj))
        }
    }

    /**
     * @description - Calculates the position and size of the rectangle, and moves the window.
     */
    HighlightMove() {
        O := this.Options
        if this.GetPos(O.Obj) {
            this.Move(
                this.L - O.OffsetL - O.Border
              , this.T - O.OffsetT - O.Border
              , this.W + O.Border * 2 + O.OffsetL + O.OffsetR
              , this.H + O.Border * 2 + O.OffsetT + O.OffsetB
            )
        }
    }

    /**
     * @description - Updates the options.
     * @param {Object} Options - An object with property : value pairs for zero or more options. See
     * the parameter hint above `RectHighlight.Call` for details about the options. Here is a list
     * of valid options: { Blink, Border, Color, Duration, OffsetL, OffsetT, OffsetR, OffsetB,
     * OnHide, OnShow }
     * @param {Boolean} [SuppressPropertyError=false] - Specifies what `RectHighlight.Prototype.HighlightSetOpt`
     * does if it encounters a property that is not a valid option.
     * - If false, throws an error.
     * - If true, skips the property.
     */
    HighlightSetOpt(Options, SuppressPropertyError := false) {
        if this.HasOwnProp('Options') {
            O := this.Options
            for Prop, Value in Options.OwnProps() {
                if Prop = 'OnHide' {
                    this.SetCallback(Value)
                } else if Prop = 'OnMove' {
                    this.SetCallback( , Value)
                } else if Prop = 'OnShow' {
                    this.SetCallback( , , Value)
                } else if HasProp(O, Prop) {
                    if Value || Value == 0 {
                        O.DefineProp(Prop, { Value: Value })
                    } else {
                        O.DeleteProp(Prop)
                    }
                } else if !SuppressPropertyError {
                    throw PropertyError('Invalid option.', -1, Prop)
                }
            }
        } else {
            this.DefineProp('Options', { Value: RectHighlight.Options(Options) })
            if Options.OnHide {
                this.SetCallback(Options.OnHide)
            }
            if Options.OnMove {
                this.SetCallback(, Options.OnMove)
            }
            if Options.OnShow {
                this.SetCallback(, , Options.OnShow)
            }
        }
        this.BackColor := O.Color
    }

    OnHide() {
        this.__ThrowOverrideError(A_ThisFunc)
    }
    OnMove() {
        this.__ThrowOverrideError(A_ThisFunc)
    }
    OnShow() {
        this.__ThrowOverrideError(A_ThisFunc)
    }

    SetCallback(OnHide?, OnMove?, OnShow?) {
        if IsSet(OnShow) {
            _Proc('OnShow', OnShow)
        }
        if IsSet(OnHide) {
            _Proc('OnHide', OnHide)
        }
        if IsSet(OnMove) {
            _Proc('OnMove', OnMove)
        }
        _Proc(Prop, Value) {
            if Value {
                this.DefineProp(Prop, { Call: Value })
            } else {
                if this.HasOwnProp(Prop) {
                    this.DeleteProp(Prop)
                } else {
                    throw PropertyError('No callback has been set.', -1, Prop)
                }
            }
        }
    }

    SetCoordinates() {
        O := this.Options
        border := O.Border
        this.TopLeft.Text := '( ' this.L ', ' this.T ' )'
        this.TopLeft.Move(border + 1, border + 1)
        this.TopRight.Text := '( ' (this.L + this.W) ', ' this.T ' )'
        this.TopRight.Move(this.W - this.TopLeft.W - border - 1, border + 1)
        this.BottomRight.Text := '( '  (this.L + this.W) ', ' (this.T + this.H) ' )'
        this.TopRight.Move(this.W - this.TopLeft.W - border - 1, this.H - this.TopLeft.H - border - 1)
        this.BottomLeft.Text := '( ' this.L ', ' (this.T + this.H) ' )'
        this.TopRight.Move(border + 1, this.H - this.TopLeft.H - border - 1)
    }

    SetPositionControlsState(Value) {
        this.TopLeft.Visible := this.TopRight.Visible := this.BottomRight.Visible := this.BottomLeft.Visible :=
        this.TopLeft.Enabled := this.TopRight.Enabled := this.BottomRight.Enabled := this.BottomLeft.Enabled := Value
    }

    /**
     * @description - Adjusts the rectangle's dimensions using the options.
     * `RectHighlight.Prototype.SetRegion` uses the following options to set the rectangle's
     * dimensions: Border, OffsetL, OffsetT, OffsetR, OffsetB, Obj.
     * @param {Boolean} [Show=true] - If true, `RectHighlight.Prototype.SetRegion` also does these
     * actions:
     * - Sets `RectHighlightObj.Visible := true`
     * - Calls `RectHighlightObj.Show('NoActivate')`
     */
    SetRegion(Show := true) {
        O := this.Options
        border := O.Border
        if this.GetPos(O.Obj) {
            WinSetRegion(Format('0-0 {1}-0 {1}-{2} 0-{2} 0-0    {3}-{4} {5}-{4} {5}-{6} {3}-{6} {3}-{4}'
                    , OuterR := this.W + border * 2 + O.OffsetL + O.OffsetR           ; Outer right - 1
                    , OuterB := this.H + border * 2 + O.OffsetT + O.OffsetB           ; Outer bottom - 2
                    , border                                                      ; Inner left - 3
                    , border                                                      ; Inner top - 4
                    , OuterR - border                                             ; Inner right - 5
                    , OuterB - border                                             ; Inner bottom - 6
                ), this.hWnd
            )
            this.Move(this.L - O.OffsetL - border, this.T - O.OffsetT - border, OuterR, OuterB)
        }
        if !this.Visible && Show {
            this.Show('NoActivate')
        }
    }

    /**
     * @description - Modifies the function that is called by `SetTimer`. There are two sets of
     * functions, and which is used depends on the value of `Options.Blink`. To modify a specific
     * function, set the `Which` parameter. To modify the function associated with the current
     * `Options.Blink` value, leave `Which` unset.
     *
     * This also changes the value returned by the property `RectHighlight.Prototype.TimerFunc`.
     * @param {*} Function - Any callable object, such as a `Func`, an object with a `Call` method,
     * or an object with a `__Call` method. To direct `RectHighlight.Prototype.SetTimerFunc` to
     * revert a modified function back to the built-in function, pass zero or an empty string to
     * `Function`.
     * @param {Integer} [Which] - Set `Which` to specify which function to adjust. Valid values are:
     * - 1: The function used when `Options.Blink` is falsy will be modified.
     * - 2: The function used when `Options.Blink` is nonzero will be modified.
     * - Unset: The function associated with the current `Options.Blink` value will be modified.
     */
    SetTimerFunc(Function, Which?) {
        if !IsSet(Which) {
            Which := this.Blink ? 2 : 1
        }
        if Which == 1 {
            if Function {
                this.DefineProp('__Func_Move', { Value: Function })
            } else {
                this.DefineProp('__Func_Move', { Value: ObjBindMethod(this, '__Timer_Move') })
            }
        } else {
            if Function {
                this.DefineProp('__Func_Blink', { Value: Function })
            } else {
                this.DefineProp('__Func_Blink', { Value: ObjBindMethod(this, '__Timer_Blink') })
            }
        }
    }

    /**
     * @description - Calls the `OnHide` callback if in use, hides the window, and sets
     * `RectHighlightObj.Visible := false`.
     */
    TimerHide() {
        if this.OnHideActive {
            this.OnHide()
        }
        this.Hide()
    }

    __ThrowOverrideError(fn) {
        throw Error('The method must be overridden.', -2, fn)
    }
    __Timer_Blink() {
        ; To handle cases when the setting is changed directly on the options object while a
        ; timer is currently active.
        if !this.Blink {
            SetTimer(, 0)
            return
        }
        if this.Timer {
            if this.Visible {
                this.TimerHide()
            } else {
                if this.OnShowActive {
                    this.OnShow()
                }
                this.SetRegion()
            }
        } else {
            SetTimer(, 0)
            this.TimerHide()
        }
    }
    __Timer_Move() {
        ; To handle cases when the setting is changed directly on the options object while a
        ; timer is currently active.
        if this.Blink {
            SetTimer(, 0)
            return
        }
        if this.Visible {
            if this.Timer {
                if this.OnMoveActive {
                    this.OnMove()
                }
                this.SetRegion(false)
            } else {
                SetTimer(, 0)
                this.TimerHide()
            }
        } else {
            if this.Timer {
                if this.OnShowActive {
                    this.OnShow()
                }
                this.SetRegion()
            }
        }
    }

    Blink {
        Get => this.Options.Blink
        Set {
            if !Value = !this.Options.Blink {
                return
            }
            SetTimer(this.TimerFunc, 0)
            this.Options.Blink := 1
            if this.Timer {
                SetTimer(this.TimerFunc, this.Duration)
            }
        }
    }

    Border {
        Get => this.Options.Border
        Set => this.Options.Border := Value
    }

    Color {
        Get => this.Options.Color
        Set => this.Options.Color := Value
    }

    Duration {
        Get => this.Options.Duration
        Set => this.Options.Duration := Value
    }

    Obj {
        Get => this.Options.Obj
        Set {
            this.Options.Obj := Value
            this.SetRegion(false)
        }
    }

    OffsetB {
        Get => this.Options.OffsetB
        Set => this.Options.OffsetB := Value
    }

    OffsetL {
        Get => this.Options.OffsetL
        Set => this.Options.OffsetL := Value
    }

    OffsetR {
        Get => this.Options.OffsetR
        Set => this.Options.OffsetR := Value
    }

    OffsetT {
        Get => this.Options.OffsetT
        Set => this.Options.OffsetT := Value
    }

    OnHideActive => this.HasOwnProp('OnHide')
    OnMoveActive => this.HasOwnProp('OnMove')
    OnShowActive => this.HasOwnProp('OnShow')

    /**
     * @description - `RectHighlight.Prototype.TimerFunc` has an optional parameter `Which`.
     * `Which` is intended to be used in cases when getting or setting a specific function object is
     * needed.
     *
     * Regarding the getter:
     *
     * The function returned by the getter depends on the value of `Options.Blink`, and whether you
     * have set your own callback function using `RectHighlight.Prototype.SetTimerFunc`. In either
     * case, the function object is located on the `RectHighlightObj.__Func_Move` property or the
     * `RectHighlightObj.__Func_Blink` property.
     *
     * If `Which` is set, the current value of `Options.Blink` is ignored.
     * - If `Which` is 1, returns `RectHighlightObj.__Func_Move`, which is the function used when
     * `Options.Blink` is falsy.
     * - If `Which` is 2, returns `RectHighlightObj.__Func_Blink`, which is the function used when
     * `Options.Blink` is nonzero.
     * - If `Which` is unset
     *   - If `Options.Blink` is falsy, returns `RectHighlightObj.__Func_Move`.
     *   - If `Options.Blink` is nonzero, returns `RectHighlightObj.__Func_Blink`.
     *
     * Regarding the setter, see the parameter hint above `RectHighlight.Prototype.SetTimerFunc`.
     * @param [Which] - Either 1 or 2 as described in the description.
     * @returns {Func} - A timer function.
     * @instance
     */
    TimerFunc[Which?] {
        Get {
            if IsSet(Which) {
                if Which == 1 {
                    return this.__Func_Move
                }
                if Which == 2 {
                    return this.__Func_Blink
                }
            }
            return this.Options.Blink ? this.__Func_Blink : this.__Func_Move
        }
        Set => this.SetTimerFunc(Value, Which ?? unset)
    }

    Visible => DllCall('IsWindowVisible', 'ptr', this.Hwnd, 'int')

    static __New() {
        if this.Prototype.__Class == 'RectHighlight' {
            this.__Properties := [
                ['L', 'T', 'R', 'B']
              , ['Left', 'Top', 'Right', 'Bottom']
              , ['X', 'Y', 'W', 'H']
              , ['X', 'Y', 'Width', 'Height']
            ]
        }
    }

    /**
     * @class
     * @description - Handles the input options.
     */
    class Options {
        static Default := {
            Blink: false
          , Border: 2
          , Color: '00e0fe'
          , Duration: -3000
          , Obj: ''
          , OffsetL: 0
          , OffsetT: 0
          , OffsetR: 0
          , OffsetB: 0
          , OnHide: ''
          , OnMove: ''
          , OnShow: ''
          , PositionFontOpt: ''
          , PositionFontName: ''
          , Title: 'Highlight'
        }

        /**
         * @description - Sets the base object such that the values are used in this priority order:
         * - 1: The input object.
         * - 2: The configuration object (if present).
         * - 3: The default object.
         * @param {Object} Options - The input object.
         * @return {Object} - The same input object.
         */
        static Call(Options) {
            if IsSet(RectHighlightConfig) {
                ObjSetBase(RectHighlightConfig, RectHighlight.Options.Default)
                ObjSetBase(Options, RectHighlightConfig)
            } else {
                ObjSetBase(Options, RectHighlight.Options.Default)
            }
            return Options
        }
    }
}

class TestSort_ListviewMenu extends TestSort_MenuEx {
    static __New() {
        this.DeleteProp('__New')
        this.DefaultItems := [
            { Name: 'Show array histogram', Value: 'SelectShowArrayHistogram' }
          , { Name: 'Show array histogram - 15 bins', Value: 'SelectShowArrayHistogram15' }
          , { Name: 'Show array histogram - 20 bins', Value: 'SelectShowArrayHistogram20' }
          , { Name: 'Show array histogram - 25 bins', Value: 'SelectShowArrayHistogram25' }
          , { Name: 'Load values into fields', Value: 'SelectLoadValuesIntoFields' }
        ]
    }
    Initialize(*) {
        this.AddObjectList(TestSort_ListviewMenu.DefaultItems)
    }
    SelectLoadValuesIntoFields(Params) {
        if Params.Token.Item {
            test.LoadValuesIntoFields(Params.Token.Item)
            return 'Loading values into fields.'
        } else {
            return 'Right-click directly on a row with text'
        }
    }
    SelectShowArrayHistogram(Params) {
        this.__ShowHistogram(Params)
    }
    SelectShowArrayHistogram15(Params) {
        this.__ShowHistogram(Params, 15)
    }
    SelectShowArrayHistogram20(Params) {
        this.__ShowHistogram(Params, 20)
    }
    SelectShowArrayHistogram25(Params) {
        this.__ShowHistogram(Params, 25)
    }
    __ShowHistogram(Params, bins?) {
        if Params.Token.Item {
            test.ShowHistogram(Params.Token.Item, bins ?? unset)
            return 'Showing histogram'
        } else {
            return 'Right-click directly on an item to select'
        }
    }
}

/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-TestSort_MenuEx
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * `TestSort_MenuEx` is a composotion of AHK's native `Menu` class. The purpose of `TestSort_MenuEx` is to provide a
 * standardized system for creating, modifying, and using a menu. For each item added to the menu,
 * an associated {@link TestSort_MenuExItem} is created and added to the collection. The `TestSort_MenuExItem` instances
 * can be accessed by name from the `TestSort_MenuEx` instance, and the `TestSort_MenuExItem` instance's properties can
 * be modified to change the characteristics of the menu item.
 *
 * ## Context Menu
 *
 * Though `TestSort_MenuEx` is useful for any menu, I designed it with a focus on functionality related to
 * context menus. When creating a context menu with `TestSort_MenuEx`, the `TestSort_MenuEx` instance will have a
 * method "Call" which activates the context menu. To use, simply pass the `TestSort_MenuEx` object to the
 * event handler for the gui or control.
 *
 * @example
 *  g := Gui()
 *  TestSort_MenuExObj := TestSort_MenuEx(Menu())
 *  g.OnEvent('ContextMenu', TestSort_MenuExObj) ; pass `TestSort_MenuExObj` to event handler
 * @
 *
 * Or
 *
 * @example
 *  g := Gui()
 *  g.Add('TreeView', 'w100 r10 vTv')
 *  TestSort_MenuExObj := TestSort_MenuEx(Menu())
 *  g['Tv'].OnEvent('ContextMenu', TestSort_MenuExObj) ; pass `TestSort_MenuExObj` to event handler
 * @
 *
 * ## Extending TestSort_MenuEx
 *
 * `TestSort_MenuEx` was designed with object inheritance in mind. One benefit of using `TestSort_MenuEx` over
 * using `Menu` directly is it makes it easy to share menu items between menus and between scripts.
 *
 * Inheriting from `TestSort_MenuEx` involves 2-4 steps. See the example in file
 * "test\demo-TreeView-context-menu.ahk" for a working example of each of these steps.
 *
 * 1. Define default items.
 *
 * To define default items, your class should define a static method "__New" that adds a property
 * "DefaultItems" to the prototype. "DefaultItems" is an array of objects, each object with required
 * properties { Name, Value } and optional properties { Options, Tooltip }.
 * - Name: The name of the menu item. This is used across the `TestSort_MenuEx` class and related classes. It
 *   is the name that is used to get a reference to the `TestSort_MenuExItem` instance associated with the
 *   menu item, e.g. `TestSort_MenuExObj.Get("ItemName")`. It is also the text that is displayed in the menu
 *   for that item.
 * - Value: "Value" can be defined with three types of values.
 *   - A `Menu` object, if the menu item is a submenu.
 *   - A `Func` or callable object that will be called when the user selects the item.
 *   - A string representing the name of a class instance method defined by your custom class which
 *     inherits from `TestSort_MenuEx` (see the "test\demo-TreeView-context-menu.ahk" for an example).
 * - Options: Any options as described in {@link https://www.autohotkey.com/docs/v2/lib/Menu.htm#Add}.
 * - Tooltip: A value as described by {@link TestSort_MenuExItem.Prototype.SetTooltipHandler}
 *
 * 2. Define "Initialize".
 *
 * Define a method "Initialize" which calls `this.AddObjectList(this.DefaultItems)` and any other
 * initialization tasks required by your class.
 *
 * 3. (Optional) Define instance methods.
 *
 * When creating a class that represents a menu that will be reused across various windows / scripts,
 * it makes sense to define the menu item functions directly in the class as instance methods.
 *
 * 4. (Optional) Define an item availability handler.
 *
 * It is often appropriate to adjust the availability of one or more menu items depending on the
 * context in which a context menu is activated. The item availability handler is only used when the
 * menu is a context menu (more specifically, the item availability handler is only used when
 * {@link TestSort_MenuEx.Prototype.SetEventHandler} is called with a value of `1` or `2`).
 *
 * Define the item availability handler as an instance method "HandlerItemAvailability".
 *
 */
class TestSort_MenuEx {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.__HandlerSelection := proto.__HandlerItemAvailability := proto.Token :=
        proto.__HandlerTooltip := ''
    }
    /**
     * @param {Menu|MenuBar} [MenuObj] - The menu object. If unset, a new instance of `Menu` is created.
     *
     * @param {Object} [Options] - An object with zero or more options as property : value pairs.
     *
     * @param {Boolean} [Options.CaseSense = false] - If true, the collection is case-sensitive. This
     * means that accessing menu items from the collection by name is case-sensitive.
     *
     * @param {*} [Options.HandlerTooltip = ""] - See {@link TestSort_MenuEx.Prototype.SetTooltipHandler~Callback}.
     *
     * @param {*} [Options.HandlerSelection = ""] - See {@link TestSort_MenuEx.Prototype.SetSelectionHandler~Callback}.
     *
     * @param {Boolean} [Options.ShowTooltip = false] - If true, enables tooltip functionality.
     * `TestSort_MenuEx`'s tooltip functionality allows you to define your menu and related options to
     * display a tooltip when the user selects a menu item. See {@link TestSort_MenuExItem.Prototype.SetTooltipHandler}
     * for details and see file "test\demo-TreeView-context-menu.ahk" for a working example.
     *
     * @param {Integer} [Options.WhichMethod = 1] - `Options.WhichMethod` is passed directly to
     * method {@link TestSort_MenuEx.Prototype.SetEventHandler}. See the description for details.
     *
     * @param {Object} [Options.TooltipDefaultOptions = ""] - The value passed to the second parameter
     * of {@link TestSort_MenuEx.TooltipHandler} when creating the tooltip handler function object. If
     * `Options.HandlerTooltip` is set with a function, then `Options.TooltipDefaultOptions` is
     * ignored.
     *
     * @param {*} [Options.HandlerItemAvailability = ""] - See
     * {@link TestSort_MenuEx.Prototype.SetItemAvailabilityHandler~Callback}.
     */
    __New(MenuObj?, Options?) {
        this.Menu := MenuObj ?? Menu()
        options := TestSort_MenuEx.Options(Options ?? unset)
        this.SetSelectionHandler(options.HandlerSelection || unset)
        this.SetTooltipHandler(options.HandlerTooltip || unset, options.TooltipDefaultOptions || unset)
        this.SetEventHandler(options.WhichMethod)
        this.SetItemAvailabilityHandler(options.HandlerItemAvailability)
        this.ShowTooltips := options.ShowTooltips
        this.__Item := TestSort_MenuExItemCollection()
        this.__Item.CaseSense := options.CaseSense
        this.__Item.Default := ''
        this.Constructor := Class()
        this.Constructor.Base := TestSort_MenuExItem
        this.Constructor.Prototype := {
            TestSort_MenuEx: this
          , __Class: TestSort_MenuExItem.Prototype.__Class
        }
        ObjSetBase(this.Constructor.Prototype, TestSort_MenuExItem.Prototype)
        ObjRelease(ObjPtr(this))
        if HasMethod(this, 'Initialize') {
            this.Initialize(options)
        }
    }
    /**
     * @param {String} Name - The name of the menu item. This is used across the {@link TestSort_MenuEx} class
     * and related classes. It is the name that is used to get a reference to the {@link TestSort_MenuExItem}
     * instance associated with the menu item, e.g. `TestSort_MenuExObj.Get("ItemName")`. It is also the text
     * that is displayed in the menu for that item. It is also the value assigned to the "__Name"
     * property of the {@link TestSort_MenuExItem} instance.
     *
     * @param {*} CallbackOrSubmenu - One of the following:
     * - A `Menu` object, if the menu item is a submenu.
     * - A `Func` or callable object that will be called when the user selects the item.
     * - A string representing the name of a class instance method defined by your custom class which
     *   inherits from `TestSort_MenuEx` (see the "test\demo-TreeView-context-menu.ahk" for an example).
     *
     * The value of `CallbackOrSubmenu` is assigned to the "__Value" property of the {@link TestSort_MenuExItem}
     * instance.
     *
     * @param {String} [Options] - The options as described in
     * {@link https://www.autohotkey.com/docs/v2/lib/Menu.htm#Add}.
     *
     * @param {*} [HandlerTooltip] - The tooltip handler options as described in
     * {@link TestSort_MenuExItem.Prototype.SetTooltipHandler}.
     *
     * @returns {TestSort_MenuExItem}
     */
    Add(Name, CallbackOrSubmenu, Options?, HandlerTooltip?) {
        this.Menu.Add(Name, this.__HandlerSelection, Options ?? unset)
        this.__Item.Set(Name, this.Constructor.Call(Name, CallbackOrSubmenu, Options ?? unset, HandlerTooltip ?? unset))
        return this.__Item.Get(Name)
    }
    /**
     * "AddList" should be used only if the menu which originally was associated with the items no
     * longer exists. To copy items from one menu to another, use "AddObjectList" instead.
     * @param {TestSort_MenuExItem[]} Items - An array of {@link TestSort_MenuExItem} objects. For each item in the
     * array, the base of the item is changed to {@link TestSort_MenuEx#Constructor.Prototype} and the item
     * is added to the menu.
     */
    AddList(Items) {
        container := this.__Item
        proto := this.Constructor.Prototype
        m := this.Menu
        for item in items {
            ObjSetBase(item, proto)
            container.Set(item.__Name, item)
            m.Add(item.__Name, item.__Value, item.__Options || unset)
        }
    }
    /**
     * @param {Object} Obj - An object with parameters as property : value pairs.
     * - Name: The name of the menu item. This is the value passed to the first parameter "Name" of
     *   {@link TestSort_MenuEx.Prototype.Add} and is the value that is set to property "__Name"
     *   of the {@link TestSort_MenuExItem} instance.
     * - Value: The value of the menu item; this is the value passed to the second parameter
     *   "CallbackOrSubmenu" of {@link TestSort_MenuEx.Prototype.Add} and is the value that is set to property
     *   "__Value" of the {@link TestSort_MenuExItem} instance.
     * - Options: The options for the menu item. This is the value passed to the third parameter
     *   "Options" of {@link TestSort_MenuEx.Prototype.Add} and is the value that is set to property
     *   "__Options" of the {@link TestSort_MenuExItem} instance.
     * - Tooltip: The tooltip options for the menu item. This is the value passed to the fourth parameter
     *   "HandlerTooltip" of {@link TestSort_MenuEx.Prototype.Add} and is the value that is set to property
     *   "__HandlerTooltip" of the {@link TestSort_MenuExItem} instance.
     * @returns {TestSort_MenuExItem}
     */
    AddObject(Obj) {
        return this.Add(
            Obj.Name
          , Obj.Value
          , HasProp(Obj, 'Options') ? (Obj.Options || unset) : unset
          , HasProp(Obj, 'Tooltip') ? (Obj.Tooltip || unset) : unset
        )
    }
    /**
     * @param {Object[]|TestSort_MenuExItem[]} Objs - An array of objects as described by {@link TestSort_MenuEx.Prototype.AddObject},
     * or an array of {@link TestSort_MenuExItem} instance objects.
     */
    AddObjectList(Objs) {
        for obj in Objs {
            this.Menu.Add(obj.Name, this.__HandlerSelection, HasProp(Obj, 'Options') ? (Obj.Options || '') : unset)
            this.__Item.Set(obj.Name, this.Constructor.Call(
                obj.Name
              , obj.Value
              , HasProp(Obj, 'Options') ? (Obj.Options || unset) : unset
              , HasProp(Obj, 'Tooltip') ? (Obj.Tooltip || unset) : unset
            ))
        }
    }
    Delete(Name) {
        this.Menu.Delete(Name)
        this.__Item.Delete(Name)
    }
    Get(Name) => this.__Item.Get(Name)
    Has(Name) => this.__Item.Has(Name)
    Initialize(*) {
        if HasProp(this, 'DefaultItems') {
            this.AddObjectList(this.DefaultItems)
        }
    }
    /**
     * @param {String|Integer} InsertBefore - The name or position of the menu item before which to
     * insert the new menu item.
     *
     * @param {String} Name - The name of the menu item. This is used across the {@link TestSort_MenuEx} class
     * and related classes. It is the name that is used to get a reference to the {@link TestSort_MenuExItem}
     * instance associated with the menu item, e.g. `TestSort_MenuExObj.Get("ItemName")`. It is also the text
     * that is displayed in the menu for that item. It is also the value assigned to the "__Name"
     * property of the {@link TestSort_MenuExItem} instance.
     *
     * @param {*} CallbackOrSubmenu - One of the following:
     * - A `Menu` object, if the menu item is a submenu.
     * - A `Func` or callable object that will be called when the user selects the item.
     * - A string representing the name of a class instance method defined by your custom class which
     *   inherits from `TestSort_MenuEx` (see the "test\demo-TreeView-context-menu.ahk" for an example).
     *
     * The value of `CallbackOrSubmenu` is assigned to the "__Value" property of the {@link TestSort_MenuExItem}
     * instance.
     *
     * @param {String} [Options] - The options as described in
     * {@link https://www.autohotkey.com/docs/v2/lib/Menu.htm#Add}.
     *
     * @param {*} [HandlerTooltip] - The tooltip handler options as described in
     * {@link TestSort_MenuExItem.Prototype.SetTooltipHandler}.
     *
     * @returns {TestSort_MenuExItem}
     */
    Insert(InsertBefore, Name, CallbackOrSubmenu, Options?, HandlerTooltip?) {
        this.Menu.Insert(InsertBefore, Name, CallbackOrSubmenu, Options ?? unset)
        this.__Item.Set(Name, this.Constructor.Call(Name, CallbackOrSubmenu, Options ?? unset, HandlerTooltip ?? unset))
        return this.__Item.Get(Name)
    }
    /**
     * "OnSelect" is the default selection handler that is called when the user selects a menu item.
     * Your code will not call "OnSelect" directly.
     * @param {String} Name - The name of the menu item that was selected.
     * @param {Integer} ItemPos - The item position of the menu item that was selected.
     * @param {Menu} MenuObj - The menu object associated wit hthe menu item that was selected.
     */
    OnSelect(Name, ItemPos, MenuObj) {
        if item := this.__Item.Get(Name) {
            params := { Menu: MenuObj, Name: Name, Pos: ItemPos, Token: this.Token }
            if IsObject(item.__Value) {
                result := item.__Value.Call(this, params)
            } else {
                result := this.%item.__Value%(params)
            }
            if this.ShowTooltips {
                if IsObject(item.__HandlerTooltip) {
                    str := item.__HandlerTooltip.Call(this, result)
                    if !IsObject(str) && StrLen(str) {
                        this.__HandlerTooltip.Call(str)
                    }
                } else if item.__HandlerTooltip {
                    this.__HandlerTooltip.Call(item.__HandlerTooltip)
                } else if !IsObject(result) && StrLen(result) {
                    this.__HandlerTooltip.Call(result)
                }
            }
        } else {
            throw UnsetItemError('Item not found.', -1, Name)
        }
    }
    /**
     * See {@link https://www.autohotkey.com/docs/v2/lib/Menu.htm#SetColor}.
     */
    SetColor(ColorValue, ApplyToSubmenus := true) {
        this.Menu.SetColor(ColorValue, ApplyToSubmenus)
    }
    /**
     * @param {Integer} [Which = 0] - One of the following:
     * - 0: Use `0` when the menu is a `MenuBar` or a submenu. Generally, if the menu is not intended
     *   to be activated as a context menu, then `0` is appropriate.
     * - 1: Use `1` when the menu is activated as a context menu and the event handler is set to a
     *   control (not the gui).
     * - 2: Use `2` when the menu is activated as a context menu and the event handler is set to a
     *   gui window (not a control).
     */
    SetEventHandler(Which := 0) {
        if Which {
            this.DefineProp('Call', this.__GetOwner('__Call' Which))
        } else if this.HasOwnProp('Call') {
            this.DeleteProp('Call')
        }
    }
    /**
     * @param {*} [Callback] - A `Func` or callable object that is called prior to showing the menu,
     * intended to enable or disable menu items depending on the item that was underneath the cursor
     * when the use right-clicked, or the item that was selected when the user activated the
     * context menu. The item availability handler is only called if
     * {@link TestSort_MenuEx.Prototype.SetEventHandler} was called with a value of `1` or `2`. If `Callback`
     * is unset, the value of property "__ItemAvailabilityHandle" is set with an empty string, which
     * causes the process to not call an item availability handler.
     */
    SetItemAvailabilityHandler(Callback?) {
        this.__HandlerItemAvailability := Callback ?? ''
    }
    /**
     * @param {*} [Callback] - A `Func` or callable object that is called when the user selects a
     * menu item. The `Callback` is unset, the selection handler is defined as the "OnSelect" method,
     * which should be suitable for most use cases.
     */
    SetSelectionHandler(Callback?) {
        if this.HasOwnProp('__HandlerSelection')
        && this.__HandlerSelection.HasOwnProp('Name')
        && this.__HandlerSelection.Name == this.OnSelect.Name ' (bound)' {
            if IsSet(Callback) {
                ObjPtrAddRef(this)
                this.__HandlerSelection := Callback
            } else {
                OutputDebug('The current selection handler is already set to ``' this.__HandlerSelection.Name '``.`n')
            }
        } else if IsSet(Callback) {
            this.__HandlerSelection := Callback
        } else {
            ; This creates a reference cycle.
            this.__HandlerSelection := ObjBindMethod(this, 'OnSelect')
            ; This is to identify that the object is the bound method (and thus requires handling
            ; the reference cycle).
            this.__HandlerSelection.DefineProp('Name', { Value: this.OnSelect.Name ' (bound)' })
        }
    }
    /**
     * @param {*} [Callback] - A `Func` or callable object that is called after the function associated
     * with a menu item returns. `Callback` is expected to display a tooltip informing the user of
     * the result of the action associated with the menu item the user selected. For details about
     * this process, see {@link TestSort_MenuExItem.Prototype.SetTooltipHandler}. If `Callback` is unset,
     * the property "__HandlerTooltip" is set with an instance of
     * {@link TestSort_MenuEx.TooltipHandler} which should be suitable for most use cases.
     * @param {Object} [DefaultOptions] - An object with property : value pairs representing the
     * options to pass to the {@link TestSort_MenuEx.TooltipHandler} constructor.
     */
    SetTooltipHandler(Callback?, DefaultOptions?) {
        this.__HandlerTooltip := Callback ?? TestSort_MenuEx.TooltipHandler(DefaultOptions ?? unset)
    }
    /**
     * See {@link https://www.autohotkey.com/docs/v2/lib/Menu.htm#Show}.
     */
    Show(X?, Y?) {
        this.Menu.Show(X ?? unset, Y ?? unset)
    }
    __Call1(Ctrl, Item, IsRightClick, X, Y) {
        this.Token := {
            Ctrl: Ctrl, Gui: Ctrl.Gui
          , IsRightClick: IsRightClick
          , Item: Item, X: X, Y: Y
        }
        ObjSetBase(this.Token, TestSort_MenuExActivationToken.Prototype)
        if HasMethod(this, 'HandlerItemAvailability') {
            this.HandlerItemAvailability()
        } else if IsObject(this.__HandlerItemAvailability) {
            this.__HandlerItemAvailability.Call(this)
        }
        this.Menu.Show(X, Y)
    }
    __Call2(GuiObj, Ctrl, Item, IsRightClick, X, Y) {
        this.Token := {
            Ctrl: Ctrl, Gui: GuiObj
          , IsRightClick: IsRightClick
          , Item: Item, X: X, Y: Y
        }
        ObjSetBase(this.Token, TestSort_MenuExActivationToken.Prototype)
        if HasMethod(this, 'HandlerItemAvailability') {
            this.HandlerItemAvailability()
        } else if IsObject(this.__HandlerItemAvailability) {
            this.__HandlerItemAvailability.Call(this)
        }
        CoordMode('Menu', 'Screen')
        this.Menu.Show(X, Y)
    }
    __Delete() {
        if this.HasOwnProp('Constructor')
        && this.Constructor.HasOwnProp('Prototype')
        && this.Constructor.Prototype.HasOwnProp('TestSort_MenuEx') {
            ObjPtrAddRef(this)
            this.DeleteProp('Constructor')
        }
        if this.HasOwnProp('__HandlerSelection')
        && this.__HandlerSelection.HasOwnProp('Name')
        && this.__HandlerSelection.Name == this.OnSelect.Name ' (bound)' {
            ObjPtrAddRef(this)
            this.DeleteProp('__HandlerSelection')
        }
    }
    __Enum(VarCount) => this.__Item.__Enum(VarCount)
    __GetOwner(Prop, ReturnDesc := true) {
        b := this
        while b {
            if b.HasOwnProp(Prop) {
                break
            }
            b := b.Base
        }
        if !b {
            throw PropertyError('Property not found.', -1, Prop)
        }
        return ReturnDesc ? b.GetOwnPropDesc(Prop) : b
    }
    Capacity {
        Get => this.__Item.Capacity
        Set => this.__Item.Capacity := Value
    }
    CaseSense => this.__Item.CaseSense
    Count => this.__Item.Count
    IsMenuBar => this.Menu is MenuBar
    HandlerItemAvailability {
        Get => this.__HandlerItemAvailability
        Set => this.SetItemAvailabilityHandler(Value)
    }
    Handle => this.Menu.Handle
    HandlerSelection {
        Get => this.__HandlerSelection
        Set => this.SetSelectionHandler(Value)
    }
    HandlerTooltip {
        Get => this.__HandlerTooltip
        Set => this.SetTooltipHandler(Value)
    }

    class Options {
        static Default := {
            CaseSense: false
          , HandlerItemAvailability: ''
          , HandlerSelection: ''
          , HandlerTooltip: ''
          , ShowTooltips: false
          , TooltipDefaultOptions: ''
          , WhichMethod: 1
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

    class TooltipHandler {
        /**
         * By default, `TestSort_MenuEx.TooltipHandler.Numbers` is an array with integers 1-20, and is used to track which
         * tooltip id numbers are available and which are in use. If tooltips are created from multiple
         * sources, then the list is invalid because it may not know about every existing tooltip. To
         * overcome this, `TestSort_MenuEx.TooltipHandler.Numbers` can be set with an array that is shared by other objects,
         * sharing the pool of available id numbers.
         *
         * All instances of `TestSort_MenuEx.TooltipHandler` will inherently draw from the same array, and so calling
         * `TestSort_MenuEx.TooltipHandler.SetNumbersList` is unnecessary if the objects handling tooltip creation are all
         * `TestSort_MenuEx.TooltipHandler` objects.
         */
        static SetNumbersList(List) {
            this.Numbers := List
        }
        static DefaultOptions := {
            Duration: 3000
          , X: 0
          , Y: 0
          , Mode: 'Mouse' ; Mouse / Absolute (M/A)
        }
        static Numbers := [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]

        /**
         * @param {Object} [DefaultOptions] - An object with zero or more options as property : value pairs.
         * These options are used when a corresponding option is not passed to {@link TestSort_MenuEx.TooltipHandler.Prototype.Call}.
         * @param {Integer} [DefaultOptions.Duration = 2000] - The duration in milliseconds for which the
         * tooltip displayed. A value of 0 causes the tooltip to b e dislpayed indefinitely until
         * {@link TestSort_MenuEx.TooltipHandler.Prototype.End} is called with the tooltip number. Negative and positive
         * values are treated the same.
         * @param {Integer} [DefaultOptions.X = 0] - If `DefaultOptions.Mode == "Mouse"` (or "M"), a number
         * of pixels to add to the X-coordinate. If `DefaultOptions.Mode == "Absolute"` (or "A"), the
         * X-coordinate relative to the screen.
         * @param {Integer} [DefaultOptions.Y = 0] - If `DefaultOptions.Mode == "Mouse"` (or "M"), a number
         * of pixels to add to the Y-coordinate. If `DefaultOptions.Mode == "Absolute"` (or "A"), the
         * Y-coordinate relative to the screen.
         * @param {String} [DefaultOptions.Mode = "Mouse"] - One of the following:
         * - "Mouse" or "M" - The tooltip is displayed near the mouse cursor.
         * - "Absolute" or "A" - The tooltip is displayed at the screen coordinates indicated by the
         * options.
         */
        __New(DefaultOptions?) {
            if IsSet(DefaultOptions) {
                o := this.DefaultOptions := {}
                d := TestSort_MenuEx.TooltipHandler.DefaultOptions
                for p in d.OwnProps()  {
                    o.%p% := HasProp(DefaultOptions, p) ? DefaultOptions.%p% : d.%p%
                }
            } else {
                this.DefaultOptions := TestSort_MenuEx.TooltipHandler.DefaultOptions.Clone()
            }
        }
        /**
         * @param {String} Str - The string to display.
         *
         * @param {Object} [Options] - An object with zero or more options as property : value pairs.
         * If a value is absent, the corresponding value from `TooltipHandlerObj.DefaultOptions` is used.
         * @param {Integer} [Options.Duration] - The duration in milliseconds for which the
         * tooltip displayed. A value of 0 causes the tooltip to b e dislpayed indefinitely until
         * {@link TestSort_MenuEx.TooltipHandler.Prototype.End} is called with the tooltip number. Negative and positive
         * values are treated the same.
         * @param {Integer} [Options.X] - If `Options.Mode == "Mouse"` (or "M"), a number
         * of pixels to add to the X-coordinate. If `Options.Mode == "Absolute"` (or "A"), the
         * X-coordinate relative to the screen.
         * @param {Integer} [Options.Y] - If `Options.Mode == "Mouse"` (or "M"), a number
         * of piYels to add to the Y-coordinate. If `Options.Mode == "Absolute"` (or "A"), the
         * Y-coordinate relative to the screen.
         * @param {String} [Options.Mode] - One of the following:
         * - "Mouse" or "M" - The tooltip is displayed near the mouse cursor.
         * - "Absolute" or "A" - The tooltip is displayed at the screen coordinates indicated by the
         * options.
         *
         * @returns {Integer} - The tooltip number used for the tooltip. If the duration is 0, pass
         * the number to {@link TestSort_MenuEx.TooltipHandler.Prototype.End} to end the tooltip. Otherwise, you do not need
         * to save the tooltip number, but the tooltip number can be used to target the tooltip when calling
         * `ToolTip`.
         */
        Call(Str, Options?) {
            if TestSort_MenuEx.TooltipHandler.Numbers.Length {
                n := TestSort_MenuEx.TooltipHandler.Numbers.Pop()
            } else {
                throw Error('The maximum number of concurrent tooltips has been reached.', -1)
            }
            if IsSet(Options) {
                Get := _Get1
            } else {
                Get := _Get2
            }
            T := CoordMode('Tooltip', 'Screen')
            switch SubStr(Get('Mode'), 1, 1), 0 {
                case 'M':
                    M := CoordMode('Mouse', 'Screen')
                    MouseGetPos(&X, &Y)
                    ToolTip(Str, X + Get('X'), Y + Get('Y'), n)
                    SetTimer(ObjBindMethod(this, 'End', n), -Abs(Get('Duration')))
                    CoordMode('Mouse', M)
                case 'A':
                    ToolTip(Str, Get('X'), Get('Y'), n)
                    SetTimer(ObjBindMethod(this, 'End', n), -Abs(Get('Duration')))
            }
            CoordMode('Tooltip', T)

            return n

            _Get1(prop) {
                return HasProp(Options, prop) ? Options.%prop% : this.DefaultOptions.%prop%
            }
            _Get2(prop) {
                return this.DefaultOptions.%prop%
            }
        }
        End(n) {
            ToolTip(,,,n)
            TestSort_MenuEx.TooltipHandler.Numbers.Push(n)
        }
        /**
         * @param {Object} [DefaultOptions] - An object with zero or more options as property : value pairs.
         * These options are used when a corresponding option is not passed to {@link TestSort_MenuEx.TooltipHandler.Prototype.Call}.
         * The existing default options are overwritten with the new object.
         */
        SetDefaultOptions(DefaultOptions) {
            this.DefaultOptions := DefaultOptions
        }
    }
}

class TestSort_MenuExItem {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.__Name := proto.__Value := proto.__Options := proto.__HandlerTooltip := ''
    }
    /**
     * @see {@link https://www.autohotkey.com/docs/v2/lib/Menu.htm#Add}.
     *
     * @param {String} Name - The text to display on the menu item. Although the AutoHotkey
     * documents indicate that, for `Menu.Prototype.Add`, the paramter `MenuItemName` can also be
     * the position of an existing item, that is not applicable here; only pass the name to this
     * parameter.
     * @param {*} CallbackOrSubmenu - The function to call as a new thread when the menu item is
     * selected, or a reference to a Menu object to use as a submenu.
     *
     * Regarding functions:
     *
     * The function can be any callable object. When using this library (`TestSort_MenuEx` and related classes),
     * the functions are not called directly when the user selects a menu item; a handler function is
     * called which then access the `TestSort_MenuExItem` object associated with the menu item that was selected.
     * The function is then called from the property "__Value".
     *
     * If `CallbackOrSubmenu` is a function, then the function should accept two parameters:
     * 1. The {@link TestSort_MenuEx} instance.
     * 2. An object with properties:
     *   - Menu: The menu object.
     *   - Name: The menu item name that was selected.
     *   - Pos: The position of the menu item that was selected.
     *   - Token: The {@link TestSort_MenuExActivationToken} instance that was created when the menu was
     *     activated. "Token" only has a significant value when {@link TestSort_MenuEx.Prototype.SetEventHandler}
     *     was called with a value of `1` or `2`. That is, if the menu is not activated as a context
     *     menu, then "Token" is always an empty string. If the menu is activated as a context menu,
     *     then "Token" is a {@link TestSort_MenuExActivationToken} instance.
     *
     * The function can also be the name of a class method. For details about this, see the section
     * "Extending TestSort_MenuEx" in the description above {@link TestSort_MenuEx}.
     *
     * The function's return value may be used if {@link TestSort_MenuEx#ShowTooltips} is nonzero. For details
     * about how the return value is used, see {@link TestSort_MenuExItem.Prototype.SetTooltipHandler}.
     *
     * @param {String} [MenuItemOptions = ""] - Any options as described in
     * {@link https://www.autohotkey.com/docs/v2/lib/Menu.htm#Add}.
     *
     * @param {*} [HandlerTooltip] - See {@link TestSort_MenuExItem.Prototype.SetTooltipHandler} for details about
     * this parameter.
     */
    __New(Name, CallbackOrSubmenu, MenuItemOptions := '', HandlerTooltip?) {
        this.__Name := Name
        this.__Value := CallbackOrSubmenu
        this.__Options := MenuItemOptions
        if IsSet(HandlerTooltip) {
            this.__HandlerTooltip := HandlerTooltip
        }
    }
    /**
     * Adds a checkbox next to the menu item.
     */
    Check() {
        this.TestSort_MenuEx.Menu.Check(this.__Name)
    }
    /**
     * Deletes the menu item.
     */
    Delete() {
        this.TestSort_MenuEx.Menu.Delete(this.__Name)
        this.TestSort_MenuEx.__Item.Delete(this.__Name)
    }
    /**
     * Disables the menu item, causing the text to appear more grey than the surrounding text and
     * making it so the user cannot interact with the menu item.
     */
    Disable() {
        this.TestSort_MenuEx.Menu.Disable(this.__Name)
    }
    /**
     * Enables the menu item, undoing the effect of {@link TestSort_MenuExItem.Prototype.Disable} if it was
     * previously called.
     */
    Enable() {
        this.TestSort_MenuEx.Menu.Enable(this.__Name)
    }
    /**
     * See {@link https://www.autohotkey.com/docs/v2/lib/Menu.htm#SetIcon} for details.
     */
    SetIcon(FileName, IconNumber := 1, IconWidth?) {
        this.TestSort_MenuEx.Menu.SetIcon(this.__Name, FileName, IconNumber, IconWidth ?? unset)
    }
    /**
     * When {@link TestSort_MenuEx#ShowTooltips} is true, there are three approaches for controlling the tooltip
     * text that is displayed when the user selects a menu item. When the user selects a menu item,
     * the return value returned by the function associated with the menu item is stored in a variable,
     * and the property {@link TestSort_MenuExItem#HandlerTooltip} is evaluated to determine if a tooltip will be displayed,
     * and if so, what the text will be.
     *
     * Note that, by default, the value of {@link TestSort_MenuExItem#HandlerTooltip} is an empty string.
     *
     * If {@link TestSort_MenuExItem#HandlerTooltip} is an object, it is assumed to be a function or callable object.
     * The function is called with parameters:
     * 1. The {@link TestSort_MenuEx} instance.
     * 2. The return value from the menu item's function.
     *
     * The function should return the string that will be displayed by the tooltip. If the function
     * returns an object or an empty string, no tooltip is displayed.
     *
     * If {@link TestSort_MenuExItem#HandlerTooltip} is a significant string value, the return value from the menu
     * item's function is ignored and {@link TestSort_MenuExItem#HandlerTooltip} is displayed in the tooltip.
     *
     * If {@link TestSort_MenuExItem#HandlerTooltip} is zero or an empty string, and if the return value from the menu
     * item's function is a number or non-empty string, the return value is displayed in the tooltip.
     * Note that if the return value is a numeric zero or a string containing only a zero, that is
     * displayed in the tooltip; only an empty string will cause a tooltip to not be displayed.
     *
     * @param {*} Value - A value to one of the effects described by the description.
     */
    SetTooltipHandler(Value) {
        /**
         * See {@link TestSort_MenuExItem.Prototype.SetTooltipHandler} for details.
         * @memberof TestSort_MenuExItem
         * @instance
         */
        this.__HandlerTooltip := Value
    }
    /**
     * Toggles the display of a checkmark next to the menu item.
     */
    ToggleCheck() {
        this.TestSort_MenuEx.Menu.ToggleCheck(this.__Name)
    }
    /**
     * Toggles the availability of the menu item.
     */
    ToggleEnable() {
        this.TestSort_MenuEx.Menu.ToggleEnable(this.__Name)
    }
    /**
     * Removes a checkmark next to the menu item if one is present.
     */
    Uncheck() {
        this.TestSort_MenuEx.Menu.Uncheck(this.__Name)
    }
    HandlerTooltip {
        Get => this.__HandlerTooltip
        Set {
            this.__HandlerTooltip := Value
        }
    }
    Name {
        Get => this.__Name
        Set {
            this.TestSort_MenuEx.Menu.Rename(this.__Name, Value)
            this.TestSort_MenuEx.__Item.Delete(this.__Name)
            this.__Name := Value
            this.TestSort_MenuEx.__Item.Set(Value, this)
        }
    }
    Options {
        Get => this.__Options
        Set {
            this.TestSort_MenuEx.Menu.Add(this.__Name, , Value)
            this.__Options := Value
        }
    }
    Value {
        Get => this.__Value
        Set {
            this.__Value := Value
        }
    }
}


class TestSort_MenuExActivationToken {
    __New(GuiObj, Ctrl, Item, IsRightClick, X, Y) {
        this.Gui := GuiObj
        this.Ctrl := Ctrl
        this.Item := Item
        this.IsRightClick := IsRightClick
        this.X := X
        this.Y := Y
    }
}

class TestSort_MenuExItemCollection extends Map {
}

/**
 * @description - Generates a histogram from an array of numbers.
 * @param {Array} Data - An array of values. If not numbers, the function `ValueCallback` should
 * return a number.
 * @param {Integer} [Bins=20] - The number of bins to divide the data into.
 * @param {Integer} [MaxSymbols=20] - The maximum number of symbols to use in the histogram.
 * @param {String} [Symbol='*'] - The symbol to use in the histogram.
 * @param {String} [Newline='`r`n'] - The newline character to use.
 * @param {Integer} [Digits=3] - The number of digits to round the bin values to.
 * @param {Func} [ValueCallback] - A function to calculate the values' numeric value. The function
 * can accept up to three parameters in this order:
 * - The value
 * - The index
 * - The array object
 * @returns {String} - The histogram.
 *  @example
 *      ; Assume an array of numbers, `Data`, has been defined.
 *      OutputDebug(Histogram(Data))
 *  ;      0.000 - 49.927  : 43  **************
 *  ;     49.927 - 99.853  : 46  ***************
 *  ;     99.853 - 149.780 : 49  ****************
 *  ;    149.780 - 199.707 : 43  **************
 *  ;    199.707 - 249.633 : 54  ******************
 *  ;    249.633 - 299.560 : 48  ****************
 *  ;    299.560 - 349.486 : 55  ******************
 *  ;    349.486 - 399.413 : 53  *****************
 *  ;    399.413 - 449.340 : 57  *******************
 *  ;    449.340 - 499.266 : 43  **************
 *  ;    499.266 - 549.193 : 58  *******************
 *  ;    549.193 - 599.120 : 44  **************
 *  ;    599.120 - 649.046 : 61  ********************
 *  ;    649.046 - 698.973 : 47  ***************
 *  ;    698.973 - 748.900 : 49  ****************
 *  ;    748.900 - 798.826 : 57  *******************
 *  ;    798.826 - 848.753 : 51  *****************
 *  ;    848.753 - 898.679 : 46  ***************
 *  ;    898.679 - 948.606 : 52  *****************
 *  ;    948.606 - 998.533 : 44  **************
 *  @
 */
TestSort_Histogram(Data, Bins := 20, MaxSymbols := 20, Symbol := '*', Newline := '`r`n', Digits := 3, ValueCallback?) {
    local BinSize, Lowest, Counts, Index, LargestCount, LargestLen, FormatStr, Start, End, Str
    if IsSet(ValueCallback) {
        Temp := Data
        Data := []
        Data.Capacity := Temp.Length
        for Item in Temp {
            Data.Push(ValueCallback(Item, A_Index, Temp))
        }
    }
    BinSize := ((Highest := Max(Data*)) - (Lowest := Min(Data*)) + 1) / Bins
    Counts := []
    Counts.Length := Bins
    Loop Bins
        Counts[A_Index] := 0
    Loop Data.Length {
        i := A_Index
        Loop Bins {
            if _FindBin(Data[i], A_Index) {
                j := A_Index
                break
            }
        }
        Counts[j]++
    }
    LargestCount := Max(Counts*)
    LargestLen := StrLen(LargestCount)
    Padding := StrLen(Round(BinSize*Bins, Digits))
    FormatStr := '{1:' Padding '} - {2:-' Padding '} : {3:-' LargestLen '}  {4}' Newline
    Start := End := Lowest
    Loop Bins
        _AddSegment(A_Index)
    return str

    _AddSegment(Index) {
        End += BinSize
        Symbols := ''
        Loop Round(Counts[Index] / LargestCount * MaxSymbols, 0)
            Symbols .= Symbol
        Str .= Format(FormatStr, Round(Start, Digits), Round(End, Digits), Counts[Index], Symbols)
        Start := End
    }
    _FindBin(Value, Index) {
        return Value > BinSize * (Index - 1) + Lowest && Value <= BinSize * Index + Lowest
    }
}

class TestSort_MenuBar extends TestSort_MenuEx {
    static __New() {
        this.DeleteProp('__New')
        this.Prototype.DefaultItems := [
            { Name: 'File', Value: 'SelectFile' }
        ]
    }
    Initialize(*) {
        super.Initialize.Call(this)
        this.File := TestSort_MenuBar.File()

    }
    SelectFile(*) {
        this.File.Show()
    }

    class File extends TestSort_MenuEx {
        static __New() {
            this.DeleteProp('__New')
            this.Prototype.DefaultItems := [
                { Name: 'Load config', Value: 'SelectLoadConfig' }
              , { Name: 'Save config', Value: 'SelectSaveConfig' }
              , { Name: 'Save config as', Value: 'SelectSaveConfigAs' }
              , { Name: 'Export history', Value: 'SelectExportHistory' }
              , { Name: 'Save and exit', Value: 'SelectSaveAndExit' }
              , { Name: 'Exit', Value: 'SelectExit' }
            ]
        }
        SelectExit(*) {
            ExitApp()
        }
        SelectSaveAndExit(Params) {
            test.SaveConfig()
            ExitApp()
        }
        SelectSaveConfig(Params) {
            test.SaveConfig()
        }
        SelectSaveConfigAs(Params) {
            test.SaveConfig(true)
        }
        SelectLoadConfig(Params) {
            test.LoadConfig()
        }
        SelectExportHistory(Params) {
            test.ExportHistory()
        }
    }
}


class TestSort_Compare_Quicksort extends TestSort_Compare_Base {
}
class TestSort_Compare_Heapsort_kary extends TestSort_Compare_Base {
}
class TestSort_Compare_Heapsort_Original extends TestSort_Compare_Base {
}
class TestSort_Compare_Heapsort extends TestSort_Compare_Base {
}

class TestSort_Compare_Base {
    static __New() {
        this.comparisons := 0
    }
    static Call(a, b) {
        this.comparisons++
        return a - b
    }
}

/***************************************************************************************
 *
 *      ClassFactory
 *
 ***************************************************************************************/

/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @description - Constructs a new class based off an existing class and prototype.
 * @param {*} Prototype - The object to use as the new class's prototype.
 * @param {String} [Name] - The name of the new class. This gets assigned to `Prototype.__Class`.
 * @param {Function} [Constructor] - An optional constructor function that is assigned to
 * `NewClassObj.Prototype.__New`. When set, this function is called for each new instance. When
 * unset, the constructor function associated with `Prototype.__Class` is called.
 */
TestSort_ClassFactory(Prototype, Name?, Constructor?) {
    Cls := Class()
    Cls.Base := GetObjectFromString(Prototype.__Class)
    Cls.Prototype := Prototype
    if IsSet(Name) {
        Prototype.__Class := Name
    }
    if IsSet(Constructor) {
        Cls.Prototype.DefineProp('__New', { Call: Constructor })
    }
    return Cls

    GetObjectFromString(Path) {
        Split := StrSplit(Path, '.')
        if !IsSet(%Split[1]%)
            return
        OutObj := %Split[1]%
        i := 1
        while ++i <= Split.Length {
            if !OutObj.HasOwnProp(Split[i])
                return
            OutObj := OutObj.%Split[i]%
        }
        return OutObj
    }

}

/***************************************************************************************
 *
 *      GetBaseObjects
 *
 ***************************************************************************************/

/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/
    Author: Nich-Cebolla
    License: MIT
*/
; Dependency:
; #Include Inheritance_Shared.ahk

/**
 * @description - Traverses an object's inheritance chain and returns the base objects.
 * @param {Object} Obj - The object from which to get the base objects.
 * @param {Integer|String} [StopAt=GBO_STOP_AT_DEFAULT ?? '-Any'] - If an integer, the number of
 * base objects to traverse up the inheritance chain. If a string, the case-insensitive name of the
 * class to stop at. If falsy, the function will traverse the entire inheritance chain up to
 * but not including `Any`.
 *
 * If you define global variable `GBO_STOP_AT_DEFAULT` with a value somewhere in your code, that
 * value will be used as the default for the function call. Otherwise, '-Any' is used.
 *
 * There are two ways to modify the function's interpretation of this value:
 *
 * - Stop before or after the class: The default is to stop after the class, such that the base object
 * associated with the class is included in the result array. To change this, include a hyphen "-"
 * anywhere in the value and `GetBaseObjects` will not include the last iterated object in the
 * result array.
 *
 * - The type of object which will be stopped at: This only applies to `StopAt` values which are
 * strings. In the code snippets below, `b` is the object being evaluated.
 *
 *   - Stop at a prototype object (default): `GetBaseObjects` will stop at the first prototype object
 * with a `__Class` property equal to `StopAt`. This is the literal condition used:
 * `Type(b) == 'Prototype' && (b.__Class = 'Any' || b.__Class = StopAt)`.
 *
 *   - Stop at a class object: To direct `GetBaseObjects` to stop at a class object tby he name
 * `StopAt`, include ":C" at the end of `StopAt`, e.g. `StopAt := "MyClass:C"`. This is the literal
 * condition used:
 * `Type(b) == 'Class' && ObjHasOwnProp(b, 'Prototype') && b.Prototype.__Class = StopAt`.
 *
 *  - Stop at an instance object: To direct `GetBaseObjects` to stop at an instance object of type
 * `StopAt`, incluide ":I" at the end of `StopAt`, e.g. `StopAt := "MyClass:I"`. This is the literal
 * condition used: `Type(b) = StopAt`.
 * @returns {Array} - The array of base objects.
 */
TestSort_GetBaseObjects(Obj, StopAt := GBO_STOP_AT_DEFAULT ?? '-Any') {
    Result := []
    b := Obj
    if StopAt {
        if InStr(StopAt, '-') {
            StopAt := StrReplace(StopAt, '-', '')
            FlagStopBefore := true
        }
    } else {
        FlagStopBefore := true
        StopAt := 'Any'
    }
    if InStr(StopAt, ':C') {
        StopAt := StrReplace(StopAt, ':C', '')
        CheckStopAt := _CheckStopAtClass
    } else if InStr(StopAt, ':I') {
        StopAt := StrReplace(StopAt, ':I', '')
        CheckStopAt := _CheckStopAtInstance
    } else {
        CheckStopAt := _CheckStopAt
    }

    if IsNumber(StopAt) {
        Loop Number(StopAt) - (IsSet(FlagStopBefore) ? 2 : 1) {
            if b := b.Base {
                Result.Push(b)
            } else {
                break
            }
        }
    } else {
        if IsSet(FlagStopBefore) {
            Loop {
                if !(b := b.Base) {
                    _Throw()
                    break
                }
                if CheckStopAt() {
                    break
                }
                Result.Push(b)
            }
        } else {
            Loop {
                if !(b := b.Base) {
                    _Throw()
                    break
                }
                Result.Push(b)
                if CheckStopAt() {
                    break
                }
            }
        }
    }
    return Result

    _CheckStopAt() {
        return  Type(b) == 'Prototype' && (b.__Class = 'Any' || b.__Class = StopAt)
    }
    _CheckStopAtClass() {
        return Type(b) == 'Class' && ObjHasOwnProp(b, 'Prototype') && b.Prototype.__Class = StopAt
    }
    _CheckStopAtInstance() {
        return Type(b) = StopAt
    }
    _Throw() {
        ; If `GetBaseObjects` encounters a non-object base, that means it traversed the inheritance
        ; chain up to Any.Prototype, which returns an empty string. If `StopAt` = 'Any' and
        ; !IsSet(FlagStopBefore) (the user did not include "-" in the param string), then this is
        ; expected. In all other cases, this means that the input `StopAt` value was never
        ; encountered, and results in this error.
        if IsSet(FlagStopBefore) || StopAt != 'Any' {
            throw Error('``GetBaseObjects`` did not encounter an object that matched the ``StopAt`` value.'
            , -2, '``StopAt``: ' (IsSet(FlagStopBefore) ? '-' : '') StopAt)
        }
    }
}

/***************************************************************************************
 *
 *      GetPropDesc
 *
 ***************************************************************************************/

/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/
    Author: Nich-Cebolla
    License: MIT
*/
; Dependency:
; #Include Inheritance_Shared.ahk

/**
 * @description - Gets the property descriptor object for the specified property of the input object.
 * {@link https://www.autohotkey.com/docs/v2/lib/Object.htm#GetOwnPropDesc}
 * @param {Object} Obj - The object from which to get the property descriptor.
 * @param {String} Prop - The name of the property.
 * @param {VarRef} [OutObj] - A variable that will receive a reference to the object which owns the
 * property.
 * @param {VarRef} [OutIndex] - A variable that will receive the index position of the object which
 * owns the property in the inheritance chain.
 * @returns {Object} - If the property exists, the property descriptor object. Else, an empty string.
 */
TestSort_GetPropDesc(Obj, Prop, &OutObj?, &OutIndex?) {
    if !HasProp(Obj, Prop) {
        return ''
    }
    OutObj := Obj
    OutIndex := 0
    while OutObj && !ObjHasOwnProp(OutObj, Prop) {
        OutIndex++
        OutObj := OutObj.Base
    }
    if OutObj {
        return ObjGetOwnPropDesc(OutObj, Prop)
    } else {
        throw Error('``GetPropDesc`` failed to identify the object which owns the property.', -1)
    }
}

/***************************************************************************************
 *
 *      GetPropsInfo
 *
 ***************************************************************************************/

/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/
    Author: Nich-Cebolla
    License: MIT
*/

/**
 * @description - Constructs a `PropsInfo` object, which is a flexible solution for cases when a
 * project would benefit from being able to quickly obtain a list of all of an object's properties,
 * and/or filter those properties.
 *
 * In this documentation, an instance of `PropsInfo` is referred to as either "a `PropsInfo` object"
 * or `PropsInfoObj`. An instance of `PropsInfoItem` is referred to as either "a `PropsInfoItem` object"
 * or `InfoItem`.
 *
 * See example-Inheritance.ahk for a walkthrough on how to use the class.
 *
 * `PropsInfo` objects are designed to be a flexible solution for accessing and/or analyzing an
 * object's properties, including inherited properties. Whereas `OwnProps` only iterates an objects'
 * own properties, `PropsInfo` objects can perform these functions for both inherited and own
 * properties:
 * - Produce an array of property names.
 * - Produce a `Map` where the key is the property name and the object is a `PropsInfoItem` object
 * for each property.
 * - Produce an array of `PropsInfoItem` objects.
 * - Be passed to a function that expects an iterable object like any of the three above bullet points.
 * - Filter the properties according to one or more conditions.
 * - Get the function objects associated with the properties.
 * - Get the values associated with the properties.
 *
 * `PropsInfoItem` objects are modified descriptor objects.
 * @see {@link https://www.autohotkey.com/docs/v2/lib/Object.htm#GetOwnPropDesc}.
 * After getting the descriptor object, `GetPropsInfo` changes the descriptor object's base, converting
 * it to a `PropsInfoItem` object and exposing additional properties. See the parameter hints above
 * each property for details.
 *
 * @param {*} Obj - The object from which to get the properties.
 * @param {Integer|String} [StopAt=GPI_STOP_AT_DEFAULT ?? '-Object'] - If an integer, the number of
 * base objects to traverse up the inheritance chain. If a string, the name of the class to stop at.
 * You can define a global variable `GPI_STOP_AT_DEFAULT` to change the default value. If
 * GPI_STOP_AT_DEFAULT is unset, the default value is '-Object', which directs `GetPropsInfo` to
 * include properties owned by objects up to but not including `Object.Prototype`.
 * @see {@link GetBaseObjects} for full details about this parameter.
 * @param {String} [Exclude=''] - A comma-delimited, case-insensitive list of properties to exclude.
 * For example: "Length,Capacity,__Item".
 * @param {Boolean} [IncludeBaseProp=true] - If true, the object's `Base` property is included. If
 * false, `Base` is excluded.
 * @param {VarRef} [OutBaseObjList] - A variable that will receive a reference to the array of
 * base objects that is generated during the function call.
 * @param {Boolean} [ExcludeMethods=false] - If true, callable properties are excluded. Note that
 * properties with a value that is a class object are unaffected by `ExcludeMethods`.
 * @returns {PropsInfo}
 */
TestSort_GetPropsInfo(Obj, StopAt := GPI_STOP_AT_DEFAULT ?? '-Object', Exclude := '', IncludeBaseProp := true, &OutBaseObjList?, ExcludeMethods := false) {
    OutBaseObjList := TestSort_GetBaseObjects(Obj, StopAt)
    Container := Map()
    Container.Default := Container.CaseSense := false
    Excluded := ','
    for s in StrSplit(Exclude, ',', '`s`t') {
        if (s) {
            Container.Set(s, -1)
        }
    }

    PropsInfoItemBase := TestSort_PropsInfoItem(Obj, OutBaseObjList.Length)

    if ExcludeMethods {
        for Prop in ObjOwnProps(Obj) {
            if (HasMethod(Obj, Prop) && not Obj.%Prop% is Class) || Container.Get(Prop) {
                if !InStr(Excluded, ',' Prop ',') {
                    Excluded .= Prop ','
                }
                continue
            }
            ObjSetBase(ItemBase := {
                /**
                 * The property name.
                 * @memberof PropsInfoItem
                 * @instance
                 */
                    Name: Prop
                /**
                 * `Count` gets incremented by one for each object which owns a property by the same name.
                 * @memberof PropsInfoItem
                 * @instance
                 */
                  , Count: 1
                }
              , PropsInfoItemBase)
            ObjSetBase(Item := ObjGetOwnPropDesc(Obj, Prop), ItemBase)
            Item.Index := 0
            Container.Set(Prop, Item)
        }
        if IncludeBaseProp {
            ObjSetBase(ItemBase := { Name: 'Base', Count: 1 }, PropsInfoItemBase)
            ObjSetBase(InfoItem_Base := { Value: Obj.Base }, ItemBase)
            InfoItem_Base.Index := 0
            Container.Set('Base', InfoItem_Base)
        }
        i := 0
        for b in OutBaseObjList {
            i++
            for Prop in ObjOwnProps(b) {
                if HasMethod(b, Prop) {
                    if !InStr(Excluded, ',' Prop ',') {
                        Excluded .= Prop ','
                    }
                }
                if r := Container.Get(Prop) {
                    if r == -1 {
                        if !InStr(Excluded, ',' Prop ',') {
                            Excluded .= Prop ','
                        }
                        continue
                    }
                    ; It's an existing property
                    ObjSetBase(Item := ObjGetOwnPropDesc(b, Prop), r.Base)
                    Item.Index := i
                    r.__SetAlt(Item)
                    r.Base.Count++
                } else {
                    ; It's a new property
                    ObjSetBase(ItemBase := { Name: Prop, Count: 1 }, PropsInfoItemBase)
                    ObjSetBase(Item := ObjGetOwnPropDesc(b, Prop), ItemBase)
                    Item.Index := i
                    Container.Set(Prop, Item)
                }
            }
            if IncludeBaseProp {
                ObjSetBase(Item := { Value: b.Base }, InfoItem_Base.Base)
                Item.Index := i
                InfoItem_Base.__SetAlt(Item)
                InfoItem_Base.Base.Count++
            }
        }
    } else {
        for Prop in ObjOwnProps(Obj) {
            if Container.Get(Prop) {
                ; Prop is in `Exclude`
                if !InStr(Excluded, ',' Prop ',') {
                    Excluded .= Prop ','
                }
                continue
            }
            ObjSetBase(ItemBase := {
                /**
                 * The property name.
                 * @memberof PropsInfoItem
                 * @instance
                 */
                    Name: Prop
                /**
                 * `Count` gets incremented by one for each object which owns a property by the same name.
                 * @memberof PropsInfoItem
                 * @instance
                 */
                  , Count: 1
                }
              , PropsInfoItemBase)
            ObjSetBase(Item := ObjGetOwnPropDesc(Obj, Prop), ItemBase)
            Item.Index := 0
            Container.Set(Prop, Item)
        }
        if IncludeBaseProp {
            ObjSetBase(ItemBase := { Name: 'Base', Count: 1 }, PropsInfoItemBase)
            ObjSetBase(InfoItem_Base := { Value: Obj.Base }, ItemBase)
            InfoItem_Base.Index := 0
            Container.Set('Base', InfoItem_Base)
        }
        i := 0
        for b in OutBaseObjList {
            i++
            for Prop in ObjOwnProps(b) {
                if r := Container.Get(Prop) {
                    if r == -1 {
                        if !InStr(Excluded, ',' Prop ',') {
                            Excluded .= Prop ','
                        }
                        continue
                    }
                    ObjSetBase(Item := ObjGetOwnPropDesc(b, Prop), r.Base)
                    Item.Index := i
                    r.__SetAlt(Item)
                    r.Base.Count++
                } else {
                    ; It's a new property
                    ObjSetBase(ItemBase := { Name: Prop, Count: 1 }, PropsInfoItemBase)
                    ObjSetBase(Item := ObjGetOwnPropDesc(b, Prop), ItemBase)
                    Item.Index := i
                    Container.Set(Prop, Item)
                }
            }
            if IncludeBaseProp {
                ObjSetBase(Item := { Value: b.Base }, InfoItem_Base.Base)
                Item.Index := i
                InfoItem_Base.__SetAlt(Item)
                InfoItem_Base.Base.Count++
            }
        }
    }
    for s in StrSplit(Exclude, ',', '`s`t') {
        if s {
            Container.Delete(s)
        }
    }
    if !IncludeBaseProp {
        Excluded .= 'Base'
    }
    return TestSort_PropsInfo(Container, PropsInfoItemBase, Trim(Excluded, ','))
}

/**
 * @classdesc - The return value for `GetPropsInfo`. See the parameter hint above `GetPropsInfo`
 * for information.
 */
class TestSort_PropsInfo {
    static __New() {
        this.DeleteProp('__New')
        Proto := this.Prototype
        Proto.DefineProp('Filter', { Value: '' })
        Proto.DefineProp('__FilterActive', { Value: 0 })
        Proto.DefineProp('__StringMode', { Value: 0 })
        Proto.DefineProp('Get', Proto.GetOwnPropDesc('__ItemGet_Bitypic'))
        Proto.DefineProp('__OnFilterProperties', { Value: ['Has', 'ToArray', 'ToMap'
        , 'Capacity', 'Count', 'Length'] })
        Proto.DefineProp('__FilteredItems', { Value: '' })
        Proto.DefineProp('__FilteredIndex', { Value: '' })
        Proto.DefineProp('__FilterCache', { Value: '' })
    }

    /**
     * @class - The constructor is intended to be called from `GetPropsInfo`.
     * @param {Map} Container - The keys are property names and the values are `PropsInfoItem` objects.
     * @param {PropsInfoItem} PropsInfoItemBase - The base object shared by all instances of
     * `PropsInfoItem` associated with this `PropsInfo` object.
     * @param {String} [Excluded] - A comma-delimited list of properties that were excluded from the
     * collection.
     * @returns {PropsInfo} - The `PropsInfo` instance.
     */
    __New(Container, PropsInfoItemBase, Excluded?) {
        this.__InfoIndex := Map()
        this.__InfoIndex.Default := this.__InfoIndex.CaseSense := false
        this.__InfoItems := []
        this.__InfoItems.Capacity := this.__InfoIndex.Capacity := Container.Count
        for Prop, InfoItem in Container {
            this.__InfoItems.Push(InfoItem)
            this.__InfoIndex.Set(Prop, A_Index)
        }
        this.__PropsInfoItemBase := PropsInfoItemBase
        this.__FilterActive := 0
        this.Excluded := Excluded ?? ''
    }

    /**
     * @description - Removes a `PropsInfoItem` object from the collection. This does not change the
     * items exposed by the currently active filter nor any cached filters. To update a filter,
     * call `PropsInfo.Prototype.FilterActivate` after calling `PropsInfo.Prototype.Delete`,
     * `PropsInfo.Prototype.Refresh`, or `PropsInfo.Prototype.RefreshProp`.
     * @param {String} Names - A comma-delimited list of property names to delete.
     * @returns {PropsInfoItem[]} - An array of deleted `PropsInfoItem` objects.
     */
    Delete(Names) {
        InfoItems := this.__InfoItems
        InfoIndex := this.__InfoIndex
        NewInfoItems := this.__InfoItems := []
        Deleted := []
        NewInfoIndex := this.__InfoIndex := Map()
        NewInfoIndex.CaseSense := false
        NewInfoItems.Capacity := NewInfoIndex.Capacity := Deleted.Capacity := InfoItems.Length
        Names := ',' Names ','
        for InfoItem in InfoItems {
            if InStr(Names, ',' InfoItem.Name ',') {
                Deleted.Push(InfoItem)
            } else {
                NewInfoItems.Push(InfoItem)
                NewInfoIndex.Set(InfoItem.Name, NewInfoItems.Length)
            }
        }
        Excluded := this.Excluded ','
        for Prop in StrSplit(Trim(Names, ','), ',', '`s`t') {
            if !InStr(Excluded, ',' Prop ',') {
                Excluded .= Prop ','
            }
        }
        this.Excluded := Trim(Excluded, ',')
        NewInfoItems.Capacity := NewInfoItems.Length
        NewInfoIndex.Capacity := NewInfoIndex.Count
        Deleted.Capacity := Deleted.Length
        return Deleted
    }

    /**
     * @description - Performs these actions:
     * - Deletes the `Root` property from the `PropsInfoItem` object that is used as the base for
     * all `PropsInfoItem` objects associated with this `PropsInfo` object. This action invalidates
     * some of the `PropsInfoItem` objects' methods and properties, and they should be considered
     * effectively disposed.
     * - Clears the `PropsInfo` object's container properties and sets their capacity to 0
     * - Deletes the `PropsInfo` object's own properties.
     */
    Dispose() {
        this.__PropsInfoItemBase.DeleteProp('Root')
        this.__InfoIndex.Clear()
        this.__InfoIndex.Capacity := this.__InfoItems.Capacity := 0
        if this.__FilteredIndex {
            this.__FilteredIndex.Capacity := 0
        }
        if this.__FilteredItems {
            this.__FilteredItems.Clear()
            this.__FilteredItems.Capacity := 0
        }
        if this.HasOwnProp('Filter') {
            this.DeleteProp('Filter')
        }
        if this.HasOwnProp('__FilterCache') {
            this.__FilterCache.Clear()
            this.__FilterCache.Capacity := 0
        }
        for Prop in this.OwnProps() {
            this.DeleteProp(Prop)
        }
        this.DefineProp('Dispose', { Call: (*) => '' })
    }

    /**
     * @description - Activates the filter, setting property `PropsInfoObj.FilterActive := 1`. While
     * `PropsInfoObj.FilterActive == 1`, the values returned by the following methods and properties
     * will be filtered:
     * __Enum, Get, GetFilteredProps (if a function object is not passed to it), Has, ToArray, ToMap,
     * __item, Capacity, Count, Length
     * @param {String|Number} [CacheName] - If set, the filtered containers will be cached under this name.
     * Else, the containers are not cached.
     * @throws {UnsetItemError} - If no filters have been added.
     */
    FilterActivate(CacheName?) {
        if !this.Filter {
            throw UnsetItemError('No filters have been added.', -1)
        }
        Filter := this.Filter
        this.DefineProp('__FilteredIndex', { Value: FilteredIndex := [] })
        this.DefineProp('__FilteredItems', { Value: FilteredItems := Map() })
        FilteredIndex.Capacity := FilteredItems.Capacity := this.__InfoItems.Length
        ; If there's only one filter object in the collection, we can save a bit of processing
        ; time by just getting a reference to the object and skipping the second loop.
        if Filter.Count == 1 {
            for FilterIndex, FilterObj in Filter {
                Fn := FilterObj
            }
            for InfoItem in this.__InfoItems {
                if Fn(InfoItem) {
                    continue
                }
                FilteredItems.Set(A_Index, InfoItem)
                FilteredIndex.Push(A_Index)
            }
        } else {
            for InfoItem in this.__InfoItems {
                for FilterIndex, FilterObj in Filter {
                    if FilterObj(InfoItem) {
                        continue 2
                    }
                }
                FilteredItems.Set(A_Index, InfoItem)
                FilteredIndex.Push(A_Index)
            }
        }
        FilteredIndex.Capacity := FilteredItems.Capacity := FilteredItems.Count
        this.__FilterActive := 1
        if IsSet(CacheName) {
            this.FilterCache(CacheName)
        }
        this.__FilterSwitchProps(1)
    }

    /**
     * @description - Activates a cached filter.
     * @param {String|Number} Name - The name of the filter to activate.
     */
    FilterActivateFromCache(Name) {
        this.__FilterActive := 1
        this.__FilteredItems := this.__FilterCache.Get(Name).Items
        this.__FilteredIndex := this.__FilterCache.Get(Name).Index
        this.Filter := this.__FilterCache.Get(Name).FilterGroup
        this.__FilterSwitchProps(1)
    }

    /**
     * @description - Adds a filter to `PropsInfoObj.Filter`.
     * @param {Boolean} [Activate=true] - If true, the filter is activated immediately.
     * @param {...String|Func|Object} Filters - The filters to add. This parameter is variadic.
     * There are four built-in filters which you can include by integer:
     * - 1: Exclude all items that are not own properties of the root object.
     * - 2: Exclude all items that are own properties of the root object.
     * - 3: Exclude all items that have an `Alt` property, i.e. exclude all properties that have
     * multiple owners.
     * - 4: Exclude all items that do not have an `Alt` property, i.e. exclude all properties that
     * have only one owner.
     *
     * In addition to the above, you can pass any of the following:
     * - A string value as a property name to exclude, or a comma-delimited list of property
     * names to exclude.
     * - A `Func`, `BoundFunc` or `Closure`.
     * - An object with a `Call` method.
     * - An object with a `__Call` method.
     *
     * Function objects should accept the `PropsInfoItem` object as its only parameter, and
     * should return a nonzero value to exclude the property. To keep the property, return zero
     * or nothing.
     * @returns {Integer} - If at least one custom filter is added (i.e. a function object or
     * callable object was added), the index that was assignedd to the filter. Indices begin from 5
     * and increment by 1 for each custom filter added. Once an index is used, it will never be used
     * by the `PropsInfo` object again. You can use the index to later delete a filter if needed.
     * Saving the index isn't necessary; you can also delete a filter by passing the function object
     * to `PropsInfo.Prototype.FilterDelete`.
     * The following built-in indices always refer to the same function:
     * - 0: The function which excludes by property name.
     * - 1 through 4: The other built-in filters described above.
     * @throws {ValueError} - If the one of the values passed to `Filters` is invalid.
     */
    FilterAdd(Activate := true, Filters*) {
        if !this.Filter {
            this.DefineProp('Filter', { Value: TestSort_PropsInfo.FilterGroup() })
        }
        this.DefineProp('FilterAdd', { Call: _FilterAdd })
        this.FilterAdd(Activate, Filters*)

        _FilterAdd(Self, Activate := true, Filters*) {
            result := Self.Filter.Add(Filters*)
            if Activate {
                Self.FilterActivate()
            }
            return result
        }
    }

    /**
     * @description - Adds the currently active filter to the cache.
     * @param {String|Number} Name - The value which will be the key that accesses the filter.
     */
    FilterCache(Name) {
        if !this.__FilterCache {
            this.__FilterCache := Map()
        }
        this.DefineProp('FilterCache', { Call: _FilterCache })
        this.FilterCache(Name)
        _FilterCache(Self, Name) => Self.__FilterCache.Set(Name, { Items: Self.__FilteredItems, Index: Self.__FilteredIndex, FilterGroup: this.Filter })
    }

    /**
     * @description - Clears the filter.
     * @throws {Error} - If the filter is empty.
     */
    FilterClear() {
        if !this.Filter {
            throw Error('The filter is empty.', -1)
        }
        this.Filter.Clear()
        this.Filter.Capacity := 0
        this.Filter.Exclude := ''
    }

    /**
     * @description - Clears the filter cache.
     * @throws {Error} - If the filter cache is empty.
     */
    FilterClearCache() {
        if !this.__FilterCache {
            throw Error('The filter cache is empty.', -1)
        }
        this.__FilterCache.Clear()
        this.__FilterCache.Capacity := 0
    }

    /**
     * @description - Deactivates the currently active filter.
     * @param {String|Number} [CacheName] - If set, the filter is added to the cache with this name prior
     * to being deactivated.
     * @throws {Error} - If the filter is not currently active.
     */
    FilterDeactivate(CacheName?) {
        if !this.__FilterActive {
            throw Error('The filter is not currently active.', -1)
        }
        if IsSet(CacheName) {
            this.FilterCache(CacheName)
        }
        this.__FilterActive := 0
        this.__FilteredItems := ''
        this.__FilteredIndex := ''
        this.__FilterSwitchProps(0)
    }

    /**
     * @description - Deletes an item from the filter.
     * @param {Func|Integer|PropsInfo.Filter|String} Key - One of the following:
     * - The function object.
     * - The index assigned to the `PropsInfo.Filter` object.
     * - The `PropsInfo.Filter` object.
     * - The function object's name.
     * @returns {PropsInfo.Filter} - The filter object that was just deleted.
     * @throws {UnsetItemError} - If `Key` is a function object and the filter does not contain
     * that function.
     * @throws {UnsetItemError} - If `Key` is a string and the filter does not contain a function
     * with that name.
     */
    FilterDelete(Key) {
        return this.Filter.Delete(Key)
    }

    /**
     * @description - Deletes a filter from the cache.
     * @param {String|Integer} Name - The name assigned to the filter.
     * @returns {Map} - The object containing the filter functions that were just deleted.
     * @throws {Error} - If the filter cache is empty.
     */
    FilterDeleteFromCache(Name) {
        if !this.__FilterCache {
            throw Error('The filter cache is empty.', -1)
        }
        r := this.__FilterCache.Get(Name)
        this.__FilterCache.Delete(Name)
        return r
    }

    /**
     * @description - Returns a comma-delimited list of names of properties that were filtered out
     * of the collection.
     * @returns {String}
     */
    FilterGetList() {
        if !this.Filter {
            throw UnsetItemError('No filters have been added.', -1)
        }
        s := ''
        for InfoItem in this.__FilteredItems {
            s .= InfoItem.Name ','
        }
        return SubStr(s, 1, -1)
    }

    /**
     * @description - Removes one or more property names from the exclude list.
     * @param {String} Name - The name to remove or a comma-delimited list of names to remove.
     * @throws {Error} - If the filter is empty.
     */
    FilterRemoveFromExclude(Name) {
        if !this.Filter {
            throw Error('The filter is empty.', -1)
        }
        Filter := this.Filter
        for _name in StrSplit(Name, ',') {
            Filter.Exclude := RegExReplace(Filter.Exclude, ',' _name '(?=,)', '')
        }
    }

    /**
     * @description - Sets the `PropsInfoObj.Filter` property with the filter group.
     * @param {PropsInfo.FilterGroup} FilterGroup - The `PropsInfo.FilterGroup` object.
     * @param {String} [CacheName] - If set, the current filter will be cached. If unset, the
     * current filter is replaced without being cached.
     * @param {Boolean} [Activate := true] - If true, the filter is activated immediately.
     */
    FilterSet(FilterGroup, CacheName?, Activate := true) {
        if IsSet(CacheName) {
            this.FilterCache(CacheName)
        }
        this.DefineProp('Filter', { Value: FilterGroup })
        if Activate {
            this.FilterActivate()
        }
    }

    /**
     * @description - Retrieves a `PropsInfoItem` object.
     * @param {String|Integer} Key - While `PropsInfoObj.StringMode == true`, `Key` must be an
     * integer index value. While `PropsInfoObj.StringMode == false`, `Key` can be either a string
     * property name or an integer index value.
     * @returns {PropsInfoItem}
     * @throws {TypeError} - If `Key` is not a number and `PropsInfoObj.StringMode == true`.
     */
    Get(Key) {
        ; This is overridden
    }

    /**
     * @description - Retrieves the index of a property.
     * @param {String} Name - The name of the property.
     * @returns {Integer} - The index of the property.
     */
    GetIndex(Name) {
        return this.__InfoIndex.Get(Name)
    }

    /**
     * @description - Retrieves a proxy object.
     * @param {String} ProxyType - The type of proxy to create. Valid values are:
     * - 1: `PropsInfo.Proxy_Array`
     * - 2: `PropsInfo.Proxy_Map`
     * @returns {PropsInfo.Proxy_Array|PropsInfo.Proxy_Map}
     * @throws {ValueError} - If `ProxyType` is not 1 or 2.
     */
    GetProxy(ProxyType) {
        switch ProxyType, 0 {
            case '1': return TestSort_PropsInfo.Proxy_Array(this)
            case '2': return TestSort_PropsInfo.Proxy_Map(this)
        }
        throw ValueError('The input ``ProxyType`` must be ``1`` or ``2``.', -1
        , IsObject(ProxyType) ? 'Type(ProxyType) == ' Type(ProxyType) : ProxyType)
    }

    /**
     * @description - Iterates the `PropsInfo` object, adding the `PropsInfoItem` objects to
     * a container.
     * @param {*} [Container] - The container to add the filtered `PropsInfoItem` objects to. If set,
     * the object must inherit from either `Map` or `Array`.
     * - If `Container` inherits from `Array`, the `PropsInfoItem` objects are added to the array using
     * `Push`.
     * - If `Container` inherits from `Map`, the `PropsInfoItem` objects are added to the map using
     * `Set`, with the property name as the key. The map's `CaseSense` property must be set to
     * "Off".
     * - If `Container` is unset, `GetFilteredProps` returns a new `PropsInfo` object.
     * @param {Function} [Function] -
     * - If set, a function object that accepts a `PropsInfoItem` object as its only parameter. The
     * function should return a nonzero value to exclude the property. Any currently active filters
     * are ignored.
     * - If unset, `GetFilteredProps` uses the filters that are currently active. The difference
     * between `GetFilteredProps` and either `ToMap` or `ToArray` in this case is that you can
     * supply your own container, or get a new `PropsInfo` object.
     * @returns {PropsInfo|Array|Map} - The container with the filtered `PropsInfoItem` objects.
     * If `Container` is unset, a new `PropsInfo` object is returned.
     * @throws {TypeError} - If `Container` is not an `Array` or `Map`.
     * @throws {Error} - If `Container` is a `Map` and its `CaseSense` property is not set to "Off".
     * @throws {Error} - If the filter is empty.
     */
    GetFilteredProps(Container?, Function?) {
        if IsSet(Container) {
            if Container is Array {
                Set := _Set_Array
                GetCount := () => Container.Length
            } else if Container is Map {
                if Container.CaseSense !== 'Off' {
                    throw Error('CaseSense must be set to "Off".', -1)
                }
                Set := _Set_Map
                GetCount := () => Container.Count
            } else {
                throw TypeError('Unexpected container type.', -1, 'Type(Container) == ' Type(Container))
            }
        } else {
            Container := Map()
            Container.CaseSense := false
            Set := _Set_Map
            GetCount := () => Container.Count
            Flag_MakePropsInfo := true
        }
        Excluded := this.Excluded ','
        InfoItems := this.__InfoItems
        Container.Capacity := InfoItems.Length
        if IsSet(Function)  {
            for InfoItem in InfoItems {
                if Function(InfoItem) {
                    if !InStr(Excluded, ',' InfoItem.Name ',') {
                        Excluded .= InfoItem.Name ','
                    }
                    continue
                }
                Set(InfoItem)
            }
        } else if this.Filter {
            Filter := this.Filter
            if Filter.Count == 1 {
                for FilterIndex, FilterObj in Filter {
                    Fn := FilterObj
                }
                for InfoItem in InfoItems {
                    if Fn(InfoItem) {
                        if !InStr(Excluded, ',' InfoItem.Name ',') {
                            Excluded .= InfoItem.Name ','
                        }
                        continue
                    }
                    Set(InfoItem)
                }
            } else {
                for InfoItem in Infoitems {
                    for FilterIndex, FilterObj in Filter {
                        if FilterObj(InfoItem) {
                            if !InStr(Excluded, ',' InfoItem.Name ',') {
                                Excluded .= InfoItem.Name ','
                            }
                            continue 2
                        }
                    }
                    Set(InfoItem)
                }
            }
        } else {
            throw Error('The filter is empty.', -1)
        }
        Container.Capacity := GetCount()
        return IsSet(Flag_MakePropsInfo) ? TestSort_PropsInfo(Container, this.__PropsInfoItemBase, Trim(StrReplace(Excluded, ',,', ','), ',')) : Container

        _Set_Array(InfoItem) => Container.Push(InfoItem)
        _Set_Map(InfoItem) => Container.Set(InfoItem.Name, InfoItem)
    }

    /**
     * @description - Checks if a property exists in the `PropsInfo` object.
     */
    Has(Key) {
        return IsNumber(Key) ? this.__InfoItems.Has(Key) : this.__InfoIndex.Has(Key)
    }

    /**
     * @description - Iterates the root object's properties, updating the `PropsInfo` object's
     * internal containers to reflect the current state of the objects. This does not change the
     * items exposed by the currently active filter nor any cached filters. To update a filter,
     * call `PropsInfo.Prototype.FilterActivate` after calling `PropsInfo.Prototype.Delete`,
     * `PropsInfo.Prototype.Refresh`, or `PropsInfo.Prototype.RefreshProp`.
     *
     * - The reason for using `PropsInfo.Prototype.Refresh` instead of calling `GetPropsInfo`
     * would be to preserve any changes that external code has made to the `PropsInfo` object or the
     * `PropsInfoItem` objects. If your code has not made any changes to any of the objects,
     * calling `GetPropsInfo` will perform better than calling `PropsInfo.Prototype.Refresh`.
     *
     * - `PropsInfoObj.FilterActive` and `PropsInfoObj.StringMode` are set to `0` at the start of the
     * procedure, and returned to their original values at the end.
     *
     * - `PropsInfo.Prototype.Refresh` will update the `InfoItem.Alt` array to be consistent with
     * the objects' current state. Any items that are removed are returned when the function ends.
     *
     * - `PropsInfo.Prototype.Refresh` updates the `PropsInfoObj.Excluded` property and the
     * `PropsInfoObj.InheritanceDepth` property.
     *
     * - If an object no longer owns a property by the name, the `PropsInfoItem` object is removed
     * from the collection and added to the returned array.
     *
     * - `InfoItem.Count` is updated for any additions and deletions.
     *
     * - `PropsInfo.Prototype.Refresh` will swap the top-level `PropsInfoItem` object if a new
     * `PropsInfoItem` object is created with a lower `Index` property value than the current top-level
     * item. The original top-level item has the `Alt` property deleted if present, then gets added
     * to the `Alt` property of the new top-level item. This is to ensure consistency that the top-level
     * `PropsInfoItem` object is always associated with either the root object or the object from
     * which the root object inherits the property.
     *
     * @param {Integer|String} [StopAt=GPI_STOP_AT_DEFAULT ?? '-Object'] - If an integer, the number of
     * base objects to traverse up the inheritance chain. If a string, the name of the class to stop at.
     * You can define a global variable `GPI_STOP_AT_DEFAULT` to change the default value. If
     * GPI_STOP_AT_DEFAULT is unset, the default value is '-Object', which directs
     * `PropsInfo.Prototype.Refresh` to include properties owned by objects up to but not including
     * `Object.Prototype`.
     * @see {@link GetBaseObjects} for full details about this parameter.
     * @param {String} [Exclude=''] - A comma-delimited, case-insensitive list of properties to exclude.
     * For example: "Length,Capacity,__Item".
     * @param {Boolean} [IncludeBaseProp=true] - If true, the object's `Base` property is included. If
     * false, `Base` is excluded.
     * @param {VarRef} [OutBaseObjList] - A variable that will receive a reference to the array of
     * base objects that is generated during the function call.
     * @param {Boolean} [ExcludeMethods=false] - If true, callable properties are excluded. Note that
     * properties with a value that is a class object are unaffected by `ExcludeMethods`.
     * @returns {PropsInfoItem[]|String} - If any items are removed from the collection they are
     * added to an array to be returned. Else, returns an empty string.
     */
    Refresh(StopAt := GPI_STOP_AT_DEFAULT ?? '-Object', Exclude := '', IncludeBaseProp := true, &OutBaseObjList?, ExcludeMethods := false) {
        if this.FilterActive {
            OriginalFilterActive := this.FilterActive
            this.FilterActive := 0
        }
        Excluded := ','
        InfoItems := this.__InfoItems
        InfoIndex := this.__InfoIndex
        OriginalStringMode := this.StringMode
        this.StringMode := 0
        Obj := this.Root
        AltMap := Map()
        AltMap.CaseSense := false
        OutBaseObjList := TestSort_GetBaseObjects(Obj, StopAt)
        this.__PropsInfoItemBase.InheritanceDepth := OutBaseObjList.Length
        OutBaseObjList.InsertAt(1, Obj)
        Exclude := ',' Exclude ','
        ToDelete := ''
        ActivePropsList := this.ToMap()
        Deleted := []
        i := -1
        for b in OutBaseObjList {
            ++i
            for Prop in ObjOwnProps(b) {
                if InStr(Exclude, ',' Prop ',') || (ExcludeMethods && HasMethod(Obj, Prop) && not Obj.%Prop% is Class) {
                    if this.Has(Prop) {
                        ToDelete .= Prop ','
                    }
                    if !InStr(Excluded, ',' Prop ',') {
                        Excluded .= Prop ','
                    }
                    continue
                }
                this.__RefreshProcess(ActivePropsList, AltMap, i, Prop, b)
            }
            if IncludeBaseProp {
                this.__RefreshProcess(ActivePropsList, AltMap, i, 'Base', b)
            }
        }
        for name, InfoItem in ActivePropsList {
            ToDelete .= name ','
        }
        if ToDelete := Trim(ToDelete, ',') {
            if DeletedItems := this.Delete(ToDelete) {
                Deleted.Push(DeletedItems*)
            }
        }
        for Prop, IndexList in AltMap {
            if InfoItem := this.Get(Prop) {
                if IndexList := Trim(IndexList, ',') {
                    if InfoItem.HasOwnProp('Alt') {
                        for s in StrSplit(IndexList, ',') {
                            if s {
                                i := 0
                                Alt := InfoItem.Alt
                                loop Alt.Length {
                                    if Alt[++i].Index = s {
                                        Deleted.Push(Alt.RemoveAt(i))
                                        this.__RefreshIncrementCount(InfoItem, -1)
                                        i--
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
                if InfoItem.HasOwnProp('Alt') && !InfoItem.Alt.Length {
                    InfoItem.DeleteProp('Alt')
                }
            }
        }
        if IsSet(OriginalFilterActive) {
            this.FilterActive := OriginalFilterActive
        }
        this.StringMode := OriginalStringMode
        this.Excluded := Trim(Excluded, ',')
        return Deleted.Length ? Deleted : ''
    }

    /**
     * @description - For each name listed in `Names`, the root object and its base objects are
     * iterated. If an object owns a property with a given name, and if the current collection does not
     * have an associated `PropsInfoItem` object for the property, a `PropsInfoItem` object is
     * created and added to the collection. This does not change the items exposed by the currently
     * active filter nor any cached filters. To update a filter, call
     * `PropsInfo.Prototype.FilterActivate` after calling `PropsInfo.Prototype.Delete`,
     * `PropsInfo.Prototype.Refresh`, or `PropsInfo.Prototype.RefreshProp`.
     *
     * - `PropsInfoObj.FilterActive` and `PropsInfoObj.StringMode` are set to `0` at the start of the
     * procedure, and returned to their original values at the end.
     *
     * - `PropsInfo.Prototype.RefreshProp` will update the `InfoItem.Alt` array to be consistent with
     * the objects' current state. Any items that are removed are returned when the function ends.
     *
     * - `PropsInfo.Prototype.RefreshProp` updates the `PropsInfoObj.Excluded` property and the
     * `PropsInfoObj.InheritanceDepth` property.
     *
     * - If an object no longer owns a property by the name, the `PropsInfoItem` object is removed
     * from the collection and added to the returned array.
     *
     * - `InfoItem.Count` is updated for any additions and deletions.
     *
     * - `PropsInfo.Prototype.RefreshProp` will swap the top-level `PropsInfoItem` object if a new
     * `PropsInfoItem` object is created with a lower `Index` property value than the current top-level
     * item. The original top-level item has the `Alt` property deleted if present, then gets added
     * to the `Alt` property of the new top-level item. This is to ensure consistency that the top-level
     * `PropsInfoItem` object is always associated with either the root object or the object from
     * which the root object inherits the property.
     *
     * @param {String} Names - A comma-delimited list of property names to update. For example,
     * "__Class,Length".
     * @param {Integer|String} [StopAt=GPI_STOP_AT_DEFAULT ?? '-Object'] - If an integer, the number of
     * base objects to traverse up the inheritance chain. If a string, the name of the class to stop at.
     * You can define a global variable `GPI_STOP_AT_DEFAULT` to change the default value. If
     * GPI_STOP_AT_DEFAULT is unset, the default value is '-Object', which directs
     * `PropsInfo.Prototype.Add` to include properties owned by objects up to but not including
     * `Object.Prototype`.
     * @see {@link GetBaseObjects} for full details about this parameter.
     * @param {VarRef} [OutBaseObjList] - A variable that will receive a reference to the array of
     * base objects that is generated during the function call.
     * @returns {PropsInfoItem[]|String} - If any items are removed from the collection they are
     * added to an array to be returned. Else, returns an empty string.
     */
    RefreshProp(Names, StopAt := GPI_STOP_AT_DEFAULT ?? '-Object', &OutBaseObjList?) {
        if this.FilterActive {
            OriginalFilterActive := this.FilterActive
            this.FilterActive := 0
        }
        OriginalStringMode := this.StringMode
        this.StringMode := 0
        OutBaseObjList := TestSort_GetBaseObjects(this.Root, StopAt)
        this.__PropsInfoItemBase.InheritanceDepth := OutBaseObjList.Length
        OutBaseObjList.InsertAt(1, this.Root)
        Names := StrSplit(Trim(Names, ','), ',', '`s`t')
        Deleted := []
        Excluded := ',' this.Excluded ','
        for Prop in Names {
            i := -1
            if InStr(Excluded, ',' Prop ',') {
                Excluded := StrReplace(Excluded, ',' Prop, '')
            }
            if this.Has(prop) {
                InfoItem := this.Get(Prop)
                IndexList := ',' InfoItem.Index ','
                if InfoItem.HasOwnProp('Alt') {
                    for AltInfoItem in InfoItem.Alt {
                        IndexList .= AltInfoItem.Index ','
                    }
                }
                for b in OutBaseObjList {
                    ++i
                    if b.HasOwnProp(Prop) {
                        if InStr(IndexList, ',' i ',') {
                            if InfoItem.Index = i {
                                InfoItem.Refresh()
                            } else {
                                for AltInfoItem in InfoItem.Alt {
                                    if AltInfoItem.Index = i {
                                        AltInfoItem.Refresh()
                                        break
                                    }
                                }
                            }
                        } else {
                            if Prop = 'Base' {
                                if i < InfoItem.Index {
                                    this.__RefreshSwap(i, InfoItem, b)
                                } else {
                                    this.__RefreshBaseProp(i, b)
                                }
                            } else {
                                if i < InfoItem.Index {
                                    this.__RefreshSwap(i, InfoItem, b)
                                } else {
                                    this.__RefreshAdd(i, Prop, b)
                                }
                            }
                        }
                    } else {
                        if InStr(IndexList, ',' i ',') {
                            if InfoItem.Index = i {
                                if InfoItem.HasOwnProp('Alt') {
                                    if InfoItem.Alt.Length > 1 {
                                        lowest := 9223372036854775807
                                        for AltInfoItem in InfoItem.Alt {
                                            if AltInfoItem.Index < lowest {
                                                lowest := AltInfoItem.Index
                                                LowestIndex := A_Index
                                            }
                                        }
                                        AltInfoItem := InfoItem.Alt.RemoveAt(LowestIndex)
                                        AltInfoItem.DefineProp('Alt', { Value: InfoItem.Alt })
                                    } else {
                                        AltInfoItem := InfoItem.Alt[1]
                                        InfoItem.DeleteProp('Alt')
                                    }
                                    this.__InfoItems[this.__InfoIndex.Get(Prop)] := AltInfoItem
                                    Deleted.Push(InfoItem)
                                    this.__RefreshIncrementCount(InfoItem, -1)
                                    AltInfoItem.Refresh()
                                } else {
                                    Deleted.Push(this.__InfoItems.RemoveAt(this.__InfoIndex.Get(Prop)))
                                    this.__RefreshIncrementCount(InfoItem, -1)
                                }
                            } else {
                                for AltInfoItem in InfoItem.Alt {
                                    if AltInfoItem.Index = i {
                                        Deleted.Push(InfoItem.Alt.RemoveAt(A_Index))
                                        this.__RefreshIncrementCount(InfoItem, -1)
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                if Prop = 'Base' {
                    for b in OutBaseObjList {
                        this.__RefreshBaseProp(++i, b)
                    }
                } else {
                    for b in OutBaseObjList {
                        ++i
                        if b.HasOwnProp(Prop) {
                            this.__RefreshAdd(i, Prop, b)
                        }
                    }
                }
            }
        }
        if IsSet(OriginalFilterActive) {
            this.FilterActive := OriginalFilterActive
        }
        this.StringMode := OriginalStringMode
        this.Excluded := Trim(Excluded, ',')

        return Deleted.Length ? Deleted : ''
    }

    /**
     * @description - Iterates the `PropsInfo` object, adding the `PropsInfoItem` objects to an array,
     * or adding the property names to an array.
     * @param {Boolean} [NamesOnly=false] - If true, the property names are added to the array. If
     * false, the `PropsInfoItem` objects are added to the array.
     * @returns {Array} - The array of property names or `PropsInfoItem` objects.
     */
    ToArray(NamesOnly := false) {
        Result := []
        Result.Capacity := this.__InfoItems.Length
        if NamesOnly {
            for Item in this.__InfoItems {
                Result.Push(Item.Name)
            }
        } else {
            for Item in this.__InfoItems {
                Result.Push(Item)
            }
        }
        return Result
    }

    /**
     * @description - Iterates the `PropsInfo` object, adding the `PropsInfoItem` objects to a map.
     * The keys are the property names.
     * @returns {Map} - The map of property names and `PropsInfoItem` objects.
     */
    ToMap() {
        Result := Map()
        Result.Capacity := this.__InfoItems.Length
        for InfoItem in this.__InfoItems {
            Result.Set(InfoItem.Name, InfoItem)
        }
        return Result
    }

    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    Capacity => this.__InfoIndex.Capacity
    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    CaseSense => this.__InfoIndex.CaseSense
    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    Count => this.__InfoIndex.Count
    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    Default => this.__InfoIndex.Default
    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    InheritanceDepth => this.__PropsInfoItemBase.InheritanceDepth
    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    Length => this.__InfoItems.Length
    /**
     * @memberof PropsInfo
     * @instance
     * @readonly
     */
    Root => this.__PropsInfoItemBase.Root

    /**
     * Set to a nonzero value to activate the current filter. Set to a falsy value to deactivate.
     * While a filter is active, the values retured by the `PropsInfo` object's methods and properties
     * will be filtered. See the parameter hint above `PropsInfo.Prototype.FilterActivate` for
     * additional details.
     * @memberof PropsInfo
     * @instance
     */
    FilterActive {
        Get => this.__FilterActive
        Set {
            if Value {
                this.FilterActivate()
            } else {
                this.FilterDeactivate()
            }
        }
    }

    /**
     * Set to a nonzero value to activate string mode. Set to a falsy value to deactivate.
     * While string mode is active, the `PropsInfo` object emulates the behavior of an array of
     * strings. The following properties and methods are influenced by string mode:
     * __Enum, Get, __Item
     * By extension, the proxies are also affected.
     * @memberof PropsInfo
     * @instance
     */
    StringMode {
        Get => this.__StringMode
        Set {
            if this.__FilterActive {
                if Value {
                    this.DefineProp('__StringMode', { Value: 1 })
                    this.DefineProp('Get', { Call: this.__FilteredGet_StringMode })
                } else {
                    this.DefineProp('__StringMode', { Value: 0 })
                    this.DefineProp('Get', { Call: this.__FilteredGet_Bitypic })
                }
            } else {
                if Value {
                    this.DefineProp('__StringMode', { Value: 1 })
                    this.DefineProp('Get', { Call: this.__ItemGet_StringMode })
                } else {
                    this.DefineProp('__StringMode', { Value: 0 })
                    this.DefineProp('Get', { Call: this.__ItemGet_Bitypic })
                }
            }
        }
    }

    /**
     * @description - `__Enum` is influenced by both string mode and any active filters. It can
     * be called in either 1-param mode or 2-param mode.
     */
    __Enum(VarCount) {
        i := 0
        if this.__FilterActive {
            Index := this.__FilteredIndex
            FilteredItems := this.__FilteredItems
            return this.__StringMode ? _Filtered_Enum_StringMode_%VarCount% : _Filtered_Enum_%VarCount%
        } else {
            InfoItems := this.__InfoItems
            return this.__StringMode ? _Enum_StringMode_%VarCount% : _Enum_%VarCount%
        }
        _Enum_1(&InfoItem) {
            if ++i > InfoItems.Length {
                return 0
            }
            InfoItem := InfoItems[i]
            return 1
        }
        _Enum_2(&Prop, &InfoItem) {
            if ++i > InfoItems.Length {
                return 0
            }
            InfoItem := InfoItems[i]
            Prop := InfoItem.Name
            return 1
        }
        _Enum_StringMode_1(&Prop) {
            if ++i > InfoItems.Length {
                return 0
            }
            Prop := InfoItems[i].Name
            return 1
        }
        _Enum_StringMode_2(&Index, &Prop) {
            if ++i > InfoItems.Length {
                return 0
            }
            Index := i
            Prop := InfoItems[i].Name
            return 1
        }
        _Filtered_Enum_1(&InfoItem) {
            if ++i > Index.Length {
                return 0
            }
            InfoItem := FilteredItems[Index[i]]
            return 1
        }
        _Filtered_Enum_2(&Prop, &InfoItem) {
            if ++i > Index.Length {
                return 0
            }
            InfoItem := FilteredItems[Index[i]]
            Prop := InfoItem.Name
            return 1
        }
        _Filtered_Enum_StringMode_1(&Prop) {
            if ++i > Index.Length {
                return 0
            }
            Prop := FilteredItems[Index[i]].Name
            return 1
        }
        _Filtered_Enum_StringMode_2(&Index, &Prop) {
            if ++i > Index.Length {
                return 0
            }
            Index := i
            Prop := FilteredItems[Index[i]].Name
            return 1
        }
    }

    /**
     * @description - Allows access to the `PropsInfoItem` objects using `Obj[Key]` syntax. Forwards
     * the `Key` to the `Get` method. {@link PropsInfo#Get}.
     */
    __Item[Key] => this.Get(Key)

    __ItemGet_StringMode(Index) {
        if !IsNumber(Index) {
            this.__ThrowTypeError()
        }
        return this.__InfoItems[Index].Name
    }

    __ItemGet_Bitypic(Key) {
        return this.__InfoItems[IsNumber(Key) ? Key : this.__InfoIndex.Get(Key)]
    }

    __FilteredGet_StringMode(Index) {
        if !IsNumber(Index) {
            this.__ThrowTypeError()
        }
        return this.__InfoItems[this.__FilteredIndex[Index]].Name
    }

    __FilteredGet_Bitypic(Key) {
        if IsNumber(Key) {
            return this.__InfoItems[this.__FilteredIndex[Key]]
        } else {
            return this.__FilteredItems.Get(this.__InfoIndex.Get(Key))
        }
    }

    __FilteredHas(Key) {
        if IsNumber(Key) {
            return this.__FilteredItems.Has(this.__InfoIndex.Get(this.__InfoItems[Key].Name))
        } else {
            return this.__FilteredItems.Has(this.__InfoIndex.Get(Key))
        }
    }

    __FilteredToArray(NamesOnly := false) {
        Result := []
        Result.Capacity := this.__FilteredItems.Count
        if NamesOnly {
            for i, InfoItem in this.__FilteredItems {
                Result.Push(InfoItem.Name)
            }
        } else {
            for i, InfoItem in this.__FilteredItems {
                Result.Push(InfoItem)
            }
        }
        return Result
    }

    __FilteredToMap(NamesOnly := false) {
        Result := Map()
        Result.Capacity := this.__FilteredItems.Count
        for i, InfoItem in this.__FilteredItems {
            Result.Set(InfoItem.Name, InfoItem)
        }
        return Result
    }

    __FilterSwitchProps(Value) {
        Proto := TestSort_PropsInfo.Prototype
        if Value {
            for Name in this.__OnFilterProperties {
                this.DefineProp(Name, Proto.GetOwnPropDesc('__Filtered' Name))
            }
            this.DefineProp('Get', Proto.GetOwnPropDesc(this.__StringMode ? '__FilteredGet_StringMode' : '__FilteredGet_Bitypic'))
        } else {
            for Name in this.__OnFilterProperties {
                this.DefineProp(Name, Proto.GetOwnPropDesc(Name))
            }
            this.DefineProp('Get', Proto.GetOwnPropDesc(this.__StringMode ? '__ItemGet_StringMode' : '__ItemGet_Bitypic'))
        }
    }

    __RefreshAdd(Index, Prop, Obj) {
        if this.Has(Prop) {
            b := InfoItem := this.Get(Prop)
            while !b.HasOwnProp('Name') {
                b := b.Base
            }
            ObjSetBase(Item := ObjGetOwnPropDesc(Obj, InfoItem.Name), b)
            Item.Index := Index
            InfoItem.__SetAlt(Item)
            b.Count++
        } else {
            ObjSetBase(ItemBase := { Name: Prop, Count: 1 }, this.__PropsInfoItemBase)
            ObjSetBase(Item := ObjGetOwnPropDesc(Obj, Prop), ItemBase)
            Item.Index := Index
            this.__InfoItems.Push(Item)
            this.__InfoIndex.Set(Prop, this.__InfoItems.Length)
        }
    }

    __RefreshBaseProp(Index, Obj) {
        if this.Has('Base') {
            b := InfoItem := this.Get('Base')
            while !b.HasOwnProp('Name') {
                b := b.Base
            }
            ObjSetBase(Item := { Value: Obj.Base, Index: Index }, b)
            InfoItem.__SetAlt(Item)
            b.Count++
        } else {
            ObjSetBase(ItemBase := { Name: 'Base', Count: 1 }, this.__PropsInfoItemBase)
            ObjSetBase(InfoItem := { Value: Obj.Base, Index: Index }, ItemBase)
            this.__InfoItems.Push(InfoItem)
            this.__InfoIndex.Set('Base', this.__InfoItems.Length)
        }
    }

    __RefreshIncrementCount(InfoItem, Count) {
        loop this.InheritanceDepth {
            if InfoItem.HasOwnProp('Count') {
                InfoItem.Count += Count
                return
            } else {
                InfoItem := InfoItem.Base
            }
        }
        throw Error('Failed to increment the count.', -1, '``InfoItem.Name == ' InfoItem.Name)
    }

    __RefreshProcess(ActivePropsList, AltMap, Index, Prop, Obj) {
        if ActivePropslist && ActivePropsList.Has(Prop) {
            ActivePropsList.Delete(Prop)
        }
        if this.Has(Prop) {
            InfoItem := this.Get(Prop)
            if !AltMap.Has(InfoItem.Name) {
                indexList := ',' InfoItem.Index ','
                if InfoItem.HasOwnProp('Alt') {
                    for AltInfoItem in InfoItem.Alt {
                        indexList .= AltInfoItem.Index ','
                    }
                }
                AltMap.Set(InfoItem.Name, indexList)
            }
            if InStr(AltMap.Get(InfoItem.Name), ',' Index ',') {
                AltMap.Set(InfoItem.Name, StrReplace(AltMap.Get(InfoItem.Name), ',' Index, ''))
                InfoItem.Refresh()
            } else {
                if Index < InfoItem.Index {
                    this.__RefreshSwap(Index, InfoItem, Obj)
                } else {
                    if Prop == 'Base' {
                        this.__RefreshBaseProp(Index, Obj)
                    } else {
                        this.__RefreshAdd(Index, Prop, Obj)
                    }
                }
            }
        } else {
            if Prop == 'Base' {
                this.__RefreshBaseProp(Index, Obj)
            } else {
                this.__RefreshAdd(Index, Prop, Obj)
            }
        }
    }

    __RefreshSwap(Index, InfoItem, Obj) {
        if InfoItem.Name = 'Base' {
            if Type(Obj) == 'Prototype' && Obj.__Class == 'Any' {
                return
            }
            Item := { Value: Obj.Base, Index: Index }
        } else {
            Item := ObjGetOwnPropDesc(Obj, InfoItem.Name)
            Item.Index := InfoItem.Index
        }
        InfoItem.Index := Index
        switch InfoItem.KindIndex {
            case 1: _SwapProps(['Call'], ['Get', 'Set', 'Value'])
            case 2: _SwapProps(['Get'], ['Call', 'Set', 'Value'])
            case 3: _SwapProps(['Get', 'Set'], ['Call', 'Value'])
            case 4: _SwapProps(['Set'], ['Call', 'Get', 'Value'])
            case 5: _SwapProps(['Value'], ['Call', 'Get', 'Set'])
        }
        b := InfoItem.Base
        while !b.HasOwnProp('Name') {
            b := b.Base
        }
        ObjSetBase(Item, b)
        b.Count++
        InfoItem.__SetAlt(Item)
        InfoItem.__DefineKindIndex()

        _SwapProps(PrimaryProps, AlternateProps) {
            for Prop in PrimaryProps {
                if Item.HasOwnProp(Prop) {
                    temp := InfoItem.%Prop%
                    InfoItem.DefineProp(Prop, { Value: Item.%Prop% })
                    Item.DefineProp(Prop, { Value: temp })
                } else {
                    Item.DefineProp(Prop, { Value: InfoItem.%Prop% })
                    InfoItem.DeleteProp(Prop)
                }
            }
            for Prop in AlternateProps {
                if Item.HasOwnProp(Prop) {
                    InfoItem.DefineProp(Prop, { Value: Item.%Prop% })
                    Item.DeleteProp(Prop)
                }
            }
        }
    }

    __ThrowTypeError() {
        ; To aid in debugging; if `StringMode == true`, then the object is supposed to behave
        ; like an array of strings, and so accessing an item by name is invalid and represents
        ; an error in the code.
        throw TypeError('Invalid input. While the ``PropsInfo`` object is in string mode,'
        ' items can only be accessed using numeric indices.', -2)
    }

    __FilteredCapacity => this.__FilteredItems.Capacity
    __FilteredCount => this.__FilteredItems.Count
    __FilteredLength => this.__FilteredItems.Count

    /**
     * `PropsInfo.Filter` constructs the filter objects when a filter is added using
     * `PropsInfo.Prototype.FilterAdd`. Filter objects have four properties:
     * - Index: The object's index which can be used to access or delete the object from the filter.
     * - Function: The function object.
     * - Call: The `Call` method which redirects the input parameter to the function and returns
     * the return value.
     * - Name: Returns the function's built-in name.
     * @classdesc
     */
    class Filter {
        __New(Function, Index) {
            this.DefineProp('Call', { Call: _Filter })
            this.Function := Function
            this.Index := Index

            _Filter(Self, Item) {
                Function := this.Function
                return Function(Item)
            }
        }
        Name => this.Function.Name
    }

    class FilterGroup extends Map {
        __New(Filters*) {
            this.Exclude := ''
            this.__Index := 5
            if Filters.Length {
                this.Add(Filters*)
            }
        }

        /**
         * @see {@link PropsInfo#FilterAdd}
         */
        Add(Filters*) {
            for filter in Filters {
                if IsObject(filter) {
                    if filter is Func || HasMethod(filter, 'Call') || HasMethod(filter, '__Call') {
                        if !IsSet(Start) {
                            Start := this.__Index
                        }
                        this.Set(this.__Index, TestSort_PropsInfo.Filter(filter, this.__Index++))
                    } else {
                        throw ValueError('A value passed to the ``Filters`` parameter is invalid.', -1
                        , 'Type(Value): ' Type(filter))
                    }
                } else {
                    switch filter, 0 {
                        case '1', '2', '3', '4':
                            this.Set(filter, TestSort_PropsInfo.Filter(_filter_%filter%, filter))
                        default:
                            if SubStr(this.Exclude, -1, 1) == ',' {
                                this.Exclude .= filter
                            } else {
                                this.Exclude .= ',' filter
                            }
                            Flag_Exclude := true
                    }
                }
            }
            if IsSet(Flag_Exclude) {
                ; By ensuring every name has a comma on both sides, we can check the names by
                ; using `InStr(Filter.Exclude, ',' Prop ',')` which should perform better than RegExMatch.
                this.Exclude .= ','
                this.Set(0, TestSort_PropsInfo.Filter(_Exclude, 0))
            }

            ; If a custom filter is added, return the start index so the caller function can keep track.
            return Start ?? ''

            _Exclude(InfoItem) {
                return InStr(this.Exclude, ',' InfoItem.Name ',')
            }
            _Filter_1(InfoItem) => InfoItem.Index
            _Filter_2(InfoItem) => !InfoItem.Index
            _Filter_3(InfoItem) => InfoItem.HasOwnProp('Alt')
            _Filter_4(InfoItem) => !InfoItem.HasOwnProp('Alt')
        }

        /**
         * @see {@link PropsInfo#FilterDelete}
         */
        Delete(Key) {
            local r
            if Key is Func {
                ptr := ObjPtr(Key)
                for Index, FilterObj in this {
                    if ObjPtr(FilterObj.Function) == ptr {
                        r := FilterObj
                        break
                    }
                }
                if IsSet(r) {
                    this.__MapDelete(r.Index)
                } else {
                    throw UnsetItemError('The function passed to ``Key`` is not in the filter.', -1)
                }
            } else if IsObject(Key) {
                r := this.Get(Key.Index)
                this.__MapDelete(Key.Index)
            } else if IsNumber(Key) {
                r := this.Get(Key)
                this.__MapDelete(Key)
            } else {
                for Fn in this {
                    if Fn.Name == Key {
                        r := Fn
                        break
                    }
                }
                if IsSet(r) {
                    this.__MapDelete(r.Index)
                } else {
                    throw UnsetItemError('The filter does not contain a function with that name.', -2, Key)
                }
            }
            return r
        }

        /**
         * @see {@link PropsInfo#FilterRemoveFromExclude}
         */
        RemoveFromExclude(Name) {
            for _name in StrSplit(Name, ',') {
                this.Exclude := RegExReplace(this.Exclude, ',' _name '(?=,)', '')
            }
        }

        static __New() {
            this.DeleteProp('__New')
            this.Prototype.DefineProp('__MapDelete', Map.Prototype.GetOwnPropDesc('Delete'))
        }
    }

    /**
     * `PropsInfo.Proxy_Array` constructs a proxy that can be passed to an external function as an
     * iterable object. Use `PropsInfo.Proxy_Array` when an external function expects an iterable Array
     * object. Using a proxy is slightly more performant than calling `PropsInfo.Prototype.ToArray` in
     * cases where the object will only be iterated once.
     * The function should not try to set or change the items in the collection. If this is necessary,
     * use `PropsInfo.Prototype.ToArray`.
     * @classdesc
     */
    class Proxy_Array extends Array {
        static __New() {
            this.DeleteProp('__New')
            this.Prototype.DefineProp('__Class', { Value: 'Array' })
        }
        __New(Client) {
            this.DefineProp('Client', { Value: Client })
        }
        Get(Index) => this.Client.Get(Index)
        Has(Index) => this.Client.__InfoItems.Has(Index)
        __Enum(VarCount) => this.Client.__Enum(VarCount)
        Capacity {
            Get => this.Client.__InfoItems.Capacity
            Set => this.Client.__InfoItems.Capacity := Value
        }
        Default {
            Get => this.Client.__InfoItems.Default
            Set => this.Client.__InfoItems.Default := Value
        }
        Length {
            Get => this.Client.__InfoItems.Length
            Set => this.Client.__InfoItems.Length := Value
        }
        __Item[Index] {
            Get => this.Client.__Item[Index]
            ; `PropsInfo` is not compatible with addint new items to the collection.
            ; Set => this.Client.__Item[Index] := Value
        }
        __Get(Name, Params) {
            if Params.Length {
                return this.Client.%Name%[Params*]
            } else {
                return this.Client.%Name%
            }
        }
        __Set(Name, Params, Value) {
            if Params.Length {
                return this.Client.%Name%[Params*] := Value
            } else {
                return this.Client.%Name% := Value
            }
        }
        __Call(Name, Params) {
            if Params.Length {
                return this.Client.%Name%(Params*)
            } else {
                return this.Client.%Name%()
            }
        }
    }

    /**
     * `PropsInfo.Proxy_Map` constructs a proxy that can be passed to an external function as an
     * iterable object. Use `PropsInfo.Proxy_Map` when an external function expects an iterable Map
     * object. Using a proxy is slightly more performant than calling `PropsInfo.Prototype.ToMap` in
     * cases where the object will only be iterated once.
     * The function should not try to set or change the items in the collection. If this is necessary,
     * use `PropsInfo.Prototype.ToMap`.
     * @classdesc
     */
    class Proxy_Map extends Map {
        static __New() {
            this.DeleteProp('__New')
            this.Prototype.DefineProp('__Class', { Value: 'Map' })
        }
        __New(Client) {
            this.DefineProp('Client', { Value: Client })
        }
        Get(Key) => this.Client.Get(Key)
        Has(Key) => this.Client.__InfoIndex.Has(Key)
        __Enum(VarCount) => this.Client.__Enum(VarCount)
        Capacity {
            Get => this.Client.__InfoIndex.Capacity
            Set => this.Client.___InfoIndex.Capacity := Value
        }
        CaseSense => this.Client.__InfoIndex.CaseSense
        Count => this.Client.__InfoIndex.Count
        Default {
            Get => this.Client.__InfoIndex.Default
            Set => this.Client.__InfoIndex.Default := Value
        }
        __Item[Key] {
            Get => this.Client.__Item[Key]
            ; `PropsInfo` is not compatible with addint new items to the collection.
            ; Set => this.Client.__Item[Key] := Value
        }
        __Get(Name, Params) {
            if Params.Length {
                return this.Client.%Name%[Params*]
            } else {
                return this.Client.%Name%
            }
        }
        __Set(Name, Params, Value) {
            if Params.Length {
                return this.Client.%Name%[Params*] := Value
            } else {
                return this.Client.%Name% := Value
            }
        }
        __Call(Name, Params) {
            if Params.Length {
                return this.Client.%Name%(Params*)
            } else {
                return this.Client.%Name%()
            }
        }
    }
}

/**
 * @classdesc - For each base object in the input object's inheritance chain (up to the stopping
 * point), the base object's own properties are iterated, generating a `PropsInfoItem` object for
 * each property (unless the property is excluded).
 */
class TestSort_PropsInfoItem {
    static __New() {
        this.DeleteProp('__New')
        this.Prototype.__KindNames := ['Call', 'Get', 'Get_Set', 'Set', 'Value']
    }

    /**
     * @description - Each time `GetPropsInfo` is called, a new `PropsInfoItem` is created.
     * The `PropsInfoItem` object is used as the base object for all further `PropsInfoItem`
     * instances generated within that `GetPropsInfo` function call (and only that function call),
     * allowing properties to be defined once on the base and shared by the rest.
     * `PropsInfoItem.Prototype.__New` is not intended to be called directly.
     * @param {Object} Root - The object that was passed to `GetPropsInfo`.
     * @param {Integer}InheritanceDepth - The number of base objects traversed during the `GetPropsInfo`
     * call.
     * @returns {PropsInfoItem} - The `PropsInfoItem` instance.
     * @class
     */
    __New(Root, InheritanceDepth) {
        this.Root := Root
        this.InheritanceDepth := InheritanceDepth
    }

    /**
     * @description - Returns the function object, optionally binding an object to the hidden `this`
     * parameter. See {@link https://www.autohotkey.com/docs/v2/Objects.htm#Custom_Classes_method}
     * for information about the hidden `this`.
     * @param {VarRef} [OutSet] - A variable that will receive the `Set` function if this object
     * has both `Get` and `Set`. If this object only has a `Set` property, the `Set` function object
     * is returned as the return value and `OutSet` remains unset.
     * @param {Integer} Flag_Bind - One of the following values:
     * - 0: The function objects are returned as-is, with the hidden `this` parameter still exposed.
     * - 1: The object that was passed to `GetPropsInfo` is bound to the function object(s).
     * - 2: The owner of the property that produced this `PropsInfoItem` object is bound to the
     * function object(s).
     * @returns {Func|BoundFunc} - The function object.
     * @throws {ValueError} - If `Flag_Bind` is not 0, 1, or 2.
     */
    GetFunc(&OutSet?, Flag_Bind := 0) {
        switch Flag_Bind, 0 {
            case '0':
                switch this.KindIndex {
                    case 1: return this.Call
                    case 2: return this.Get
                    case 3:
                        OutSet := this.Set
                        return this.Get
                    case 4: return this.Set
                    case 5: return ''
                }
            case '1': return _Proc(this.Root)
            case '2': return _Proc(this.Owner)
            default: throw ValueError('Invalid value passed to the ``Flag_Bind`` parameter.', -1
            , IsObject(Flag_Bind) ? 'Type(Flag_Bind) == ' Type(Flag_Bind) : Flag_Bind)
        }

        _Proc(Obj) {
            switch this.KindIndex {
                case 1: return this.Call.Bind(Obj)
                case 2: return this.Get.Bind(Obj)
                case 3:
                    OutSet := this.Set.Bind(Obj)
                    return this.Get.Bind(Obj)
                case 4: return this.Set.Bind(Obj)
                case 5: return ''
            }
        }
    }

    /**
     * @description - `PropsInfoItem.Prototye.GetOwner` travels up the root object's inheritance chain
     * for `InfoItem.Index` objects, and if that object owns a property named `InfoItem.Name`, the
     * object is returned. If it does not own a property with that name,`PropsInfoItem.Prototype.GetOwner`
     * returns `0`.
     * The `InfoItem.Index` value represents the position in the inheritance chain of the object
     * that produced this `PropsInfoItem` object, beginning with the root object passed to
     * `GetPropsInfo`. Unless something has changed, the object at `InfoItem.Index` will be the
     * original owner of the property `InfoItem.Name`
     *
     * This example depicts a scenario in which the value returned by `PropsInfoItem.Prototype.GetOwner`
     * is not the original owner of the property that produced the `PropsInfoItem` object.
     * @example
     *  class a {
     *      __SomeProp := 0
     *      SomeProp => this.__SomeProp
     *  }
     *  class b extends a {
     *
     *  }
     *  class c {
     *      __SomeOtherProp := 1
     *      SomeProp => this.__SomeOtherProp
     *  }
     *  Obj := b()
     *  PropsInfoObj := GetPropsInfo(Obj)
     *  InfoItem := PropsInfoObj.Get('SomeProp')
     *  OriginalOwner := InfoItem.GetOwner()
     *  Obj.Base.Base := c.Prototype
     *  NewOwner := InfoItem.GetOwner()
     *  MsgBox(ObjPtr(OriginalOwner) == ObjPtr(NewOwner)) ; 0
     * @
     *
     * @returns {*} - If the object owns the property, the object. Else, returns 0.
     */
    GetOwner() {
        b := this.Root
        loop this.Index {
            b := b.Base
        }
        if this.Name = 'Base' || b.HasOwnProp(this.Name) {
            return b
        }
        return 0
    }

    /**
     * @description - If this is associated with a value property, provides the value that the property
     * had at the time this `PropsInfoItem` object was created. If this is associated with a dynamic
     * property with a `Get` accessor, attempts to access and provide the value.
     * @param {VarRef} OutValue - Because `GetValue` is expected to sometimes fail, the property's
     * value is set to the `OutValue` variable, and a status code is returned by the function.
     * @param {Boolean} [FromOwner=false] - When true, the object that produced this `PropsInfoItem`
     * object is passed as the first parameter to the `Get` accessor. When false, the root object
     * (the object passed to the `GetPropsInfo` call) is passed as the first parameter to the `Get`
     * accessor.
     * @returns {Integer} - One of these status codes:
     * - An empty string: The value was successfully accessed and `OutValue` is the value.
     * - 1: This `PropsInfoItem` object does not have a `Get` or `Value` property and the `OutValue`
     * variable remains unset.
     * - 2: An error occurred while calling the `Get` function, and `OutValue` is the error object.
     */
    GetValue(&OutValue, FromOwner := false) {
        switch this.KindIndex {
            case 1, 4: return 1 ; Call, Set
            case 2, 3:
                try {
                    if FromOwner {
                        OutValue := (Get := this.Get)(this.Owner)
                    } else {
                        OutValue := (Get := this.Get)(this.Root)
                    }
                } catch Error as err {
                    OutValue := err
                    return 2
                }
            case 5:
                OutValue := this.Value
        }
    }

    /**
     * @description - Calls `PropsInfo.Prototype.GetOwner` to retrieve the owner of the property that
     * produced this `PropsInfoItem` object, then calls `Object.Prototype.GetOwnPropDesc` and updates
     * this `PropsInfoItem` object according to the return value, replacing or removing the existing
     * properties as needed.
     *
     * If the property is "Base", calls `this.DefineProp('Value', { Value: Owner })` and returns `5`.
     * @returns {Integer} - The kind index, which indicates the kind of property. They are:
     * - 1: Callable property
     * - 2: Dynamic property with only a getter
     * - 3: Dynamic property with both a getter and setter
     * - 4: Dynamic property with only a setter
     * - 5: Value property
     *
     * If the object returned by `PropsInfoItem.Prototype.GetOwner` no longer owns a property by
     * the name `InfoItem.Name`, then `PropsInfoItem.Prototype.Refresh` returns 0. You can call
     * `PropsInfo.Prototype.RefreshProp` to adjust the collection to reflect the objects' current
     * state.
     */
    Refresh() {
        if !(Owner := this.Owner) {
            return 0
        }
        if this.Name = 'Base' {
            this.DefineProp('Value', { Value: Owner })
            return 5
        }
        desc := Owner.GetOwnPropDesc(this.Name)
        n := 0
        KindIndex := this.KindIndex
        for Prop, Val in desc.OwnProps() {
            if this.HasOwnProp(Prop) {
                n++
            }
            this.DefineProp(Prop, { Value: Val })
        }
        switch KindIndex {
            case 1,2,4,5:
                ; The type of property changed
                if !n {
                    this.DeleteProp(this.Type)
                }
            case 3:
                ; One of the accessors no longer exists
                if n == 1 {
                    if desc.HasOwnProp('Get') {
                        this.DeleteProp('Set')
                    } else {
                        this.DeleteProp('Get')
                    }
                ; The type of property changed
                } else if !n {
                    this.DeleteProp('Get')
                    this.DeleteProp('Set')
                }
        }
        return this.__DefineKindIndex()
    }

    /**
     * Returns the owner of the property which produced this `PropsInfoItem` object.
     * @memberof PropsInfoItem
     * @instance
     */
    Owner => this.GetOwner()
    /**
     * A string representation of the kind of property which produced this `PropsInfoItem` object.
     * The possible values are:
     * - Call
     * - Get
     * - Get_Set
     * - Set
     * - Value
     * @memberof PropsInfoItem
     * @instance
     */
    Kind => this.__KindNames[this.KindIndex]
    /**
     * An integer that indicates the kind of property which produced this `PropsInfoItem` object.
     * The possible values are:
     * - 1: Callable property
     * - 2: Dynamic property with only a getter
     * - 3: Dynamic property with both a getter and setter
     * - 4: Dynamic property with only a setter
     * - 5: Value property
     * @memberof PropsInfoItem
     * @instance
     */
    KindIndex => this.__DefineKindIndex()

    /**
     * @description - The first time `KindIndex` is accessed, evaluates the object to determine
     * the property kind, then overrides `KindIndex`.
     */
    __DefineKindIndex() {
        ; Override with a value property so this is only processed once
        if this.HasOwnProp('Call') {
            this.DefineProp('KindIndex', { Value: 1 })
        } else if this.HasOwnProp('Get') {
            if this.HasOwnProp('Set') {
                this.DefineProp('KindIndex', { Value: 3 })
            } else {
                this.DefineProp('KindIndex', { Value: 2 })
            }
        } else if this.HasOwnProp('Set') {
            this.DefineProp('KindIndex', { Value: 4 })
        } else if this.HasOwnProp('Value') {
            this.DefineProp('KindIndex', { Value: 5 })
        } else {
            throw Error('Unable to process an unexpected value.', -1)
        }
        return this.KindIndex
    }
    /**
     * @description - The first time `PropsInfoItem.Prototype.__SetAlt` is called, it sets the `Alt`
     * property with an array, then overrides `__SetAlt` to a function which just add items to the
     * array.
     */
    __SetAlt(Item) {
        /**
         * An array of `PropsInfoItem` objects, each sharing the same name. The property associated
         * with the `PropsInfoItem` object that has the `Alt` property is the property owned by
         * or inherited by the object passed to the `GetPropsInfo` function call. Exactly zero of
         * the `PropsInfoItem` objects contained within the `Alt` array will have an `Alt` property.
         * The below example illustrates this concept but expressed in code:
         * @example
         * Obj := [1, 2]
         * OutputDebug('`n' A_LineNumber ': ' Obj.Length) ; 2
         * ; Ordinarily when we access the `Length` property from an array
         * ; instance, the `Array.Prototype.Length.Get` function is called.
         * OutputDebug('`n' A_LineNumber ': ' Obj.Base.GetOwnPropDesc('Length').Get.Name) ; Array.Prototype.Length.Get
         * ; We override the property for some reason.
         * Obj.DefineProp('Length', { Value: 'Arbitrary' })
         * OutputDebug('`n' A_LineNumber ': ' Obj.Length) ; Arbitrary
         * ; GetPropsInfo
         * PropsInfoObj := GetPropsInfo(Obj)
         * ; Get the `PropsInfoItem` for "Length".
         * InfoItem_Length := PropsInfoObj.Get('Length')
         * if code := InfoItem_Length.GetValue(&Value) {
         *     throw Error('GetValue failed.', -1, 'Code: ' code)
         * } else {
         *     OutputDebug('`n' A_LineNumber ': ' Value) ; Arbitrary
         * }
         * ; Checking if the property was overridden (we already know
         * ; it was, but just for example)
         * OutputDebug('`n' A_LineNumber ': ' InfoItem_Length.Count) ; 2
         * OutputDebug('`n' A_LineNumber ': ' (InfoItem_Length.HasOwnProp('Alt'))) ; 1
         * InfoItem_Length_Alt := InfoItem_Length.Alt[1]
         * ; Calling `GetValue()` below returns the true length because
         * ; `Obj` is passed to `Array.Prototype.Length.Get`, producing
         * ; the same result as `Obj.Length` if we never overrode the
         * ; property.
         * if code := InfoItem_Length_Alt.GetValue(&Value) {
         *     throw Error('GetValue failed.', -1, 'Code: ' code)
         * } else {
         *     OutputDebug('`n' A_LineNumber ': ' Value) ; 2
         * }
         * ; The objects nested in the `Alt` array never have an `Alt`
         * ; property, but have the other properties.
         * OutputDebug('`n' A_LineNumber ': ' (InfoItem_Length_Alt.HasOwnProp('Alt'))) ; 0
         * OutputDebug('`n' A_LineNumber ': ' InfoItem_Length_Alt.Count) ; 2
         * OutputDebug('`n' A_LineNumber ': ' InfoItem_Length_Alt.Name) ; Length
         * @instance
         */
        if this.HasOwnProp('Alt') {
            this.Alt.Push(Item)
        } else {
            this.Alt := [ Item ]
        }
    }
}

/*
    Github: https://github.com/Nich-Cebolla/StringifyAll
    Author: Nich-Cebolla
    Version: 1.3.0
    License: MIT
*/

/*
    Github: https://github.com/Nich-Cebolla/StringifyAll
    Author: Nich-Cebolla
    Version: 1.3.1
    License: MIT
*/

#include *i <ConfigLibrary>

/**
 * @description - A customizable solution for serializing an object's properties, including inherited
 * properties, and/or items into a 100% valid JSON string. See the documentation for full details.
 *
 * `StringifyAll` exposes many options to programmatically restrict what gets included in the JSON
 * string. It also includes options for adjusting the spacing in the string. To set your options, you
 * can:
 * - Copy "templates\StringifyAllConfigTemplate.ahk" into your project directory and set the options
 * using the template.
 * - Prepare the `ConfigLibrary` class and reference the configuration by name. See the file
 * "templates\ConfigLibrary.ahk".
 * - Define a class `StringifyAllConfig` anywhere in your code.
 * - Pass an object to the `Options` parameter.
 *
 * The options defined by the `Options` parameter supercede options defined by the `StringifyConfig`
 * class. This is convenient for setting your own defaults based on your personal preferences /
 * project needs using the class object, and then passing an object to the `Options` parameter to
 * adjust your defaults on-the-fly.
 *
 * Note that these are short descriptions of the options. For complete details about the options,
 * see the documentation "README.md".
 *
 * @param {*} Obj - The object to stringify.
 *
 * @param {Object|String} [Options] - If you are using `ConfigLibrary, the name of the configuration.
 * Or, the options object with zero or more of the following properties.
 *
 * ## Options
 *
 * ### Enum options -------------
 *
 * @param {*} [Options.EnumTypeMap = Map('Array', 1, 'Map', 2, 'RegExMatchInfo', 2) ] -
 * `Options.EnumTypeMap` controls which objects have `__Enum` called, and if it is called in 1-param
 * mode or 2-param mode.
 *
 * @param {Boolean} [Options.ExcludeMethods = true ] - If true, properties with a `Call`
 * accessor and properties with only a `Set` accessor are excluded from stringification.
 *
 * @param {String} [Options.ExcludeProps = '' ] - A comma-delimited, case-insensitive list of
 * property names to exclude from stringification. Also see `Options.Filter` and
 * `Options.FilterTypeMap`.
 *
 * @param {*} [Options.FilterTypeMap = '' ] - `Options.FilterTypeMap` controls the filter applied to
 * the `PropsInfo` objects, if any.
 *
 * @param {Integer} [Options.MaxDepth = 0 ] - The maximum depth `StringifyAll` will recurse
 * into. The root depth is 1. Note "depth" and "indent level" do not necessarily line up.
 *
 * @param {Boolean} [Options.Multiple = false ] - When true, there is no limit to how many times
 * `StringifyAll` will process an object. Each time an individual object is encountered, it will
 * be processed unless doing so will result in infinite recursion. When false, `StringifyAll`
 * processes each individual object a maximum of 1 time, and all other encounters result in
 * `StringifyAll` printing a placeholder string that is a string representation of the object path
 * at which the object was first encountered.
 *
 * @param {*} [Options.PropsTypeMap = 1 ] - `Options.PropsTypeMap` controls which objects have
 * their properties iterated and written to the JSON string.
 *
 * @param {*} [Options.StopAtTypeMap = "-Object" ] - `Options.StopAtTypeMap` controls the value
 * that is passed to the `StopAt` parameter of `GetPropsInfo`.
 *
 * ### Callbacks ----------------
 *
 * @param {*} [Options.CallbackError = '' ] - A function or callable object that is called when `StringifyAll`
 * encounters an error when attempting to access the value of a property.
 *
 * @param {*} [Options.CallbackGeneral = '' ] - A function or callable object, or an array of
 * one or more functions or callable objects, that will be called for each object prior to processing.
 *
 * @param {*} [Options.CallbackPlaceholder = '' ] - When `StringifyAll` skips processing an
 * object, a placeholder is printed instead. You can define `Options.CallbackPlaceholder`
 * with any callable object to customize the string that gets printed.
 *
 * ### Newline and indent options
 *
 * @param {Integer} [Options.CondenseCharLimit = 0 ]
 * @param {Integer} [Options.CondenseCharLimitEnum1 = 0 ]
 * @param {Integer} [Options.CondenseCharLimitEnum2 = 0 ]
 * @param {Integer} [Options.CondenseCharLimitEnum2Item = 0 ]
 * @param {Integer} [Options.CondenseCharLimitProps = 0 ] -
 * Sets a threshold which `StringifyAll` uses to determine whether an object's JSON substring should
 * be condensed to a single line as a function of the character length of the substring.
 *
 * @param {Boolean} [Options.CondenseDepthThreshold = 0
 * @param {Integer} [Options.CondenseDepthThresholdEnum1 = 0 ]
 * @param {Integer} [Options.CondenseDepthThresholdEnum2 = 0 ]
 * @param {Integer} [Options.CondenseDepthThresholdEnum2Item = 0 ]
 * @param {Integer} [Options.CondenseDepthThresholdProps = 0 ] -
 * If any of the `Options.CondenseCharLimit` options are in use, the `Options.CondenseDepthThreshold`
 * options set a depth requirement to apply the option. For example, if
 * `Options.CondenseDepthThreshold == 2`, all `Options.CondenseCharLimit` options will only be
 * applied if the current depth is 2 or more; values at the root depth (1) will be processed without
 * applying the `Options.CondenseCharLimit` option.
 *
 * @param {String} [Options.Indent = '`s`s`s`s' ] - The literal string that will be used for one level
 * of indentation. Note that the first line with the opening brace is not indented.
 *
 * @param {String} [Options.InitialIndent = 0 ] - The initial indent level.
 *
 * @param {String} [Options.Newline = '`r`n' ] - The literal string that will be used for line
 * breaks. If set to zero or an empty string, the `Options.Singleline` option is effectively
 * enabled.
 *
 * @param {Integer} [Options.NewlineDepthLimit = 0 ] - Sets a threshold directing `StringifyAll`
 * to stop adding line breaks between values after exceeding the threshold.
 *
 * @param {Boolean} [Options.Singleline = false ] - If true, the JSON string is printed without
 * line breaks or indentation. All other "Newline and indent options" are ignored.
 *
 * ### Print options ------------
 *
 * @param {Number|String} [Options.CorrectFloatingPoint = false] - If nonzero, `StringifyAll` will
 * round numbers that appear to be effected by the floating point precision issue described in
 * {@link https://www.autohotkey.com/docs/v2/Concepts.htm#float-imprecision AHK's documentation}.
 * This process is facilitated by a regex pattern that attempts to identify these occurrences.
 * If `Options.CorrectFloatingPoint` is a nonzero number, `StringifyAll` will use the built-in
 * default pattern "JS)(?<round>(?:0{3,}|9{3,})\d)$". You can also set `Options.CorrectFloatingPoint`
 * with your own regex pattern as a string and `StringifyAll` will use that pattern. See the
 * documentation for details about this options.
 *
 * If `Options.CorrectFloatingPoint` is zero or an empty string, no correction occurs.
 *
 * @param {String} [Options.ItemProp = '__Item__' ] - The name that `StringifyAll` will use as a
 * faux-property for including an object's items returned by its enumerator.
 *
 * @param {Boolean|String} [Options.PrintErrors = false ] - When `StringifyAll` encounters an error
 * accessing a property's value, `Options.PrintErrors` influences how it is handled. `Options.PrintErrors`
 * is ignored if `Options.CallbackError` is set.
 * - If `Options.PrintErrors` is a string value, it should be a comma-delimited list of `Error` property
 * names to include in the output as the value of the property that caused the error.
 * - If any other nonzero value, `StringifyAll` will print just the "Message" property of the `Error`
 * object in the string.
 * - If zero or an empty string, `StringifyAll` skips the property.
 *
 * @param {Boolean} [Options.QuoteNumericKeys = false ] - When true, and when `StringifyAll` is
 * processing an object's enumerator in 2-param mode, if the value returned to the first parameter
 * (the "key") is numeric, it will be quoted in the JSON string.
 *
 * @param {String} [Options.RootName = '$' ] - Specifies the name of the root object used in the
 * string representation of an object's path when the object is skipped due to already having been
 * stringified.
 *
 * @param {String} [Options.UnsetArrayItem = '""' ] - The string to print for unset array items.
 *
 * ### General options ----------
 *
 * @param {Integer} [Options.InitialPtrListCapacity = 64 ] - `StringifyAll` tracks the ptr
 * addresses of every object it stringifies to prevent infinite recursion. `StringifyAll` will set
 * the initial capacity of the `Map` object used for this purpose to
 * `Options.InitialPtrListCapacity`.
 *
 * @param {Integer} [Options.InitialStrCapacity = 65536 ] - `StringifyAll` calls `VarSetStrCapacity`
 * using `Options.InitialStrCapacity` for the output string during the initialization stage.
 * For the best performance, you can overestimate the approximate length of the string; `StringifyAll`
 * calls `VarSetStrCapacity(&OutStr, -1)` at the end of the function to release any unused memory.
 *
 * ------------------------------
 *
 * @param {VarRef} [OutStr] - A variable that will be set with the JSON string value. The value
 * is also returned as the return value, but for very long strings receiving the string via the
 * `VarRef` will be slightly faster because the string will not need to be copied.
 *
 * @param {Boolean} [SkipOptions = false] - If true, `StringifyAll.Options.Call` is not called. The
 * purpose of this options is to enable the caller to avoid the overhead cost of processing the
 * input options for repeated calls. Note that `Options` must be set with an object that has been
 * returned from `StringifyAll.Options.Call` or must be set with an object that inherits from
 * `StringifyAll.Options.Default`. See the documentation section "Options" for more information.
 *
 * @returns {String}
 */
class TestSort_StringifyAll {

    static Call(Obj, Options?, &OutStr?, SkipOptions := false) {
        if IsSet(Options) {
            if !SkipOptions {
                if IsObject(Options) {
                    Options := this.Options(Options)
                } else {
                    if IsSet(ConfigLibrary) {
                        Options := this.Options(ConfigLibrary(Options))
                    } else {
                        throw Error('``ConfigLibrary`` is not loaded into the project. String options are invalid.', -1)
                    }
                }
            }
        } else {
            Options := this.Options()
        }
        controllerBase := {
            LenContainerEnum: ''
          , LenContainerEnum2Item: ''
          , LenContainerProps: ''
          , PrepareNextProp: _PrepareNextProp1
          , PrepareNextEnum1: _PrepareNextEnum11
          , ProcessProps: (excludeMethods := Options.ExcludeMethods) ? _ProcessProps1 : _ProcessProps2
        }
        objectsToDeleteDefault := []
        objectsToDeleteDefault.Capacity := 4
        controllerBase.DefineProp('Path', { Get: (Self) => Self.PathObj.Call() })
        enumTypeMap := Options.EnumTypeMap
        if IsObject(enumTypeMap) {
            if enumTypeMap is Map {
                if enumTypeMap.Count {
                    if !enumTypeMap.HasOwnProp('Default') {
                        enumTypeMap.Default := 0
                        objectsToDeleteDefault.Push(enumTypeMap)
                    }
                    CheckEnum := _CheckEnum1
                } else {
                    enumTypeMap := enumTypeMap.HasOwnProp('Default') ? enumTypeMap.Default : 0
                    CheckEnum := IsObject(enumTypeMap) ? enumTypeMap : _CheckEnum2
                }
            } else {
                CheckEnum := enumTypeMap
            }
        } else {
            CheckEnum := _CheckEnum2
        }
        excludeProps := Options.ExcludeProps
        maxDepth := Options.MaxDepth > 0 ? Options.MaxDepth : 9223372036854775807
        propsTypeMap := Options.PropsTypeMap
        if IsObject(propsTypeMap) {
            if propsTypeMap is Map {
                if propsTypeMap.Count {
                    if !propsTypeMap.HasOwnProp('Default') {
                        propsTypeMap.Default := 0
                        objectsToDeleteDefault.Push(propsTypeMap)
                    }
                    CheckProps := _CheckProps1
                } else {
                    propsTypeMap := propsTypeMap.HasOwnProp('Default') ? propsTypeMap.Default : 0
                    CheckProps := IsObject(propsTypeMap) ? propsTypeMap : _CheckProps2
                }
            } else {
                CheckProps := propsTypeMap
            }
        } else {
            CheckProps := _CheckProps2
        }
        if filterTypeMap := Options.FilterTypeMap {
            if filterTypeMap is PropsInfo.FilterGroup {
                SetFilter := _SetFilter3
            } else if filterTypeMap is Map {
                if filterTypeMap.Count {
                    if !filterTypeMap.HasOwnProp('Default') {
                        filterTypeMap.Default := 0
                        objectsToDeleteDefault.Push(filterTypeMap)
                    }
                    SetFilter := _SetFilter1
                } else {
                    if filterTypeMap.HasOwnProp('Default') && filterTypeMap.Default {
                        filterTypeMap := filterTypeMap.Default
                        if filterTypeMap is PropsInfo.FilterGroup {
                            SetFilter := _SetFilter3
                        } else if HasMethod(filterTypeMap, 'Call') {
                            SetFilter := _SetFilter2
                        } else {
                            throw ValueError('If ``Options.FilterTypeMap`` is nonzero, it must inherit from ``Map``'
                            ' or must be an object with a "Call" property.', -1)
                        }
                    }
                }
            } else if HasMethod(filterTypeMap, 'Call') {
                SetFilter := _SetFilter2
            } else {
                throw ValueError('If ``Options.FilterTypeMap`` is nonzero, it must inherit from ``Map``'
                ' or must be an object with a "Call" property.', -1)
            }
        }
        stopAtTypeMap := Options.StopAtTypeMap
        if IsSet(SetFilter) {
            if IsObject(stopAtTypeMap) {
                if stopAtTypeMap is Map {
                    if stopAtTypeMap.Count {
                        if !stopAtTypeMap.HasOwnProp('Default') {
                            stopAtTypeMap.Default := '-Object'
                            objectsToDeleteDefault.Push(stopAtTypeMap)
                        }
                        _GetPropsInfo := _GetPropsInfo1
                    } else {
                        stopAtTypeMap := stopAtTypeMap.HasOwnProp('Default') ? stopAtTypeMap.Default : '-Object'
                        _GetPropsInfo := IsObject(stopAtTypeMap) ? _GetPropsInfo2 : _GetPropsInfo3
                    }
                } else {
                    _GetPropsInfo := _GetPropsInfo2
                }
            } else {
                _GetPropsInfo := _GetPropsInfo3
            }
        } else {
            if IsObject(stopAtTypeMap) {
                if stopAtTypeMap is Map {
                    if stopAtTypeMap.Count {
                        if !stopAtTypeMap.HasOwnProp('Default') {
                            stopAtTypeMap.Default := '-Object'
                            flag_deleteStopAtTypeMapDefault := true
                        }
                        _GetPropsInfo := _GetPropsInfo4
                    } else {
                        stopAtTypeMap := stopAtTypeMap.HasOwnProp('Default') ? stopAtTypeMap.Default : '-Object'
                        _GetPropsInfo := IsObject(stopAtTypeMap) ? _GetPropsInfo5 : _GetPropsInfo6
                    }
                } else {
                    _GetPropsInfo := _GetPropsInfo5
                }
            } else {
                _GetPropsInfo := _GetPropsInfo6
            }
        }
        HandleMultiple := Options.Multiple ? _HandleMultiple : (*) => 1
        if Options.CallbackError {
            HandleError := Options.CallbackError
        } else if printErrors := Options.PrintErrors {
            if IsNumber(printErrors) {
                HandleError := _HandleError1
            } else {
                HandleError := _HandleError2
            }
        } else {
            HandleError := _HandleError3
        }
        if Options.CallbackGeneral {
            if Options.CallbackGeneral is Array {
                CallbackGeneral := Options.CallbackGeneral
            } else {
                CallbackGeneral := [Options.CallbackGeneral]
            }
            HandleProp := _HandleProp2
            HandleEnum1 := _HandleEnum12
            HandleEnum2 := _HandleEnum22
        } else {
            HandleProp := _HandleProp1
            HandleEnum1 := _HandleEnum11
            HandleEnum2 := _HandleEnum21
        }
        GetPlaceholder := Options.CallbackPlaceholder ? Options.CallbackPlaceholder : _GetPlaceholder
        itemProp := Options.ItemProp
        quoteNumericKeys := Options.QuoteNumericKeys
        unsetArrayItem := Options.UnsetArrayItem
        if Options.CorrectFloatingPoint {
            GetVal := _GetVal2
            if IsNumber(Options.CorrectFloatingPoint) {
                pattern_correctFloatingPoint := 'JS)(?<round>(?:0{3,}|9{3,})\d)$'
            } else {
                pattern_correctFloatingPoint := Options.CorrectFloatingPoint
            }
        } else {
            GetVal := _GetVal1
        }

        Recurse := _Recurse1
        OutStr := ''
        VarSetStrCapacity(&OutStr, Options.InitialStrCapacity)
        depth := 0

        if Options.SingleLine || !Options.Newline {
            singleLineActive := 1
            nl := _nl2
            ind := _ind2
            controllerBase.OpenProps := _OpenProps3
            controllerBase.OpenEnum1 := _OpenEnum13
            controllerBase.OpenEnum2 := _OpenEnum23
            controllerBase.CloseProps := _CloseProps1
            controllerBase.CloseEnum1 := _CloseEnum11
            controllerBase.CloseEnum2 := _CloseEnum21
            controllerBase.PrepareNextEnum2 := _PrepareNextEnum21
            controllerBase.ProcessEnum2 := _ProcessEnum21
            IncDepth := _IncDepth2
        } else {
            ; Newline / indent options
            CondenseCharLimitEnum1 := Options.CondenseCharLimitEnum1 || Options.CondenseCharLimit
            CondenseCharLimitEnum2 := Options.CondenseCharLimitEnum2 || Options.CondenseCharLimit
            CondenseCharLimitEnum2Item := Options.CondenseCharLimitEnum2Item || Options.CondenseCharLimit
            CondenseCharLimitProps := Options.CondenseCharLimitProps || Options.CondenseCharLimit
            if Options.newlineDepthLimit > 0 {
                newlineDepthLimit := Options.NewlineDepthLimit
                IncDepth := _IncDepth1
            } else {
                IncDepth := _IncDepth2
            }
            newlineCount := whitespaceChars := singleLineActive := 0
            indent := [Options.Indent]
            indent.Capacity := Options.MaxDepth ? Options.MaxDepth + 1 : 16
            nlStr := Options.Newline
            newlineLen := StrLen(nlStr)
            indentlevel := Options.InitialIndent
            nl := _nl1
            ind := _ind1
            if CondenseCharLimitEnum1 > 0 {
                CondenseDepthThresholdEnum1 := Options.CondenseDepthThresholdEnum1 || Options.CondenseDepthThreshold
                if CondenseDepthThresholdEnum1 > 0 {
                    controllerBase.OpenEnum1 := _OpenEnum14
                } else {
                    controllerBase.OpenEnum1 := _OpenEnum12
                }
                controllerBase.CloseEnum1 := _CloseEnum12
            } else {
                controllerBase.OpenEnum1 := _OpenEnum11
                controllerBase.CloseEnum1 := _CloseEnum11
            }
            if CondenseCharLimitEnum2 > 0 {
                CondenseDepthThresholdEnum2 := Options.CondenseDepthThresholdEnum2 || Options.CondenseDepthThreshold
                if CondenseDepthThresholdEnum2 > 0 {
                    controllerBase.OpenEnum2 := _OpenEnum24
                } else {
                    controllerBase.OpenEnum2 := _OpenEnum22
                }
                controllerBase.CloseEnum2 := _CloseEnum22
            } else {
                controllerBase.OpenEnum2 := _OpenEnum21
                controllerBase.CloseEnum2 := _CloseEnum21
            }
            if CondenseCharLimitEnum2Item > 0 {
                CondenseDepthThresholdEnum2Item := Options.CondenseDepthThresholdEnum2Item || Options.CondenseDepthThreshold
                if CondenseDepthThresholdEnum2Item > 0 {
                    controllerBase.PrepareNextEnum2 := _PrepareNextEnum25
                } else {
                    controllerBase.PrepareNextEnum2 := _PrepareNextEnum23
                }
                controllerBase.ProcessEnum2 := _ProcessEnum22
            } else {
                controllerBase.PrepareNextEnum2 := _PrepareNextEnum21
                controllerBase.ProcessEnum2 := _ProcessEnum21
            }
            if CondenseCharLimitProps > 0 {
                CondenseDepthThresholdProps := Options.CondenseDepthThresholdProps || Options.CondenseDepthThreshold
                if CondenseDepthThresholdProps > 0 {
                    controllerBase.OpenProps := _OpenProps4
                } else {
                    controllerBase.OpenProps := _OpenProps2
                }
                controllerBase.CloseProps := _CloseProps2
            } else {
                controllerBase.OpenProps := _OpenProps1
                controllerBase.CloseProps := _CloseProps1
            }
        }

        GetController := ClassFactory(controllerBase)
        controller := GetController()
        controller.PathObj := TestSort_StringifyAll.Path(Options.RootName)
        ptrList := Map(ObjPtr(Obj), [controller])
        ptrList.Capacity := Options.InitialPtrListCapacity

        Recurse(controller, Obj, &OutStr)

        VarSetStrCapacity(&OutStr, -1)
        for o in objectsToDeleteDefault {
            o.DeleteProp('Default')
        }

        return OutStr

        _Recurse1(controller, Obj, &OutStr) {
            IncDepth(1)
            controller.Obj := Obj
            flag_enum := HasMethod(Obj, '__Enum') ? CheckEnum(Obj) : 0
            if flag_props := CheckProps(Obj) {
                PropsInfoObj := _GetPropsInfo(Obj)
                flag_props := PropsInfoObj.Count
            }
            if flag_props {
                controller.OpenProps(&OutStr)
                controller.ProcessProps(Obj, PropsInfoObj, &OutStr)
                if flag_enum == 1 {
                    OutStr .= ',' nl() ind() '"' itemProp '": '
                    controller.OpenEnum1(&OutStr)
                    controller.CloseEnum1(_ProcessEnum1(controller, Obj, &OutStr), &OutStr)
                } else if flag_enum == 2 {
                    OutStr .= ',' nl() ind() '"' itemProp '": '
                    controller.OpenEnum2(&OutStr)
                    controller.CloseEnum2(controller.ProcessEnum2(Obj, &OutStr), &OutStr)
                } else if flag_enum {
                    throw Error('Invalid return value from ``Options.EnumTypeMap``.', -1, flag_enum)
                }
                controller.CloseProps(&OutStr)
            } else if flag_enum == 1 {
                controller.OpenEnum1(&OutStr)
                controller.CloseEnum1(_ProcessEnum1(controller, Obj, &OutStr), &OutStr)
            } else if flag_enum == 2 {
                controller.OpenEnum2(&OutStr)
                controller.CloseEnum2(controller.ProcessEnum2(Obj, &OutStr), &OutStr)
            } else if flag_enum {
                throw Error('Invalid return value from ``Options.EnumTypeMap``.', -1, flag_enum)
            }else {
                OutStr .= '{}'
            }
            if IsSet(PropsInfoObj) {
                PropsInfoObj.Dispose()
                PropsInfoObj := unset
            }
            IncDepth(-1)
        }
        _CheckEnum1(Obj) {
            if IsObject(Item := enumTypeMap.Get(Type(Obj))) {
                return Item(Obj)
            } else {
                return Item
            }
        }
        _CheckEnum2(*) {
            return enumTypeMap
        }
        _CheckProps1(Obj) {
            if IsObject(Item := propsTypeMap.Get(Type(Obj))) {
                return Item(Obj)
            } else {
                return Item
            }
        }
        _CheckProps2(*) {
            return propsTypeMap
        }
        _CloseEnum11(controller, count, &OutStr) {
            indentLevel--
            if count {
                OutStr .= nl() ind() ']'
            } else {
                OutStr .= ']'
            }
        }
        _CloseEnum12(controller, count, &OutStr) {
            indentLevel--
            if count {
                OutStr .= nl() ind() ']'
                if container := controller.LenContainerEnum {
                    if StrLen(OutStr) - container.Len - (diff := whitespaceChars - container.whitespaceChars) <= condenseCharLimitEnum1 {
                        whitespaceChars -= diff
                        OutStr := RegExReplace(OutStr, '\R *(?!$)', '', , , container.len || 1)
                    }
                }
            } else {
                OutStr .= ']'
            }
        }
        _CloseEnum21(controller, count, &OutStr) {
            indentLevel--
            if count {
                OutStr .= nl() ind() ']'
            } else {
                OutStr .= '[]]'
            }
        }
        _CloseEnum22(controller, count, &OutStr) {
            indentLevel--
            if count {
                OutStr .= nl() ind() ']'
                if container := controller.LenContainerEnum {
                    if StrLen(OutStr) - container.Len - (diff := whitespaceChars - container.whitespaceChars) <= condenseCharLimitEnum2 {
                        whitespaceChars -= diff
                        OutStr := RegExReplace(OutStr, '\R *(?!$)', '', , , container.len || 1)
                    }
                }
            } else {
                OutStr .= '[]]'
            }
        }
        _CloseProps1(controller, &OutStr) {
            indentLevel--
            OutStr .= nl() ind() '}'
        }
        _CloseProps2(controller, &OutStr) {
            indentLevel--
            OutStr .= nl() ind() '}'
            if container := controller.LenContainerProps {
                if StrLen(OutStr) - container.Len - (diff := whitespaceChars - container.whitespaceChars) <= condenseCharLimitProps {
                    whitespaceChars -= diff
                    OutStr := RegExReplace(OutStr, '\R *(?!$)', '', , , container.len || 1)
                }
            }
        }
        _GetPlaceholder(PathObj, Val, *) {
            return '"{ ' this.GetType(Val) ':' ObjPtr(Val) ' }"'
        }
        _GetPropsInfo1(Obj) {
            if IsObject(Item := stopAtTypeMap.Get(Type(Obj))) {
                pi := GetPropsInfo(Obj, Item(Obj), excludeProps, false, , excludeMethods)
            } else {
                pi := GetPropsInfo(Obj, Item, excludeProps, false, , excludeMethods)
            }
            SetFilter(Obj, pi)
            return pi
        }
        _GetPropsInfo2(Obj) {
            pi := GetPropsInfo(Obj, stopAtTypeMap(Obj), excludeProps, false, , excludeMethods)
            SetFilter(Obj, pi)
            return pi
        }
        _GetPropsInfo3(Obj) {
            pi := GetPropsInfo(Obj, stopAtTypeMap, excludeProps, false, , excludeMethods)
            SetFilter(Obj, pi)
            return pi
        }
        _GetPropsInfo4(Obj) {
            if IsObject(Item := stopAtTypeMap.Get(Type(Obj))) {
                return GetPropsInfo(Obj, Item(Obj), excludeProps, false, , excludeMethods)
            } else {
                return GetPropsInfo(Obj, Item, excludeProps, false, , excludeMethods)
            }
        }
        _GetPropsInfo5(Obj) {
            return GetPropsInfo(Obj, stopAtTypeMap(Obj), excludeProps, false, , excludeMethods)
        }
        _GetPropsInfo6(Obj) {
            return GetPropsInfo(Obj, stopAtTypeMap, excludeProps, false, , excludeMethods)
        }
        _GetVal1(&Val, flag_quote_number := false) {
            if IsNumber(Val) {
                if flag_quote_number {
                    Val := '"' Val '"'
                }
            } else {
                Val := '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(Val, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
            }
        }
        _GetVal2(&Val, flag_quote_number := false) {
            if IsNumber(Val) {
                if flag_quote_number {
                    if InStr(Val, '.') && RegExMatch(Val, pattern_correctFloatingPoint, &matchNum) {
                        Val := '"' Round(Val, StrLen(Val) - InStr(Val, '.') - matchNum.Len['round']) '"'
                    } else {
                        Val := '"' Val '"'
                    }
                } else {
                    if InStr(Val, '.') && RegExMatch(Val, pattern_correctFloatingPoint, &matchNum) {
                        Val := Round(Val, StrLen(Val) - InStr(Val, '.') - matchNum.Len['round'])
                    } else {
                        Val := Val
                    }
                }
            } else {
                Val := '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(Val, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
            }
        }
        _HandleEnum11(controller, Val, &Key, &OutStr) {
            controller.PrepareNextEnum1(&OutStr)
            if ptrList.Has(ptr := ObjPtr(Val)) {
                if HandleMultiple(controller.PathObj, Val) {
                    OutStr .= '"{ ' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(ptrList.Get(ptr)[1].PathObj.Unescaped(), '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') ' }"'
                } else {
                    newController := GetController()
                    newController.PathObj := controller.PathObj.MakeItem(&Key)
                    ptrList.Get(ptr).Push(newController)
                    Recurse(newController, Val, &OutStr)
                }
            } else if depth >= maxDepth || Val is ComObject || Val is ComValue {
                OutStr .= GetPlaceholder(controller.PathObj, Val, , &Key)
            } else {
                newController := GetController()
                newController.PathObj := controller.PathObj.MakeItem(&Key)
                ptrList.Set(ptr, [newController])
                Recurse(newController, Val, &OutStr)
            }
        }
        _HandleEnum12(controller, Val, &Key, &OutStr) {
            if ptrList.Has(ptr := ObjPtr(Val)) {
                if HandleMultiple(controller.PathObj, Val) {
                    controller.PrepareNextEnum1(&OutStr)
                    OutStr .= '"{ ' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(ptrList.Get(ptr)[1].PathObj.Unescaped(), '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') ' }"'
                    return
                }
            } else if depth >= maxDepth || Val is ComObject || Val is ComValue {
                controller.PrepareNextEnum1(&OutStr)
                OutStr .= GetPlaceholder(controller.PathObj, Val, , &Key)
                return
            }
            for cb in CallbackGeneral {
                if result := cb(controller.PathObj, Val, &OutStr, , key) {
                    if result is String {
                        controller.PrepareNextEnum1(&OutStr)
                        OutStr .= result
                    } else if result !== -1 {
                        controller.PrepareNextEnum1(&OutStr)
                        OutStr .= GetPlaceholder(controller.PathObj, Val, , &Key)
                    }
                    return
                }
            }
            newController := GetController()
            newController.PathObj := controller.PathObj.MakeItem(&Key)
            if ptrList.Has(ptr) {
                ptrList.Get(ptr).Push(newController)
            } else {
                ptrList.Set(ptr, [newController])
            }
            controller.PrepareNextEnum1(&OutStr)
            Recurse(newController, Val, &OutStr)
        }
        _HandleEnum21(controller, Val, &Key, &OutStr) {
            controller.PrepareNextEnum2(&OutStr)
            if ptrList.Has(ptr := ObjPtr(Val)) {
                if HandleMultiple(controller.PathObj, Val) {
                    GetVal(&Key, quoteNumericKeys)
                    OutStr .= Key ',' nl() ind() '"{ ' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(ptrList.Get(ptr)[1].PathObj.Unescaped(), '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') ' }"'
                } else {
                    newController := GetController()
                    newController.PathObj := controller.PathObj.MakeItem(&Key)
                    ptrList.Get(ptr).Push(newController)
                    GetVal(&Key, quoteNumericKeys)
                    OutStr .= Key ',' nl() ind()
                    Recurse(newController, Val, &OutStr)
                }
            } else if depth >= maxDepth || Val is ComObject || Val is ComValue {
                placeholder := GetPlaceholder(controller.PathObj, Val, , &Key)
                GetVal(&Key, quoteNumericKeys)
                OutStr .= Key ',' nl() ind() placeholder
            } else {
                newController := GetController()
                newController.PathObj := controller.PathObj.MakeItem(&Key)
                ptrList.Set(ptr, [newController])
                GetVal(&Key, quoteNumericKeys)
                OutStr .= Key ',' nl() ind()
                Recurse(newController, Val, &OutStr)
            }
        }
        _HandleEnum22(controller, Val, &Key, &OutStr) {
            if ptrList.Has(ptr := ObjPtr(Val)) {
                if HandleMultiple(controller.PathObj, Val) {
                    controller.PrepareNextEnum2(&OutStr)
                    GetVal(&Key, quoteNumericKeys)
                    OutStr .= Key ',' nl() ind() '"{ ' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(ptrList.Get(ptr)[1].PathObj.Unescaped(), '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') ' }"'
                    return
                }
            } else if depth >= maxDepth || Val is ComObject || Val is ComValue {
                controller.PrepareNextEnum2(&OutStr)
                placeholder := GetPlaceholder(controller.PathObj, Val, , &Key)
                GetVal(&Key, quoteNumericKeys)
                OutStr .= Key ',' nl() ind() placeholder
                return
            }
            for cb in CallbackGeneral {
                if result := cb(controller.PathObj, Val, &OutStr, , key) {
                    if result is String {
                        controller.PrepareNextEnum2(&OutStr)
                        GetVal(&Key, quoteNumericKeys)
                        OutStr .= Key ',' nl() ind() result
                    } else if result !== -1 {
                        controller.PrepareNextEnum2(&OutStr)
                        placeholder := GetPlaceholder(controller.PathObj, Val, , &Key)
                        GetVal(&Key, quoteNumericKeys)
                        OutStr .= Key ',' nl() ind() placeholder
                    }
                    return
                }
            }
            controller.PrepareNextEnum2(&OutStr)
            newController := GetController()
            newController.PathObj := controller.PathObj.MakeItem(&Key)
            if ptrList.Has(ptr) {
                ptrList.Get(ptr).Push(newController)
            } else {
                ptrList.Set(ptr, [newController])
            }
            GetVal(&Key, quoteNumericKeys)
            OutStr .= Key ',' nl() ind()
            Recurse(newController, Val, &OutStr)
        }
        _HandleError1(PathObj, Err, *) {
            return '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(Err.Message, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
        }
        _HandleError2(PathObj, Err, *) {
            local str := ''
            for s in StrSplit(Options.PrintErrors, ',') {
                if s {
                    str .= s ': ' Err.%s% '; '
                }
            }
            str := SubStr(str, 1, -2)
            return '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(str, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
        }
        _HandleError3(*) {
            return -1
        }
        _HandleMultiple(PathObj, Val) {
            path := '$.' PathObj.Unescaped()
            for c in ptrList.Get(ObjPtr(Val)) {
                if InStr(path, '$.' c.PathObj.Unescaped()) {
                    return 1
                }
            }
        }
        _HandleProp1(controller, Val, &Prop, &OutStr) {
            if ptrList.Has(ptr := ObjPtr(Val)) {
                if HandleMultiple(controller.PathObj, Val) {
                    controller.PrepareNextProp(&OutStr)
                    OutStr .= '"' Prop '": ' '"{ ' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(ptrList.Get(ptr)[1].PathObj.Unescaped(), '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') ' }"'
                    return
                }
            } else if depth >= maxDepth || Val is ComObject || Val is ComValue {
                _WriteProp2(controller, &Prop, GetPlaceholder(controller.PathObj, Val, &Prop), &OutStr)
                return
            }
            controller.PrepareNextProp(&OutStr)
            OutStr .= '"' Prop '": '
            newController := GetController()
            newController.PathObj := controller.PathObj.MakeProp(&Prop)
            if ptrList.Has(ptr) {
                ptrList.Get(ptr).Push(newController)
            } else {
                ptrList.Set(ptr, [newController])
            }
            Recurse(newController, Val, &OutStr)
        }
        _HandleProp2(controller, Val, &Prop, &OutStr) {
            if ptrList.Has(ptr := ObjPtr(Val)) {
                if HandleMultiple(controller.PathObj, Val) {
                    controller.PrepareNextProp(&OutStr)
                    OutStr .= '"' Prop '": ' '"{ ' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(ptrList.Get(ptr)[1].PathObj.Unescaped(), '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') ' }"'
                    return
                }
            } else if depth >= maxDepth || Val is ComObject || Val is ComValue {
                _WriteProp2(controller, &Prop, GetPlaceholder(controller.PathObj, Val, &Prop), &OutStr)
                return
            }
            for cb in CallbackGeneral {
                if result := cb(controller.PathObj, Val, &OutStr, Prop) {
                    if result is String {
                        _WriteProp3(controller, &Prop, &result, &OutStr)
                    } else if result !== -1 {
                        _WriteProp2(controller, &Prop, GetPlaceholder(controller.PathObj, Val, &Prop), &OutStr)
                    }
                    return
                }
            }
            controller.PrepareNextProp(&OutStr)
            OutStr .= '"' Prop '": '
            newController := GetController()
            newController.PathObj := controller.PathObj.MakeProp(&Prop)
            if ptrList.Has(ptr) {
                ptrList.Get(ptr).Push(newController)
            } else {
                ptrList.Set(ptr, [newController])
            }
            Recurse(newController, Val, &OutStr)
        }
        _IncDepth1(delta) {
            _depth := depth
            depth += delta
            if _depth > newlineDepthLimit {
                if depth <= newlineDepthLimit {
                    nl := _nl1
                    ind := _ind1
                }
            } else if _depth <= newlineDepthLimit {
                if depth > newlineDepthLimit {
                    nl := _nl2
                    ind := _ind2
                }
            } else if delta > 0 {
                nl := _nl2
                ind := _ind2
            }
        }
        _IncDepth2(delta) {
            depth += delta
        }
        _ind1() {
            if singleLineActive || !indentLevel {
                return ''
            }
            while indentLevel > indent.Length {
                indent.Push(indent[-1] indent[1])
            }
            whitespaceChars += StrLen(indent[indentLevel])
            return indent[indentLevel]
        }
        _ind2() {
            return ''
        }
        _nl1() {
            if singleLineActive {
                return ''
            }
            whitespaceChars += newlineLen
            newlineCount++
            return nlStr
        }
        _nl2() {
            return ''
        }
        _OpenEnum11(controller, &OutStr) {
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum12(controller, &OutStr) {
            controller.LenContainerEnum := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum13(controller, &OutStr) {
            OutStr .= '['
        }
        _OpenEnum14(controller, &OutStr) {
            if depth >= CondenseDepthThresholdEnum1 {
                controller.LenContainerEnum := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            }
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum21(controller, &OutStr) {
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum22(controller, &OutStr) {
            controller.LenContainerEnum := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum23(controller, &OutStr) {
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum24(controller, &OutStr) {
            if depth >= CondenseDepthThresholdEnum2 {
                controller.LenContainerEnum := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            }
            OutStr .= '['
            indentLevel++
        }
        _OpenProps1(controller, &OutStr) {
            OutStr .= '{'
            indentLevel++
        }
        _OpenProps2(controller, &OutStr) {
            controller.LenContainerProps := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            OutStr .= '{'
            indentLevel++
        }
        _OpenProps3(controller, &OutStr) {
            OutStr .= '{'
        }
        _OpenProps4(controller, &OutStr) {
            if depth >= CondenseDepthThresholdProps {
                controller.LenContainerProps := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            }
            OutStr .= '{'
            indentLevel++
        }
        _PrepareNextEnum11(controller, &OutStr) {
            OutStr .= nl() ind()
            controller.PrepareNextEnum1 := _PrepareNextEnum12
        }
        _PrepareNextEnum12(controller, &OutStr) {
            OutStr .= ',' nl() ind()
        }
        _PrepareNextEnum21(controller, &OutStr) {
            OutStr .= nl() ind() '['
            indentLevel++
            OutStr .= nl() ind()
            controller.PrepareNextEnum2 := _PrepareNextEnum22
        }
        _PrepareNextEnum22(controller, &OutStr) {
            OutStr .= ',' nl() ind() '['
            indentLevel++
            OutStr .= nl() ind()
        }
        _PrepareNextEnum23(controller, &OutStr) {
            OutStr .= nl() ind() '['
            controller.LenContainerEnum2Item := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            indentLevel++
            OutStr .= nl() ind()
            controller.PrepareNextEnum2 := _PrepareNextEnum24
        }
        _PrepareNextEnum24(controller, &OutStr) {
            OutStr .= ',' nl() ind() '['
            controller.LenContainerEnum2Item := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            indentLevel++
            OutStr .= nl() ind()
        }
        _PrepareNextEnum25(controller, &OutStr) {
            OutStr .= nl() ind() '['
            if depth >= CondenseDepthThresholdEnum2Item {
                controller.LenContainerEnum2Item := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            }
            indentLevel++
            OutStr .= nl() ind()
            controller.PrepareNextEnum2 := _PrepareNextEnum26
        }
        _PrepareNextEnum26(controller, &OutStr) {
            OutStr .= ',' nl() ind() '['
            if depth >= CondenseDepthThresholdEnum2Item {
                controller.LenContainerEnum2Item := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            }
            indentLevel++
            OutStr .= nl() ind()
        }
        _PrepareNextProp1(controller, &OutStr) {
            OutStr .= nl() ind()
            controller.PrepareNextProp := _PrepareNextProp2
        }
        _PrepareNextProp2(controller, &OutStr) {
            OutStr .= ',' nl() ind()
        }
        _ProcessEnum1(controller, Obj, &OutStr) {
            count := 0
            for Val in Obj {
                count++
                if IsSet(Val) {
                    if IsObject(Val) {
                        HandleEnum1(controller, Val, &(i := A_Index), &OutStr)
                    } else {
                        controller.PrepareNextEnum1(&OutStr)
                        GetVal(&Val)
                        OutStr .= Val
                    }
                } else {
                    controller.PrepareNextEnum1(&OutStr)
                    OutStr .= unsetArrayItem
                }
            }
            return count
        }
        _ProcessEnum21(controller, Obj, &OutStr) {
            count := 0
            for Key, Val in Obj {
                count++
                if IsObject(Key) {
                    Key := '{ ' this.GetType(Key) ':' ObjPtr(Key) ' }'
                }
                if IsObject(Val) {
                    HandleEnum2(controller, Val, &Key, &OutStr)
                } else {
                    controller.PrepareNextEnum2(&OutStr)
                    GetVal(&Key, quoteNumericKeys)
                    OutStr .= Key ',' nl() ind()
                    GetVal(&Val)
                    OutStr .= Val
                }
                indentLevel--
                OutStr .= nl() ind() ']'
            }
            return count
        }
        _ProcessEnum22(controller, Obj, &OutStr) {
            count := 0
            for Key, Val in Obj {
                count++
                if IsObject(Key) {
                    Key := '{ ' this.GetType(Key) ':' ObjPtr(Key) ' }'
                }
                if IsObject(Val) {
                    HandleEnum2(controller, Val, &Key, &OutStr)
                } else {
                    controller.PrepareNextEnum2(&OutStr)
                    GetVal(&Key, quoteNumericKeys)
                    OutStr .= Key ',' nl() ind()
                    GetVal(&Val)
                    OutStr .= Val
                }
                indentLevel--
                OutStr .= nl() ind() ']'
                if container := controller.LenContainerEnum2Item {
                    if StrLen(OutStr) - container.len - (diff := whitespaceChars - container.whitespaceChars) <= condenseCharLimitEnum2Item {
                        whitespaceChars -= diff
                        OutStr := RegExReplace(OutStr, '\R *(?!$)', '', , , container.len || 1)
                    }
                }
            }
            return count
        }
        ; ExcludeMethod = true
        _ProcessProps1(controller, Obj, PropsInfoObj, &OutStr) {
            for Prop, InfoItem in PropsInfoObj {
                if InfoItem.GetValue(&Val) {
                    if IsSet(Val) {
                        if errorResult := HandleError(controller.PathObj, Val, Obj, InfoItem) {
                            if errorResult is String {
                                _WriteProp3(controller, &Prop, &errorResult, &OutStr)
                            } else if errorResult !== -1 {
                                Val := Val.Message
                                _WriteProp1(controller, &Prop, &Val, &OutStr)
                            }
                            Val := unset
                            continue
                        }
                    } else {
                        continue
                    }
                }
                if IsObject(Val) {
                    HandleProp(controller, Val, &Prop, &OutStr)
                } else {
                    _WriteProp1(controller, &Prop, &Val, &OutStr)
                }
                Val := unset
            }
        }
        ; ExcludeMethod = false
        _ProcessProps2(controller, Obj, PropsInfoObj, &OutStr) {
            for Prop, InfoItem in PropsInfoObj {
                if InfoItem.GetValue(&Val) {
                    if IsSet(Val) {
                        if errorResult := HandleError(controller.PathObj, Val, Obj, InfoItem) {
                            if errorResult is String {
                                _WriteProp3(controller, &Prop, &errorResult, &OutStr)
                            } else if errorResult !== -1 {
                                Val := Val.Message
                                _WriteProp1(controller, &Prop, &Val, &OutStr)
                            }
                            Val := unset
                            continue
                        }
                    } else {
                        Val := '{ ' InfoItem.GetFunc().Name ' }'
                    }
                }
                if IsObject(Val) {
                    HandleProp(controller, Val, &Prop, &OutStr)
                } else {
                    _WriteProp1(controller, &Prop, &Val, &OutStr)
                }
                Val := unset
            }
        }
        _SetFilter1(Obj, pi) {
            if Item := filterTypeMap.Get(Type(Obj)) {
                if HasMethod(Item, 'Call') {
                    if val := Item(Obj) {
                        pi.FilterSet(Val)
                    }
                } else {
                    pi.FilterSet(Item)
                }
            }
        }
        _SetFilter2(Obj, pi) {
            if val := filterTypeMap(Obj) {
                pi.FilterSet(val)
            }
        }
        _SetFilter3(Obj, pi) {
            pi.FilterSet(filterTypeMap)
        }
        _WriteProp1(controller, &Prop, &Val, &OutStr) {
            controller.PrepareNextProp(&OutStr)
            GetVal(&Val)
            OutStr .= '"' Prop '": ' Val
        }
        _WriteProp2(controller, &Prop, Val, &OutStr) {
            controller.PrepareNextProp(&OutStr)
            OutStr .= '"' Prop '": ' Val
        }
        _WriteProp3(controller, &Prop, &Val, &OutStr) {
            controller.PrepareNextProp(&OutStr)
            OutStr .= '"' Prop '": ' Val
        }
    }

    /**
     * @description - The function that produces the default placeholder string for skipped objects.
     * @param {*} Obj - The object being evaluated.
     */
    static GetPlaceholder(Obj) {
        return '"{ ' this.GetType(Obj) ':' ObjPtr(Obj) ' }"'
    }

    /**
     * @description - For use with the output from `TestSort_StringifyAll` to parse the placeholder substrings
     * that are printed due to one of the following conditions:
     * - The object has already been stringified and `Options.Multiple == false`.
     * - Stringifying the object would cause infinite recursion.
     *
     * The placeholder printed by `TestSort_StringifyAll` is in the form: `"{ <Options.RootName><object path> }"`
     * where <object path> is the string representation of the object path in AHK syntax
     * (e.g. ".prop[3].prop[\"key\"][1]").
     *
     * The `RegExMatchInfo` objects in the output array match the entire placeholder, including the
     * exterior quotation marks and curly braces. Two subcapture groups are available:
     * - "root": Matches with just the root name.
     * - "path": Matches with just <object path> as described above.
     *
     * For example, if the placeholder is: "{ $.prop[3].prop[\"key\"][1] }"
     * - Match[0] == '"{ $.prop[3].prop[\"key\"][1] }"'
     * - Match["root"] == "$"
     * - Match["path"] == '.prop[3].prop[\"key\"][1]'
     *
     * If you want to supply a pattern to match with only a subset of the placeholders, just copy
     * the pattern in this code file (in the body of the function) and add on one or more segments
     * of the target path separated by "(?&segment)*". Note you only need to modify the part of the
     * pattern in the "(?<path> ... )" subcapture group, and you will have to replace `RootName` with
     * the actual root name. If you used the default `Options.RootName == "$"`, remember to escape the
     * "$" character.
     *
     * For example, if we want to restrict the function to only match with placeholders that have
     * a property "prop", we could do this:
     * @example
     *  Pattern := (
     *      'S)'
     *      ; This creates a callable subpattern that matches with a quoted string using single quotes,
     *      ; skipping escaped quote characters.
     *      "(?(DEFINE)(?<quote>(?<=\[)'.*?(?<!``)(?:````)*+'))"
     *      ; This creates a callable subpattern that matches with one segment of the object path.
     *      '(?(DEFINE)'
     *          '(?<segment>'
     *              ; This matches with a pair of square brackets, skipping any internally quoted strings so
     *              ; brackets in the string literal don't disrupt the match.
     *              '(?<body>\[((?&quote)|[^"\][]++|(?&body))*\])'
     *          '|'
     *              '\.'
     *              ; This (I believe) is the correct pattern for characters that are valid when used within
     *              ; AHK object property names.
     *              '(?:[\p{L}_0-9]|[^\x00-\x7F\x80-\x9F])+'
     *          ')'
     *      ')'
     *      '"\{ '
     *      ; Escape "$" if you did not change `Options.RootName`.
     *      '(?<root>\$)'
     *      '(?<path>'
     *          ; To allow zero or more segments before to the property "prop"
     *          '(?&segment)*'
     *          '\.prop'
     *          ; To allow zero or more segments after to the property "prop"
     *          '(?&segment)*'
     *      ')'
     *      ' \}"'
     *  )
     * @
     *
     * @param {VarRef} Json - The json string. This is passed by reference to avoid copying the
     * string; the string will not be modified.
     * @param {String} [RootName = "$"] - The value of `Options.RootName` when `TestSort_StringifyAll`
     * produced the json string. If your `RootName` contains characters that must be escaped to be
     * used literally in PCRE RegEx, your code is responsible for escaping those characters.
     * @param {String} [Pattern] - Supply your own pattern to parse the placeholders, for example,
     * to match with only a subset of the placeholder.
     *
     * @returns {Array} - An array of `RegExMatchInfo` objects.
     */
    static GetPlaceholderSubstrings(&Json, RootName := '\$', Pattern?) {
        if !IsSet(Pattern) {
            Pattern := (
                'S)'
                ; This creates a callable subpattern that matches with a quoted string using single
                ; quotes, skipping escaped quote characters.
                "(?(DEFINE)(?<quote>(?<=\[)'.*?(?<!``)(?:````)*+'))"
                ; This creates a callable subpattern that matches with one segment of the object path.
                '(?(DEFINE)'
                    '(?<segment>'
                        ; This matches with a pair of square brackets, skipping any internally quoted
                        ; strings so brackets in the string literal don't disrupt the match.
                        '(?<body>\[((?&quote)|[^"\][]++|(?&body))*\])'
                    '|'
                        '\.'
                        ; This (I believe) is the correct pattern for characters that are valid when
                        ; used within AHK object property names.
                        '(?:[\p{L}_0-9]|[^\x00-\x7F\x80-\x9F])+'
                    ')'
                ')'
                '"\{ '
                '(?<root>\$)'
                '(?<path>(?&segment)+)'
                ' \}"'
            )
        }

        result := []
        result.Capacity := 64
        pos := 1
        while RegExMatch(Json, Pattern, &Match, pos) {
            pos := Match.Pos + Match.Len
            result.Push(Match)
        }
        return result
    }

    /**
     * @description - Returns a string with information about the object's type. There are two
     * details included in the string, separated by a colon. The left side of the string is either
     * "Class", "Prototype", or "Instance". The right side of the string is the name of the class to
     * which the object is associated.
     * @param {*} Obj - Any object.
     * @returns {String}
     */
    static GetType(Obj) {
        if Obj is Class {
            return 'Class:' Obj.Prototype.__Class
        }
        if Type(Obj) == 'Prototype' {
            return 'Prototype:' Obj.__Class
        }
        return 'Instance:' Type(Obj)
    }

    /**
     * @description - Escapes the following with a backslash: tab, carriage return, line feed, double quote, backslash.
     * @param {VarRef} Str - The string to escape.
     * @param {Boolean} [AddQuotes] - If true, the result string is enclosed in double quotes.
     */
    static StrEscapeJson(&Str, AddQuotes := false) {
        if AddQuotes {
            Str := '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(Str, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
        } else {
            Str := StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(Str, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t')
        }
    }

    /**
     * @description - Unescapes the following with a backslash: tab, carriage return, line feed, double quote, backslash.
     * @param {VarRef} Str - The string to unescape.
     */
    static StrUnescapeJson(&Str) {
        n := 0xFFFD
        while InStr(Str, Chr(n)) {
            n++
        }
        Str := StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(Str, '\\', Chr(n)), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), Chr(n), '\')
    }

    class Options {
        static Default := {
            ; Enum options
            EnumTypeMap: Map('Array', 1, 'Map', 2, 'RegExMatchInfo', 2)
          , ExcludeMethods: true
          , ExcludeProps: ''
          , FilterTypeMap: ''
          , MaxDepth: 0
          , Multiple: false
          , PropsTypeMap: 1
          , StopAtTypeMap: '-Object'

            ; Callbacks
          , CallbackError: ''
          , CallbackGeneral: ''
          , CallbackPlaceholder: ''

            ; Newline and indent options
          , CondenseCharLimit: 0
          , CondenseCharLimitEnum1: 0
          , CondenseCharLimitEnum2: 0
          , CondenseCharLimitEnum2Item: 0
          , CondenseCharLimitProps: 0
          , CondenseDepthThreshold: 0
          , CondenseDepthThresholdEnum1: 0
          , CondenseDepthThresholdEnum2: 0
          , CondenseDepthThresholdEnum2Item: 0
          , CondenseDepthThresholdProps: 0
          , Indent: '`s`s`s`s'
          , InitialIndent: 0
          , Newline: '`r`n'
          , NewlineDepthLimit: 0
          , Singleline: false

            ; Print options
          , CorrectFloatingPoint: false
          , ItemProp: '__Items__'
          , PrintErrors: false
          , QuoteNumericKeys: false
          , RootName: '$'
          , UnsetArrayItem: '""'

            ; General options
          , InitialPtrListCapacity: 64
          , InitialStrCapacity: 65536
        }
        static Call(Options?) {
            if IsSet(Options) {
                o := {}
                d := this.Default
                if IsSet(TestSort_StringifyAllConfig) {
                    for prop in d.OwnProps() {
                        if HasProp(Options, prop) {
                            o.%prop% := Options.%prop%
                        } else if HasProp(TestSort_StringifyAllConfig, prop) {
                            o.%prop% := TestSort_StringifyAllConfig.%prop%
                        } else if IsObject(d.%prop%) {
                            o.%prop% := this.ObjDeepClone(d.%prop%)
                        } else {
                            o.%prop% := d.%prop%
                        }
                    }
                } else {
                    for prop in d.OwnProps() {
                        if HasProp(Options, prop) {
                            o.%prop% := Options.%prop%
                        } else if IsObject(d.%prop%) {
                            o.%prop% := this.ObjDeepClone(d.%prop%)
                        } else {
                            o.%prop% := d.%prop%
                        }
                    }
                }
                return o
            } else if IsSet(TestSort_StringifyAllConfig) {
                o := {}
                d := this.Default
                for prop in d.OwnProps() {
                    if HasProp(TestSort_StringifyAllConfig, prop) {
                        o.%prop% := TestSort_StringifyAllConfig.%prop%
                    } else if IsObject(d.%prop%) {
                        o.%prop% := this.ObjDeepClone(d.%prop%)
                    } else {
                        o.%prop% := d.%prop%
                    }
                }
                return o
            } else {
                return this.ObjDeepClone(this.Default)
            }
        }
        static ObjDeepClone(Self, ConstructorParams?, Depth := 0) {
            GetTarget := IsSet(ConstructorParams) ? _GetTarget2 : _GetTarget1
            PtrList := Map(ObjPtr(Self), Result := GetTarget(Self))
            CurrentDepth := 0
            return _Recurse(Result, Self)

            _Recurse(Target, Subject) {
                CurrentDepth++
                for Prop in Subject.OwnProps() {
                    Desc := Subject.GetOwnPropDesc(Prop)
                    if Desc.HasOwnProp('Value') {
                        Target.DefineProp(Prop, { Value: IsObject(Desc.Value) ? _ProcessValue(Desc.Value) : Desc.Value })
                    } else {
                        Target.DefineProp(Prop, Desc)
                    }
                }
                if Target is Array {
                    Target.Length := Subject.Length
                    for item in Subject {
                        if IsSet(item) {
                            Target[A_Index] := IsObject(item) ? _ProcessValue(item) : item
                        }
                    }
                } else if Target is Map {
                    Target.Capacity := Subject.Capacity
                    for Key, Val in Subject {
                        if IsObject(Key) {
                            Target.Set(_ProcessValue(Key), IsObject(Val) ? _ProcessValue(Val) : Val)
                        } else {
                            Target.Set(Key, IsObject(Val) ? _ProcessValue(Val) : Val)
                        }
                    }
                }
                CurrentDepth--
                return Target
            }
            _GetTarget1(Subject) {
                try {
                    Target := GetObjectFromString(Subject.__Class)()
                } catch {
                    if Subject Is Map {
                        Target := Map()
                    } else if Subject is Array {
                        Target := Array()
                    } else {
                        Target := Object()
                    }
                }
                try {
                    ObjSetBase(Target, Subject.Base)
                }
                return Target
            }
            _GetTarget2(Subject) {
                if ConstructorParams.Has(Subject.__Class) {
                    Target := GetObjectFromString(Subject.__Class)(ConstructorParams.Get(Subject.__Class)*)
                } else {
                    try {
                        Target := GetObjectFromString(Subject.__Class)()
                    } catch {
                        if Subject Is Map {
                            Target := Map()
                        } else if Subject is Array {
                            Target := Array()
                        } else {
                            Target := Object()
                        }
                    }
                    try {
                        ObjSetBase(Target, Subject.Base)
                    }
                }
                return Target
            }
            _ProcessValue(Val) {
                if Type(Val) == 'ComValue' || Type(Val) == 'ComObject' {
                    return Val
                }
                if PtrList.Has(ObjPtr(Val)) {
                    return PtrList.Get(ObjPtr(Val))
                }
                if CurrentDepth == Depth {
                    return Val
                } else {
                    PtrList.Set(ObjPtr(Val), _Target := GetTarget(Val))
                    return _Recurse(_Target, Val)
                }
            }

            /**
             * @description -
             * Use this function when you need to convert a string to an object reference, and the object
             * is nested within an object path. For example, we cannot get a reference to the class `Gui.Control`
             * by setting the string in double derefs like this: `obj := %'Gui.Control'%. Instead, we have to
             * traverse the path to get each object along the way, which is what this function does.
             * @param {String} Path - The object path.
             * @returns {*} - The object if it exists in the scope. Else, returns an empty string.
             * @example
             *  class MyClass {
             *      class MyNestedClass {
             *          static MyStaticProp := {prop1_1: 1, prop1_2: {prop2_1: {prop3_1: 'Hello, World!'}}}
             *      }
             *  }
             *  obj := GetObjectFromString('MyClass.MyNestedClass.MyStaticProp.prop1_2.prop2_1')
             *  OutputDebug(obj.prop3_1) ; Hello, World!
             * @
             */
            GetObjectFromString(Path) {
                Split := StrSplit(Path, '.')
                if !IsSet(%Split[1]%)
                    return
                OutObj := %Split[1]%
                i := 1
                while ++i <= Split.Length {
                    if !OutObj.HasOwnProp(Split[i])
                        return
                    OutObj := OutObj.%Split[i]%
                }
                return OutObj
            }
        }
    }

    /**
     * @classdesc - This is a solution for tracking object paths using strings.
     * @example
     *  ; Say we are processing this object and need to keep track of the object path somehow.
     *  Obj := {
     *      Prop1: {
     *          NestedProp1: {
     *              NestedMap: Map(
     *                  'Key1 `r`n"`t``', Map(
     *                      'Key2', 'Val1'
     *                  )
     *              )
     *          }
     *        , NestedProp2: [ 1, 2, { Prop: 'Val' }, 4 ]
     *      }
     *  }
     *  ; Get an instance of `TestSort_StringifyAll.Path`
     *  Root := TestSort_StringifyAll.Path('Obj')
     *  ; Process the properties / items
     *  O1 := Root.MakeProp('Prop1')
     *  O2 := O1.MakeProp('NestedProp1')
     *  O3 := O2.MakeProp('NestedMap')
     *  O4 := O3.MakeItem('Key1 `r`n"`t``')
     *  O5 := O4.MakeItem('Key2')
     *
     *  ; Calling the object produces a path that will apply AHK escape sequences using the backtick as needed.
     *  OutputDebug(O5() '`n') ; Obj.Prop1.NestedProp1.NestedMap["Key1 `r`n`"`t``"]["Key2"]
     *
     *  ; You can start another branch
     *  B1 := O1.MakeProp('NestedProp2')
     *  B2 := B1.MakeItem(3)
     *  B3 := B2.MakeProp('Prop')
     *  OutputDebug(B3() '`n') ; Obj.Prop1.NestedProp2[3].Prop
     *
     *  ; Some operations don't benefit from having the keys escaped. Save processing time by calling
     *  ; the "Unescaped" method.
     *  OutputDebug(O5.Unescaped() '`n')
     *  ; Obj.Prop1.NestedProp1.NestedMap["Key1
     *  ; "	   `"]["Key2"]
     *
     *  ; Normally you would use `TestSort_StringifyAll.Path` in some type of recursive loop.
     *  Recurse(obj, TestSort_StringifyAll.Path('obj'))
     *  Recurse(obj, path) {
     *      OutputDebug(path() '`n')
     *      for p, v in obj.OwnProps() {
     *          if IsObject(v) {
     *              Recurse(v, path.MakeProp(p))
     *          }
     *      }
     *      if HasMethod(obj, '__Enum') {
     *          for k, v in obj {
     *              if IsObject(v) {
     *                  Recurse(v, path.MakeItem(k))
     *              }
     *          }
     *      }
     *  }
     * @
     */
    class Path {
        static InitialBufferSize := 256
        static __New() {
            this.DeleteProp('__New')
            this.hModule := DllCall('LoadLibrary', 'Str', 'msvcrt.dll', 'Ptr')
            this.memmove := DllCall('GetProcAddress', 'Ptr', this.hModule, 'AStr', 'memmove', 'Ptr')
            this.Prototype.DefineProp('propdesc', { Value:this.Prototype.GetOwnPropDesc('__GetPathSegmentProp_U') })
        }
        /**
         * An instance of `TestSort_StringifyAll.Path` should be used as the root object of the path is being constructed.
         * All child segments should be created by calling `TestSort_StringifyAll.Path.Prototype.MakeProp` or
         * `TestSort_StringifyAll.Path.Prototype.MakeItem`.
         *
         * @param {String} [Name = "$"] - The name to assign the object.
         * @param {Boolean} [EscapePropNames = false] - If true, calling `TestSort_StringifyAll.Path.Prototype.Call` will
         * apply AHK escape sequences to property names using the backtick where appropriate. In AHK
         * syntax, there are no characters which have AHK escape sequences that can be used within a
         * property name, and so this should generally be left `false` to save processing time.
         * `TestSort_StringifyAll.Path.Prototype.Unescaped` is unaffected by this option.
         */
        __New(Name := '$', EscapePropNames := false) {
            static desc := TestSort_StringifyAll.Path.Prototype.GetOwnPropDesc('__GetPathSegmentRoot1')
            , desc_u := TestSort_StringifyAll.Path.Prototype.GetOwnPropDesc('__GetPathSegmentRoot_U')
            , propdesc := TestSort_StringifyAll.Path.Prototype.GetOwnPropDesc('__GetPathSegmentProp1')
            this.Name := Name
            this.DefineProp('GetPathSegment', desc)
            this.DefineProp('GetPathSegment_U', desc_u)
            if EscapePropNames {
                this.DefineProp('propdesc', { Value: propdesc })
            }
        }
        Call(*) {
            if !this.HasOwnProp('__Path') {
                o := this
                buf := Buffer(TestSort_StringifyAll.Path.InitialBufferSize)
                offset := TestSort_StringifyAll.Path.InitialBufferSize - 2
                NumPut('ushort', 0, buf, offset) ; null terminator
                loop {
                    if o.GetPathSegment(buf, &offset) {
                        break
                    }
                    o := o.Base
                }
                this.DefineProp('__Path', { Value: StrGet(buf.Ptr + offset) })
            }
            return this.__Path
        }
        MakeProp(&Name) {
            static desc_u := TestSort_StringifyAll.Path.Prototype.GetOwnPropDesc('__GetPathSegmentProp_U')
            ObjSetBase(Segment := { Name: Name }, this)
            Segment.DefineProp('GetPathSegment', this.propdesc)
            Segment.DefineProp('GetPathSegment_U', desc_u)
            return Segment
        }
        MakeItem(&Name) {
            static descNumber := TestSort_StringifyAll.Path.Prototype.GetOwnPropDesc('__GetPathSegmentItem_Number')
            , descString := TestSort_StringifyAll.Path.Prototype.GetOwnPropDesc('__GetPathSegmentItem_String1')
            , descString_u := TestSort_StringifyAll.Path.Prototype.GetOwnPropDesc('__GetPathSegmentItem_String_U1')
            ObjSetBase(Segment := { Name: Name }, this)
            if IsNumber(Name) {
                Segment.DefineProp('GetPathSegment', descNumber)
                Segment.DefineProp('GetPathSegment_U', descNumber)
            } else {
                Segment.DefineProp('GetPathSegment', descString)
                Segment.DefineProp('GetPathSegment_U', descString_u)
            }
            return Segment
        }
        Unescaped(*) {
            if !this.HasOwnProp('__Path_U') {
                o := this
                buf := Buffer(TestSort_StringifyAll.Path.InitialBufferSize)
                offset := TestSort_StringifyAll.Path.InitialBufferSize - 2
                NumPut('ushort', 0, buf, offset) ; null terminator
                loop {
                    if o.GetPathSegment_U(buf, &offset) {
                        break
                    }
                    o := o.Base
                }
                this.DefineProp('__Path_U', { Value: StrGet(buf.Ptr + offset) })
            }
            return this.__Path_U
        }
        __GetPathSegmentItem_Number(buf, &offset) {
            bytes := StrPut(this.Name) + 2 ; -2 for null terminator, then +4 for the brackets
            if bytes > offset {
                count := buf.Size - offset
                while bytes > offset {
                    TestSort_StringifyAll.Path.InitialBufferSize *= 2
                    buf.Size *= 2
                    DllCall(
                        TestSort_StringifyAll.Path.memmove
                      , 'ptr', buf.Ptr + buf.Size - count
                      , 'ptr', buf.Ptr + offset
                      , 'int', count
                      , 'ptr'
                    )
                    offset := buf.Size - count
                }
            }
            offset -= bytes
            StrPut('[' this.Name ']', buf.Ptr + offset, bytes / 2)
        }

        ;@region Escaped
        __GetPathSegmentItem_String1(buf, &offset) {
            static desc2 := TestSort_StringifyAll.Path.Prototype.GetOwnPropDesc('__GetPathSegmentItem_String2')
            this.DefineProp('NameEscaped', { Value: StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(this.Name, '``', '````'), '`n', '``n'), '`r', '``r'), "'", "``'"), '`t', '``t') })
            this.DefineProp('GetPathSegment', desc2)
            this.GetPathSegment(buf, &offset)
        }
        __GetPathSegmentItem_String2(buf, &offset) {
            bytes := StrPut(this.NameEscaped) + 6 ; -2 for null terminator, then +4 for the brackets and +4 for the quotes
            if bytes > offset {
                count := buf.Size - offset
                while bytes > offset {
                    TestSort_StringifyAll.Path.InitialBufferSize *= 2
                    buf.Size *= 2
                    DllCall(
                        TestSort_StringifyAll.Path.memmove
                      , 'ptr', buf.Ptr + buf.Size - count
                      , 'ptr', buf.Ptr + offset
                      , 'int', count
                      , 'ptr'
                    )
                    offset := buf.Size - count
                }
            }
            offset -= bytes
            StrPut("['" this.NameEscaped "']", buf.Ptr + offset, bytes / 2)
        }
        __GetPathSegmentProp1(buf, &offset) {
            static desc2 := TestSort_StringifyAll.Path.Prototype.GetOwnPropDesc('__GetPathSegmentProp2')
            this.DefineProp('NameEscaped', { Value: StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(this.Name, '``', '````'), '`n', '``n'), '`r', '``r'), '"', '``"'), '`t', '``t') })
            this.DefineProp('GetPathSegment', desc2)
            this.GetPathSegment(buf, &offset)
        }
        __GetPathSegmentProp2(buf, &offset) {
            bytes := StrPut(this.NameEscaped) ; -2 for null terminator, then +2 for the period
            if bytes > offset {
                count := buf.Size - offset
                while bytes > offset {
                    TestSort_StringifyAll.Path.InitialBufferSize *= 2
                    buf.Size *= 2
                    DllCall(
                        TestSort_StringifyAll.Path.memmove
                      , 'ptr', buf.Ptr + buf.Size - count
                      , 'ptr', buf.Ptr + offset
                      , 'int', count
                      , 'ptr'
                    )
                    offset := buf.Size - count
                }
            }
            offset -= bytes
            StrPut('.' this.NameEscaped, buf.Ptr + offset, bytes / 2)
        }
        __GetPathSegmentRoot1(buf, &offset) {
            static desc2 := TestSort_StringifyAll.Path.Prototype.GetOwnPropDesc('__GetPathSegmentRoot2')
            this.DefineProp('NameEscaped', { Value: StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(this.Name, '``', '````'), '`n', '``n'), '`r', '``r'), '"', '``"'), '`t', '``t') })
            this.DefineProp('GetPathSegment', desc2)
            return this.GetPathSegment(buf, &offset)
        }
        __GetPathSegmentRoot2(buf, &offset) {
            bytes := StrPut(this.NameEscaped) - 2 ; -2 for null terminator
            if bytes > offset {
                count := buf.Size - offset
                while bytes > offset {
                    TestSort_StringifyAll.Path.InitialBufferSize *= 2
                    buf.Size *= 2
                    DllCall(
                        TestSort_StringifyAll.Path.memmove
                      , 'ptr', buf.Ptr + buf.Size - count
                      , 'ptr', buf.Ptr + offset
                      , 'int', count
                      , 'ptr'
                    )
                    offset := buf.Size - count
                }
            }
            offset -= bytes
            StrPut(this.NameEscaped, buf.Ptr + offset, bytes / 2)
            return 1
        }
        ;@endregion

        ;@region Unescaped
        __GetPathSegmentItem_String_U1(buf, &offset) {
            static desc2 := TestSort_StringifyAll.Path.Prototype.GetOwnPropDesc('__GetPathSegmentItem_String_U2')
            this.DefineProp('__NamePartialEscaped', { Value: StrReplace(this.Name, "'", "``'") })
            this.DefineProp('GetPathSegment', desc2)
            this.GetPathSegment(buf, &offset)
        }
        __GetPathSegmentItem_String_U2(buf, &offset) {
            bytes := StrPut(this.__NamePartialEscaped) + 6 ; -2 for null terminator, then +4 for the brackets and +4 for the quotes
            if bytes > offset {
                count := buf.Size - offset
                while bytes > offset {
                    TestSort_StringifyAll.Path.InitialBufferSize *= 2
                    buf.Size *= 2
                    DllCall(
                        TestSort_StringifyAll.Path.memmove
                      , 'ptr', buf.Ptr + buf.Size - count
                      , 'ptr', buf.Ptr + offset
                      , 'int', count
                      , 'ptr'
                    )
                    offset := buf.Size - count
                }
            }
            offset -= bytes
            StrPut("['" this.__NamePartialEscaped "']", buf.Ptr + offset, bytes / 2)
        }
        __GetPathSegmentProp_U(buf, &offset) {
            bytes := StrPut(this.Name) ; -2 for null terminator, then +2 for the period
            if bytes > offset {
                count := buf.Size - offset
                while bytes > offset {
                    TestSort_StringifyAll.Path.InitialBufferSize *= 2
                    buf.Size *= 2
                    DllCall(
                        TestSort_StringifyAll.Path.memmove
                      , 'ptr', buf.Ptr + buf.Size - count
                      , 'ptr', buf.Ptr + offset
                      , 'int', count
                      , 'ptr'
                    )
                    offset := buf.Size - count
                }
            }
            offset -= bytes
            StrPut('.' this.Name, buf.Ptr + offset, bytes / 2)
        }
        __GetPathSegmentRoot_U(buf, &offset) {
            bytes := StrPut(this.Name) - 2 ; -2 for null terminator
            if bytes > offset {
                count := buf.Size - offset
                while bytes > offset {
                    TestSort_StringifyAll.Path.InitialBufferSize *= 2
                    buf.Size *= 2
                    DllCall(
                        TestSort_StringifyAll.Path.memmove
                      , 'ptr', buf.Ptr + buf.Size - count
                      , 'ptr', buf.Ptr + offset
                      , 'int', count
                      , 'ptr'
                    )
                    offset := buf.Size - count
                }
            }
            offset -= bytes
            StrPut(this.Name, buf.Ptr + offset, bytes / 2)
            return 1
        }
        ;@endregion

        Path => this.Unescaped()
        PathEscaped => this()
    }
}

/**
 * @description - `SA_MapHelper` exists to allow us to create the `Map` object with all significant
 * properties in a single expression, instead of requiring two or three expressions.
 */
class TestSort_SA_MapHelper extends Map {
    __New(CaseSense := false, Default?, Values*) {
        this.CaseSense := CaseSense
        if IsSet(Default) {
            this.Default := Default
        }
        if Values.Length {
            this.Set(Values*)
        }
    }
}

TestSort_CallbackClear(scroller) {
    test.History.Length := 0
    scroller.UpdatePages(0)
}

/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-Array/edit/main/Array.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

/**
 * @description - Implements Javascript's `array.prototype.reduce` in AutoHotkey. `Array.Prototype.Reduce` is
 * used to iterate upon the values in an array, using a VarRef parameter to generate a cumulative
 * result.
 * @param {Array} Arr - The array to iterate. If calling this method from an array instance, skip
 * this parameter completely, don't leave a space for it.
 * @param {Func|BoundFunc|Closure} Callback - The function to execute on each element in the array.
 * The callback can accept two to four parameters:
 * - The accumulator. This must be VarRef.
 * - The current value being processed in the array.
 * - [Optional] The index of the current element being processed in the array.
 * - [Optional] The array reduce was called upon.
 * The function does not need a return value, and if it exists it is ignored.
 * @param {Any} [InitialValue] - The initial value of the accumulator. If not set, the first element
 * of the array will be used and iteration begins from the second element.
 * @param {Any} [Default] - The value to use when an array index is unset. If unset, that index
 * is skipped.
 * @returns {Any} - The value that results from the reduction.
 * @example
    arr := [1,2,,3,4,,,5]
    Callback := (&Accumulator, Value, *) => Accumulator += Value
    OutputDebug(arr.Reduce(Callback, , 1)) ; 18
   @
*/
TestSort_Array_Reduce(Arr, Callback, InitialValue?, Default?) {
    i := 0
    while !Arr.Has(++i)
        continue
    if IsSet(InitialValue)
        Accumulator := InitialValue, i--
    else
        Accumulator := Arr[i]
    if IsSet(Default)
        _LoopWithDefault()
    else
        _Loop()
    return Accumulator

    _Loop() {
        while ++i <= Arr.Length {
            if !Arr.Has(i)
                continue
            Callback(&Accumulator, Arr[i], i, Arr)
        }
    }
    _LoopWithDefault() {
        while ++i <= Arr.Length
            Callback(&Accumulator, Arr.Has(i) ? Arr[i] : Default, i, Arr)
    }
}
/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-Array/edit/main/Array.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

/**
 * @description - Implements Javascript's `array.prototype.forEach` method in AutoHotkey.
 * `Array.Prototype.ForEach` is used to do an action on every value in an array.
 * @param {Array} Arr - The array to iterate. If calling this method from an array instance, skip
 * this parameter completely, don't leave a space for it.
 * @param {Func|BoundFunc|Closure} Callback - The function to call for each element in the array.
 * If using `ThisArg`, this can accept two to four parameters. If not, it can accept one to three:
 * - The value passed to `ThisArg`. (This is only when `ThisArg` is set).
 * - The current element being processed in the array.
 * - [Optional] The index of the current element being processed in the array.
 * - [Optional] The array `ForEach` was called upon.
 * The function does not need a return value, and if one exists it is ignored.
 * @param {Any} [Default] - The value to use when an array index is unset. If `Default` is unset
 * and `ForEach` encounters an unset index, that index is skipped.
 * @param {Object} [ThisArg] - The object to use as `this` when executing the callback.
 */
TestSort_Array_ForEach(Arr, Callback, Default?, ThisArg?) {
    if IsSet(ThisArg) {
        if IsSet(Default) {
            for Item in Arr
                Callback(ThisArg, Item??Default, A_Index, Arr)
        } else {
            for Item in Arr {
                if IsSet(Item)
                    Callback(ThisArg, Item, A_Index, Arr)
            }
        }
    } else {
        if IsSet(Default) {
            for Item in Arr
                Callback(Item??Default, A_Index, Arr)
        } else {
            for Item in Arr {
                if IsSet(Item)
                    Callback(Item, A_Index, Arr)
            }
        }
    }
}

TestSort_OnScroll(index, scroller) {
    test.OnScroll(index, scroller)
}

class TestSort_QuickFind_Equality {
    /**
     * Constructs a callable object that can be used to repeatedly search an input
     * array. The function has the following characteristics:
     * - The array is assumed to be in order of value.
     * - All indices must have a value.
     * - Comparisons are made by direct numeric comparison.
     *
     * @param {Array} Arr - The array to search.
     */
    __New(Arr) {
        this.Arr := Arr
    }
    /**
     * @param {*} Value - The value to find.
     * @param {VarRef} [OutLastIndex] -  If there are multiple indices containing the input value,
     * the function assigns `OutLastIndex` with the greatest index which contains the input value.
     * If there is one index containing the input value, `OutLastIndex` will be the same as
     * the return value.
     * @returns {Integer} - If the value is found, the first index containing the value. Else,
     * 0.
     */
    Call(Value, &OutLastIndex?) {
        Arr := this.Arr
        if !Arr.Length {
            throw Error('The array is empty.', -1)
        }
        IndexEnd := Arr.Length
        IndexStart := 1
        if Arr.Length == 1 {
            if Arr[1] = Value {
                return OutLastIndex := 1
            } else {
                return 0
            }
        }
        StopBinary := 0
        R := IndexEnd - IndexStart + 1
        loop 100 { ; 100 is arbitrary
            if R * 0.5 ** (StopBinary + 1) * 14 <= 27 {
                break
            }
            StopBinary++
        }
        loop StopBinary {
            i := IndexEnd - Ceil((IndexEnd - IndexStart) * 0.5)
            if Value == Arr[i] {
                Start := i
                --i
                loop i - IndexStart + 1 {
                    if Value == Arr[i] {
                        --i
                    } else {
                        break
                    }
                }
                Result := i + 1
                i := Start + 1
                loop IndexEnd - i + 1 {
                    if Value == Arr[i] {
                        ++i
                    } else {
                        break
                    }
                }
                OutLastIndex := i - 1
                return Result
            } else if Value > Arr[i] {
                IndexStart := i
            } else {
                IndexEnd := i
            }
        }
        i := IndexStart
        loop IndexEnd - i + 1 {
            if Value == Arr[i] {
                Result := OutLastIndex := i
                break
            }
            ++i
        }
        ; Value was not found
        if !IsSet(Result) {
            return 0
        }
        ++i
        loop IndexEnd - i + 1 {
            if Value == Arr[i] {
                ++i
            } else {
                break
            }
        }
        OutLastIndex := i - 1
        return Result
    }
    Dispose() {
        if this.HasOwnProp('Arr') {
            this.DeleteProp('Arr')
        }
    }
    /**
     * This version of the function does not search for multiple indices; it only finds
     * the first index from left-to-right that contains the input value.
     * @param {*} Value - The value to find.
     * @returns {Integer} - If the value is found, the first index containing the value. Else,
     * 0.
     */
    Find(Value) {
        Arr := this.Arr
        if !Arr.Length {
            throw Error('The array is empty.', -1)
        }
        IndexEnd := Arr.Length
        IndexStart := 1
        if Arr.Length == 1 {
            if Arr[1] = Value {
                return OutLastIndex := 1
            } else {
                return 0
            }
        }
        StopBinary := 0
        R := IndexEnd - IndexStart + 1
        loop 100 { ; 100 is arbitrary
            if R * 0.5 ** (StopBinary + 1) * 14 <= 27 {
                break
            }
            StopBinary++
        }
        loop StopBinary {
            i := IndexEnd - Ceil((IndexEnd - IndexStart) * 0.5)
            if Value == Arr[i] {
                return i
            } else if Value > Arr[i] {
                IndexStart := i
            } else {
                IndexEnd := i
            }
        }
        i := IndexStart
        loop IndexEnd - i + 1 {
            if Value == Arr[i] {
                return i
            }
            ++i
        }
        return 0
    }
}
