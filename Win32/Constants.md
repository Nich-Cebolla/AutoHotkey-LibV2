
## Contents

<ul>
  <li><a href="#uncategorized">Uncategorized</a></li>
  <li><a href="#ttm">TTM - Tooltip messages </a></li>
  <li><a href="#ttdt">TTDT - Tooltip delay time</a></li>
  <li><a href="#ttf">TTF - Tooltip flags</a></li>
  <li><a href="#tti">TTI - Tooltip icons</a></li>
  <li><a href="#tts">TTS - Tooltip styles</a></li>
  <li><a href="#ttn">TTN - Tooltip notifications</a></li>
  <li><a href="#ws">WS - Window sstyles</a></li>
  <li><a href="#ws_ex">WS_EX - Window extended styles</a></li>
  <li><a href="#wm">WM - Window messages</a></li>
</ul>

### Uncategorized

- CW_USEDEFAULT := 0x80000000
- TOOLTIPS_CLASSW := "tooltips_class32"

### TTM

- TTM_ACTIVATE := 1025
- TTM_ADDTOOLA := 1028
- TTM_ADDTOOLW := 1074
- TTM_ADJUSTRECT := 1055
- TTM_DELTOOLA := 1029
- TTM_DELTOOLW := 1075
- TTM_ENUMTOOLSA := 1038
- TTM_ENUMTOOLSW := 1082
- TTM_GETBUBBLESIZE := 1054
- TTM_GETCURRENTTOOLA := 1039
- TTM_GETCURRENTTOOLW := 1083
- TTM_GETDELAYTIME := 1045
- TTM_GETMARGIN := 1051
- TTM_GETMAXTIPWIDTH := 1049
- TTM_GETTEXTA := 1035
- TTM_GETTEXTW := 1080
- TTM_GETTIPBKCOLOR := 1046
- TTM_GETTIPTEXTCOLOR := 1047
- TTM_GETTITLE := 1059
- TTM_GETTOOLCOUNT := 1037
- TTM_GETTOOLINFOA := 1032
- TTM_GETTOOLINFOW := 1077
- TTM_HITTESTA := 1034
- TTM_HITTESTW := 1079
- TTM_NEWTOOLRECTA := 1030
- TTM_NEWTOOLRECTW := 1076
- TTM_POP := 1052
- TTM_POPUP := 1058
- TTM_RELAYEVENT := 1031
- TTM_SETDELAYTIME := 1027
- TTM_SETMARGIN := 1050
- TTM_SETMAXTIPWIDTH := 1048
- TTM_SETTIPBKCOLOR := 1043
- TTM_SETTIPTEXTCOLOR := 1044
- TTM_SETTITLEA := 1056
- TTM_SETTITLEW := 1057
- TTM_SETTOOLINFOA := 1033
- TTM_SETTOOLINFOW := 1078
- TTM_TRACKACTIVATE := 1041
- TTM_TRACKPOSITION := 1042
- TTM_UPDATE := 1053
- TTM_UPDATETIPTEXTA := 1036
- TTM_UPDATETIPTEXTW := 1081
- TTM_WINDOWFROMPOINT := 1040

The same as above but without converting the value to decimal

- TTM_ACTIVATE := 0x0400 + 1
- TTM_ADDTOOLA := 0x0400 + 4
- TTM_ADDTOOLW := 0x0400 + 50
- TTM_ADJUSTRECT := 0x0400 + 31
- TTM_DELTOOLA := 0x0400 + 5
- TTM_DELTOOLW := 0x0400 + 51
- TTM_ENUMTOOLSA := 0x0400 +14
- TTM_ENUMTOOLSW := 0x0400 +58
- TTM_GETBUBBLESIZE := 0x0400 + 30
- TTM_GETCURRENTTOOLA := 0x0400 + 15
- TTM_GETCURRENTTOOLW := 0x0400 + 59
- TTM_GETDELAYTIME := 0x0400 + 21
- TTM_GETMARGIN := 0x0400 + 27
- TTM_GETMAXTIPWIDTH := 0x0400 + 25
- TTM_GETTEXTA := 0x0400 +11
- TTM_GETTEXTW := 0x0400 +56
- TTM_GETTIPBKCOLOR := 0x0400 + 22
- TTM_GETTIPTEXTCOLOR := 0x0400 + 23
- TTM_GETTITLE := 0x0400 + 35
- TTM_GETTOOLCOUNT := 0x0400 +13
- TTM_GETTOOLINFOA := 0x0400 + 8
- TTM_GETTOOLINFOW := 0x0400 + 53
- TTM_HITTESTA := 0x0400 +10
- TTM_HITTESTW := 0x0400 +55
- TTM_NEWTOOLRECTA := 0x0400 + 6
- TTM_NEWTOOLRECTW := 0x0400 + 52
- TTM_POP := 0x0400 + 28
- TTM_POPUP := 0x0400 + 34
- TTM_RELAYEVENT := 0x0400 + 7
- TTM_SETDELAYTIME := 0x0400 + 3
- TTM_SETMARGIN := 0x0400 + 26
- TTM_SETMAXTIPWIDTH := 0x0400 + 24
- TTM_SETTIPBKCOLOR := 0x0400 + 19
- TTM_SETTIPTEXTCOLOR := 0x0400 + 20
- TTM_SETTITLEA := 0x0400 + 32
- TTM_SETTITLEW := 0x0400 + 33
- TTM_SETTOOLINFOA := 0x0400 + 9
- TTM_SETTOOLINFOW := 0x0400 + 54
- TTM_TRACKACTIVATE := 0x0400 + 17
- TTM_TRACKPOSITION := 0x0400 + 18
- TTM_UPDATE := 0x0400 + 29
- TTM_UPDATETIPTEXTA := 0x0400 +12
- TTM_UPDATETIPTEXTW := 0x0400 +57
- TTM_WINDOWFROMPOINT := 0x0400 + 16

