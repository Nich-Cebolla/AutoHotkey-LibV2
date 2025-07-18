; I have not released TestInterface yet, you cannot run this test.
#include <TestInterfaceConfig>
#include <ResolveRelativePath>

#include ..\test-code-template-makers\rect-instance.ahk

; #include any scripts
#include ..\..\structs\Rect.ahk
#include ..\..\structs\Point.ahk
#include ..\..\structs\WindowInfo.ahk


test_rect.Instance()

class test_rect extends test {
    static Call() {
        ; Filter := PropsInfo.FilterGroup()

        ; Filter := PropsInfo.FilterGroup(FilterFunc)

        ; FilterFunc(InfoItem) {

        ; }
        Subjects := TestInterface.SubjectCollection()

        ; Point
        ;  := ScriptParser('C:\Users\Shared\001_Repos\AutoHotkey-LibV2\structs\Point.ahk')
        ; Point
        PropsInfo_Point := GetPropsInfo(Point, , , false)
        Subjects.Add('Point', PropsInfo_Point)
        Subjects.Get('Point').InitialValues := Map()
        ; Methods
        Subjects.Get('Point').InitialValues.Set('Call', [, ])
        Subjects.Get('Point').InitialValues.Set('ClientToScreen', [, ])
        Subjects.Get('Point').InitialValues.Set('FromMouse', [, ])
        Subjects.Get('Point').InitialValues.Set('GetCaretPos', [, ])
        Subjects.Get('Point').InitialValues.Set('LogToPhysical', [, ])
        Subjects.Get('Point').InitialValues.Set('PhysicalToLog', [, ])
        Subjects.Get('Point').InitialValues.Set('ScreenToClient', [, ])
        Subjects.Get('Point').InitialValues.Set('SetCaretPos', [, ])

        ; Rect
        ;  := ScriptParser('C:\Users\Shared\001_Repos\AutoHotkey-LibV2\structs\Rect.ahk')
        ; Rect
        PropsInfo_Rect := GetPropsInfo(Rect, , , false)
        Subjects.Add('Rect', PropsInfo_Rect)
        Subjects.Get('Rect').InitialValues := Map()
        ; Methods
        Subjects.Get('Rect').InitialValues.Set('__Call', [, ])
        Subjects.Get('Rect').InitialValues.Set('Call', [, ])
        Subjects.Get('Rect').InitialValues.Set('FromDimensions', [, ])
        Subjects.Get('Rect').InitialValues.Set('FromPtr', [, ])
        Subjects.Get('Rect').InitialValues.Set('Intersect', [, ])
        Subjects.Get('Rect').InitialValues.Set('Make', [, ])
        Subjects.Get('Rect').InitialValues.Set('Order', [, ])
        Subjects.Get('Rect').InitialValues.Set('Split', [, ])
        Subjects.Get('Rect').InitialValues.Set('Union', [, ])

        ; RectBase
        PropsInfo_RectBase := GetPropsInfo(RectBase, , , false)
        Subjects.Add('RectBase', PropsInfo_RectBase)
        Subjects.Get('RectBase').InitialValues := Map()
        ; Methods
        Subjects.Get('RectBase').InitialValues.Set('__Call', [, ])
        Subjects.Get('RectBase').InitialValues.Set('Call', [, ])
        Subjects.Get('RectBase').InitialValues.Set('Make', [, ])

        ; WinRect
        PropsInfo_WinRect := GetPropsInfo(WinRect, , , false)
        Subjects.Add('WinRect', PropsInfo_WinRect)
        Subjects.Get('WinRect').InitialValues := Map()
        ; Methods
        Subjects.Get('WinRect').InitialValues.Set('__Call', [, ])
        Subjects.Get('WinRect').InitialValues.Set('Call', [, ])
        Subjects.Get('WinRect').InitialValues.Set('FromDimensions', [, ])
        Subjects.Get('WinRect').InitialValues.Set('FromPtr', [, ])
        Subjects.Get('WinRect').InitialValues.Set('Intersect', [, ])
        Subjects.Get('WinRect').InitialValues.Set('Make', [, ])
        Subjects.Get('WinRect').InitialValues.Set('Order', [, ])
        Subjects.Get('WinRect').InitialValues.Set('Split', [, ])
        Subjects.Get('WinRect').InitialValues.Set('Union', [, ])

        ; Functions
        Subjects.AddFunc(RECT_GetCoordinate)
        Subjects.Get('RECT_GetCoordinate').InitialValues := []
        Subjects.AddFunc(RECT_GetDpi)
        Subjects.Get('RECT_GetDpi').InitialValues := []
        Subjects.AddFunc(RECT_GetLength)
        Subjects.Get('RECT_GetLength').InitialValues := []
        Subjects.AddFunc(RECT_GetPoint)
        Subjects.Get('RECT_GetPoint').InitialValues := []
        Subjects.AddFunc(RECT_GetSegment)
        Subjects.Get('RECT_GetSegment').InitialValues := []
        Subjects.AddFunc(RECT_Intersect)
        Subjects.Get('RECT_Intersect').InitialValues := []
        Subjects.AddFunc(RECT_Move)
        Subjects.Get('RECT_Move').InitialValues := []
        Subjects.AddFunc(RECT_Union)
        Subjects.Get('RECT_Union').InitialValues := []
        Subjects.AddFunc(WINRECT_Move)
        Subjects.Get('WINRECT_Move').InitialValues := []
        Subjects.AddFunc(WINRECT_MoveOnly)
        Subjects.Get('WINRECT_MoveOnly').InitialValues := []
        ; WindowInfo
        ;  := ScriptParser('C:\Users\Shared\001_Repos\AutoHotkey-LibV2\structs\WindowInfo.ahk')
        ; WindowInfo
        PropsInfo_WindowInfo := GetPropsInfo(WindowInfo, , , false)
        Subjects.Add('WindowInfo', PropsInfo_WindowInfo)
        Subjects.Get('WindowInfo').InitialValues := Map()
        ; Methods
        Subjects.Get('WindowInfo').InitialValues.Set('__Call', [, ])
        Subjects.Get('WindowInfo').InitialValues.Set('Call', [, ])


        TI := this.TI := TestInterface('Rect', Subjects)
    }

