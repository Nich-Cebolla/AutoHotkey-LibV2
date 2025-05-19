/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/QuickStrings.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

#Singleinstance force
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Align.ahk
#include <Align_V1.1.0>
; https://github.com/Nich-Cebolla/Stringify-ahk/blob/main/Stringify.ahk
#include <Stringify>
; https://github.com/Nich-Cebolla/Stringify-ahk/blob/main/ParseJson.ahk
#include <ParseJson>
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/tree/main/inheritance
#include <Inheritance>
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GetRelativePath.ahk
#include <GetRelativePath>
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/GuiResizer.ahk
#include <GuiResizer>
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/ItemScroller.ahk
#include <ItemScroller>

q := quickstrings({ PathIn: A_MyDocuments '\AutoHotkey\config\QuickStrings\config.json' })
; last thing I was doing was trying to get the string id onto the group of controls

class QuickStrings extends Map {
    static ShowTooltip(Str) {
        static N := [1,2,3,4,5,6,7]
        Z := N.Pop()
        OM := CoordMode('Mouse', 'Screen')
        OT := CoordMode('Tooltip', 'Screen')
        MouseGetPos(&x, &y)
        Tooltip(Str, x, y, Z)
        SetTimer(_End.Bind(Z), -2000)
        CoordMode('Mouse', OM)
        CoordMode('Tooltip', OT)

        _End(Z) {
            ToolTip(,,,Z)
            N.Push(Z)
        }
    }

    __New(Options?) {
        O := this.Options := QuickStrings.Options(Options ?? {})
        if !O.OnToggle {
            this.ToggleCallback := ObjBindMethod(this, 'MoveByMouse')
        }
        if O.PathIn {
            this.Options := ParseJson(, O.PathIn)
            ObjSetBase(this.Options, O)
        }
        if !this.Options.HasOwnProp('Id') {
            this.Options.Id := 1
        }
        this.Profiles := ''
        this.Launch()
    }

    AddProfile(Name) {
        if !this.Profiles {
            this.Profiles := {}
        }
        if Name := Trim(Name, '`s`t`r`n') {
            if IsNumber(Name) {
                return 'Profile names cannot be completely numeric.'
            }
            if this.Profiles.HasOwnProp(Name) {
                return 'Profile name "' Name '" is already in use.'
            }
            this.Profiles.DefineProp(Name, { Value: { Name: Name, Strings: [] } })
            this.G.Profiles.DefineProp(Name, { Value: { Name: Name, StringDisplayControls: [] } })
            this.ActiveProfile := this.Profiles.%Name%
            this.AddTab(Name)
            QS_Gui.Prototype.ProfileIndexes.Set(Name, QS_Gui.Prototype.GetIndex())
            QS_Gui.Prototype.ProfileIndexes.Set(QS_Gui.Prototype.ProfileIndexes.Get(Name), Name)
        } else {
            return 'Profile names must contain at least one visible character.'
        }
    }

    AddString(StringObj) {
        if !StringObj {
            return
        }
        Controls := this.ActiveControls
        Strings := this.ActiveStrings
        if Strings.Length > Controls.Length {

        }

    }

