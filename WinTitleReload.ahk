
#Requires AutoHotkey >=2.0

/**
 * @classdesc - Many editors include the active file's path in the window title, including Notepad++
 * and VSCode. This can be leveraged to easily launch an AHK script, or any type of file, using
 * that title. If the editor does not display the full path, check the configuration options for
 * a way to adjust the title's format.
 */
class WinTitleReload {
    static __New() {
        this.DeleteProp('__New')
        Proto := this.Prototype
        Proto.AhkExe := ''
        Proto.Ext := 'ahk'
        Proto.Callback := ''
        ; The "{}" at the end in the "ext" subcapture group is so the list of extensions can
        ; be applied using `Format(this.Pattern, this.Ext)`.
        Proto.Pattern := '(?<dir>(?:(?<drive>[a-zA-Z]):\\)?(?:[^\r\n\\/:*?"<>|]++\\?)+)\\(?<file>[^\r\n\\/:*?"<>|]+?)\.(?<ext>{})\b'
        Proto.SuccessMessage := 'Running: {}.'
        Proto.ErrorMessage1 := 'Failed to launch. Press the hotkey again to add the error details to clipboard.'
        Proto.ErrorMessage2 := 'Error details added to clipboard.'
        Proto.ErrorMessageDuration := 3000
    }
    __New(AhkExe?, Ext?, Callback?, Pattern?) {
        for prop in ['AhkExe', 'Ext', 'Callback', 'Pattern'] {
            if IsSet(%prop%) {
                this.%prop% := %prop%
            }
        }
        this.Error := 0
    }
    Call(*) {
        if this.Error {
            A_Clipboard := (
                'Path: ' this.Error.Path '`r`n'
                'Message:`r`n' this.Error.Message '`r`n'
                'What: ' this.Error.What '`r`n'
                'Line: ' this.Error.Line '`r`n'
                'Extra: ' this.Error.Extra '`r`n'
                'Stack:`r`n' this.Error.Stack
            )
            this.Error := 0
            this.ShowTooltip(2)
        } else {
            if this.Callback {
                this.title := this.Callback.Call(WinGetTitle('A'))
            } else {
                this.title := WinGetTitle('A')
            }
            if RegExMatch(this.title, Format(this.Pattern, this.Ext), &Match) {
                try {
                    Run('"' (this.AhkExe || A_AhkPath) '" "' this.title '"')
                    this.ShowToolTip(0)
                } catch Error as err {
                    err.Path := Match[0]
                    this.Error := err
                    this.ShowTooltip(1)
                    SetTimer(_SetError, this.ErrorMessageDuration * -1)
                }
            }
        }

        _SetError(*) {
            this.Error := 0
        }
    }
    ShowTooltip(id) {
        static N := [1,2,3,4,5,6,7]
        Z := N.Pop()
        OM := CoordMode('Mouse', 'Screen')
        OT := CoordMode('Tooltip', 'Screen')
        MouseGetPos(&x, &y)
        switch id {
            case 0: Tooltip(Format(this.SuccessMessage, this.Title), x, y, Z)
            case 1:
                Tooltip(this.ErrorMessage1, x, y, Z)
                SetTimer(_End.Bind(Z), this.ErrorMessageDuration * -1)
                return
            case 2: Tooltip(this.ErrorMessage2, x, y, Z)
        }
        SetTimer(_End.Bind(Z), -2000)
        CoordMode('Mouse', OM)
        CoordMode('Tooltip', OT)

        _End(Z) {
            ToolTip(,,,Z)
            N.Push(Z)
        }
    }
}
