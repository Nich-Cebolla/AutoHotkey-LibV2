
#SingleInstance force
#include ..\Win32\WinEventHook.ahk
#include ..\win32\WinEventFilter.ahk

test()

class test {
    /**
     * @param {Map} [InitialCheckedEvents] - A map object where the key is the symbol name of the event
     * and the value is anything. If the map has the symbol name, it will start off checked. If the
     * map does not have the symbol name, it will start off unchecked.
     * @param {Map} [InitialCheckedObjects] - A map object where the key is the symbol name of the event
     * and the value is anything. If the map has the symbol name, it will start off checked. If the
     * map does not have the symbol name, it will start off unchecked.
     */
    static Call(InitialCheckedEvents?, InitialCheckedObjects?) {
        Test_SetConstants()
        this.ItemHandles := []
        this.LastHwnd := 0
        g := this.Gui := Gui('+Resize', , this)
        g.SetFont('s11 q5', 'Segoe Ui')
        this.pause := g.Add('Button', 'Section', 'Pause')
        this.pause.OnEvent('Click', 'HClickButtonPause')
        g.Add('Button' , 'ys', 'Exit').OnEvent('Click', (*) => ExitApp())
        g.Add('Text', 'xs Section', 'Hwnd:').GetPos(, , &_w)
        g.Add('Text', 'ys w400 vTxtValue', '0')
        this.Tv := g.Add('TreeView', 'xs w400 Section r19')
        lv := this.LvEvent := g.Add('ListView', 'ys w300 r7 Section Checked', [ 'Name' ])
        lv.OnEvent('ItemCheck', 'HItemCheckEvent')
        options := this.Options := {}
        options.Callback := WinEventCallback
        event := options.Event := this.ListEvent := []
        if IsSet(InitialCheckedEvents) {
            this.InitialCheckedEvents := InitialCheckedEvents
            flag_all_event := true
            for name, n in event_alphabetized {
                if InitialCheckedEvents.Has(name) {
                    lv.Add('Check', name)
                    event.Push(n)
                } else {
                    lv.Add(, name)
                    flag_all_event := false
                }
            }
        } else {
            for name, n in event_alphabetized {
                lv.Add('Check', name)
                event.Push(n)
            }
            flag_all_event := true
        }
        this.ChkObject := g.Add('Checkbox', 'xs', 'Check all')
        this.ChkObject.OnEvent('Click', 'HClickCheckObject')
        lv := this.LvObject := g.Add('ListView', 'xs w300 r7 Checked', [ 'Name' ])
        lv.OnEvent('ItemCheck', 'HItemCheckObject')
        obj := options.Object := this.ListObject := []
        if IsSet(InitialCheckedObjects) {
            this.InitialCheckedObjects := InitialCheckedObjects
            flag_all := true
            for name, n in object_alphabetized {
                if InitialCheckedObjects.Has(name) {
                    lv.Add('Check', name)
                    obj.Push(n)
                } else {
                    lv.Add(, name)
                    flag_all := false
                }
            }
            this.ChkObject.Value := flag_all
        } else {
            for name, n in object_alphabetized {
                lv.Add('Check', name)
                obj.Push(n)
            }
            this.ChkObject.Value := 1
        }
        this.LvEvent.GetPos(&x, &y)
        this.ChkObject.GetPos(, , , &h)
        this.ChkEvent := g.Add('Checkbox', 'x' x ' y' (y - h - g.MarginY), 'Check all')
        this.ChkEvent.OnEvent('Click', 'HClickCheckEvent')
        this.ChkEvent.Value := flag_all_event
        MonitorGet(1, &l, &t)
        g.Show('x' (l + 10) ' y' (t + 100))
        g.GetPos(&x, &y, &w)
        this.MsgReady := RegisterWindowMessage()
        OnMessage(this.MsgReady.Code, OnReady, 1)
        this.MsgExit := RegisterWindowMessage()
        ExecScript(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(FileRead('test-WinEventFilter-2.ahk')
          , 'msgReady := 0', 'msgReady := ' this.MsgReady.Code)
          , 'msgExit := 0', 'msgExit := ' this.MsgExit.Code)
          , 'hwndParent := 0', 'hwndParent := ' A_ScriptHwnd)
          , 'x := 0', 'x := ' (x + w + 10))
          , 'y := 0', 'y := ' y)
        )
        OnExit(_OnExit, 1)
        _OnExit(*) {
            if test.HasOwnProp('EventFilter') {
                test.EventFilter.Unhook()
            }
            PostMessage(this.MsgExit.Code, , , , Number(test.ScriptHwnd))
        }
    }
    static CheckAll(value, Name) {
        lv := this.Lv%Name%
        list := this.List%Name%
        if this.HasOwnProp('EventFilter') {
            this.EventFilter.Unhook()
        }
        if value {
            loop lv.GetCount() {
                lv.Modify(A_Index, '+Check')
            }
            list.Length := 0
            for n in %name%_map {
                list.Push(n)
            }
            this.EventFilter.%Name% := this.Options.%Name% := list
        } else {
            loop lv.GetCount() {
                lv.Modify(A_Index, '-Check')
            }
            if this.EventFilter.HasOwnProp(Name) {
                this.EventFilter.DeleteProp(Name)
            }
            if this.Options.HasOwnProp(Name) {
                this.Options.DeleteProp(Name)
            }
            list.Length := 0
        }
        if this.HasOwnProp('EventFilter') {
            this.EventFilter.UpdateCall()
            this.EventFilter.Hook()
        }
    }
    static HClickCheckEvent(ctrl, *) {
        this.CheckAll(ctrl.Value, 'Event')
    }
    static HClickCheckObject(ctrl, *) {
        this.CheckAll(ctrl.Value, 'Object')
    }
    static HItemCheckObject(lv, item, checked) {
        this.ItemChecked(lv, item, checked, 'Object')
    }
    static ItemChecked(lv, item, checked, name) {
        list := this.List%Name%
        if checked {
            if !list.Length {
                if this.HasOwnProp('EventFilter') {
                    this.EventFilter.Unhook()
                    this.EventFilter.%name% := list
                    this.EventFilter.UpdateCall()
                    this.EventFilter.Hook()
                }
                this.Options.%name% := list
            }
            list.Push(%lv.GetText(item, 1)%)
        } else {
            if list.Length = 1 {
                if this.HasOwnProp('EventFilter') {
                    this.EventFilter.Unhook()
                    if this.EventFilter.HasOwnProp(name) {
                        this.EventFilter.DeleteProp(name)
                    }
                    this.EventFilter.UpdateCall()
                    this.EventFilter.Hook()
                }
                if this.Options.HasOwnProp(name) {
                    this.Options.DeleteProp(name)
                }
                list.Length := 0
            } else {
                n := %lv.GetText(item, 1)%
                for _n in list {
                    if n = _n {
                        list.RemoveAt(A_Index)
                        break
                    }
                }
            }
        }
    }
    static HClickButtonPause(*) {
        if this.pause.Text = 'Pause' {
            this.EventFilter.Unhook()
            this.pause.Text := 'Resume'
        } else {
            this.EventFilter.Hook()
            this.pause.Text := 'Pause'
        }
    }
}