### TTDT

- TTDT_AUTOMATIC          0
- TTDT_RESHOW             1
- TTDT_AUTOPOP            2
- TTDT_INITIAL            3

### TTF

https://learn.microsoft.com/en-us/windows/win32/api/commctrl/ns-commctrl-tttoolinfoa

- TTF_IDISHWND            0x0001
- TTF_CENTERTIP           0x0002
- TTF_RTLREADING          0x0004
- TTF_SUBCLASS            0x0010
- TTF_TRACK               0x0020
- TTF_ABSOLUTE            0x0080
- TTF_TRANSPARENT         0x0100
- TTF_PARSELINKS          0x1000
- TTF_DI_SETITEM          0x8000       // valid only on the TTN_NEEDTEXT callback

### TTI

- TTI_NONE                0
- TTI_INFO                1
- TTI_WARNING             2
- TTI_ERROR               3

- #if (NTDDI_VERSION >= NTDDI_VISTA)
  - TTI_INFO_LARGE          4
  - TTI_WARNING_LARGE       5
  - TTI_ERROR_LARGE         6
- #endif  // (NTDDI_VERSION >= NTDDI_VISTA)

### TTS

- Indicates that the tooltip control appears when the cursor is on a tool, even if the tooltip control's owner window is inactive. Without this style, the tooltip appears only when the tool's owner window is active.
  - TTS_ALWAYSTIP := 0x01

- Prevents the system from stripping ampersand characters from a string or terminating a string at a tab character. Without this style, the system automatically strips ampersand characters and terminates a string at the first tab character. This allows an application to use the same string as both a menu item and as text in a tooltip control.
  - TTS_NOPREFIX            0x02

- Version 5.80. Disables sliding tooltip animation on Windows 98 and Windows 2000 systems. This style is ignored on earlier systems.
  - TTS_NOANIMATE           0x10

- Version 5.80. Disables fading tooltip animation.
  - TTS_NOFADE              0x20

- Version 5.80. Indicates that the tooltip control has the appearance of a cartoon "balloon," with rounded corners and a stem pointing to the item.
  - TTS_BALLOON             0x40

- Displays a Close button on the tooltip. Valid only when the tooltip has the TTS_BALLOON style and a title; see TTM_SETTITLE.
  - TTS_CLOSE               0x80

- #if (NTDDI_VERSION >= NTDDI_VISTA)
  - Uses themed hyperlinks. The theme will define the styles for any links in the tooltip. This style always requires TTF_PARSELINKS to be set.
    - TTS_USEVISUALSTYLE      0x100  // Use themed hyperlinks

### TTN

- TTN_GETDISPINFOA        4294966766
- TTN_GETDISPINFOW        4294966766
- TTN_SHOW                4294966775
- TTN_POP                 4294966774
- TTN_LINKCLICK           4294966773

### WS

- The window has a thin-line border
  - WS_BORDER := 0x00800000

- The window has a title bar (includes the WS_BORDER style).
  - WS_CAPTION := 0x00C00000

- The window is a child window. A window with this style cannot have a menu bar. This style cannot be used with the WS_POPUP style
  - WS_CHILD := 0x40000000

- Same as the WS_CHILD style.
  - WS_CHILDWINDOW := 0x40000000

