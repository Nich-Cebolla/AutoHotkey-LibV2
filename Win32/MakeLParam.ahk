
MakeLParam(Low, High) {
    return (High & 0xFFFF) << 16 | (Low & 0xFFFF)
}