WinEventCallback(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime, filter) {
    tv := test.Tv
    id := tv.Add(event_map.Get(event), 0, 'First Bold')
    test.ItemHandles.Push(id)
    tv.Add('Hwnd: ' hwnd, id)
    if WinExist(hwnd) {
        tv.Add('Title: ' StrReplace(StrReplace(WinGetTitle(hwnd), '`r', '``r'), '`n', '``n'), id)
    }
    tv.Add('idObject: ' object_map.Get(idObject), id)
    tv.Add('idChild: ' idChild, id)
    tv.Add('idEventThread: ' idEventThread, id)
    tv.Add('Time: ' dwmsEventTime, id)
    handles := test.ItemHandles
    if handles.Length > 110 {
        loop handles.Length - 100 {
            tv.Delete(handles.Pop())
        }
    }
}

OnReady(wParam, lParam, msg, hwnd) {
    test.ScriptHwnd := wParam
    test.Options.Hwnd := [ wParam ]
    if test.Options.Process := DllCall('GetProcessId', 'ptr', DllCall('Oleacc.dll\GetProcessHandleFromHwnd', 'ptr', wParam, 'ptr'), 'ptr') {
        test.EventFilter := WinEventFilter(test.Options)
    } else {
        throw OSError()
    }

}

ExecScript(Script) {
    shell := ComObject('WScript.Shell')
    exec := shell.Exec('AutoHotkey.exe /ErrorStdOut *')
    exec.StdIn.Write(Script)
    exec.StdIn.Close()
}


