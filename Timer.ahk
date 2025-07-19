
/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Timer.ahk
    AutoHotkey post: https://www.autohotkey.com/boards/viewtopic.php?f=83&t=138178
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

/**
 * @classdesc - A reusable timer object with history functionality.
 *
 * For classes which inherit from `Timer`, the class can define a method `Init` which, if
 * present, will be called when an instance is constructed. This is just so the `__New` method
 * doesn't need to be rewritten with new initialization logic for inheritors; that
 * can instead be defined on `Init`.
 *
 * When the timer is active, the value of `TimerObj.Status == 1` until the period elapses and
 * the callback is called. When the callback is processing, the start time is recorded,
 * `TimerObj.Status` is set to `2`, then the callback is called. When the callback returns, the
 * end time is recorded and `TimerObj.Status` is set back to 1.
 *
 * When the timer is not active, `TimerObj.Status == 0`.
 *
 * The timer also has a history functionality. {@link Timer#ActivateHistory}.
 * {@link https://www.autohotkey.com/docs/v2/lib/SetTimer.htm}.
 */
class Timer extends Array {
    static __New() {
        this.DeleteProp('__New')
        Proto := this.Prototype
        Proto.Status := Proto.LastActionStart := Proto.LastActionEnd := Proto.__HistoryActive :=
        Proto.__HistoryMaxItems := Proto.__Period := Proto.__Priority := 0
        Proto.HistoryReleaseRatio := 0.05
    }
    /**
     * @description - Defines the number of items that are removed from the array whenever
     * the quantity exceeds the limit defined by `HistoryMaxItems`. The value is a ratio that
     * is multiplied by `HistoryMaxItems`. For example, if `HistoryMaxItems == 1000`, and if
     * `Timer.Prototype.HistoryReleaseRatio == 0.09`, then every time `TimerObj.Length == 1000`,
     * 90 items will be removed.
     */
    static SetHistoryReleaseRatio(Ratio) {
        this.Prototype.HistoryReleaseRatio := Ratio
    }
    /**
     * @class
     * @param {*} Callback - A `Func` or callable object to call when the timer is active.
     * @param {Integer} Period - The period (milliseconds) at which `Callback` is called when the
     * timer is active.
     * @param {Integer} [Priority = 0] - The value passed to the `Priority` parameter of `SetTimer`.
     */
    __New(Period, Priority := 0, Callbacks*) {
        this.Callbacks := Callbacks
        this.__Period := Period
        this.__Priority := Priority
        this.__Count := 0
        if HasMethod(this, 'Init') {
            this.Init()
        }
    }
    /**
     * @description - Activates the history functionality. When the callback is called, an object
     * is created with properties { End, Result, Start }. `Start` is the time the callback was called,
     * `End` is the time the callback returned, and `Result` is the value returned by the callback.
     * These objects are added to the `Timer` object, which is an array.
     * @param {Integer} [MaxItems] - Defines the maximum number of items that may be in the array
     * before removing some. The number of items removed at a time is returned by the property
     * `Timer.Prototype.HistoryReleaseCount`, which is the quotient
     * `MaxItems * Timer.Prototype.HistoryReleaseRatio`. You can adjust the ratio by calling the
     * static method `Timer.SetHistoryReleaseRatio`. The default is `0.05`.
     */
    ActivateHistory(MaxItems?) {
        this.__HistoryActive := 1
        if IsSet(MaxItems) {
            this.HistoryMaxItems := MaxItems
        }
        this.DefineProp('Call', Timer.Prototype.GetOwnPropDesc('__CallHistoryActive'))
        this.DefineProp('TimeRemaining', Timer.Prototype.GetOwnPropDesc('__TimeRemainingHistoryActive'))
        this.DefineProp('LastActionDuration', Timer.Prototype.GetOwnPropDesc('__LastActionDurationHistoryActive'))
    }
    /**
     * @description - When the timer's period elapses, `Timer.Prototype.Call` is called.
     */
    Call(*) {
        if !this.Status {
            SetTimer(, 0)
            return
        }
        this.Status := 2
        this.LastActionStart := A_TickCount
        for cb in this.Callbacks {
            if cb() {
                break
            }
        }
        this.LastActionEnd := A_TickCount
        this.Status := 1
        this.__Count++
    }
    /**
     * @description - Deactivates the history functionality.
     */
    DeactivateHistory() {
        this.__HistoryActive := 0
        this.DefineProp('Call', Timer.Prototype.GetOwnPropDesc('Call'))
        this.DefineProp('TimeRemaining', Timer.Prototype.GetOwnPropDesc('TimeRemaining'))
        this.DefineProp('LastActionDuration', Timer.Prototype.GetOwnPropDesc('LastActionDuration'))
    }
    /**
     * @description - Deletes all own properties and sets `TimerObj.Capacity := 0`.
     */
    Dispose() {
        props := []
        for prop in this.OwnProps() {
            props.Push(prop)
        }
        for prop in props {
            this.DeleteProp(prop)
        }
        this.Capacity := 0
    }
    /**
     * @description - Starts the timer.
     */
    Start() {
        this.Status := 1
        SetTimer(this, this.Period, this.Priority)
    }
    /**
     * @description - Stops the timer.
     */
    Stop() {
        this.Status := 0
        SetTimer(this, 0)
    }
    /**
     * @description - Toggles the timer.
     */
    Toggle() {
        if this.Status {
            this.Stop()
        } else {
            this.Start()
        }
    }
    __CallHistoryActive(*) {
        if !this.Status {
            SetTimer(, 0)
            return
        }
        this.Status := 2
        this.Push({ Start: A_TickCount, Result: Result := [] })
        Result.Capacity := 100
        for cb in this.Callbacks {
            if cb(&Value) {
                break
            }
        }
        Result.Result := this.Callback.Call()
        Result.End := A_TickCount
        this.Status := 1
        Result.Index := this.__Count++
        this.Push(Result)
        if this.HistoryMaxItems > 0 && this.Length > this.HistoryMaxItems {
            this.RemoveAt(1, this.HistoryReleaseCount)
        }
    }

