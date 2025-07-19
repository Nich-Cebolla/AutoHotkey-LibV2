/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/structs/IntegerArray.ahk
    Author: Nich-Cebolla
    License: MIT
*/
/**
 * @classdesc - A buffer object that can be used with Dll calls or other actions that require a
 * pointer to a buffer. You can specify the integer type.
 *
 * This class is intended to simplify the handling of any series of integers contained in a buffer;
 * the objects can be enumerated by calling it in a `for` loop, and the items can be accessed by index,
 * which is a slight convenience to using multiples of the byte size with `NumGet`. Negative indices
 * are treated as right-to-left.
 *
 * Note: To adhere to AHK's convention, the value at byte offset 0 is considered index 1.
 *
 * @example
 *  ; I know that the object is going to have one more item added to it
 *  ; later, so I'll set its capacity to 4 so it doesn't need to be resized.
 *  iArr := IntegerArray(4, , 10, 23, 1991)
 *  MsgBox(iArr[1]) ; 10
 *  MsgBox(iArr[-1]) ; <integer> the fourth index hasn't been set.
 *                   ; This will still return a value, albeit
 *                   ; a meaningless one in the context of this app.
 *  MsgBox(iArr[-2]) ; 1991
 *  iArr[4] := 18
 *  MsgBox(iArr[-1]) ; 18
 *  ; enumerate the values
 *  for n in iArr {
 *      str .= n ', '
 *  }
 *  MsgBox(Trim(str, ', ')) ; 10, 23, 1991, 18
 *
 *  ; In some other part of the code, there's a small possibility that
 *  ; the object needs resized, so I only resize it if the condition
 *  ; occurs.
 *
 *  iArr[5] := 30 ; IndexError: Index out of range.
 *
 *  if Condition {
 *      iArr.Capacity := 5
 *  }
 *  iArr[5] := 30
 *  MsgBox(iArr[-1]) ; 30
 *
 *  ; To use in a `DllCall`, just pass the object directly
 *  if DllCall('FunctionName', 'ptr', iArr, 'int') {
 *      throw OSError()
 *  }
 * @
 * The object does not track which indices are set; accessing an unset index will return an
 * indeterminate value. This means that, when calling the object in a `for` loop, it will iterate the
 * entire buffer even if you never added an integer to any index. If your code would benefit from
 * oversizing the object and you need to iterate a number of items that isn't known until runtime,
 * you have two options to handle this. If, at that point, the size is not expected to change again,
 * you can just resize it to the correct size then call it in a `for` loop. If you expect the
 * object will still have more items added to it later, you'll just need to call the `__Enum` property
 * directly, as I added an `End` parameter you can use to limit it.
 * @example
 *  iArr := IntegerArray(6, , 10, 9, 10)
 *  ; The first parameter of `IntegerArray.Prototype.__Enum` is `VarCount`
 *  ; The second is `End`, so we set it to 3.
 *  for n in iArr.__Enum(1, 3) {
 *      ; work
 *  }
 *  ; or
 *  for i, n in iArr.__Enum(2, 3) {
 *      s .= i ': ' n ', '
 *  }
 *  MsgBox(Trim(s, ', ')) ; 1: 10, 2: 9, 3: 10
 * @
 * Regarding the `IntegerArray.Prototype.__Item` property, -1 will always be the last position
 * according to the `Size` property, even if you never added a value there.
 */
