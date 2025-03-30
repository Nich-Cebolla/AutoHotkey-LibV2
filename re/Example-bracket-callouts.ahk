/*
    This example demonstrates how to extract every substring enclosed by curly braces within a source
    file. Every time an open or close bracket is found, the function saves the matched content. While
    this is occurring, the function also keeps track of the text that precedes the open bracket, to
    contextualize what the substring represents. When you launch this script you will get a small
    GUI. Click the "Example1" button to run the example, then you can scroll through the matched
    content using the other buttons. Notice how there's no loops in the function; the callout
    functions are called each time the corresponding bracket is found all within a single RegExMatch
    call.

    The GUI window displays the substrings out-of-order
*/
#SingleInstance force



Example1(Ctrl, *) {
    local LastCtrl := Ctrl
    G := Ctrl.Gui

    ; Two modifications to the pattern in Re.Pattern.BracketCurly. I have added the callout syntax
    ; for two functions, OnOpenBrace and OnCloseBrace.
    Pattern := '(?<full>\{(?COnOpenBrace)(?<inner>[^}{]++|(?-2))*\}(?COnCloseBrace))'

    ; `tracker` is used within the OnOpenBrace callout to store information related to the open brace
    ; When OnCloseBrace is called, that information is removed from the array and used to construct
    ; the full substring enclosed by the bracketed text.
    tracker := []

    ; These values don't have a functional purpose in the context of what this example is
    ; demonstrating. I'm tracking them just to display in the GUI window.
    tracker.sequence := tracker.close := tracker.open := tracker.complete := 0

    ; Call the function.
    RegExMatch(G['content'].Text, Pattern, &Match)

    OnOpenBrace(Match, *) {
        ; The value contained in Match[0] is the matched content -- up to this point in the current match --
        MatchedContent := Match[0]

        ; A little arithmetic to get the preceding text.
        LastNewlinePos := InStr(SubStr(G['content'].Text, 1, Match.Pos + Match.Len - 1), '`n', , -1)
        Preceding := Trim(SubStr(G['content'].Text, LastNewlinePos + 1, Match.Pos + Match.Len - LastNewlinePos - 2), '`s`t`r`n')

        ; Store the relevant information.
        tracker.Push({ Pos: Match.Pos + Match.Len - 1, Preceding: Preceding })
        
        MsgBox('Open brace found`r`n' Match[0])

        ; Below here is just GUI things.
        LastCtrl.GetPos(&cx, &cy, , &ch)
        if cy + ch * 2 + G.MarginY > 500
            cx := 120, cy := 0 - ch
        (LastCtrl := G.Add('Button', Format('x{} y{} w100 vopen{}', cx, cy + ch + G.MarginY, ++tracker.open), 'Open ' tracker.open)).OnEvent('Click', HClickButtonUpdateContent).Content := {
            Which: 'OnOpenBrace content #' tracker.open
            , N: tracker.open
            , Content: MatchedContent
            , Sequence: ++tracker.sequence
        }
    }

    OnCloseBrace(Match, *) {
        ; Pull the last content from OnOpenBrace.
        Open := tracker.Pop()

        ; We have to reconstruct the substring that is contained in the bracketed text using the
        ; position value obtained in OnOpenBrace, and pair it with the preceding text also obtained
        ; in OnOpenBrace.
        CompleteContent := Open.Preceding ' ' SubStr(G['content'].Text, Open.Pos, Match.Pos + Match.Len - Open.Pos)

        ; The value contained in Match[0] is the matched content -- up to this point in the current match --
        MatchedContent := Match[0]

        MsgBox('Close brace found`r`n' Match[0])

        ; Below here is just GUI things.
        LastCtrl.GetPos(&cx, &cy, , &ch)
        if cy + ch * 2 + G.MarginY > 500
            cx := 120, cy := 0 - ch
        (LastCtrl := G.Add('Button', Format('x{} y{} w100 vclose{}', cx, cy + ch + G.MarginY, ++tracker.close)
        , 'Close ' tracker.close)).OnEvent('Click', HClickButtonUpdateContent).Content := {
            Which: 'OnCloseBrace content #' tracker.close
            , N: tracker.close
            , Content: MatchedContent
            , Sequence: ++tracker.sequence
        }
        LastCtrl.GetPos(&cx, &cy, , &ch)
        if cy + ch * 2 + G.MarginY > 500
            cx := 120, cy := 0 - ch
        (LastCtrl := G.Add('Button', Format('x{} y{} w100 vcomplete{}', cx, cy + ch + G.MarginY, ++tracker.complete)
        , 'Complete ' tracker.complete)).OnEvent('Click', HClickButtonUpdateContent).Content := {
            Which: 'Complete bracketed text #' tracker.complete
            , N: tracker.complete
            , Content: CompleteContent
            , Sequence: ++tracker.sequence
        }
    }

    HClickButtonUpdateContent(Ctrl, *) {
        Content := Ctrl.Content
        G := Ctrl.Gui
        G['header'].Text := Content.Which '`r`nIndex order: ' Content.Sequence
        G['match'].Text := Content.Content
    }

}


SetControlFunctions()

G := Gui('+Resize -DPIScale')
G.SetFont('s10', 'Consolas')
G.Add('Button', 'w100 Section vexample1', 'Example 1').OnEvent('Click', Example1)
G.SetFont('s11', 'Consolas')
G.Add('Text', 'x230 y5 w500 r2 Section vheader').GetPos(&x,,, &h)
G.Add('Edit', Format('x{} w500 h{} -wrap +hscroll vmatch', x, 500 - h - G.MarginY))
G.Add('Edit', 'ys w500 h500 -wrap +hscroll vcontent', Trim(FileRead('Example-bracket-Callouts-subject.ahk'), '`r`n'))
G.SetFont('s10', 'Consolas')
G.Show()



SetControlFunctions() {
    CTRL_ONEVENT := Gui.Control.Prototype.OnEvent
    Gui.Control.Prototype.DefineProp('OnEvent', { Call: CTRL_NEWONEVENT.Bind(CTRL_ONEVENT) })
    CTRL_NEWONEVENT(OldOnevent, Ctrl, EventType, Function) {
        OldOnevent(Ctrl, EventType, Function)
        return Ctrl
    }
}