    static Instance() {
        Subjects := this.GetSubjects()
        ; Uis
        ; PropsInfo_Uis := GetPropsInfo(Uis, '-Array', , false)
        ; Subjects.Add('Uis', PropsInfo_Uis)
        Subjects.Get('Uis').InitialValues := Map()

        ; Edits
        ; PropsInfo_Edits := GetPropsInfo(Edits, '-Array', , false)
        ; Subjects.Add('Edits', PropsInfo_Edits)
        Subjects.Get('Edits').InitialValues := Map()

        ; window_rect
        ; PropsInfo_window_rect := GetPropsInfo(window_rect, '-Buffer', , false)
        ; Subjects.Add('window_rect', PropsInfo_window_rect)
        Subjects.Get('window_rect').InitialValues := Map()
        ; Methods
        Subjects.Get('window_rect').InitialValues.Set('__Call', [, ])
        Subjects.Get('window_rect').InitialValues.Set('__New', [, ])
        Subjects.Get('window_rect').InitialValues.Set('ChildFromPoint', [, ])
        Subjects.Get('window_rect').InitialValues.Set('ChildWindowFromPointEx', [, ])
        Subjects.Get('window_rect').InitialValues.Set('EnumChildWindows', [, ])
        Subjects.Get('window_rect').InitialValues.Set('GetPos', [, ])
        Subjects.Get('window_rect').InitialValues.Set('Intersect', [, ])
        Subjects.Get('window_rect').InitialValues.Set('IsChild', [, ])
        Subjects.Get('window_rect').InitialValues.Set('IsParent', [, ])
        Subjects.Get('window_rect').InitialValues.Set('IsVisible', [, ])
        Subjects.Get('window_rect').InitialValues.Set('Move', [, ])
        Subjects.Get('window_rect').InitialValues.Set('MoveAdjacent', [, ])
        Subjects.Get('window_rect').InitialValues.Set('MoveOnly', [, ])
        Subjects.Get('window_rect').InitialValues.Set('RealChildFromPoint', [, ])
        Subjects.Get('window_rect').InitialValues.Set('Show', [, ])
        Subjects.Get('window_rect').InitialValues.Set('Split', [, ])
        Subjects.Get('window_rect').InitialValues.Set('ToClient', [, ])
        Subjects.Get('window_rect').InitialValues.Set('ToScreen', [, ])
        Subjects.Get('window_rect').InitialValues.Set('Union', [, ])
        ; Get accessors
        Subjects.Get('window_rect').InitialValues.Set('B', [, ])
        Subjects.Get('window_rect').InitialValues.Set('BR', [, ])
        Subjects.Get('window_rect').InitialValues.Set('Dpi', [, ])
        Subjects.Get('window_rect').InitialValues.Set('H', [, ])
        Subjects.Get('window_rect').InitialValues.Set('L', [, ])
        Subjects.Get('window_rect').InitialValues.Set('MidX', [, ])
        Subjects.Get('window_rect').InitialValues.Set('MidY', [, ])
        Subjects.Get('window_rect').InitialValues.Set('Monitor', [, ])
        Subjects.Get('window_rect').InitialValues.Set('R', [, ])
        Subjects.Get('window_rect').InitialValues.Set('T', [, ])
        Subjects.Get('window_rect').InitialValues.Set('TL', [, ])
        Subjects.Get('window_rect').InitialValues.Set('Visible', [, ])
        Subjects.Get('window_rect').InitialValues.Set('W', [, ])
        Subjects.Get('window_rect').InitialValues.Set('X', [, ])
        Subjects.Get('window_rect').InitialValues.Set('Y', [, ])

        ; client_rect
        ; PropsInfo_client_rect := GetPropsInfo(client_rect, '-Buffer', , false)
        ; Subjects.Add('client_rect', PropsInfo_client_rect)
        Subjects.Get('client_rect').InitialValues := Map()
        ; Methods
        Subjects.Get('client_rect').InitialValues.Set('__Call', [, ])
        Subjects.Get('client_rect').InitialValues.Set('__New', [, ])
        Subjects.Get('client_rect').InitialValues.Set('ChildFromPoint', [, ])
        Subjects.Get('client_rect').InitialValues.Set('ChildWindowFromPointEx', [, ])
        Subjects.Get('client_rect').InitialValues.Set('EnumChildWindows', [, ])
        Subjects.Get('client_rect').InitialValues.Set('GetPos', [, ])
        Subjects.Get('client_rect').InitialValues.Set('Intersect', [, ])
        Subjects.Get('client_rect').InitialValues.Set('IsChild', [, ])
        Subjects.Get('client_rect').InitialValues.Set('IsParent', [, ])
        Subjects.Get('client_rect').InitialValues.Set('IsVisible', [, ])
        Subjects.Get('client_rect').InitialValues.Set('Move', [, ])
        Subjects.Get('client_rect').InitialValues.Set('MoveAdjacent', [, ])
        Subjects.Get('client_rect').InitialValues.Set('MoveOnly', [, ])
        Subjects.Get('client_rect').InitialValues.Set('RealChildFromPoint', [, ])
        Subjects.Get('client_rect').InitialValues.Set('Show', [, ])
        Subjects.Get('client_rect').InitialValues.Set('Split', [, ])
        Subjects.Get('client_rect').InitialValues.Set('ToClient', [, ])
        Subjects.Get('client_rect').InitialValues.Set('ToScreen', [, ])
        Subjects.Get('client_rect').InitialValues.Set('Union', [, ])
        ; Get accessors
        Subjects.Get('client_rect').InitialValues.Set('B', [, ])
        Subjects.Get('client_rect').InitialValues.Set('BR', [, ])
        Subjects.Get('client_rect').InitialValues.Set('Dpi', [, ])
        Subjects.Get('client_rect').InitialValues.Set('H', [, ])
        Subjects.Get('client_rect').InitialValues.Set('L', [, ])
        Subjects.Get('client_rect').InitialValues.Set('MidX', [, ])
        Subjects.Get('client_rect').InitialValues.Set('MidY', [, ])
        Subjects.Get('client_rect').InitialValues.Set('Monitor', [, ])
        Subjects.Get('client_rect').InitialValues.Set('R', [, ])
        Subjects.Get('client_rect').InitialValues.Set('T', [, ])
        Subjects.Get('client_rect').InitialValues.Set('TL', [, ])
        Subjects.Get('client_rect').InitialValues.Set('Visible', [, ])
        Subjects.Get('client_rect').InitialValues.Set('W', [, ])
        Subjects.Get('client_rect').InitialValues.Set('X', [, ])
        Subjects.Get('client_rect').InitialValues.Set('Y', [, ])

        ; rc
        ; PropsInfo_rc := GetPropsInfo(rc, '-Buffer', , false)
        ; Subjects.Add('rc', PropsInfo_rc)
        Subjects.Get('rc').InitialValues := Map()
        ; Methods
        Subjects.Get('rc').InitialValues.Set('__Call', [, ])
        Subjects.Get('rc').InitialValues.Set('__New', [, ])
        Subjects.Get('rc').InitialValues.Set('Intersect', [, ])
        Subjects.Get('rc').InitialValues.Set('Split', [, ])
        Subjects.Get('rc').InitialValues.Set('ToClient', [, ])
        Subjects.Get('rc').InitialValues.Set('ToScreen', [, ])
        Subjects.Get('rc').InitialValues.Set('Union', [, ])
        ; Get accessors
        Subjects.Get('rc').InitialValues.Set('B', [, ])
        Subjects.Get('rc').InitialValues.Set('BR', [, ])
        Subjects.Get('rc').InitialValues.Set('Dpi', [, ])
        Subjects.Get('rc').InitialValues.Set('H', [, ])
        Subjects.Get('rc').InitialValues.Set('L', [, ])
        Subjects.Get('rc').InitialValues.Set('MidX', [, ])
        Subjects.Get('rc').InitialValues.Set('MidY', [, ])
        Subjects.Get('rc').InitialValues.Set('R', [, ])
        Subjects.Get('rc').InitialValues.Set('T', [, ])
        Subjects.Get('rc').InitialValues.Set('TL', [, ])
        Subjects.Get('rc').InitialValues.Set('W', [, ])
        Subjects.Get('rc').InitialValues.Set('X', [, ])
        Subjects.Get('rc').InitialValues.Set('Y', [, ])

        ; buf
        ; PropsInfo_buf := GetPropsInfo(buf, '-Buffer', , false)
        ; Subjects.Add('buf', PropsInfo_buf)
        uis := Subjects.Get('Uis').Obj
        for ui in uis {
            ui.Show()
        }

        Subjects.Get('buf').InitialValues := Map()
        TI := this.TI := TestInterface('Rect', Subjects)
    }

}
