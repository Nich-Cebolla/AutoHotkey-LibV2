

class HotkeyObj {
    __New(Name, KeyName?, Options?, HotIfCallback?) {
        this.Name := Name
        this.KeyName := KeyName ?? ''
        this.Options := Options ?? ''
        this.HotIfCallback := HotIfCallback ?? ''
        this.Status := 0
    }

    Toggle(Action?, Options?, &OutPreviousHotIfCriteria?) {
        OutPreviousHotIfCriteria := (cb := this.HotIfCallback)(this)
        return this.ToggleSkipCallback(Action ?? unset, Options ?? unset)
    }

    ToggleSkipCallback(Action?, Options?) {
        if IsSet(Action) {
            switch Action, 0 {
                case 'Off': this.Status := 0
                case 'On': this.Status := 1
                case 'Toggle': this.Status := !this.Status
            }
        } else {
            if this.Status {
                Action := 'Off'
                this.Status := 0
            } else {
                Action := 'On'
                this.Status := 1
            }
        }
        HotKey(this.KeyName, Action, Options ?? this.Options || unset)
        return Action
    }
}