    Count => this.__Count

    /**
     * Returns `1` if the history functionality is currently active. Returns `0` if it is not.
     * If set with a nonzero value, `Timer.Prototype.ActivateHistory` is called. If set with zero
     * or an empty string, `Timer.Prototype.DeactivateHistory` is called.
     * @memberof Timer
     * @instance
     */
    HistoryActive {
        Get => this.__HistoryActive
        Set {
            if Value {
                this.ActivateHistory()
            } else {
                this.DeactivateHistory()
            }
        }
    }
    /**
     * Gets or sets the maximum items allowed in the array when using the history functionality.
     * @memberof Timer
     * @instance
     */
    HistoryMaxItems {
        Get => this.__HistoryMaxItems
        Set {
            if this.Length > Value {
                this.RemoveAt(1, this.Length - Value + this.HistoryReleaseCount)
            }
            this.Capacity := this.__HistoryMaxItems := Value
        }
    }
    /**
     * Returns the number of items that are removed from the array whenever the length of the array
     * is greater than or equal to the maximum.
     * @memberof Timer
     * @instance
     */
    HistoryReleaseCount => Round(this.HistoryMaxItems * this.HistoryReleaseRatio, 0) || 1
    /**
     * Returns the time that elapsed between the start and end of the last callback call.
     * @memberof Timer
     * @instance
     */
    LastActionDuration => this.LastActionEnd - this.LastActionStart
    /**
     * Gets or sets the timer's period. If a timer is currently active, the period is updated.
     * If `Period` is set to 0 when the timer is active, `Timer.Prototype.Stop` is called.
     * @memberof Timer
     * @instance
     */
    Period {
        Get => this.__Period
        Set {
            this.__Period := Value
            if this.Status {
                SetTimer(this, Value)
                if !Value {
                    this.Stop()
                }
            }
        }
    }
    /**
     * Gets or sets the timer's priority. If a timer is currently active, the priority is updated.
     * @memberof Timer
     * @instance
     */
    Priority {
        Get => this.__Priority
        Set {
            this.__Priority := Value
            if this.Status {
                SetTimer(this, , Value)
            }
        }
    }
    /**
     * Returns the milliseconds remaining until the timer is due to call the callback.
     * @memberof Timer
     * @instance
     */
    TimeRemaining => this.Period - A_TickCount + this.LastActionStart
    /**
     * Returns the decimal value representing the proportion of the current period that has elapsed.
     * For example, a value of 0.98 indicates the timer is due to call the callback right now, and a
     * value of 0.04 indicates the callback was just called.
     * @memberof Timer
     * @instance
     */
    TimeRemainingDecimal => this.TimeRemaining / this.Period
    __LastActionDurationHistoryActive => this[-1].End - this[-1].Start
    __TimeRemainingHistoryActive => this.Period - A_TickCount + this[-1].Start
}
