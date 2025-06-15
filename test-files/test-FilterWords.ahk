#include ..\FilterWords.ahk

; There are seven components to using `FilterWords`

; 1. A list of words
wordsall := strsplit(fileread('words.txt'), '|', '`s`t`r`n')
words := []
loop 25 {
    words.Push(wordsall[Random(1, wordsall.Length)])
}

; 2. An object that uses the words for something. In this case,
; we display them using a ListView.
g := gui('+Resize')
lv := g.Add('ListView', 'w300 r11 vcb', ['Word'])
; Add the words to the listview
for w in words {
    lv.Add(, w)
}

; 3. A function that returns the text used for filtering. Typically
; this would be some input from the user, so in this case we will
; accomplish this by using an `Edit` control and defining the function
; to return its text value.
edt := g.Add('Edit', 'w300 r1 Section vEdtInput')
GetTextCallback := ((Ctrl) => Ctrl.Text).Bind(edt)

; 4. A function that adds items to the object. The function should
; have one parameter, the string to add to the object. In this case,
; the `ListView` control already has a function for doing that, so
; we can just use that. Note that we have to bind an empty string to
; the first parameter of `Gui.ListView.Prototype.Add`.
AddCallback := ObjBindMethod(lv, 'Add', '')

; 5. A function that deletes items from the object. The function should
; have one parameter, the index of the item *in the filtered list*. Similar to
; adding, the `ListView` control also has a method for deleting.
DeleteCallback := ObjBindMethod(lv, 'Delete')

; 6. A function that compares the strings. The parameters passed to the function are 1. The array
; item being evaluated, and 2. the input string returned from #3 above. The default is `InStr`, but
; we could do something more compelex like the below function. See the bottom of this page for a
; description of this function.
FilterCallback(Item, Input) {
    LeftOffsetInput := LeftOffsetItem := 1
    RightOffsetInput := 0
    _Input := RegExReplace(Input, '\s', '')
    _Item := RegExReplace(Item, '\s', '')
    LenInput := SubLen := StrLen(_Input)
    LenItem := StrLen(_Item)
    found := []
    found.Capacity := LenInput

    loop {
        ssInput := SubStr(_Input, LeftOffsetInput, LenInput - LeftOffsetInput - RightOffsetInput + 1)
        if pos := InStr(_Item, ssInput, , LeftOffsetItem) {
            LenSsInput := StrLen(ssInput)
            LeftOffsetItem := pos + LenSsInput
            LeftOffsetInput += LenSsInput
            found.Push(LeftOffsetInput, LenInput - LeftOffsetInput - RightOffsetInput + 1, pos)
            if LeftOffsetInput > LenInput {
                return found
            } else {
                RightOffsetInput := 0
            }
        } else {
            RightOffsetInput++
            if RightOffsetInput + LeftOffsetInput > LenInput {
                return 0
            }
        }
    }
}

; 7. An event that calls the filter.
HChangeEdit(Ctrl, *) {
    ; Our event handler must disable the event handler,
    ; call the filter, then re-enable the event handler before
    ; returning.
    Ctrl.OnEvent('Change', HChangeEdit, 0)
    Ctrl.Gui.Filter.Call()
    Ctrl.OnEvent('Change', HChangeEdit, 1)
}
edt.OnEvent('Change', HChangeEdit)

; In this example I assign the reference to the `FilterWords` instance to a property on the gui object,
; but this isn't strictly necessary. In this example, it's the best place for the reference because
; it makes it easy to access the instance from gui control event handlers. But you can keep the reference
; anywhere as long as your event handler has access to the refence. Also keep in mind that, while
; the `FilterWords` function is active, to add items to the array you must call `FilterWords.Prototype.Add`,
; and to delete items you must call `FilterWords.Prototype.Delete`.
g.Filter := FilterWords(words, GetTextCallback, AddCallback, DeleteCallback, FilterCallback)

; Let's also add a couple buttons and another edit control to demonstrate adding and deleting items.
g.Add('Button', 'w93 xs ys+40 Section vBtnAdd', 'Add').OnEvent('Click', HClickButtonGeneral)
g.Add('Button', 'w93 ys vBtnDelete', 'Delete').OnEvent('Click', HClickButtonGeneral)
g.Add('Button', 'w93 ys vBtnClear', 'Clear').OnEvent('Click', (Ctrl, *) => Ctrl.Gui['EdtInput2'].Text := '')
g.Add('Edit', 'w300 xs vEdtInput2')
HClickButtonGeneral(Ctrl, *) {
    g := Ctrl.Gui
    Edt := g['EdtInput2']
    if Edt.Text {
        if g.HasOwnProp('TxtMessage') {
            g.TxtMessage.Text := ''
        }
        if InStr(Ctrl.Name, 'Add') {
            g.Filter.Add(Edt.Text)
        } else if InStr(Ctrl.Name, 'Delete') {
            g.Filter.Delete(Edt.Text)
        } else {
            throw Error('An unexpected button called ``HClickButtonGeneral``.', -1, Ctrl.Name)
        }
    } else {
        if InStr(Ctrl.Name, 'Add') {
            msg := 'Enter a word to add.'
        } else if InStr(Ctrl.Name, 'Delete') {
            msg := 'Enter a word to delete.'
        } else {
            throw Error('An unexpected button called ``HClickButtonGeneral``.', -1, Ctrl.Name)
        }
        if g.HasOwnProp('TxtMessage') {
            g.TxtMessage.Text := msg
        } else {
            g.TxtMessage := g.Add('Text', 'xs w300', msg)
            g.TxtMessage.GetPos(, &txty, , &txth)
            g.Show('h' (txty + txth + g.MarginY))
        }
    }
}

g.show()


/* Description of `FilterCallback`:

`FilterCallback` will include strings for which `InStr(Item, Input)` returns nonzero, and also
includes strings that can be described as:
- If we break the input string into a series of substrings, `FilterCallback` will return nonzero if
both of the following are true:
- Each substring is found in the item.
- The substrings are represented in the item in the same order in which they appear in the input.

The process ignores case and whitespace.

For example, the following would satisfy the condition:
Item := "This is an example item"
Input := "Is ample"

But the following would not, because the substrings are not in the correct order:
Item := "This is an example item"
Input := "Is this an item"

Though `FilterWords` doesn't make use of it, for each found substring `FilterCallback` populates an
array with integers representing these values:
[ <InputSubstringStartPos>, <InputSubstringLength>, <ItemFoundPos>, ... ]
These could be used to, for example, embolden the found substrings in a rich text control. The
handler function would need to calculate the lengths and positions including the whitespace
characters that were excluded from `FilterCallback`'s process.