- Excludes the area occupied by child windows when drawing occurs within the parent window. This style is used when creating the parent window
  - WS_CLIPCHILDREN := 0x02000000

- Clips child windows relative to each other; that is, when a particular child window receives a WM_PAINT message, the WS_CLIPSIBLINGS style clips all other overlapping child windows out of the region of the child window to be updated. If WS_CLIPSIBLINGS is not specified and child windows overlap, it is possible, when drawing within the client area of a child window, to draw within the client area of a neighboring child window
  - WS_CLIPSIBLINGS := 0x04000000

- The window is initially disabled. A disabled window cannot receive input from the user. To change this after a window has been created, use the EnableWindow function
  - WS_DISABLED := 0x08000000

- The window has a border of a style typically used with dialog boxes. A window with this style cannot have a title bar
  - WS_DLGFRAME := 0x00400000

- The window is the first control of a group of controls. The group consists of this first control and all controls defined after it, up to the next control with the WS_GROUP style. The first control in each group usually has the WS_TABSTOP style so that the user can move from group to group. The user can subsequently change the keyboard focus from one control in the group to the next control in the group by using the direction keys. You can turn this style on and off to change dialog box navigation. To change this style after a window has been created, use the SetWindowLong function
  - WS_GROUP := 0x00020000

- The window has a horizontal scroll bar.
  - WS_HSCROLL := 0x00100000

- The window is initially minimized. Same as the WS_MINIMIZE style.
  - WS_ICONIC := 0x20000000

- The window is initially maximized.
  - WS_MAXIMIZE := 0x01000000

- The window has a maximize button. Cannot be combined with the WS_EX_CONTEXTHELP style. The WS_SYSMENU style must also be specified
  - WS_MAXIMIZEBOX := 0x00010000

- The window is initially minimized. Same as the WS_ICONIC style.
  - WS_MINIMIZE := 0x20000000

- The window has a minimize button. Cannot be combined with the WS_EX_CONTEXTHELP style. The WS_SYSMENU style must also be specified
  - WS_MINIMIZEBOX := 0x00020000

- The window is an overlapped window. An overlapped window has a title bar and a border. Same as the WS_TILED style
  - WS_OVERLAPPED := 0x00000000

- The window is an overlapped window. Same as the WS_TILEDWINDOW style.
  - WS_OVERLAPPEDWINDOW := (WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)

- The window is a pop-up window. This style cannot be used with the WS_CHILD style.
  - WS_POPUP := 0x80000000

- The window is a pop-up window. The WS_CAPTION and WS_POPUPWINDOW styles must be combined to make the window menu visible.
  - WS_POPUPWINDOW := (WS_POPUP | WS_BORDER | WS_SYSMENU)

- The window has a sizing border. Same as the WS_THICKFRAME style.
  - WS_SIZEBOX := 0x00040000

- The window has a window menu on its title bar. The WS_CAPTION style must also be specified.
  - WS_SYSMENU := 0x00080000

- The window is a control that can receive the keyboard focus when the user presses the TAB key. Pressing the TAB key changes the keyboard focus to the next control with the WS_TABSTOP style. You can turn this style on and off to change dialog box navigation. To change this style after a window has been created, use the SetWindowLong function. For user-created windows and modeless dialogs to work with tab stops, alter the message loop to call the IsDialogMessage function
  - WS_TABSTOP := 0x00010000

- The window has a sizing border. Same as the WS_SIZEBOX style.
  - WS_THICKFRAME := 0x00040000

- The window is an overlapped window. An overlapped window has a title bar and a border. Same as the WS_OVERLAPPED style
  - WS_TILED := 0x00000000

- The window is an overlapped window. Same as the WS_OVERLAPPEDWINDOW style.
  - WS_TILEDWINDOW := (WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)

- The window is initially visible. This style can be turned on and off by using the ShowWindow or SetWindowPos function
  - WS_VISIBLE := 0x10000000

- The window has a vertical scroll bar.
  - WS_VSCROLL := 0x00200000

### WS_EX

- The window accepts drag-drop files.
  - WS_EX_ACCEPTFILES := 0x00000010

- Forces a top-level window onto the taskbar when the window is visible.
  - WS_EX_APPWINDOW := 0x00040000

- The window has a border with a sunken edge.
  - WS_EX_CLIENTEDGE := 0x00000200

- Paints all descendants of a window in bottom-to-top painting order using double-buffering. Bottom-to-top painting order allows a descendent window to have translucency (alpha) and transparency (color-key) effects, but only if the descendent window also has the WS_EX_TRANSPARENT bit set. Double-buffering allows the window and its descendents to be painted without flicker. This cannot be used if the window has a class style of CS_OWNDC, CS_CLASSDC, or CS_PARENTDC.  Windows 2000: This style is not supported
  - WS_EX_COMPOSITED := 0x02000000