    AddTab(Name) {
        G := this.G
        O := this.Options
        Tab := G['Tab']
        Tab.Add([Name])
        Tab.UseTab(Name)
        Tab.GetPos(&tabx, &taby, &tabw, &tabh)
        MarginX := G.MarginX
        MarginY := G.MarginY
        G.MarginX := O.StringMarginX
        G.MarginY := O.StringMarginY
        PaddingY := O.StringPaddingY
        if !G.Profiles.HasOwnProp(Name) {
            G.Profiles.DefineProp(Name, { Value: { StringDisplayControls: [] } })
        }
        StringDisplayControls := G.Profiles.%Name%.StringDisplayControls
        Constructor :=
        tabb := taby + tabh
        StringDisplayControls.Push(Col := [ Group := {
            Checkbox: G.Add('Checkbox', Format('w{} h{} Section vChk_{}_1', O.StringCheckboxWidth, O.StringCtrlHeight, Name))
        } ])
        Group.Checkbox.GetPos(&chkx, &chky, &chkw, &chkh)
        X := chkx
        Y := chky + chkh + PaddingY
        i := 1
        _Add()
        H := taby + tabh - chky - O.StringMarginY * 2 - 30
        TotalH := chkh
        Padding := 0
        loop O.StringItemColumns {
            loop {
                Col.Push(Group := {
                    Checkbox: G.Add('Checkbox', Format('x{} y{} w{} h{} Section vChk_{}_{}', X, Y, O.StringCheckboxWidth, O.StringCtrlHeight, Name, ++i))
                })
                _Add()
                if TotalH + Padding + PaddingY + chkh > H {
                    ; skip the calculations
                    if StringDisplayControls.Length == O.StringItemColumns {
                        break 2
                    }
                    Group.Hotkey.GetPos(&edtx, &edty, &edtw, &edth)
                    X := edtx + edtw + O.StringPaddingX
                    Y := chky
                    StringDisplayControls.Push(Col := [])
                    TotalH := 0
                } else {
                    Y += chkh + PaddingY
                    TotalH += chkh
                    Padding += PaddingY
                }
            }
        }
        Index := this.G.ProfileIndexes.Get(Name)
        for Col in StringDisplayControls {
            for Group in Col {
                for Prop, Ctrl in Group.OwnProps() {
                    Ctrl.ProfileIndex := Index
                    Ctrl.DefineProp('ProfileName', { Get: (Self) => Self.Gui.ProfileIndexes.Get(Self.ProfileIndex) })
                }
            }
        }
        G.MarginX := MarginX
        G.MarginY := MarginY

        return

        _Add() {
            Group.Id := G.Add('Text', Format('h{} ys xs+20 Section vTxtId_{}_{}'
                , O.StringCtrlHeight
                , Name
                , i
            ), '0000')
            Group.Name := G.Add('Text', Format('w{} h{} ys backgroundblack vTxtName_{}_{}'
                , O.StringTextNameWidth
                , O.StringCtrlHeight
                , Name
                , i
            ))
            Group.Name.OnEvent('DoubleClick', HDoubleClickTextName)
            Group.Preview := G.Add('Edit', Format('w{} h{} ys vEdt_Preview_{}_{}'
                , O.StringEditPreviewWidth
                , O.StringCtrlHeight
                , Name
                , i
            ))
            Group.Hotkey := G.Add('Edit', Format('w{} h{} ys vEdt_Hotkey_{}_{}'
                , O.EditHotkeyWidth
                , O.StringCtrlHeight
                , Name
                , i
            ))
        }

        HDoubleClickTextName(Ctrl, *) {
            G := Ctrl.Gui
            if !G.HasOwnProp('AddWindow') {
                G.DefineProp('AddWindow', { Value: this.LaunchAddWindow('AddString') })
            }
            AW := G.AddWindow
            Align.MoveAdjacent(AW, G)
            if Ctrl.HasOwnProp('String') {
                AW['EdtInput'].Text := Ctrl.String.Text
                AW['EdtName'].Text := Ctrl.String.Name
                AW.Callback := ObjBindMethod(this, 'UpdateString', Ctrl.String)
            } else {
                AW.Callback := 'AddString'
            }
            AW.Show()
        }
    }

    BackupOptions() {
        SplitPath(this.Options.PathIn, &Name, &Dir)
        if !DirExist(Dir '\backups') {
            try {
                DirCreate(Dir '\backups')
            } catch Error as err {
                MsgBox('Failed to create directory: ' Dir '\backups.')
                return
            }
        }
        if DirExist(Dir '\backups') {
            fs := ''
            date := A_Now
            n := 0
            loop Files Dir '\backups\*QuickStrings*.bak' {
                fs .= DateDiff(date, A_LoopFileTimeCreated, 'S') ':' A_LoopFileFullpath '`n'
                n++
            }
            if n > this.Options.BackupMaxFiles - 1 {
                fs := StrSplit(Sort(Trim(fs, '`n'), 'N'), '`n')
                loop n - this.Options.BackupMaxFiles + 1 {
                    FileDelete(SubStr(f := fs.Pop(), InStr(f, ':') + 1))
                }
            }
            FileCopy(this.Options.PathIn, Dir '\backups\backup-QuickStrings-' A_Now '.bak')
        }
    }

    GetId() {
        return ++this.Options.Id
    }

