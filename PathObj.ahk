﻿/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/PathObj.ahk
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

/**
 * @classdesc - This is a solution for tracking object paths using strings.
 * @example
 *  Obj := {
 *      Prop1: {
 *          NestedProp1: {
 *              NestedMap: Map(
 *                  'Key1', Map(
 *                      'Key2', 'Val1'
 *                  )
 *              )
 *          }
 *      }
 *  }
 *  Root := PathObj('Obj')
 *  O1 := Root.MakeProp('Prop1')
 *  O2 := O1.MakeProp('NestedProp1')
 *  O3 := O2.MakeProp('NestedMap')
 *  O4 := O3.MakeItem('Key1')
 *  O5 := O4.MakeItem('Key2')
 *  OutputDebug(O5()) ; Obj.Prop1.NestedProp1.NestedMap["Key1"]["Key2"]
 *
 *  ; You can start another branch
 *  Obj.Prop1.Branch := [ 1, 2, { Prop: 'Val' }, 4 ]
 *  B1 := O1.MakeProp('Branch')
 *  B2 := B1.MakeItem(3)
 *  B3 := B2.MakeProp('Prop')
 *  OutputDebug('`n' B3()) ; Obj.Prop1.Branch[3].Prop
 * @
 */
class PathObj {
    __New(Name := '$') {
        this.Name := Name
        this.Count := 1
        this.DefineProp('GetPathSegment', PathObj.Prototype.GetOwnPropDesc('__GetPathSegmentRoot'))
    }
    Call() {
        o := this
        p := ''
        loop {
            if o.GetPathSegment(&p) {
                break
            }
            o := o.Base
        }
        return o.Name p
    }
    MakeProp(Name) {
        ObjSetBase(Segment := { Name: Name, Count: this.Count + 1 }, this)
        Segment.DefineProp('GetPathSegment', PathObj.Prototype.GetOwnPropDesc('__GetPathSegmentProp'))
        return Segment
    }
    MakeItem(Name) {
        ObjSetBase(Segment := { Name: Name, Count: this.Count + 1 }, this)
        if IsNumber(Name) {
            Segment.DefineProp('GetPathSegment', PathObj.Prototype.GetOwnPropDesc('__GetPathSegmentItem_Number'))
        } else {
            Segment.DefineProp('GetPathSegment', PathObj.Prototype.GetOwnPropDesc('__GetPathSegmentItem_String'))
        }
        return Segment
    }
    __GetPathSegmentItem_Number(&Path) {
        Path := '[' this.Name ']' Path
    }
    __GetPathSegmentItem_String(&Path) {
        Path := '["' this.Name '"]' Path
    }
    __GetPathSegmentProp(&Path) {
        Path := '.' this.Name Path
    }
    __GetPathSegmentRoot(*) {
        return 1
    }
}
