
#include ..\Headers2ToC.ahk

if A_LineFile == A_ScriptFullPath {
    result := test()
}

class test {
    static Call() {
        result := []
        options := {
            AppendToBottom: ''
          , aStyle: ''
          , aStyleAll: ''
          , Encoding: ''
          , Flags: HEADERS2TOC_LOWERCASE | HEADERS2TOC_NOPUNCTUATION | HEADERS2TOC_REPLACESPACE |
                HEADERS2TOC_TRIMHYPHENS | HEADERS2TOC_SERIALIZEDUPLICATES
          , FormatElement: ''
          , FormatElementAll: ''
          , Header: '# Table of contents`n`n'
          , IndentChar: '`s'
          , IndentLen: 2
          , InitialIndent: 0
          , IsMarkdown: true
          , LinkToHeaders2ToC: false
          , liStyle: ''
          , liStyleAll: ''
          , LineEnding: '`n'
          , LineStart: 0
          , olStyle: ''
          , olStyleAll: ''
          , olType: [ 'I', 'A', '1', 'i', 'a' ]
          , PosStart: 0
        }

        for cb in [ GetMarkdown, GetHtml ] {
            if A_Index == 2 {
                options.IsMarkdown := false
            }
            ; 1 - liStyle
            o := options.Clone()
            o.liStyle := [ 'font-size: 13px;', 'font-size: 12px;', 'font-size: 11px;' ]
            result.Push(Headers2ToC(cb(), , o))
            if result[-1].toc != '
            (
                # Table of contents

                <ol type="I">
                  <li style="font-size: 13px;"><a href="#example-header-1---subheader-text">Example header 1 - subheader text</a></li>
                  <ol type="A">
                    <li style="font-size: 12px;"><a href="#example-header-2---subheader-text">Example header 2 - subheader text</a></li>
                    <ol type="1">
                      <li style="font-size: 11px;"><a href="#example-header-3---subheader-text">Example header 3 - subheader text</a></li>
                    </ol>
                    <li style="font-size: 12px;"><a href="#example-header-4---subheader-text">Example header 4 - subheader text</a></li>
                  </ol>
                </ol>
            )' {
                throw Error('Invalid result', , A_LineNumber)
            }

            ; 2 - liStyleAll
            o.liStyle := [ 'font-size: 13px;', 'font-size: 12px;' ]
            o.liStyleAll := 'font-color: red;'
            result.Push(Headers2ToC(cb(), , o))
            if result[-1].toc != '
            (
                # Table of contents

                <ol type="I">
                  <li style="font-size: 13px; font-color: red;"><a href="#example-header-1---subheader-text">Example header 1 - subheader text</a></li>
                  <ol type="A">
                    <li style="font-size: 12px; font-color: red;"><a href="#example-header-2---subheader-text">Example header 2 - subheader text</a></li>
                    <ol type="1">
                      <li style="font-color: red;"><a href="#example-header-3---subheader-text">Example header 3 - subheader text</a></li>
                    </ol>
                    <li style="font-size: 12px; font-color: red;"><a href="#example-header-4---subheader-text">Example header 4 - subheader text</a></li>
                  </ol>
                </ol>
            )' {
                throw Error('Invalid result', , A_LineNumber)
            }