    Launch() {
        ;@region Constructor

        ; Prepare options
        O := this.Options
        G := this.G := QS_Gui(O.GuiOpt || unset, O.Title || unset)
        for s in StrSplit(O.FontFamily, ',') {
            if s {
                G.SetFont(, s)
            }
        }
        G.SetFont(O.FontOpt)
        G.Profiles := {}

        ; Create buttons
        W := 0
        G.OptButtons := []
        for Name in QuickStrings.Config.Buttons {
            _Name := RegExReplace(Name, '\W', '')
            G.OptButtons.Push(G.Add('Button', 'vBtn' _Name, Name))
            G.OptButtons[-1].OnEvent('Click', HClickButton%_Name%)
            G.OptButtons[-1].GetPos(, , &btnw)
            W := Max(W, btnw)
        }
        for Btn in G.OptButtons {
            Btn.Move(, , W)
        }
        G.OptButtons[1].GetPos(&btnx, &btny, &btnw, &btnh)

        ; Create checkboxes and associated edits
        G.OptCheckboxes := []
        G.HotkeyEdits := []
        W := 0
        X := btnx + btnw + G.MarginX
        for Name in QuickStrings.Config.Checkboxes {
            _Name := RegExReplace(Name, '\W', '')
            G.OptCheckboxes.Push(Chk := G.Add('Checkbox', Format('x{} y{} {} vChk{}', X, btny, O.Chk%_Name% ? 'Checked' : '', _Name) , Name))
            G.OptCheckboxes[-1].OnEvent('Click', HClickCheckbox%_Name%)
            G.OptCheckboxes[-1].GetPos(, , &chkw)
            W := Max(W, chkw)
            G.HotkeyEdits.Push(Edt := G.Add('Edit', Format('x{} y{} w{} vEdtHk{}', X, btny, O.EditHotkeyWidth, _Name), O.Hotkey%_Name%))
            ; The edit controls have these properties assigned to them
            Edt.Checkbox := Chk
            Edt.OptionName := _Name
            Edt.ActiveHotkey := ''
        }
        G.HotkeyEdits[1].GetPos(, , , &edth)
        G.OptCheckboxes[1].GetPos(&chkx, &chky, , &chkh)
        X := chkx + W + G.MarginX
        for Chk in G.OptCheckboxes {
            G.OptButtons[A_Index].GetPos(, &btny, , &btnh)
            Chk.Move(, btny + 0.5 * (btnh - chkh), W)
            G.HotkeyEdits[A_Index].Move(X, btny + 0.5 * (btnh - edth))
        }
        G.OptButtons[this.G.OptCheckboxes.Length + 1].GetPos(, &btny)

        ; "Window visibility" doesn't make sense as a checkbox, so it gets separate handling
        G.Add('Text', Format('x{} y{} w{} vTxtWindowVisibility', btnx + btnw + G.MarginX, btny + 0.5 * (btnh - edth), W), 'Toggle window visibility')
        G.HotkeyEdits.Push(G.Add('Edit', Format('x{} y{} w{} vEdtWindowVisibility'
            , btnx + btnw + G.MarginX * 2 + W
            , btny + 0.5 * (btnh - edth)
            , O.EditHotkeyWidth
        ), O.HotkeyWindowVisibility))
        G.HotkeyEdits[-1].OptionName := 'WindowVisibility'
        G.HotkeyEdits[-1].ActiveHotkey := ''

        ; Create the console
        this.Console := G.Add(
            'Edit', Format('x{} y{} w{} r{} Section vConsole'
          , consoleX := chkx + W + G.MarginX * 2 + O.EditHotkeyWidth
          , G.MarginY
          , O.ConsoleWidth
          , O.ConsoleRows
        )
          , (
            'QuickStrings : v1.0.0 : By Cebolla`r`n'
            '`r`nEnter "?" or "Help" for commands.`r`n`r`n'

          )
        )
        this.Console.History := ''
        this.Console.MaxLen := O.ConsoleMaxLen
        this.Console.DefineProp('__SetInfo', { Call: _SetInfo })
        this.Console.__SetInfo()
        for s in StrSplit(O.ConsoleFontFamily, ',') {
            if s {
                this.Console.SetFont(, s)
            }
        }
        this.Console.SetFont(O.ConsoleFontOpt)
        ; At the bottom of this script there is a function that producse this as a string.
        this.Export := Map()
        this.Export.CaseSense := false
        this.Export.Set(
            'HChangeTab', HChangeTab
          , 'HClickButtonAdd', HClickButtonAdd
          , 'HClickButtonApplyHotkeys', HClickButtonApplyHotkeys
          , 'HClickButtonLoadData', HClickButtonLoadData
          , 'HClickButtonCreateProfile', HClickButtonCreateProfile
          , 'HClickButtonSaveData', HClickButtonSaveData
          , 'HClickButtonDeleteProfile', HClickButtonDeleteProfile
          , 'HClickButtonCheckAll', HClickButtonCheckAll
          , 'HClickButtonUncheckAll', HClickButtonUncheckAll
          , 'HClickButtonRestart', HClickButtonRestart
          , 'HClickButtonExit', HClickButtonExit
          , 'HClickCheckboxAlwaysOnTop', HClickCheckboxAlwaysOnTop
          , 'HClickCheckboxCtrlEnterSendToConsole', HClickCheckboxCtrlEnterSendToConsole
          , 'HClickCheckboxMonitorClipboard', HClickCheckboxMonitorClipboard
          , 'HClickCheckboxSuspendHotkeys', HClickCheckboxSuspendHotkeys
          , 'HClickCheckboxSaveOnExit', HClickCheckboxSaveOnExit
          , 'HkAlwaysOnTop', HkAlwaysOnTop
          , 'HkCtrlEnterSendToConsole', HkCtrlEnterSendToConsole
          , 'HkMonitorClipboard', HkMonitorClipboard
          , 'HkSuspendHotkeys', HkSuspendHotkeys
          , 'HkSaveOnExit', HkSaveOnExit
          , 'HkWindowVisibility', HkWindowVisibility
          , 'HkSendToConsole', HkSendToConsole
          , '_Line', _Line
          , '_PrepareLine', _PrepareLine
          , '_ProcessCommand', _ProcessCommand
          , '_ReplaceNameInConsole', _ReplaceNameInConsole
          , '_SetInfo', _SetInfo
          , '_UnknownCommand', _UnknownCommand
        )
        ; Create the tab control
        G['TxtWindowVisibility'].GetPos(&txtx, &txty, , &txth)
        G.Add('Tab2', Format('x{} y{} w{} h{} vTab'
            , txtx
            , txty + txth + G.MarginY * 2
            , ConsoleX + O.ConsoleWidth - txtx
            , O.TabHeight
        ), QuickStrings.Config.TabLabels)

        ; If profiles have already been loaded, set their tabs
        if O.Profiles {
            this.Profiles := O.Profiles
            ; Add names to the tab labels
            for Name, Obj in this.Profiles.OwnProps() {
                if A_Index == 1 {
                    _Obj := Obj
                }
                QS_Gui.Prototype.ProfileIndexes.Set(Name, QS_Gui.Prototype.GetIndex())
                QS_Gui.Prototype.ProfileIndexes.Set(QS_Gui.Prototype.ProfileIndexes.Get(Name), Name)
                this.AddTab(Name)
                if Obj.Strings.Length {

                }
            }
            ; Set active profile
            if O.InitialProfile {
                this.ActiveProfile := this.Profiles.%O.InitialProfile%
            } else {
                this.ActiveProfile := _Obj
            }
            G['Tab'].Choose(this.ActiveProfile.Name)
            this.Console.Text .= _Line()
            this.ConsolePrompt := 0
        } else {
            this.ConsolePrompt := 1
        }

        ; Add item scroller
        G['Tab'].UseTab()
        G.OptButtons[-1].GetPos(&btnx, &btny, &btnw, &btnh)
        this.Scroller := ItemScroller(G, {
            Array: this.Profiles ? this.ActiveStrings : []
          , BtnFontOpt: O.ScrollerTextFontOpt || O.FontOpt
          , BtnFontFamily: O.ScrollerTextFontFamily || O.FontFamily
          , EditBackgroundColor: O.ScrollerEditBackground
          , EditFontOpt: O.ScrollerEditFontOpt || O.ConsoleFontOpt
          , EditFontFamily: O.ScrollerEditFontFamily || O.ConsoleFontFamily
          , Horizontal: false
          , StartX: btnx
          , StartY: btny + btnh + G.MarginY
          , TextBackgroundColor: O.ScrollerTextBackground
          , TextFontOpt: O.ScrollerTextFontOpt || O.FontOpt
          , TextFontFamily: O.ScrollerTextFontFamily || O.FontFamily
        })

        G['Tab'].OnEvent('Change', HChangeTab)
        this.Console.__SetInfo()
        HClickButtonApplyHotkeys()
        OnExit(_OnExit, 1)
        G.Show()
        ;@endregion

        return

        ;@region Handlers
        HChangeTab(*) {
            G := this.G
            if G['Tab'].Text = 'Clipboard' {
                return
            }
            Name := this.ActiveProfile.Name
            this.ActiveProfile := this.Profiles.%G['Tab'].Text%
            _ReplaceNameInConsole(Name)
        }
        HClickButtonAdd(*) {
            if !this.G.HasOwnProp('AddWindow') {
                this.G.DefineProp('AddWindow', { Value: this.LaunchAddWindow('AddString') })
            }
            Align.MoveAdjacent(this.G.AddWindow, this.G)
            this.G.AddWindow.Show()
        }
        HClickButtonApplyHotkeys(*) {
            for Edt in this.G.HotkeyEdits {
                if hk := Trim(Edt.Text, '`s`r`t`n') {
                    HotKey(hk, this.Export.Get('Hk' Edt.OptionName), 'On')
                    Edt.ActiveHotkey := hk
                } else if Edt.ActiveHotkey {
                    HotKey(Edt.ActiveHotkey, this.Export.Get('Hk' Edt.OptionName), 'Off')
                    Edt.ActiveHotkey := ''
                }
            }
        }
        HClickButtonLoadData(Ctrl, *) {

        }
        HClickButtonCreateProfile(Ctrl, *) {
            this.ConsolePrompt := 1
        }
        HClickButtonSaveData(*) {
            this.WriteOutOptions()
        }
        HClickButtonDeleteProfile(Ctrl, *) {

        }
        HClickButtonCheckAll(Ctrl, *) {

        }
        HClickButtonUncheckAll(Ctrl, *) {

        }
        HClickButtonRestart(Ctrl, *) {

        }
        HClickButtonExit(Ctrl, *) {

        }
        HClickCheckboxAlwaysOnTop(Ctrl, *) {
            if !Ctrl {
                Ctrl := this.G['ChkAlwaysOnTop']
                Ctrl.Value := !Ctrl.Value
            }
            if this.G['ChkAlwaysOnTop'].Value {
                WinSetAlwaysOnTop(1, this.G.hWnd)
            } else {
                WinSetAlwaysOnTop(0, this.G.hWnd)
            }
        }
        HClickCheckboxCtrlEnterSendToConsole(Ctrl, *) {
            if !Ctrl {
                Ctrl := this.G['ChkCtrlEnterSendToConsole']
                Ctrl.Value := !Ctrl.Value
            }
            HotIfWinActive(this.G.Title ' ahk_class AutoHotkeyGUI')
            if Ctrl.Value {
                HotKey('^Enter', HkSendToConsole, 'On')
                HotKey('Enter', HkSendToConsole, 'Off')
            } else {
                HotKey('Enter', HkSendToConsole, 'On')
                HotKey('^Enter', HkSendToConsole, 'Off')
            }
            HotIfWinActive()
        }
        HClickCheckboxMonitorClipboard(Ctrl, *) {
            if !Ctrl {
                Ctrl := this.G['ChkCtrlEnterSendToConsole']
                Ctrl.Value := !Ctrl.Value
            }
        }
        HClickCheckboxSuspendHotkeys(Ctrl, *) {
            if !Ctrl {
                Ctrl := this.G['ChkSuspendHotkeys']
                Ctrl.Value := !Ctrl.Value
            }
        }
        HClickCheckboxSaveOnExit(Ctrl, *) {
            if !Ctrl {
                Ctrl := this.G['ChkSuspendHotkeys']
                Ctrl.Value := !Ctrl.Value
            }
        }
        HkAlwaysOnTop(*) {
            HClickCheckboxAlwaysOnTop('')
        }
        HkCtrlEnterSendToConsole(*) {
            HClickCheckboxCtrlEnterSendToConsole('')
        }
        HkMonitorClipboard(*) {
            HClickCheckboxMonitorClipboard('')
        }
        HkSuspendHotkeys(*) {
            HClickCheckboxSuspendHotkeys('')
        }
        HkSaveOnExit(*) {
            HClickCheckboxSaveOnExit('')
        }
        HkWindowVisibility(*) {
            this.Toggle()
        }
        HkSendToConsole(*) {
            if this.G.FocusedCtrl && this.G.FocusedCtrl.hWnd !== this.Console.hWnd {
                return
            }
            if this.ConsolePrompt {
                Prompt := QuickStrings.Config.Prompts[this.ConsolePrompt]
                if (Pos := InStr(this.Console.Text, Prompt.Str, , , -1)) && Pos == this.Console.Pos {
                    if Message := this.%Prompt.Callback%(Trim(SubStr(this.Console.Text, this.Console.Len + 1), '`s`t`r`n')) {
                        this.Console.Text .= '`r`nInvalid entry. ' Message '`r`n' Prompt.Str
                    } else {
                        _PrepareLine()
                        this.ConsolePrompt := 0
                    }
                } else {
                    this.Console.Text .= '`r`n' Prompt.Str
                }
            } else {
                if (Pos := InStr(this.Console.Text, _Line(), , , -1)) && Pos == this.Console.Pos {
                    text := Trim(SubStr(this.Console.Text, Pos), '`s`t`r`n')
                    if RegExMatch(text, P := '(?<=[\r\n]|^)' this.ActiveProfile.Name ' >\s*(\w+)(?:\s(.+))?$', &Match) {
                        if Index := QuickStrings.Config.Commands.Get(Match[1]) {
                            if _ProcessCommand(Index, Match) {
                                _PrepareLine()
                            } else {
                                _UnknownCommand()
                            }
                        }
                    } else {
                        _UnknownCommand()
                    }
                } else {
                    _UnknownCommand()
                }
            }
            this.Console.__SetInfo()
            ControlSend('^{End}', this.Console.hWnd)
        }
        _Line() {
            return this.ActiveProfile.Name ' > '
        }
        _OnExit(*) {
            if this.G['ChkSaveOnExit'].Value {
                this.WriteOutOptions()
            }
        }
        _PrepareLine() {
            this.Console.Text .= '`r`n' _Line()
        }
        _ProcessCommand(Index, Match) {
            Command := QuickStrings.Config.CommandsList[Index]
            if RegExMatch(Match[0], Command.Pattern, &Match) {
                return QuickStrings.Config.%Command.Callback%(this, Match)
            }
        }
        _ReplaceNameInConsole(Name) {
            RegExMatch(this.Console.Text, '(?<=[\r\n])([^\r\n>]+)( >.*)$', &Match)
            if Match[1] = Name {
                this.Console.Text := SubStr(this.Console.Text, 1, Match.Pos - 1) this.ActiveProfile.Name Match[2]
            }
        }
        _Scroll(Index, Scroller) {

        }
        _SetInfo(Self) {
            Self.LastText := StrSplit(SubStr(Self.Text, InStr(Self.Text, '`n', , , -5) || 1), '`n', '`r')
            Self.Len := StrLen(Self.Text)
            if Self.Len > Self.MaxLen {
                Self.History .= SubStr(Self.Text, 1, 1000)
                Self.Text := SubStr(Self.Text, 1001)
                Self.Len := StrLen(Self.Text)
            }
            i := Self.LastText.Length + 1
            while --i > 0 {
                if Self.LastText[i] {
                    break
                }
            }
            Self.Pos := InStr(Self.Text, Self.LastText[i], , , -1)
        }
        _UnknownCommand() {
            this.Console.Text .= '`r`nUnknown command.`r`n' _Line()
        }
        ;@endregion
    }

