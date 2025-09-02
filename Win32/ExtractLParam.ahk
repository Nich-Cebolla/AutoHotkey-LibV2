
ExtractLParam(Value, &OutLow?, &OutHigh?) {
    OutLow := Value & 0xFFFF
    OutHigh := (Value >> 16) & 0xFFFF
}