            ; 3 - olStyle
            o := options.Clone()
            o.olStyle := [ 'list-style-type: upper-roman; list-style-position: outside;', 'list-style-type: upper-alpha; list-style-position: outside;', 'list-style-type: decimal; list-style-position: outside;' ]
            o.olType := ''
            result.Push(Headers2ToC(cb(), , o))
            if result[-1].toc != '
            (
                # Table of contents

                <ol style="list-style-type: upper-roman; list-style-position: outside;">
                  <li><a href="#example-header-1---subheader-text">Example header 1 - subheader text</a></li>
                  <ol style="list-style-type: upper-alpha; list-style-position: outside;">
                    <li><a href="#example-header-2---subheader-text">Example header 2 - subheader text</a></li>
                    <ol style="list-style-type: decimal; list-style-position: outside;">
                      <li><a href="#example-header-3---subheader-text">Example header 3 - subheader text</a></li>
                    </ol>
                    <li><a href="#example-header-4---subheader-text">Example header 4 - subheader text</a></li>
                  </ol>
                </ol>
            )' {
                throw Error('Invalid result', , A_LineNumber)
            }

            ; 4 - olStyleAll
            o := options.Clone()
            o.olStyle := [ '', '', 'list-style-type: decimal;' ]
            o.olStyleAll := 'list-style-position: outside;'
            o.olType := [ 'I', 'A', '' ]
            result.Push(Headers2ToC(cb(), , o))
            if result[-1].toc != '
            (
                # Table of contents

                <ol type="I" style="list-style-position: outside;">
                  <li><a href="#example-header-1---subheader-text">Example header 1 - subheader text</a></li>
                  <ol type="A" style="list-style-position: outside;">
                    <li><a href="#example-header-2---subheader-text">Example header 2 - subheader text</a></li>
                    <ol type="" style="list-style-type: decimal; list-style-position: outside;">
                      <li><a href="#example-header-3---subheader-text">Example header 3 - subheader text</a></li>
                    </ol>
                    <li><a href="#example-header-4---subheader-text">Example header 4 - subheader text</a></li>
                  </ol>
                </ol>
            )' {
                throw Error('Invalid result', , A_LineNumber)
            }

            ; 5 - aStyle
            o := options.Clone()
            o.aStyle := [ 'color: red;', 'color: blue;', 'color: purple;' ]
            result.Push(Headers2ToC(cb(), , o))
            if result[-1].toc != '
            (
                # Table of contents

                <ol type="I">
                  <li><a href="#example-header-1---subheader-text" style="color: red;">Example header 1 - subheader text</a></li>
                  <ol type="A">
                    <li><a href="#example-header-2---subheader-text" style="color: blue;">Example header 2 - subheader text</a></li>
                    <ol type="1">
                      <li><a href="#example-header-3---subheader-text" style="color: purple;">Example header 3 - subheader text</a></li>
                    </ol>
                    <li><a href="#example-header-4---subheader-text" style="color: blue;">Example header 4 - subheader text</a></li>
                  </ol>
                </ol>
            )' {
                throw Error('Invalid result', , A_LineNumber)
            }

            ; 6 - aStyleAll
            o := options.Clone()
            o.aStyle := [ 'color: red;', 'color: blue;' ]
            o.aStyleAll := 'text-underline-offset: 3px;'
            result.Push(Headers2ToC(cb(), , o))
            if result[-1].toc != '
            (
                # Table of contents

                <ol type="I">
                  <li><a href="#example-header-1---subheader-text" style="color: red; text-underline-offset: 3px;">Example header 1 - subheader text</a></li>
                  <ol type="A">
                    <li><a href="#example-header-2---subheader-text" style="color: blue; text-underline-offset: 3px;">Example header 2 - subheader text</a></li>
                    <ol type="1">
                      <li><a href="#example-header-3---subheader-text" style="text-underline-offset: 3px;">Example header 3 - subheader text</a></li>
                    </ol>
                    <li><a href="#example-header-4---subheader-text" style="color: blue; text-underline-offset: 3px;">Example header 4 - subheader text</a></li>
                  </ol>
                </ol>
            )' {
                throw Error('Invalid result', , A_LineNumber)
            }
            A_Clipboard := result[-2].toc '`n`n`n' result[-1].toc

            ; 7 - FormatElement
            o := options.Clone()
            o.FormatElement := [ '<i>', '<b><i><s>', '<b><s>' ]
            result.Push(Headers2ToC(cb(), , o))
            if result[-1].toc != '
            (
                # Table of contents

                <ol type="I">
                  <li><a href="#example-header-1---subheader-text"><i>Example header 1 - subheader text</i></a></li>
                  <ol type="A">
                    <li><a href="#example-header-2---subheader-text"><b><i><s>Example header 2 - subheader text</b></i></s></a></li>
                    <ol type="1">
                      <li><a href="#example-header-3---subheader-text"><b><s>Example header 3 - subheader text</b></s></a></li>
                    </ol>
                    <li><a href="#example-header-4---subheader-text"><b><i><s>Example header 4 - subheader text</b></i></s></a></li>
                  </ol>
                </ol>
            )' {
                throw Error('Invalid result', , A_LineNumber)
            }

            ; 8 - FormatElementAll
            o := options.Clone()
            o.FormatElement := [ '<em>', '<sup>' ]
            o.FormatElementAll := '<b><s>'
            result.Push(Headers2ToC(cb(), , o))
            if result[-1].toc != '
            (
                # Table of contents

                <ol type="I">
                  <li><a href="#example-header-1---subheader-text"><em><b><s>Example header 1 - subheader text</em></b></s></a></li>
                  <ol type="A">
                    <li><a href="#example-header-2---subheader-text"><sup><b><s>Example header 2 - subheader text</sup></b></s></a></li>
                    <ol type="1">
                      <li><a href="#example-header-3---subheader-text"><b><s>Example header 3 - subheader text</b></s></a></li>
                    </ol>
                    <li><a href="#example-header-4---subheader-text"><sup><b><s>Example header 4 - subheader text</sup></b></s></a></li>
                  </ol>
                </ol>
            )' {
                throw Error('Invalid result', , A_LineNumber)
            }

            ; 9 - SubheaderDelimiter & SubheaderSeparator
            o := options.Clone()
            o.SubheaderDelimiter := ' - '
            o.SubheaderSeparator := ' - '
            result.Push(Headers2ToC(cb(), , o))
            if result[-1].toc != '
            (
                # Table of contents

                <ol type="I">
                  <li><a href="#example-header-1---subheader-text">Example header 1</a> - subheader text</li>
                  <ol type="A">
                    <li><a href="#example-header-2---subheader-text">Example header 2</a> - subheader text</li>
                    <ol type="1">
                      <li><a href="#example-header-3---subheader-text">Example header 3</a> - subheader text</li>
                    </ol>
                    <li><a href="#example-header-4---subheader-text">Example header 4</a> - subheader text</li>
                  </ol>
                </ol>
            )' {
                throw Error('Invalid result', , A_LineNumber)
            }

            ; 10 - SubheaderFormatElement
            o := options.Clone()
            o.SubheaderDelimiter := ' - '
            o.SubheaderSeparator := ' - '
            o.SubheaderFormatElement := [ '<i>', '<b><i><s>', '<b><s>' ]
            result.Push(Headers2ToC(cb(), , o))
            if result[-1].toc != '
            (
                # Table of contents

                <ol type="I">
                  <li><a href="#example-header-1---subheader-text">Example header 1</a> - <i>subheader text</i></li>
                  <ol type="A">
                    <li><a href="#example-header-2---subheader-text">Example header 2</a> - <b><i><s>subheader text</b></i></s></li>
                    <ol type="1">
                      <li><a href="#example-header-3---subheader-text">Example header 3</a> - <b><s>subheader text</b></s></li>
                    </ol>
                    <li><a href="#example-header-4---subheader-text">Example header 4</a> - <b><i><s>subheader text</b></i></s></li>
                  </ol>
                </ol>
            )' {
                throw Error('Invalid result', , A_LineNumber)
            }

            ; 11 - SubheaderFormatElementAll
            o := options.Clone()
            o.SubheaderDelimiter := ' - '
            o.SubheaderSeparator := ' - '
            o.SubheaderFormatElement := [ '<em>', '<sup>' ]
            o.SubheaderFormatElementAll := '<b><s>'
            result.Push(Headers2ToC(cb(), , o))
            if result[-1].toc != '
            (
                # Table of contents

                <ol type="I">
                  <li><a href="#example-header-1---subheader-text">Example header 1</a> - <em><b><s>subheader text</em></b></s></li>
                  <ol type="A">
                    <li><a href="#example-header-2---subheader-text">Example header 2</a> - <sup><b><s>subheader text</sup></b></s></li>
                    <ol type="1">
                      <li><a href="#example-header-3---subheader-text">Example header 3</a> - <b><s>subheader text</b></s></li>
                    </ol>
                    <li><a href="#example-header-4---subheader-text">Example header 4</a> - <sup><b><s>subheader text</sup></b></s></li>
                  </ol>
                </ol>
            )' {
                throw Error('Invalid result', , A_LineNumber)
            }
        }
        return result
    }
}

GetMarkdown() {
    return '
        (
            # Example header 1 - subheader text
            
            text
            
            ## Example header 2 - subheader text
            
            text
            
            ### Example header 3 - subheader text
            
            text
            
            ## Example header 4 - subheader text
            
            text
        )'
}

GetHtml() {
    return '
        (
            <h1>Example header 1 - subheader text</h1>
            
            text
            
            <h2>Example header 2 - subheader text</h2>
            
            text
            
            <h3>Example header 3 - subheader text</h3>
            
            text
            
            <h2>Example header 4 - subheader text</h2>
            
            text
        )'
}