    LaunchAddWindow(Callback) {
        G := this.G
        O := this.Options
        AW := QS_Gui(O.GuiOpt, O.Title)
        AW.Callback := Callback
        for s in StrSplit(O.FontFamily, ',') {
            if s {
                AW.SetFont(, s)
            }
        }
        if O.FontOpt {
            AW.SetFont(O.FontOpt)
        }
        AW.Add('Edit', 'w' (edtw := O.AddWindowWidth - AW.MarginX * 2) ' r' O.AddWindowEditRows ' Section vEdtInput').Resizer := { W: 1, H: 1 }
        List := [
            AW.Add('Text', 'xs Section vTxtName', 'Name:')
          , AW.Add('Edit', 'w' O.AddWindowEditNameWidth ' ys vEdtName')
          , AW.Add('Text', 'ys vTxtHotkey', 'Hotkey:')
          , AW.Add('Edit', 'w' O.EditHotkeyWidth ' ys vEdtHotkey')
        ]
        W := 0
        for Name in QuickStrings.Config.AddWindowButtons {
            _Name := RegExReplace(Name, '\W', '')
            Btn := AW.Add('Button', 'ys v' _Name, Name)
            Btn.OnEvent('Click', HClickButton%_Name%)
            Btn.GetPos(, &btny, &btnw, &btnh)
            W := Max(W, btnw)
            List.Push(Btn)
        }
        for Ctrl in List {
            Ctrl.Resizer := { Y: 1 }
        }
        Align.CenterVList(List)
        ; X := AW.MarginX
        ; Y := btny
        ; for Ctrl in AW {
        ;     if Ctrl.Type == 'Edit' {
        ;         continue
        ;     }
        ;     Ctrl.Move(X, Y, W)
        ;     if X + W + AW.MarginX > edtw {
        ;         Y += btnh + AW.MarginY
        ;         X := AW.MarginX
        ;     } else {
        ;         X += W + AW.MarginX
        ;     }
        ; }
        AW.OnEvent('Close', HClickButtonCancel)
        AW.Resizer := GuiResizer(AW)
        return AW

        HClickButtonCancel(Obj, *) {
            G := Obj is Gui.Button ? Obj.Gui : Obj
            G.Hide()
            Callback := G.Callback
            if IsObject(Callback) {
                Callback('')
            } else {
                this.%Callback%('', '')
            }
        }
        HClickButtonSubmit(Ctrl, *) {
            AW := Ctrl.Gui
            AW.Hide()
            Callback := AW.Callback
            StringObj := { Text: AW['EdtInput'].Text, Name: AW['EdtName'].Text, Hotkey: AW['EdtHotkey'].Text }
            if IsObject(Callback) {
                Callback(StringObj)
            } else {
                this.%Callback%(StringObj)
            }
        }
    }

