
#include ..\Pattern.ahk

; This tests the patterns which define valid and invalid characters to use with AHK variables

test()

class test {
    static Call() {
        pValid := Pattern.AhkAllowedSymbolChars
        pInvalid := Pattern.AhkInvalidSymbolChars
        valid := ['var1', '_var1', Chr(0x1F600), Chr(0x1F40D), Chr(0x1F680), Chr(0x3042), Chr(0x30A2), Chr(0x65E5) ]

        ; To demonstrate they are valid
        😀 :=   ; 128512 / 0x1F600
        🐍 :=   ; 128013 / 0x1F40D
        🚀 :=   ; 128640 / 0x1F680
        あ :=   ; 12354 / 0x3042
        ア :=   ; 12450 / 0x30A2
        日 := 1 ; 26085 / 0x65E5

        invalid := [ '#', '$', '%', '^', '`t', '`n', '`r', '`s', Chr(0x0085), Chr(0x009F) ]

        for str in valid {
            if !RegExMatch(str, pValid) {
                throw Error('A valid string was not matched by the valid pattern.', -1, str)
            }
            if RegExMatch(str, pInvalid) {
                throw Error('A valid string was matched by the invalid pattern.', -1, str)
            }
        }
        for str in invalid {
            if RegExMatch(str, pValid) {
                throw Error('An invalid string was matched by the valid pattern.', -1, str)
            }
            if !RegExMatch(str, pInvalid) {
                throw Error('An invalid string was not matched by the invalid pattern.', -1, str)
            }
        }
    }
}
