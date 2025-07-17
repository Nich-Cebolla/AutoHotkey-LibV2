

class UnderMouse {
    __New(Callback) {
        this.Callback := Callback
    }
    Call(
        DpiAwarenessContext := -4
      , GetWindowDetails := true
      , GetPixelDetails := true
      , GetControlDetails := true
      , GetIUIAutomationElement := true
      , GetParentWindowDetails := true
      , GetOwnerWindowDetails := true
      , GetControlParentWindowDetails := true
      , GetControlOwnerWindowDetails := true
    ) {
            ; Window details
        global um_win_title, um_win_class, um_win_exe, um_win_pid
        , um_win_path, um_win_id
            ; Window rect
        , um_win_l, um_win_t, um_win_r, um_win_b
            ; Window's client area rect
        , um_win_client_l, um_win_client_t, um_win_client_r, um_win_client_b
            ; Mouse coordinates
        , um_mou_x, um_mou_y
            ; Mouse coodinates relative to um_win_id
        , um_mou_client_x, um_mou_client_y
            ; Pixel details
        , um_pix_color, um_pix_r, um_pix_g, um_pix_b
            ; Control details
        , um_con_class, um_con_id, um_con_parent, um_con_text
            ; Control's window rect
        , um_con_l, um_con_t, um_con_r, um_con_b
            ; Control's client area rect
        , um_con_client_l, um_con_client_t, um_con_client_r, um_con_client_b
            ; Parent window details
        , um_par_title, um_par_class, um_par_pid, um_par_id
            ; Parent window dimensions
        , um_par_x, um_par_y, um_par_w, um_par_h
            ; IUMtomationElement
        , um_ele
            ; Array of objects { ele, rect }
        , um_list
        if !isset(um_list) {
            UM_SetVars()
        }

        if !DllCall('IsValidDpiAwarenessContext', 'ptr', DpiAwarenessContext, 'uint')
        || !(DpiAwarenessContext := DllCall('SetThreadDpiAwarenessContext', 'ptr', DpiAwarenessContext, 'ptr')) {
            throw OSError('The ``DpiAwarenessContext`` value is invalid.', -1, DpiAwarenessContext)
        }
        loop {
            MouseGetPos(&um_mou_x, &um_mou_y, &um_win_id, &um_con_id, 2)
            if !WinExist(um_win_id) {
                um_win_id := 0
            }
            if !WinExist(um_con_id) {
                um_con_id := 0
            }
            if GetWindowDetails {
                if um_win_id {
                    WinGetPos(&um_win_x, &um_win_y, &um_win_w, &um_win_h, um_win_id)
                    um_win_title := WinGetTitle(um_win_id)
                    um_win_class := WinGetClass(um_win_id)
                    um_win_exe := WinGetProcessName(um_win_id)
                    um_win_pid := WinGetPID(um_win_id)
                    um_win_path := WinGetProcessPath(um_win_id)
                } else {
                    um_win_title := um_win_class := um_win_exe := um_win_pid := um_win_path :=
                    um_mou_client_x := um_mou_client_y := 0
                }
            }
            if um_win_id {
                pt := Buffer(8)
                NumPut('uint', um_mou_client_x, 'uint', um_mou_client_x, pt)
                if !DllCall('ScreenToClient', 'ptr', um_win_id, 'ptr', pt, 'int') {
                    throw OSError()
                }
                um_mou_client_x := NumGet(pt, 'uint')
                um_mou_client_y := NumGet(pt, 4, 'uint')
            } else {
                um_mou_client_x := um_mou_client_y := 0
            }
            if GetPixelDetails {
                um_pix_color := PixelGetColor(um_mou_x, um_mou_y)
                um_pix_r := SubStr(um_pix_color, 1, 2)
                um_pix_g := SubStr(um_pix_color, 3, 2)
                um_pix_b := SubStr(um_pix_color, 5)
            }
            if GetControlDetails {
                if um_con_id {
                    um_con_class := ControlGetClassNN(um_con_id)
                    um_con_text := ControlGetText(um_con_id)
                    WinGetPos(&um_con_x_screen, &um_con_y_screen, &um_con_w, &um_con_h, um_con_id)
                    if um_con_parent := DllCall('GetParent', 'ptr', um_con_id, 'ptr') {
                        rc := Buffer(16)
                        NumPut(
                            'uint', um_con_x_screen
                          , 'uint', um_con_y_screen
                          , 'uint', um_con_x_screen + um_con_w
                          , 'uint', um_con_y_screen + um_con_h
                          , rc
                        )
                        if DllCall('User32.dll\GetClientRect', 'ptr', um_con_parent, 'ptr', rc, 'int') {
                            um_con_x_client := NumGet(rc, 0, 'uint')
                            um_con_y_client := NumGet(rc, 4, 'uint')
                        } else {
                            throw OSError()
                        }
                    } else {
                        um_con_class := um_con_text := um_con_parent := um_con_x_client := um_con_y_client
                        := um_con_x_screen := um_con_y_screen := um_con_w := um_con_h := 0
                    }
                } else {
                }
            }

            _GetWindowDetails(Which) {

            }
        }
    }
}

UM_SetVars() {
        ; Window details
    global um_win_title := um_win_class := um_win_exe := um_win_pid
    := um_win_path := um_win_id
        ; Window dimensions
    := um_win_x := um_win_y := um_win_w := um_win_h
        ; Mouse coordinates
    := um_mou_client_x := um_mou_client_y := um_mou_x := um_mou_y
        ; pix under mouse
    := um_pix_color := um_pix_r := um_pix_g := um_pix_b
        ; Control details
    := um_con_class um_con_id := um_con_parent := um_con_text
        ; Control dimensions
    := um_con_x_client := um_con_y_client := um_con_x_screen
    := um_con_y_screen := um_con_w := um_con_h
        ; UIAAutomationElement
    := um_ele := 0
        ; Array of objects { ele , rect }
    , um_list := []
    um_list.Capacity := 100
}
