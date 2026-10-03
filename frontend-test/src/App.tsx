import { useMemo, useState } from 'react';
import Board from './components/Board';

type Position = { row: number; column: number };

const KNIGHT_DELTAS = [
  { row: -1, column: 2 },
  { row: 1, column: 2 },
  { row: -1, column: -2 },
  { row: 1, column: -2 },
  { row: -2, column: 1 },
  { row: 2, column: 1 },
  { row: -2, column: -1 },
  { row: 2, column: -1 },
];

function isInsideBoard(row: number, column: number, rows: number, columns: number) {
  return row >= 0 && row < rows && column >= 0 && column < columns;
}

function getAllowedMoves(knight: Position, rows: number, columns: number) {
  const moves = new Set<string>();

  for (const delta of KNIGHT_DELTAS) {
    const row = knight.row + delta.row;
    const column = knight.column + delta.column;

    if (isInsideBoard(row, column, rows, columns)) {
      moves.add(`${row}-${column}`);
    }
  }

  return moves;
}

function App() {
  const [rowInput, setRowInput] = useState('8');
  const [columnInput, setColumnInput] = useState('8');
  const [rows, setRows] = useState(8);
  const [columns, setColumns] = useState(8);
  const [knight, setKnight] = useState<Position>({ row: 0, column: 0 });
  const [hovered, setHovered] = useState<Position | null>(null);

  const nextRows = Number(rowInput);
  const nextColumns = Number(columnInput);
  const rowsAreValid = Number.isInteger(nextRows) && nextRows >= 1 && nextRows <= 100;
  const columnsAreValid =
    Number.isInteger(nextColumns) && nextColumns >= 1 && nextColumns <= 100;
  const dimensionsAreValid =
    rowsAreValid && columnsAreValid;

  const allowedMoves = useMemo(
    () => getAllowedMoves(knight, rows, columns),
    [knight, rows, columns],
  );

  const handleGenerate = () => {
    if (!dimensionsAreValid) return;

    setRows(nextRows);
    setColumns(nextColumns);
    setKnight({ row: 0, column: 0 });
    setHovered(null);
  };

  const handleCellClick = (row: number, column: number) => {
    if (allowedMoves.has(`${row}-${column}`)) {
      setKnight({ row, column });
      setHovered(null);
    }
  };

  return (
    <main className="page">
      <section className="game-card">
        <h1>Chess Lonely Knight</h1>

        <div className="controls">
          <label>
            <span>Row</span>
            <input
              type="number"
              min={1}
              max={100}
              step={1}
              value={rowInput}
              onChange={(event) => setRowInput(event.target.value)}
              aria-invalid={!rowsAreValid}
            />
          </label>

          <label>
            <span>Column</span>
            <input
              type="number"
              min={1}
              max={100}
              step={1}
              value={columnInput}
              onChange={(event) => setColumnInput(event.target.value)}
              aria-invalid={!columnsAreValid}
            />
          </label>

          <button
            className="generate-button"
            type="button"
            onClick={handleGenerate}
            disabled={!dimensionsAreValid}
          >
            Generate
            <br />
            Board
          </button>
        </div>

        {!dimensionsAreValid && (
          <p className="form-error" role="alert">
            Row and column must be whole numbers from 1 to 100.
          </p>
        )}

        <div className="board-wrapper">
          <Board
            rows={rows}
            columns={columns}
            knight={knight}
            allowedMoves={allowedMoves}
            hovered={hovered}
            onHover={(row, column) => setHovered({ row, column })}
            onLeave={() => setHovered(null)}
            onCellClick={handleCellClick}
          />
        </div>
      </section>
    </main>
  );
}

export default App;