    /**
     * @description - Moves a window by a point while ensuring that the window stays within the
     * monitor's work area.
     * @returns {Integer} - Returns `1` if the `MonitorFromPoint` fails; it would typically indicate
     * the mouse was outside of any monitor's visible area.
     */
    MoveByMouse(*) {
        if Result := DllCall('User32.dll\GetCursorPos', 'ptr', PT := Buffer(8), 'int') {
            X := NumGet(PT, 0, 'int')
            Y := NumGet(PT, 4, 'int')
            if !(hMon := DllCall('User32\MonitorFromPoint', 'ptr', (X & 0xFFFFFFFF) | (Y << 32), 'uint', 0 , 'ptr')) {
                return 1
            }
        } else {
            throw OSError()
        }
        Mon := QuickMon(hMon)
        this.G.GetPos(&wx, &wy, &ww, &wh)
        this.G.Move(_GetX(), _GetY())

        return

        _GetX() {
            if (_X := Mon.RW - this.Options.MoveByMousePaddingX - ww - X) > 0 {
                return X + this.Options.MoveByMousePaddingX
            } else {
                return X + _X
            }
        }
        _GetY() {
            if (_Y := Mon.BW - this.Options.MoveByMousePaddingY - wh - Y) > 0 {
                return Y + this.Options.MoveByMousePaddingY
            } else {
                return Y + _Y
            }
        }
    }

