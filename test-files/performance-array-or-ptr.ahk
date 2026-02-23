
/**
    The purpose of this test is to determine which method for referring to a function performs better:
    - Storing the function object reference in an array
    - Passing the function pointer to ObjPtrAddRef

    The following results were typical on my machine. Conclusion: Passing the function pointer to
    ObjPtrAddRef performs better.

    arr total: 1.109
    arr avg: 0.27725
    arr 1: 281
    arr 2: 266
    arr 3: 281
    arr 4: 281
    ptr total: 0.92200000000000004
    ptr avg: 0.23050000000000001
    ptr 1: 235
    ptr 2: 234
    ptr 3: 234
    ptr 4: 219
*/

#SingleInstance force

ProcessSetPriority('High')
A_ListLines := 0

sleep 5000
fn := ObjBindMethod(Object, 'Call')
arr := [ fn ]
ptr := ObjPtr(fn)

; --------------------- 1

start := A_TickCount
loop 1000000 {
    o := arr[1]()
}
arr_1 := A_TickCount - start

start := A_TickCount
loop 1000000 {
    o := ObjFromPtrAddRef(ptr)()
}
ptr_1 := A_TickCount - start

; --------------------- 2

start := A_TickCount
loop 1000000 {
    o := ObjFromPtrAddRef(ptr)()
}
ptr_2 := A_TickCount - start

start := A_TickCount
loop 1000000 {
    o := arr[1]()
}
arr_2 := A_TickCount - start

; --------------------- 3

start := A_TickCount
loop 1000000 {
    o := arr[1]()
}
arr_3 := A_TickCount - start

start := A_TickCount
loop 1000000 {
    o := ObjFromPtrAddRef(ptr)()
}
ptr_3 := A_TickCount - start

; --------------------- 4

start := A_TickCount
loop 1000000 {
    o := ObjFromPtrAddRef(ptr)()
}
ptr_4 := A_TickCount - start

start := A_TickCount
loop 1000000 {
    o := arr[1]()
}
arr_4 := A_TickCount - start

; ---------------------

arr_t := (arr_1 + arr_2 + arr_3 + arr_4) / 1000
arr_a := arr_t / 4
ptr_t := (ptr_1 + ptr_2 + ptr_3 + ptr_4) / 1000
ptr_a := ptr_t / 4

msgbox(A_Clipboard := (
    'arr total: ' arr_t '`narr avg: ' arr_a '`narr 1: ' arr_1 '`narr 2: ' arr_2 '`narr 3: ' arr_3 '`narr 4: ' arr_4 '`n'
    'ptr total: ' ptr_t '`nptr avg: ' ptr_a '`nptr 1: ' ptr_1 '`nptr 2: ' ptr_2 '`nptr 3: ' ptr_3 '`nptr 4: ' ptr_4
))
