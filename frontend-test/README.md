# Frontend Test

## Stack
- React
- TypeScript
- Vite

## Run
```bash
npm install
npm run dev
```

## Implementation notes
- `Board` and `Cell` are separate components as requested.
- The knight starts at row 0, column 0.
- Only legal knight moves can change the knight position.
- Hovering the current square or an illegal square is red.
- Hovering a legal destination is green.
- Generate Board validates integer values from 1 through 100 and resets the knight.
- `Cell` and `Board` use `memo`; legal moves are derived with `useMemo` instead of storing redundant state.