- The title bar of the window includes a question mark. When the user clicks the question mark, the cursor changes to a question mark with a pointer. If the user then clicks a child window, the child receives a WM_HELP message. The child window should pass the message to the parent window procedure, which should call the WinHelp function using the HELP_WM_HELP command. The Help application displays a pop-up window that typically contains help for the child window. WS_EX_CONTEXTHELP cannot be used with the WS_MAXIMIZEBOX or WS_MINIMIZEBOX styles
  - WS_EX_CONTEXTHELP := 0x00000400

- The window itself contains child windows that should take part in dialog box navigation. If this style is specified, the dialog manager recurses into children of this window when performing navigation operations such as handling the TAB key, an arrow key, or a keyboard mnemonic
  - WS_EX_CONTROLPARENT := 0x00010000

- The window has a double border; the window can, optionally, be created with a title bar by specifying the WS_CAPTION style in the dwStyle parameter
  - WS_EX_DLGMODALFRAME := 0x00000001

- The window is a layered window. This style cannot be used if the window has a class style of either CS_OWNDC or CS_CLASSDC. Windows 8: The WS_EX_LAYERED style is supported for top-leve windows and child windows. Previous Windows versions support WS_EX_LAYERED only for top-leve windows
  - WS_EX_LAYERED := 0x00080000

- If the shell language is Hebrew, Arabic, or another language that supports reading order alignment, the horizontal origin of the window is on the right edge. Increasing horizontal values advance to the left.
  - WS_EX_LAYOUTRTL := 0x00400000

- The window has generic left-aligned properties. This is the default.
  - WS_EX_LEFT := 0x00000000

- If the shell language is Hebrew, Arabic, or another language that supports reading order alignment, the vertical scroll bar (if present) is to the left of the client area. For other languages, the style is ignored
  - WS_EX_LEFTSCROLLBAR := 0x00004000

- The window text is displayed using left-to-right reading-order properties. This is the default.
  - WS_EX_LTRREADING := 0x00000000

- The window is a MDI child window.
  - WS_EX_MDICHILD := 0x00000040

- A top-level window created with this style does not become the foreground window when the user clicks it. The system does not bring this window to the foreground when the user minimizes or closes the foreground window. The window should not be activated through programmatic access or via keyboard navigation by accessible technology, such as Narrator. To activate the window, use the SetActiveWindow or SetForegroundWindow function. The window does not appear on the taskbar by default. To force the window to appear on the taskbar, use the WS_EX_APPWINDOW style
  - WS_EX_NOACTIVATE := 0x08000000

- The window does not pass its window layout to its child windows.
  - WS_EX_NOINHERITLAYOUT := 0x00100000

- The child window created with this style does not send the WM_PARENTNOTIFY message to its parent window when it is created or destroyed
  - WS_EX_NOPARENTNOTIFY := 0x00000004

- The window does not render to a redirection surface. This is for windows that do not have visible content or that use mechanisms other than surfaces to provide their visua
  - WS_EX_NOREDIRECTIONBITMAP := 0x00200000

- The window is an overlapped window.
  - WS_EX_OVERLAPPEDWINDOW := (WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE)

- The window is palette window, which is a modeless dialog box that presents an array of commands.
  - WS_EX_PALETTEWINDOW := (WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST)

- The window has generic "right-aligned" properties. This depends on the window class. This style has an effect only if the shell language is Hebrew, Arabic, or another language that supports reading-order alignment; otherwise, the style is ignored. Using the WS_EX_RIGHT style for static or edit controls has the same effect as using the SS_RIGHT or ES_RIGHT style, respectively. Using this style with button controls has the same effect as using BS_RIGHT and BS_RIGHTBUTTON styles.
  - WS_EX_RIGHT := 0x00001000

- The vertical scroll bar (if present) is to the right of the client area. This is the default.
  - WS_EX_RIGHTSCROLLBAR := 0x00000000

- If the shell language is Hebrew, Arabic, or another language that supports reading-order alignment, the window text is displayed using right-to-left reading-order properties. For other languages, the style is ignored
  - WS_EX_RTLREADING := 0x00002000

- The window has a three-dimensional border style intended to be used for items that do not accept user input
  - WS_EX_STATICEDGE := 0x00020000

