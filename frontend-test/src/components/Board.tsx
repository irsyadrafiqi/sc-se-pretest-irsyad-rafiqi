import { memo } from 'react';
import Cell from './Cell';

type Position = { row: number; column: number };

type BoardProps = {
  rows: number;
  columns: number;
  knight: Position;
  allowedMoves: Set<string>;
  hovered: Position | null;
  onHover: (row: number, column: number) => void;
  onLeave: () => void;
  onCellClick: (row: number, column: number) => void;
};

function Board({
  rows,
  columns,
  knight,
  allowedMoves,
  hovered,
  onHover,
  onLeave,
  onCellClick,
}: BoardProps) {
  const cells = Array.from({ length: rows * columns }, (_, index) => {
    const row = Math.floor(index / columns);
    const column = index % columns;
    const key = `${row}-${column}`;

    return (
      <Cell
        key={key}
        row={row}
        column={column}
        isKnight={knight.row === row && knight.column === column}
        isAllowed={allowedMoves.has(key)}
        isHovered={hovered?.row === row && hovered?.column === column}
        onHover={onHover}
        onLeave={onLeave}
        onClick={onCellClick}
      />
    );
  });

  return (
    <div
      className="board"
      style={{
        gridTemplateColumns: `repeat(${columns}, minmax(0, 1fr))`,
        gridTemplateRows: `repeat(${rows}, minmax(0, 1fr))`,
      }}
      role="grid"
      aria-label={`${rows} by ${columns} chess board`}
    >
      {cells}
    </div>
  );
}

export default memo(Board);