Test_SetConstants() {
    global
; An object's KeyboardShortcut property has changed. Server applications send this event for their accessible objects.
EVENT_OBJECT_ACCELERATORCHANGE := 0x8012
; Sent when a window is cloaked. A cloaked window still exists, but is invisible to the user.
EVENT_OBJECT_CLOAKED := 0x8017
; A window object's scrolling has ended. Unlike EVENT_SYSTEM_SCROLLINGEND, this event is associated with the scrolling window. Whether the scrolling is horizontal or vertical scrolling, this event should be sent whenever the scroll action is completed.
; The hwnd parameter of the WinEventProc callback function describes the scrolling window; the idObject parameter is OBJID_CLIENT, and the idChild parameter is CHILDID_SELF.
EVENT_OBJECT_CONTENTSCROLLED := 0x8015
; An object has been created. The system sends this event for the following user interface elements: caret, header control, list-view control, tab control, toolbar control, tree view control, and window object. Server applications send this event for their accessible objects.
; Before sending the event for the parent object, servers must send it for all of an object's child objects. Servers must ensure that all child objects are fully created and ready to accept IAccessible calls from clients before the parent object sends this event.
; Because a parent object is created after its child objects, clients must make sure that an object's parent has been created before calling IAccessible::get_accParent, particularly if in-context hook functions are used.
EVENT_OBJECT_CREATE := 0x8000
; An object's DefaultAction property has changed. The system sends this event for dialog boxes. Server applications send this event for their accessible objects.
EVENT_OBJECT_DEFACTIONCHANGE := 0x8011
; An object's Description property has changed. Server applications send this event for their accessible objects.
EVENT_OBJECT_DESCRIPTIONCHANGE := 0x800D
; An object has been destroyed. The system sends this event for the following user interface elements: caret, header control, list-view control, tab control, toolbar control, tree view control, and window object. Server applications send this event for their accessible objects.
; Clients assume that all of an object's children are destroyed when the parent object sends this event.
; After receiving this event, clients do not call an object's IAccessible properties or methods. However, the interface pointer must remain valid as long as there is a reference count on it (due to COM rules), but the UI element may no longer be present. Further calls on the interface pointer may return failure errors; to prevent this, servers create proxy objects and monitor their life spans.
EVENT_OBJECT_DESTROY := 0x8001
; The user started to drag an element. The hwnd, idObject, and idChild parameters of the WinEventProc callback function identify the object being dragged.
EVENT_OBJECT_DRAGSTART := 0x8021
; The user has ended a drag operation before dropping the dragged element on a drop target. The hwnd, idObject, and idChild parameters of the WinEventProc callback function identify the object being dragged.
EVENT_OBJECT_DRAGCANCEL := 0x8022
; The user dropped an element on a drop target. The hwnd, idObject, and idChild parameters of the WinEventProc callback function identify the object being dragged.
EVENT_OBJECT_DRAGCOMPLETE := 0x8023
; The user dragged an element into a drop target's boundary. The hwnd, idObject, and idChild parameters of the WinEventProc callback function identify the drop target.
EVENT_OBJECT_DRAGENTER := 0x8024
; The user dragged an element out of a drop target's boundary. The hwnd, idObject, and idChild parameters of the WinEventProc callback function identify the drop target.
EVENT_OBJECT_DRAGLEAVE := 0x8025
; The user dropped an element on a drop target. The hwnd, idObject, and idChild parameters of the WinEventProc callback function identify the drop target.
EVENT_OBJECT_DRAGDROPPED := 0x8026
; The highest object event value.
EVENT_OBJECT_END := 0x80FF
; An object has received the keyboard focus. The system sends this event for the following user interface elements: list-view control, menu bar, pop-up menu, switch window, tab control, tree view control, and window object. Server applications send this event for their accessible objects.
; The hwnd parameter of the WinEventProc callback function identifies the window that receives the keyboard focus.
EVENT_OBJECT_FOCUS := 0x8005
; An object's Help property has changed. Server applications send this event for their accessible objects.
EVENT_OBJECT_HELPCHANGE := 0x8010
; An object is hidden. The system sends this event for the following user interface elements: caret and cursor. Server applications send this event for their accessible objects.
; When this event is generated for a parent object, all child objects are already hidden. Server applications do not send this event for the child objects.
; Hidden objects include the STATE_SYSTEM_INVISIBLE flag; shown objects do not include this flag. The EVENT_OBJECT_HIDE event also indicates that the STATE_SYSTEM_INVISIBLE flag is set. Therefore, servers do not send the EVENT_OBJECT_STATECHANGE event in this case.
EVENT_OBJECT_HIDE := 0x8003
; A window that hosts other accessible objects has changed the hosted objects. A client might need to query the host window to discover the new hosted objects, especially if the client has been monitoring events from the window. A hosted object is an object from an accessibility framework (MSAA or UI Automation) that is different from that of the host. Changes in hosted objects that are from the same framework as the host should be handed with the structural change events, such as EVENT_OBJECT_CREATE for MSAA. For more info see comments within winuser.h.
EVENT_OBJECT_HOSTEDOBJECTSINVALIDATED := 0x8020
; An IME window has become hidden.
EVENT_OBJECT_IME_HIDE := 0x8028
; An IME window has become visible.
EVENT_OBJECT_IME_SHOW := 0x8027
; The size or position of an IME window has changed.
EVENT_OBJECT_IME_CHANGE := 0x8029
; An object has been invoked; for example, the user has clicked a button. This event is supported by common controls and is used by UI Automation.
; For this event, the hwnd, ID, and idChild parameters of the WinEventProc callback function identify the item that is invoked.
EVENT_OBJECT_INVOKED := 0x8013
; An object that is part of a live region has changed. A live region is an area of an application that changes frequently and/or asynchronously.
EVENT_OBJECT_LIVEREGIONCHANGED := 0x8019
; An object has changed location, shape, or size. The system sends this event for the following user interface elements: caret and window objects. Server applications send this event for their accessible objects.
; This event is generated in response to a change in the top-level object within the object hierarchy; it is not generated for any children that the object might have. For example, if the user resizes a window, the system sends this notification for the window, but not for the menu bar, title bar, scroll bar, or other objects that have also changed.
; The system does not send this event for every non-floating child window when the parent moves. However, if an application explicitly resizes child windows as a result of resizing the parent window, the system sends multiple events for the resized children.
; If an object's State property is set to STATE_SYSTEM_FLOATING, the server sends EVENT_OBJECT_LOCATIONCHANGE whenever the object changes location. If an object does not have this state, servers only trigger this event when the object moves in relation to its parent. For this event notification, the idChild parameter of the WinEventProc callback function identifies the child object that has changed.
EVENT_OBJECT_LOCATIONCHANGE := 0x800B
; An object's Name property has changed. The system sends this event for the following user interface elements: check box, cursor, list-view control, push button, radio button, status bar control, tree view control, and window object. Server applications send this event for their accessible objects.
EVENT_OBJECT_NAMECHANGE := 0x800C
; An object has a new parent object. Server applications send this event for their accessible objects.
EVENT_OBJECT_PARENTCHANGE := 0x800F
; A container object has added, removed, or reordered its children. The system sends this event for the following user interface elements: header control, list-view control, toolbar control, and window object. Server applications send this event as appropriate for their accessible objects.
; For example, this event is generated by a list-view object when the number of child elements or the order of the elements changes. This event is also sent by a parent window when the Z-order for the child windows changes.
EVENT_OBJECT_REORDER := 0x8004
; The selection within a container object has changed. The system sends this event for the following user interface elements: list-view control, tab control, tree view control, and window object. Server applications send this event for their accessible objects.
; This event signals a single selection: either a child is selected in a container that previously did not contain any selected children, or the selection has changed from one child to another.
; The hwnd and idObject parameters of the WinEventProc callback function describe the container; the idChild parameter identifies the object that is selected. If the selected child is a window that also contains objects, the idChild parameter is OBJID_WINDOW.
EVENT_OBJECT_SELECTION := 0x8006
; A child within a container object has been added to an existing selection. The system sends this event for the following user interface elements: list box, list-view control, and tree view control. Server applications send this event for their accessible objects.
; The hwnd and idObject parameters of the WinEventProc callback function describe the container. The idChild parameter is the child that is added to the selection.
EVENT_OBJECT_SELECTIONADD := 0x8007
; An item within a container object has been removed from the selection. The system sends this event for the following user interface elements: list box, list-view control, and tree view control. Server applications send this event for their accessible objects.
; This event signals that a child is removed from an existing selection.
; The hwnd and idObject parameters of the WinEventProc callback function describe the container; the idChild parameter identifies the child that has been removed from the selection.
EVENT_OBJECT_SELECTIONREMOVE := 0x8008
; Numerous selection changes have occurred within a container object. The system sends this event for list boxes; server applications send it for their accessible objects.
; This event is sent when the selected items within a control have changed substantially. The event informs the client that many selection changes have occurred, and it is sent instead of several EVENT_OBJECT_SELECTIONADD or EVENT_OBJECT_SELECTIONREMOVE events. The client queries for the selected items by calling the container object's IAccessible::get_accSelection method and enumerating the selected items.
; For this event notification, the hwnd and idObject parameters of the WinEventProc callback function describe the container in which the changes occurred.
EVENT_OBJECT_SELECTIONWITHIN := 0x8009
; A hidden object is shown. The system sends this event for the following user interface elements: caret, cursor, and window object. Server applications send this event for their accessible objects.
; Clients assume that when this event is sent by a parent object, all child objects are already displayed. Therefore, server applications do not send this event for the child objects.
; Hidden objects include the STATE_SYSTEM_INVISIBLE flag; shown objects do not include this flag. The EVENT_OBJECT_SHOW event also indicates that the STATE_SYSTEM_INVISIBLE flag is cleared. Therefore, servers do not send the EVENT_OBJECT_STATECHANGE event in this case.
EVENT_OBJECT_SHOW := 0x8002
; An object's state has changed. The system sends this event for the following user interface elements: check box, combo box, header control, push button, radio button, scroll bar, toolbar control, tree view control, up-down control, and window object. Server applications send this event for their accessible objects.
; For example, a state change occurs when a button object is clicked or released, or when an object is enabled or disabled.
; For this event notification, the idChild parameter of the WinEventProc callback function identifies the child object whose state has changed.
EVENT_OBJECT_STATECHANGE := 0x800A
; The conversion target within an IME composition has changed. The conversion target is the subset of the IME composition which is actively selected as the target for user-initiated conversions.
EVENT_OBJECT_TEXTEDIT_CONVERSIONTARGETCHANGED := 0x8030
; An object's text selection has changed. This event is supported by common controls and is used by UI Automation.
; The hwnd, ID, and idChild parameters of the WinEventProc callback function describe the item that is contained in the updated text selection.
EVENT_OBJECT_TEXTSELECTIONCHANGED := 0x8014
; Sent when a window is uncloaked. A cloaked window still exists, but is invisible to the user.
EVENT_OBJECT_UNCLOAKED := 0x8018
; An object's Value property has changed. The system sends this event for the user interface elements that include the scroll bar and the following controls: edit, header, hot key, progress bar, slider, and up-down. Server applications send this event for their accessible objects.
EVENT_OBJECT_VALUECHANGE := 0x800E
; An alert has been generated. Server applications should not send this event.
EVENT_SYSTEM_ALERT := 0x0002
; A preview rectangle is being displayed.
EVENT_SYSTEM_ARRANGMENTPREVIEW := 0x8016
; A window has lost mouse capture. This event is sent by the system, never by servers.
EVENT_SYSTEM_CAPTUREEND := 0x0009
; A window has received mouse capture. This event is sent by the system, never by servers.
EVENT_SYSTEM_CAPTURESTART := 0x0008
; A window has exited context-sensitive Help mode. This event is not sent consistently by the system.
EVENT_SYSTEM_CONTEXTHELPEND := 0x000D
; A window has entered context-sensitive Help mode. This event is not sent consistently by the system.
EVENT_SYSTEM_CONTEXTHELPSTART := 0x000C
; The active desktop has been switched.
EVENT_SYSTEM_DESKTOPSWITCH := 0x0020
; A dialog box has been closed. The system sends this event for standard dialog boxes; servers send it for custom dialog boxes. This event is not sent consistently by the system.
EVENT_SYSTEM_DIALOGEND := 0x0011
; A dialog box has been displayed. The system sends this event for standard dialog boxes, which are created using resource templates or Win32 dialog box functions. Servers send this event for custom dialog boxes, which are windows that function as dialog boxes but are not created in the standard way.
; This event is not sent consistently by the system.
EVENT_SYSTEM_DIALOGSTART := 0x0010
; An application is about to exit drag-and-drop mode. Applications that support drag-and-drop operations must send this event; the system does not send this event.
EVENT_SYSTEM_DRAGDROPEND := 0x000F
; An application is about to enter drag-and-drop mode. Applications that support drag-and-drop operations must send this event because the system does not send it.
EVENT_SYSTEM_DRAGDROPSTART := 0x000E
; The highest system event value.
EVENT_SYSTEM_END := 0x00FF
; The foreground window has changed. The system sends this event even if the foreground window has changed to another window in the same thread. Server applications never send this event.
; For this event, the WinEventProc callback function's hwnd parameter is the handle to the window that is in the foreground, the idObject parameter is OBJID_WINDOW, and the idChild parameter is CHILDID_SELF.
EVENT_SYSTEM_FOREGROUND := 0x0003
; A pop-up menu has been closed. The system sends this event for standard menus; servers send it for custom menus.
; When a pop-up menu is closed, the client receives this message, and then the EVENT_SYSTEM_MENUEND event.
; This event is not sent consistently by the system.
EVENT_SYSTEM_MENUPOPUPEND := 0x0007
; A pop-up menu has been displayed. The system sends this event for standard menus, which are identified by HMENU, and are created using menu-template resources or Win32 menu functions. Servers send this event for custom menus, which are user interface elements that function as menus but are not created in the standard way. This event is not sent consistently by the system.
EVENT_SYSTEM_MENUPOPUPSTART := 0x0006
; A menu from the menu bar has been closed. The system sends this event for standard menus; servers send it for custom menus.
; For this event, the WinEventProc callback function's hwnd, idObject, and idChild parameters refer to the control that contains the menu bar or the control that activates the context menu. The hwnd parameter is the handle to the window that is related to the event. The idObject parameter is OBJID_MENU or OBJID_SYSMENU for a menu, or OBJID_WINDOW for a pop-up menu. The idChild parameter is CHILDID_SELF.
EVENT_SYSTEM_MENUEND := 0x0005
; A menu item on the menu bar has been selected. The system sends this event for standard menus, which are identified by HMENU, created using menu-template resources or Win32 menu API elements. Servers send this event for custom menus, which are user interface elements that function as menus but are not created in the standard way.
; For this event, the WinEventProc callback function's hwnd, idObject, and idChild parameters refer to the control that contains the menu bar or the control that activates the context menu. The hwnd parameter is the handle to the window related to the event. The idObject parameter is OBJID_MENU or OBJID_SYSMENU for a menu, or OBJID_WINDOW for a pop-up menu. The idChild parameter is CHILDID_SELF.
; The system triggers more than one EVENT_SYSTEM_MENUSTART event that does not always correspond with the EVENT_SYSTEM_MENUEND event.
EVENT_SYSTEM_MENUSTART := 0x0004
; A window object is about to be restored. This event is sent by the system, never by servers.
EVENT_SYSTEM_MINIMIZEEND := 0x0017
; A window object is about to be minimized. This event is sent by the system, never by servers.
EVENT_SYSTEM_MINIMIZESTART := 0x0016
; The movement or resizing of a window has finished. This event is sent by the system, never by servers.
EVENT_SYSTEM_MOVESIZEEND := 0x000B
; A window is being moved or resized. This event is sent by the system, never by servers.
EVENT_SYSTEM_MOVESIZESTART := 0x000A
; Scrolling has ended on a scroll bar. This event is sent by the system for standard scroll bar controls and for scroll bars that are attached to a window. Servers send this event for custom scroll bars, which are user interface elements that function as scroll bars but are not created in the standard way.
; The idObject parameter that is sent to the WinEventProc callback function is OBJID_HSCROLL for horizontal scroll bars, and OBJID_VSCROLL for vertical scroll bars.
EVENT_SYSTEM_SCROLLINGEND := 0x0013
; Scrolling has started on a scroll bar. The system sends this event for standard scroll bar controls and for scroll bars attached to a window. Servers send this event for custom scroll bars, which are user interface elements that function as scroll bars but are not created in the standard way.
; The idObject parameter that is sent to the WinEventProc callback function is OBJID_HSCROLL for horizontal scrolls bars, and OBJID_VSCROLL for vertical scroll bars.
EVENT_SYSTEM_SCROLLINGSTART := 0x0012
; A sound has been played. The system sends this event when a system sound, such as one for a menu, is played even if no sound is audible (for example, due to the lack of a sound file or a sound card). Servers send this event whenever a custom UI element generates a sound.
; For this event, the WinEventProc callback function receives the OBJID_SOUND value as the idObject parameter.
EVENT_SYSTEM_SOUND := 0x0001
; The user has released ALT+TAB. This event is sent by the system, never by servers. The hwnd parameter of the WinEventProc callback function identifies the window to which the user has switched.
; If only one application is running when the user presses ALT+TAB, the system sends this event without a corresponding EVENT_SYSTEM_SWITCHSTART event.
EVENT_SYSTEM_SWITCHEND := 0x0015
; The user has pressed ALT+TAB, which activates the switch window. This event is sent by the system, never by servers. The hwnd parameter of the WinEventProc callback function identifies the window to which the user is switching.
; If only one application is running when the user presses ALT+TAB, the system sends an EVENT_SYSTEM_SWITCHEND event without a corresponding EVENT_SYSTEM_SWITCHSTART event.
EVENT_SYSTEM_SWITCHSTART := 0x0014
    event_map := Map(
        EVENT_OBJECT_CONTENTSCROLLED, 'EVENT_OBJECT_CONTENTSCROLLED'
      , EVENT_OBJECT_CREATE, 'EVENT_OBJECT_CREATE'
      , EVENT_OBJECT_DESTROY, 'EVENT_OBJECT_DESTROY'
      , EVENT_OBJECT_FOCUS, 'EVENT_OBJECT_FOCUS'
      , EVENT_OBJECT_HIDE, 'EVENT_OBJECT_HIDE'
      , EVENT_OBJECT_INVOKED, 'EVENT_OBJECT_INVOKED'
      , EVENT_OBJECT_LOCATIONCHANGE, 'EVENT_OBJECT_LOCATIONCHANGE'
      , EVENT_OBJECT_NAMECHANGE, 'EVENT_OBJECT_NAMECHANGE'
      , EVENT_OBJECT_TEXTSELECTIONCHANGED, 'EVENT_OBJECT_TEXTSELECTIONCHANGED'
      , EVENT_SYSTEM_FOREGROUND, 'EVENT_SYSTEM_FOREGROUND'
      , EVENT_SYSTEM_MOVESIZEEND, 'EVENT_SYSTEM_MOVESIZEEND'
      , EVENT_SYSTEM_MOVESIZESTART, 'EVENT_SYSTEM_MOVESIZESTART'
      , EVENT_SYSTEM_SCROLLINGEND, 'EVENT_SYSTEM_SCROLLINGEND'
      , EVENT_SYSTEM_SCROLLINGSTART, 'EVENT_SYSTEM_SCROLLINGSTART'
      , EVENT_OBJECT_SHOW, 'EVENT_OBJECT_SHOW'
      , EVENT_OBJECT_ACCELERATORCHANGE, 'EVENT_OBJECT_ACCELERATORCHANGE'
      , EVENT_OBJECT_CLOAKED, 'EVENT_OBJECT_CLOAKED'
      , EVENT_OBJECT_CONTENTSCROLLED, 'EVENT_OBJECT_CONTENTSCROLLED'
      , EVENT_OBJECT_CREATE, 'EVENT_OBJECT_CREATE'
      , EVENT_OBJECT_DEFACTIONCHANGE, 'EVENT_OBJECT_DEFACTIONCHANGE'
      , EVENT_OBJECT_DESCRIPTIONCHANGE, 'EVENT_OBJECT_DESCRIPTIONCHANGE'
      , EVENT_OBJECT_DESTROY, 'EVENT_OBJECT_DESTROY'
      , EVENT_OBJECT_DRAGSTART, 'EVENT_OBJECT_DRAGSTART'
      , EVENT_OBJECT_DRAGCANCEL, 'EVENT_OBJECT_DRAGCANCEL'
      , EVENT_OBJECT_DRAGCOMPLETE, 'EVENT_OBJECT_DRAGCOMPLETE'
      , EVENT_OBJECT_DRAGENTER, 'EVENT_OBJECT_DRAGENTER'
      , EVENT_OBJECT_DRAGLEAVE, 'EVENT_OBJECT_DRAGLEAVE'
      , EVENT_OBJECT_DRAGDROPPED, 'EVENT_OBJECT_DRAGDROPPED'
      , EVENT_OBJECT_END, 'EVENT_OBJECT_END'
      , EVENT_OBJECT_FOCUS, 'EVENT_OBJECT_FOCUS'
      , EVENT_OBJECT_HELPCHANGE, 'EVENT_OBJECT_HELPCHANGE'
      , EVENT_OBJECT_HIDE, 'EVENT_OBJECT_HIDE'
      , EVENT_OBJECT_HOSTEDOBJECTSINVALIDATED, 'EVENT_OBJECT_HOSTEDOBJECTSINVALIDATED'
      , EVENT_OBJECT_IME_HIDE, 'EVENT_OBJECT_IME_HIDE'
      , EVENT_OBJECT_IME_SHOW, 'EVENT_OBJECT_IME_SHOW'
      , EVENT_OBJECT_IME_CHANGE, 'EVENT_OBJECT_IME_CHANGE'
      , EVENT_OBJECT_INVOKED, 'EVENT_OBJECT_INVOKED'
      , EVENT_OBJECT_LIVEREGIONCHANGED, 'EVENT_OBJECT_LIVEREGIONCHANGED'
      , EVENT_OBJECT_LOCATIONCHANGE, 'EVENT_OBJECT_LOCATIONCHANGE'
      , EVENT_OBJECT_NAMECHANGE, 'EVENT_OBJECT_NAMECHANGE'
      , EVENT_OBJECT_PARENTCHANGE, 'EVENT_OBJECT_PARENTCHANGE'
      , EVENT_OBJECT_REORDER, 'EVENT_OBJECT_REORDER'
      , EVENT_OBJECT_SELECTION, 'EVENT_OBJECT_SELECTION'
      , EVENT_OBJECT_SELECTIONADD, 'EVENT_OBJECT_SELECTIONADD'
      , EVENT_OBJECT_SELECTIONREMOVE, 'EVENT_OBJECT_SELECTIONREMOVE'
      , EVENT_OBJECT_SELECTIONWITHIN, 'EVENT_OBJECT_SELECTIONWITHIN'
      , EVENT_OBJECT_SHOW, 'EVENT_OBJECT_SHOW'
      , EVENT_OBJECT_STATECHANGE, 'EVENT_OBJECT_STATECHANGE'
      , EVENT_OBJECT_TEXTEDIT_CONVERSIONTARGETCHANGED, 'EVENT_OBJECT_TEXTEDIT_CONVERSIONTARGETCHANGED'
      , EVENT_OBJECT_TEXTSELECTIONCHANGED, 'EVENT_OBJECT_TEXTSELECTIONCHANGED'
      , EVENT_OBJECT_UNCLOAKED, 'EVENT_OBJECT_UNCLOAKED'
      , EVENT_OBJECT_VALUECHANGE, 'EVENT_OBJECT_VALUECHANGE'
      , EVENT_SYSTEM_ALERT, 'EVENT_SYSTEM_ALERT'
      , EVENT_SYSTEM_ARRANGMENTPREVIEW, 'EVENT_SYSTEM_ARRANGMENTPREVIEW'
      , EVENT_SYSTEM_CAPTUREEND, 'EVENT_SYSTEM_CAPTUREEND'
      , EVENT_SYSTEM_CAPTURESTART, 'EVENT_SYSTEM_CAPTURESTART'
      , EVENT_SYSTEM_CONTEXTHELPEND, 'EVENT_SYSTEM_CONTEXTHELPEND'
      , EVENT_SYSTEM_CONTEXTHELPSTART, 'EVENT_SYSTEM_CONTEXTHELPSTART'
      , EVENT_SYSTEM_DESKTOPSWITCH, 'EVENT_SYSTEM_DESKTOPSWITCH'
      , EVENT_SYSTEM_DIALOGEND, 'EVENT_SYSTEM_DIALOGEND'
      , EVENT_SYSTEM_DIALOGSTART, 'EVENT_SYSTEM_DIALOGSTART'
      , EVENT_SYSTEM_DRAGDROPEND, 'EVENT_SYSTEM_DRAGDROPEND'
      , EVENT_SYSTEM_DRAGDROPSTART, 'EVENT_SYSTEM_DRAGDROPSTART'
      , EVENT_SYSTEM_END, 'EVENT_SYSTEM_END'
      , EVENT_SYSTEM_FOREGROUND, 'EVENT_SYSTEM_FOREGROUND'
      , EVENT_SYSTEM_MENUPOPUPEND, 'EVENT_SYSTEM_MENUPOPUPEND'
      , EVENT_SYSTEM_MENUPOPUPSTART, 'EVENT_SYSTEM_MENUPOPUPSTART'
      , EVENT_SYSTEM_MENUEND, 'EVENT_SYSTEM_MENUEND'
      , EVENT_SYSTEM_MENUSTART, 'EVENT_SYSTEM_MENUSTART'
      , EVENT_SYSTEM_MINIMIZEEND, 'EVENT_SYSTEM_MINIMIZEEND'
      , EVENT_SYSTEM_MINIMIZESTART, 'EVENT_SYSTEM_MINIMIZESTART'
      , EVENT_SYSTEM_MOVESIZEEND, 'EVENT_SYSTEM_MOVESIZEEND'
      , EVENT_SYSTEM_MOVESIZESTART, 'EVENT_SYSTEM_MOVESIZESTART'
      , EVENT_SYSTEM_SCROLLINGEND, 'EVENT_SYSTEM_SCROLLINGEND'
      , EVENT_SYSTEM_SCROLLINGSTART, 'EVENT_SYSTEM_SCROLLINGSTART'
      , EVENT_SYSTEM_SOUND, 'EVENT_SYSTEM_SOUND'
      , EVENT_SYSTEM_SWITCHEND, 'EVENT_SYSTEM_SWITCHEND'
      , EVENT_SYSTEM_SWITCHSTART, 'EVENT_SYSTEM_SWITCHSTART'
    )
    event_alphabetized := Map()
    for n, name in event_map {
        event_alphabetized.Set(name, n)
    }
    object_map := Map(
        OBJID_WINDOW, 'OBJID_WINDOW'
      , OBJID_SYSMENU, 'OBJID_SYSMENU'
      , OBJID_TITLEBAR, 'OBJID_TITLEBAR'
      , OBJID_MENU, 'OBJID_MENU'
      , OBJID_CLIENT, 'OBJID_CLIENT'
      , OBJID_VSCROLL, 'OBJID_VSCROLL'
      , OBJID_HSCROLL, 'OBJID_HSCROLL'
      , OBJID_SIZEGRIP, 'OBJID_SIZEGRIP'
      , OBJID_CARET, 'OBJID_CARET'
      , OBJID_CURSOR, 'OBJID_CURSOR'
      , OBJID_ALERT, 'OBJID_ALERT'
      , OBJID_SOUND, 'OBJID_SOUND'
      , OBJID_QUERYCLASSNAMEIDX, 'OBJID_QUERYCLASSNAMEIDX'
      , OBJID_NATIVEOM, 'OBJID_NATIVEOM'
    )
    object_alphabetized := Map()
    for n, name in object_map {
        object_alphabetized.Set(name, n)
    }
    event_map.Default := object_map.Default := 0
}
ShowTooltip(Str) {
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

/*

    https://github.com/Nich-Cebolla/AutoHotkey-Interprocess-Communication

*/

class RegisterWindowMessage {
    /**
     * @description - Use {@link RegisterWindowMessage} to obtain a window message code that can
     * be shared across processes and that does not conflict with codes in use by the system or
     * other applications.
     * @example
     * ; Make the script persistent so it doesn't
     * ; exit before the message is received
     * Persistent
     * ; Get a unique window message code
     * wmComplete := RegisterWindowMessage()
     * ; Define a function to be called when the
     * ; script's window receives a message with
     * ; the code
     * OnMessageComplete(*) {
     *     MsgBox("Complete!")
     *     ExitApp()
     * }
     * ; Call `OnMessage`
     * OnMessage(wmComplete.Code, OnMessageComplete, 1)
     * ; Define ahk code as a string.
     * ; Use the `Format` function to input
     * ; the window message code and this
     * ; script's hwnd. Call `PostMessage`.
     * ahkCode := Format(
     * "    code := {1}`n"
     * "    hwnd := {2}`n"
     * "    PostMessage(code, 0, 0, , hwnd)"
     * , wmComplete.Code
     * , A_ScriptHwnd
     * )
     * ; Execute the string as code as a
     * ; new process.
     * shell := ComObject('WScript.Shell')
     * exec := shell.Exec('"' A_AhkPath '" *')
     * exec.StdIn.Write(ahkCode)
     * exec.StdIn.Close()
     * @
     * @class
     *
     * See {@link https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-registerwindowmessagew}.
     *
     * @param {String} Name - The name associated with the window message. When this calls
     * `RegisterWindowMessage`, if the name is already in use, the system returns the same window
     * message that was returned when `RegisterWindowMessage` was first called using that name, so
     * all processes will receive the same number. If the name is not in use, `RegisterWindowMessage`
     * returns a number that has not yet been registered by the system.
     *
     * <!-- Note: If you are reading this from the source file, the backslashes below are escaped so the
     * markdown renderer displays them correctly. Treat each backslash pair as a single backslash. -->
     *
     * To direct {@link RegisterWindowMessage.Prototype.__New} to generate a random name, set
     * `Name` with any string that ends with a backslash optionally followed by a number
     * representing the number of characters to include in the name. If the string ends in only
     * a backslash, a random string of 16 characters is appended to the string. Your code can begin
     * the string with any valid string to use as a prefix, and the random characters will be appended
     * to the prefix. For example, each of the following are valid for producing a random name:
     * - "\\" - generates a random name of 16 characters.
     * - "\\20" - generates a random name of 20 characters.
     * - "MyAppName_\\" - generates a random name of 16 characters and appends it to "MyAppName_".
     * - "MyAppName\\14" - generates a random name of 14 characters and appends it to "MyAppName".
     * - "Ajmz(eOO\\10" - generates a random name of 10 characters and appends it to "Ajmz(eOO".
     *
     * The random characters fall between code points 33 - 126, inclusive. If your application requires
     * a different set of characters to be used, set the `Chars` parameter with an array of strings
     * where each item in the array is a substring that can be used when generating the string.
     *
     * Using a random name has the benefit of preventing a scenario where a bad-actor blocks your
     * application from functioning intentionally by preemptively calling `RegisterWindowMessage` with
     * a name known to be used by your application. It is also helpful for avoiding a scenario where
     * your application attempts to use the same name as another application coincidentally.
     *
     * @param {String[]} [Chars] - If set, an array of strings where each item in the array is a
     * substring that can be included in a randomly generated name. If unset, characters between
     * 33 - 126 inclusive are used. See the description of parameter `Name` for more information.
     */
    __New(Name?, Chars?) {
        if IsSet(Name) {
            if RegExMatch(Name, '\\(\d*)$', &match) {
                Name := SubStr(Name, 1, match.Pos - 1)
                _Proc(match[1] || 16)
            }
        } else {
            Name := ''
            _Proc(16)
        }
        this.Name := Name
        if !(this.Code := DllCall('RegisterWindowMessageW', 'str', Name, 'uint')) {
            throw OSError()
        }

        return

        _Proc(n) {
            if IsSet(Chars) {
                len := Chars.Length
                loop n {
                    Name .= Chars[Random(1, len)]
                }
            } else {
                loop n {
                    Name .= Chr(Random(33, 126))
                }
            }
        }
    }
}