- The window is intended to be used as a floating toolbar. A tool window has a title bar that is shorter than a normal title bar, and the window title is drawn using a smaller font. A too window does not appear in the taskbar or in the dialog that appears when the user presses ALT+TAB. If a tool window has a system menu, its icon is not displayed on the title bar. However, you can display the system menu by right-clicking or by typing ALT+SPACE.
  - WS_EX_TOOLWINDOW := 0x00000080

- The window should be placed above all non-topmost windows and should stay above them, even when the window is deactivated. To add or remove this style, use the SetWindowPos function
  - WS_EX_TOPMOST := 0x00000008

- The window should not be painted until siblings beneath the window (that were created by the same thread) have been painted. The window appears transparent because the bits of underlying sibling windows have already been painted. To achieve transparency without these restrictions, use the SetWindowRgn function
  - WS_EX_TRANSPARENT := 0x00000020

- The window has a border with a raised edge.
  - WS_EX_WINDOWEDGE := 0x00000100

### WM

- WM_NULL                         0x0000
- WM_CREATE                       0x0001
- WM_DESTROY                      0x0002
- WM_MOVE                         0x0003
- WM_SIZE                         0x0005

- WM_ACTIVATE                     0x0006

- WM_ACTIVATE state values
- WA_INACTIVE     0
- WA_ACTIVE       1
- WA_CLICKACTIVE  2

- WM_SETFOCUS                     0x0007
- WM_KILLFOCUS                    0x0008
- WM_ENABLE                       0x000A
- WM_SETREDRAW                    0x000B
- WM_SETTEXT                      0x000C
- WM_GETTEXT                      0x000D
- WM_GETTEXTLENGTH                0x000E
- WM_PAINT                        0x000F
- WM_CLOSE                        0x0010
- #ifndef _WIN32_WCE
- WM_QUERYENDSESSION              0x0011
- WM_QUERYOPEN                    0x0013
- WM_ENDSESSION                   0x0016
- #endif
- WM_QUIT                         0x0012
- WM_ERASEBKGND                   0x0014
- WM_SYSCOLORCHANGE               0x0015
- WM_SHOWWINDOW                   0x0018
- WM_WININICHANGE                 0x001A
- #if(WINVER >= 0x0400)
- WM_SETTINGCHANGE                WM_WININICHANGE
- #endif /* WINVER >= 0x0400

- WM_DEVMODECHANGE                0x001B
- WM_ACTIVATEAPP                  0x001C
- WM_FONTCHANGE                   0x001D
- WM_TIMECHANGE                   0x001E
- WM_CANCELMODE                   0x001F
- WM_SETCURSOR                    0x0020
- WM_MOUSEACTIVATE                0x0021
- WM_CHILDACTIVATE                0x0022
- WM_QUEUESYNC                    0x0023

- WM_GETMINMAXINFO                0x0024