    /**
     * @description - Toggles the window's visibility.
     * @param {Boolean} [Value] - Set this to specify a value instead of toggling it.
     */
    Toggle(Value?) {
        G := this.G
        if IsSet(Value) {
            if Value {
                (cb := this.ToggleCallback)(this)
                G.Show()
            } else {
                G.Hide()
            }
        } else {
            if DllCall('IsWindowVisible', 'Ptr', G.hWnd, 'int') {
                G.Hide()
            } else {
                (cb := this.ToggleCallback)(this)
                G.Show()
            }
        }
    }

    UpdateString(Id, StringObj) {
        for Col in this.ActiveControls {
            for Group in Col {
                if Group.Id.Text = StringObj.Id {
                    Group.Name := StringObj.Name
                    Group.Preview := StringObj.Text
                    Group.Hotkey := StringObj.Hotkey
                    break 2
                }
            }
        }
        for _obj in this.ActiveProfile.Strings {
        }
    }

    WriteOutOptions() {
        if this.Options.BackupOptions {
            this.BackupOptions()
        }
        Props := GetPropsInfo(this.Options, , , false)
        Obj := {}
        for Name, InfoItem in Props {
            if Code := InfoItem.GetValue(&Value) {
                ; OutputDebug('`nCould not get value. Prop: ' Name '; ' (IsObject(Code) ? 'Error: ' Code.Message : 'Code: ' Code))
                MsgBox('Could not get value. Prop: ' Name '; ' (IsObject(Code) ? 'Error: ' Code.Message : 'Code: ' Code))
            } else {
                if InStr(Name, 'Path') {
                    Obj.DefineProp(Name, { Value: GetRelativePath(Value) })
                } else {
                    Obj.DefineProp(Name, { Value: Value })
                }
            }
        }
        if this.Profiles {
            Obj.DefineProp('Profiles', { Value: this.Profiles })
        }
        str := Stringify(Obj)
        f := FileOpen(this.Options.PathIn, 'w', this.Options.Encoding || unset)
        f.Write(str)
        f.Close()
    }

