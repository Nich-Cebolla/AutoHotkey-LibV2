
RGB(Color) {
    if !RegExMatch(Color, 'i)R(?<R>\d+)\s*G(?<G>\d+)\s*B(?<B>\d+)', &Match) {
        throw ValueError('The input value must be a string in format "R<n> G<n> B<n>".', -1)
    }
    return (Number(Match['R']) << 16) | (Number(Match['G']) << 8) | Number(Match['B'])
}