- WM_PAINTICON                    0x0026
- WM_ICONERASEBKGND               0x0027
- WM_NEXTDLGCTL                   0x0028
- WM_SPOOLERSTATUS                0x002A
- WM_DRAWITEM                     0x002B
- WM_MEASUREITEM                  0x002C
- WM_DELETEITEM                   0x002D
- WM_VKEYTOITEM                   0x002E
- WM_CHARTOITEM                   0x002F
- WM_SETFONT                      0x0030
- WM_GETFONT                      0x0031
- WM_SETHOTKEY                    0x0032
- WM_GETHOTKEY                    0x0033
- WM_QUERYDRAGICON                0x0037
- WM_COMPAREITEM                  0x0039
- #if(WINVER >= 0x0500)
- #ifndef _WIN32_WCE
- WM_GETOBJECT                    0x003D
- #endif
- #endif /* WINVER >= 0x0500
- WM_COMPACTING                   0x0041
- WM_COMMNOTIFY                   0x0044  /* no longer suported
- WM_WINDOWPOSCHANGING            0x0046
- WM_WINDOWPOSCHANGED             0x0047

- WM_POWER                        0x0048

- WM_COPYDATA                     0x004A
- WM_CANCELJOURNAL                0x004B


- #if(WINVER >= 0x0400)
- WM_NOTIFY                       0x004E
- WM_INPUTLANGCHANGEREQUEST       0x0050
- WM_INPUTLANGCHANGE              0x0051
- WM_TCARD                        0x0052
- WM_HELP                         0x0053
- WM_USERCHANGED                  0x0054
- WM_NOTIFYFORMAT                 0x0055

- NFR_ANSI                             1
- NFR_UNICODE                          2
- NF_QUERY                             3
- NF_REQUERY                           4

- WM_CONTEXTMENU                  0x007B
- WM_STYLECHANGING                0x007C
- WM_STYLECHANGED                 0x007D
- WM_DISPLAYCHANGE                0x007E
- WM_GETICON                      0x007F
- WM_SETICON                      0x0080
- #endif /* WINVER >= 0x0400

- WM_NCCREATE                     0x0081
- WM_NCDESTROY                    0x0082
- WM_NCCALCSIZE                   0x0083
- WM_NCHITTEST                    0x0084
- WM_NCPAINT                      0x0085
- WM_NCACTIVATE                   0x0086
- WM_GETDLGCODE                   0x0087
- #ifndef _WIN32_WCE
- WM_SYNCPAINT                    0x0088
- #endif
- WM_NCMOUSEMOVE                  0x00A0
- WM_NCLBUTTONDOWN                0x00A1
- WM_NCLBUTTONUP                  0x00A2
- WM_NCLBUTTONDBLCLK              0x00A3
- WM_NCRBUTTONDOWN                0x00A4
- WM_NCRBUTTONUP                  0x00A5
- WM_NCRBUTTONDBLCLK              0x00A6
- WM_NCMBUTTONDOWN                0x00A7
- WM_NCMBUTTONUP                  0x00A8
- WM_NCMBUTTONDBLCLK              0x00A9



- #if(_WIN32_WINNT >= 0x0500)
- WM_NCXBUTTONDOWN                0x00AB
- WM_NCXBUTTONUP                  0x00AC
- WM_NCXBUTTONDBLCLK              0x00AD
- #endif /* _WIN32_WINNT >= 0x0500


- #if(_WIN32_WINNT >= 0x0501)
- WM_INPUT_DEVICE_CHANGE          0x00FE
- #endif /* _WIN32_WINNT >= 0x0501

- #if(_WIN32_WINNT >= 0x0501)
- WM_INPUT                        0x00FF
- #endif /* _WIN32_WINNT >= 0x0501

- WM_KEYFIRST                     0x0100
- WM_KEYDOWN                      0x0100
- WM_KEYUP                        0x0101
- WM_CHAR                         0x0102
- WM_DEADCHAR                     0x0103
- WM_SYSKEYDOWN                   0x0104
- WM_SYSKEYUP                     0x0105
- WM_SYSCHAR                      0x0106
- WM_SYSDEADCHAR                  0x0107
- #if(_WIN32_WINNT >= 0x0501)
- WM_UNICHAR                      0x0109
- WM_KEYLAST                      0x0109
- UNICODE_NOCHAR                  0xFFFF
- #else
- WM_KEYLAST                      0x0108
- #endif /* _WIN32_WINNT >= 0x0501

- #if(WINVER >= 0x0400)
- WM_IME_STARTCOMPOSITION         0x010D
- WM_IME_ENDCOMPOSITION           0x010E
- WM_IME_COMPOSITION              0x010F
- WM_IME_KEYLAST                  0x010F
- #endif /* WINVER >= 0x0400

- WM_INITDIALOG                   0x0110
- WM_COMMAND                      0x0111
- WM_SYSCOMMAND                   0x0112
- WM_TIMER                        0x0113
- WM_HSCROLL                      0x0114
- WM_VSCROLL                      0x0115
- WM_INITMENU                     0x0116
- WM_INITMENUPOPUP                0x0117
- #if(WINVER >= 0x0601)
- WM_GESTURE                      0x0119
- WM_GESTURENOTIFY                0x011A
- #endif /* WINVER >= 0x0601
- WM_MENUSELECT                   0x011F
- WM_MENUCHAR                     0x0120
- WM_ENTERIDLE                    0x0121
- #if(WINVER >= 0x0500)
- #ifndef _WIN32_WCE
- WM_MENURBUTTONUP                0x0122
- WM_MENUDRAG                     0x0123
- WM_MENUGETOBJECT                0x0124
- WM_UNINITMENUPOPUP              0x0125
- WM_MENUCOMMAND                  0x0126
- #ifndef _WIN32_WCE
- #if(_WIN32_WINNT >= 0x0500)
- WM_CHANGEUISTATE                0x0127
- WM_UPDATEUISTATE                0x0128
- WM_QUERYUISTATE                 0x0129
- #endif /* _WIN32_WINNT >= 0x0500
- #endif
- #endif
- #endif /* WINVER >= 0x0500

- WM_CTLCOLORMSGBOX               0x0132
- WM_CTLCOLOREDIT                 0x0133
- WM_CTLCOLORLISTBOX              0x0134
- WM_CTLCOLORBTN                  0x0135
- WM_CTLCOLORDLG                  0x0136
- WM_CTLCOLORSCROLLBAR            0x0137
- WM_CTLCOLORSTATIC               0x0138
- MN_GETHMENU                     0x01E1

- WM_MOUSEFIRST                   0x0200
- WM_MOUSEMOVE                    0x0200
- WM_LBUTTONDOWN                  0x0201
- WM_LBUTTONUP                    0x0202
- WM_LBUTTONDBLCLK                0x0203
- WM_RBUTTONDOWN                  0x0204
- WM_RBUTTONUP                    0x0205
- WM_RBUTTONDBLCLK                0x0206
- WM_MBUTTONDOWN                  0x0207
- WM_MBUTTONUP                    0x0208
- WM_MBUTTONDBLCLK                0x0209
- #if (_WIN32_WINNT >= 0x0400) || (_WIN32_WINDOWS > 0x0400)
- WM_MOUSEWHEEL                   0x020A
- #endif
- #if (_WIN32_WINNT >= 0x0500)
- WM_XBUTTONDOWN                  0x020B
- WM_XBUTTONUP                    0x020C
- WM_XBUTTONDBLCLK                0x020D
- #endif
- #if (_WIN32_WINNT >= 0x0600)
- WM_MOUSEHWHEEL                  0x020E
- #endif

- #if (_WIN32_WINNT >= 0x0600)
- WM_MOUSELAST                    0x020E
- #elif (_WIN32_WINNT >= 0x0500)
- WM_MOUSELAST                    0x020D
- #elif (_WIN32_WINNT >= 0x0400) || (_WIN32_WINDOWS > 0x0400)
- WM_MOUSELAST                    0x020A
- #else
- WM_MOUSELAST                    0x0209
#endif /* (_WIN32_WINNT >= 0x0600)


- WM_PARENTNOTIFY                 0x0210
- WM_ENTERMENULOOP                0x0211
- WM_EXITMENULOOP                 0x0212

- #if(WINVER >= 0x0400)
- WM_NEXTMENU                     0x0213
- WM_SIZING                       0x0214
- WM_CAPTURECHANGED               0x0215
- WM_MOVING                       0x0216
- #endif /* WINVER >= 0x0400

- #if(WINVER >= 0x0400)


- WM_POWERBROADCAST               0x0218

- #if(WINVER >= 0x0400)
- WM_DEVICECHANGE                 0x0219
- #endif /* WINVER >= 0x0400

- WM_MDICREATE                    0x0220
- WM_MDIDESTROY                   0x0221
- WM_MDIACTIVATE                  0x0222
- WM_MDIRESTORE                   0x0223
- WM_MDINEXT                      0x0224
- WM_MDIMAXIMIZE                  0x0225
- WM_MDITILE                      0x0226
- WM_MDICASCADE                   0x0227
- WM_MDIICONARRANGE               0x0228
- WM_MDIGETACTIVE                 0x0229


- WM_MDISETMENU                   0x0230
- WM_ENTERSIZEMOVE                0x0231
- WM_EXITSIZEMOVE                 0x0232
- WM_DROPFILES                    0x0233
- WM_MDIREFRESHMENU               0x0234

- #if(WINVER >= 0x0602)
- WM_POINTERDEVICECHANGE          0x238
- WM_POINTERDEVICEINRANGE         0x239
- WM_POINTERDEVICEOUTOFRANGE      0x23A
- #endif /* WINVER >= 0x0602

- #if(WINVER >= 0x0601)
- WM_TOUCH                        0x0240
- #endif /* WINVER >= 0x0601

- #if(WINVER >= 0x0602)
- WM_NCPOINTERUPDATE              0x0241
- WM_NCPOINTERDOWN                0x0242
- WM_NCPOINTERUP                  0x0243
- WM_POINTERUPDATE                0x0245
- WM_POINTERDOWN                  0x0246
- WM_POINTERUP                    0x0247
- WM_POINTERENTER                 0x0249
- WM_POINTERLEAVE                 0x024A
- WM_POINTERACTIVATE              0x024B
- WM_POINTERCAPTURECHANGED        0x024C
- WM_TOUCHHITTESTING              0x024D
- WM_POINTERWHEEL                 0x024E
- WM_POINTERHWHEEL                0x024F
- DM_POINTERHITTEST               0x0250
- WM_POINTERROUTEDTO              0x0251
- WM_POINTERROUTEDAWAY            0x0252
- WM_POINTERROUTEDRELEASED        0x0253
- #endif /* WINVER >= 0x0602


- #if(WINVER >= 0x0400)
- WM_IME_SETCONTEXT               0x0281
- WM_IME_NOTIFY                   0x0282
- WM_IME_CONTROL                  0x0283
- WM_IME_COMPOSITIONFULL          0x0284
- WM_IME_SELECT                   0x0285
- WM_IME_CHAR                     0x0286
- #endif /* WINVER >= 0x0400
- #if(WINVER >= 0x0500)
- WM_IME_REQUEST                  0x0288
- #endif /* WINVER >= 0x0500
- #if(WINVER >= 0x0400)
- WM_IME_KEYDOWN                  0x0290
- WM_IME_KEYUP                    0x0291
- #endif /* WINVER >= 0x0400

- #if((_WIN32_WINNT >= 0x0400) || (WINVER >= 0x0500))
- WM_MOUSEHOVER                   0x02A1
- WM_MOUSELEAVE                   0x02A3
- #endif
- #if(WINVER >= 0x0500)
- WM_NCMOUSEHOVER                 0x02A0
- WM_NCMOUSELEAVE                 0x02A2
- #endif /* WINVER >= 0x0500

- #if(_WIN32_WINNT >= 0x0501)
- WM_WTSSESSION_CHANGE            0x02B1

- WM_TABLET_FIRST                 0x02c0
- WM_TABLET_LAST                  0x02df
- #endif /* _WIN32_WINNT >= 0x0501

- #if(WINVER >= 0x0601)
- WM_DPICHANGED                   0x02E0
- #endif /* WINVER >= 0x0601
- #if(WINVER >= 0x0605)
- WM_DPICHANGED_BEFOREPARENT      0x02E2
- WM_DPICHANGED_AFTERPARENT       0x02E3
- WM_GETDPISCALEDSIZE             0x02E4
- #endif /* WINVER >= 0x0605

- WM_CUT                          0x0300
- WM_COPY                         0x0301
- WM_PASTE                        0x0302
- WM_CLEAR                        0x0303
- WM_UNDO                         0x0304
- WM_RENDERFORMAT                 0x0305
- WM_RENDERALLFORMATS             0x0306
- WM_DESTROYCLIPBOARD             0x0307
- WM_DRAWCLIPBOARD                0x0308
- WM_PAINTCLIPBOARD               0x0309
- WM_VSCROLLCLIPBOARD             0x030A
- WM_SIZECLIPBOARD                0x030B
- WM_ASKCBFORMATNAME              0x030C
- WM_CHANGECBCHAIN                0x030D
- WM_HSCROLLCLIPBOARD             0x030E
- WM_QUERYNEWPALETTE              0x030F
- WM_PALETTEISCHANGING            0x0310
- WM_PALETTECHANGED               0x0311
- WM_HOTKEY                       0x0312

- #if(WINVER >= 0x0400)
- WM_PRINT                        0x0317
- WM_PRINTCLIENT                  0x0318
- #endif /* WINVER >= 0x0400

- #if(_WIN32_WINNT >= 0x0500)
- WM_APPCOMMAND                   0x0319
- #endif /* _WIN32_WINNT >= 0x0500

- #if(_WIN32_WINNT >= 0x0501)
- WM_THEMECHANGED                 0x031A
- #endif /* _WIN32_WINNT >= 0x0501


- #if(_WIN32_WINNT >= 0x0501)
- WM_CLIPBOARDUPDATE              0x031D
- #endif /* _WIN32_WINNT >= 0x0501

- #if(_WIN32_WINNT >= 0x0600)
- WM_DWMCOMPOSITIONCHANGED        0x031E
- WM_DWMNCRENDERINGCHANGED        0x031F
- WM_DWMCOLORIZATIONCOLORCHANGED  0x0320
- WM_DWMWINDOWMAXIMIZEDCHANGE     0x0321
- #endif /* _WIN32_WINNT >= 0x0600

- #if(_WIN32_WINNT >= 0x0601)
- WM_DWMSENDICONICTHUMBNAIL           0x0323
- WM_DWMSENDICONICLIVEPREVIEWBITMAP   0x0326
- #endif /* _WIN32_WINNT >= 0x0601


- #if(WINVER >= 0x0600)
- WM_GETTITLEBARINFOEX            0x033F
- #endif /* WINVER >= 0x0600

- #if(WINVER >= 0x0400)
- #endif /* WINVER >= 0x0400


- #if(WINVER >= 0x0400)
- WM_HANDHELDFIRST                0x0358
- WM_HANDHELDLAST                 0x035F

- WM_AFXFIRST                     0x0360
- WM_AFXLAST                      0x037F
- #endif /* WINVER >= 0x0400

- WM_PENWINFIRST                  0x0380
- WM_PENWINLAST                   0x038F


- #if(WINVER >= 0x0400)
- WM_APP                          0x8000
- #endif /* WINVER >= 0x0400

- WM_USER                         0x0400