    ActiveControls {
        Get {
            Columns := this.G.Profiles%this.ActiveProfile.Name%.StringDisplayControls
            if Columns.Length > 1 {
                List := []
                List.Capacity := Columns.Length * Columns[1].Length
                for Col in Columns {
                    List.Push(Col*)
                }
                return List
            } else {
                return Columns[1]
            }
        }
    }
    ActiveStrings => this.ActiveProfile.Strings

    ConsolePrompt {
        Get => this.__ConsolePrompt
        Set {
            this.__ConsolePrompt := Value
            if Value {
                this.Console.Opt('Background' this.Options.ConsolePromptBackgroundColor)
                this.Console.Text .= '`r`n' QuickStrings.Config.Prompts[Value].Str
                this.Console.__SetInfo()
                this.Console.Focus()
                ControlSend('^{End}', this.Console.hWnd)
            } else {
                this.Console.Opt('Background' this.Options.ConsoleBackgroundColor)
            }
        }
    }

    class Config {
        static __New() {
            this.Commands := Map()
            this.Commands.CaseSense := false
            this.Commands.Default := ''
            this.Commands.Set(
                '?', 1, 'Help', 1, 'H', 1
            )
            this.DeleteProp('__New')
        }
        static Buttons := [ 'Add', 'Apply Hotkeys', 'Load Data', 'Create Profile', 'Save Data'
        , 'Delete Profile', 'Check All', 'Uncheck All', 'Restart', 'Exit' ]
        , TabLabels := [ 'Clipboard' ]
        , Checkboxes := [ 'Always on top', 'Monitor clipboard', 'Suspend hotkeys', 'Ctrl + Enter send to console', 'Save on exit' ]
        , Prompts := [
            { Index: 1, Str: 'Enter profile name: ', Callback: 'AddProfile' }
        ]
        , CommandsList := [
            { Name: 'Help', Pattern: 'i)(?:Help|\?|H)(?:\s+(\w+))?', Callback: 'CommandHelp' }
        ]
        , AddWindowButtons := [ 'Submit', 'Cancel' ]

        static CommandHelp(ti, Match) {
            if Match[1] {

            } else {
                ti.Console.Text .= (
                    '`r`nConsole commands have not been implemented yet.'
                )
            }
            return 1
        }
    }