class IntegerArray extends Buffer {
    /**
     * Constructs an `IntegerArray` instance.
     * @param {Integer} [Capacity=0] - The maximum item count in number of items. This value is used
     * to set the `Size` property of the buffer object, which directs the AHK interpreter to allocate
     * the memory and perform other necessary actions. There is also a `Capacity` property on the
     * isntance that you can use to change the maximum number of items. Remember, when working with
     * the `Capacity` property, use indices, and when working with the `Size` property, use bytes
     * (items * 4).
     * See {@link https://www.autohotkey.com/docs/v2/lib/Buffer.htm} for the details about
     * `BufferObj.Size`.
     * @param {String} [IntType='int'] - The type of integer. This gets used as the `Type` param
     * of `NumGet` and `NumPut`. See {@link https://www.autohotkey.com/docs/v2/lib/DllCall.htm#types}
     * @param {...Integer} [Values] - Any number of values to be added to the buffer. Be mindful
     * of the the limitations of whichever type of integer you are working. For undertanding bytes
     * and integers, see {@link https://www.autohotkey.com/docs/v2/Concepts.htm#pure-numbers}.
     * @returns {IntegerArray}
     * @class
     */
    __New(Capacity := 0, IntType := 'int', IntBytes := 4, Values*) {
        if Values.Length > Capacity {
            throw ValueError('Insufficient memory allocated for quantity of values.', -1
            , 'Capacity: ' Capacity '; Quantity: ' Values.Length)
        }
        this.Capacity := Capacity
        this.__IntBytes := IntBytes
        /**
         * @property Type - The integer type to use with `NumGet` and `NumPut`.
         */
        this.Type := IntType
        for Value in Values {
            NumPut(IntType, Value, this, (A_Index - 1) * this.__IntBytes)
        }
    }

    /**
     * @description - Returns an enumerator. Supports 1- or 2-param mode `for` loops. In 1-param mode,
     * the variable receives the value at that index. In 2-param mode, the first variable receives
     * the item's index, and the second variable receives the item's value.
     * @param {Integer} VarCount - The number of parameters used in the `for` loop. Typically AHK
     * sets this parameter to the correct value, but if you need to call `iArr.__Enum` directly,
     * you have to set this to the correct number of variables used in your `for` loop.
     */
    __Enum(VarCount, End?) {
        i := 0
        if !IsSet(End) {
            End := this.Size / this.__IntBytes
        }
        return VarCount == 1 ? _Enum : _Enum2

        _Enum(&Value) {
            if ++i > End {
                return 0
            }
            Value := NumGet(this, (i - 1) * this.__IntBytes, this.Type)
            return 1
        }
        _Enum2(&Index, &Value) {
            if ++i > End {
                return 0
            }
            Value := NumGet(this, (i - 1) * this.__IntBytes, this.Type)
            Index := i
            return 1
        }
    }

    IntBytes => this.__IntBytes

    /**
     * @property IntegerArray.Prototype.Capacity - Gets or sets the maximum number of items that
     * can be contained in the IntegerArray.
     */
    Capacity {
        Get => this.Size / this.__IntBytes
        Set => this.Size := Value * this.__IntBytes
    }

    /**
     * @property Size - The size of the buffer in number of bytes. `Size` is on the base object,
     * and so is not actually seen here.
     */

    /**
     * @property IntegerArray.Prototype.__Item - Gets or sets an integer using an index position.
     * `IntegerArray` instances use a 1-based index.
     * @param {Integer} Index - The 1-based index to get or set.
     */
    __Item[Index] {
        Get {
            if Abs(Index) > this.Size / this.__IntBytes || !Index {
                throw IndexError('Index out of range.', -1, 'Index: ' Index '; Length: ' (this.Size / this.__IntBytes))
            }
            return NumGet(this, Index > 0 ? (Index - 1) * this.__IntBytes : this.Size + Index * this.__IntBytes, 'int')

        }
        Set {
            if Abs(Index) > this.Size / this.__IntBytes || !Index {
                throw IndexError('Index out of range.', -1, 'Index: ' Index '; Length: ' (this.Size / this.__IntBytes))
            }
            If !IsNumber(Value) {
                throw TypeError('``Value`` must be a number.', -1, 'Type(Value) == ' Type(Value))
            }
            NumPut(this.Type, Value, this, Index > 0 ? (Index - 1) * this.__IntBytes : this.Size + Index * this.__IntBytes)
        }
    }
}
