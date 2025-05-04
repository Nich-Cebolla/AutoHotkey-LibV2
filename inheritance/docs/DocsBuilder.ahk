#Include ..\..\..\DocsBuilder\DocsBuilder.ahk
; https://github.com/Nich-Cebolla/AutoHotkey-MD-to-AHK-Forum-Post

AhkForum := {
    ; Replace
    Link: ''
  , Header1Color: '[color=#800000]'
  , Header2Color: '[color=#800000]'
  , Header3Color: '[color=#800000]'
  , Header1Size: '[size=165]'
  , Header2Size: '[size=145]'
  , Header3Size: '[size=125]'
  , TextSize: '[size=100]'
  , TextColor: '[color=#000000]'
  , ParamTypeColor: '[color=#008000]'
  , ParamSize: '[size=100]'
  , ChangelogDateSize: '[size=100]'
  , ChangelogDateColor: '[color=#000000]'
  , ChangelogTextSize: '[size=100]'
  , ChangelogTextColor: '[color=#000000]'
  , FileNameSize: '[size=125]'
  , FileNameColor: '[color=#000000]'
}

Github := {
    ; Replace
    Link: 'https://github.com/Nich-Cebolla/AutoHotkey-LibV2/tree/main/inheritance'
}

class JsdocToMdConfig {

}

Changelog := FileRead('Changelog.md')

if A_LineFile == A_ScriptFullPath {
    DocsBuilder.MakeForumPost('README-raw.md', 'AHK-forum-post.txt')
    MsgBox('done')
}