    /**
     * @classdesc - Handles the input options.
     */
    class Options {
        static Default := {
            AddWindowEditNameWidth: 120
          , AddWindowEditRows: 5
          , AddWindowWidth: 500
          , BackupOptions: true
          , BackupMaxFiles: 10
          , ChkAlwaysOnTop: false
          , ChkCtrlEnterSendToConsole: false
          , ChkMonitorClipboard: false
          , ChkSuspendHotkeys: false
          , ChkSaveOnExit: true
          , ConsoleBackgroundColor: '000000'
          , ConsoleFontFamily: 'Mono,Arial Rounded MT,Roboto Mono,IBM Plex Mono,Ubuntu Mono'
          , ConsoleFontOpt: 'cFFFFFF s11 q5'
          , ConsoleRows: 10
          , ConsolePromptRows: 1
          , ConsolePromptBackgroundColor: '2e082a'
          , ConsoleMaxLen: 5000
          , ConsoleWidth: 500
          , EditHotkeyWidth: 50
          , Encoding: ''
          , FontFamily: 'Aptos,Roboto,Segoe UI'
          , FontOpt: 's11 q5'
          , GuiOpt: '+Resize'
          , HotkeyAlwaysOnTop: ''
          , HotkeyCtrlEnterSendToConsole: ''
          , HotkeyMonitorClipboard: ''
          , HotkeySuspendHotkeys: ''
          , HotkeySaveOnExit: ''
          , HotkeyWindowVisibility: '#c'
          , InitialProfile: ''
          , MoveByMousePaddingX: 20
          , MoveByMousePaddingY: 20
          , OnToggle: ''
          , PathIn: ''
          , Profiles: ''
          , ScrollerEditBackground: '000000'
          , ScrollerEditFontOpt: '' ; uses `ConsoleFontOpt` when absent
          , ScrollerEditFontFamily: '' ; uses `ConsoleFontFamily` when absent
          , ScrollerTextBackground: ''
          , ScrollerTextFontOpt: '' ; uses `FontOpt` when absent
          , ScrollerTextFontFamily: '' ; uses `FontFamily` when absent
          , StringCheckboxWidth: 15
          , StringCtrlHeight: 20
          , StringEditPreviewWidth: 175
          , StringItemColumns: 1
          , StringMarginX: 8
          , StringMarginY: 7
          , StringPaddingX: 5
          , StringPaddingY: 5
          , StringTextNameWidth: 100
          , Title: 'QuickStrings'
          , TabHeight: 300
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
            if IsSet(QuickStringsConfig) {
                ObjSetBase(QuickStringsConfig, QuickStrings.Options.Default)
                ObjSetBase(Options, QuickStringsConfig)
            } else {
                ObjSetBase(Options, QuickStrings.Options.Default)
            }
            return Options
        }
    }

    class Pages {
        __New(qs) {
            this.Parent := qs
        }
    }
}

class QS_Gui extends Gui {
    static Call(Opt?, Title?, EventHandler?) {
        ObjSetBase(G := Gui(Opt ?? unset, Title ?? unset, EventHandler ?? unset), this.Prototype)
        return G
    }

    GetIndex() {
        return ++this.__Index
    }

    static __New() {
        this.Prototype.DefineProp('ProfileIndexes', { Value: Map() })
        this.Prototype.ProfileIndexes.CaseSense := false
        this.Prototype.DefineProp('__Index', { Value: 0 })
        this.DeleteProp('__New')
    }
}

/*
Use this function to construct the `obj.Export` map
GetExportFunctions()
GetExportFunctions() {
    Content := StrReplace(FileRead(A_LineFile), '`t', '`s`s`s`s')
    if !RegExMatch(Content, 'i)(?<=[\r\n])(?<indent>`s+)Launch\(.*?\)`s*(?<full>\{(?:[^}{]++|(?&full))*\})', &Match) {
        throw Error('Failed to match with ``QuickStrings.Prototype.Launch``.', -1)
    }
    outputdebug(match[0])
    Pos := InStr(Match[0], 'return', , , 1)
    i := ''
    loop 4 {
        i .= '`s'
    }
    s := i i 'this.Export.Set(`n' i i i
    Content := Match[0]
    loop {
        if !RegExMatch(Content, '(?<=[\r\n])(?<indent>`s+)(?<name>\w+)\(.*?\)`s*\{[\w\W]+?\R\g{indent}\}', &Match, Pos) {
            break
        }
        s .= "'" Match['name'] "', " Match['name'] '`n' i i '`s`s,`s'
        Pos := Match.Pos + Match.Len
    }
    A_Clipboard := SubStr(s, 1, -4) ')'
    CoordMode('Mouse', 'Screen')
    CoordMode('Tooltip', 'Screen')
    MouseGetPos(&x, &y)
    ToolTip('Done', x, y)
    sleep 2000
    Exit()
}
*/

