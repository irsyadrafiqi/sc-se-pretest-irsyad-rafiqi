import { memo } from 'react';

type CellProps = {
  row: number;
  column: number;
  isKnight: boolean;
  isAllowed: boolean;
  isHovered: boolean;
  onHover: (row: number, column: number) => void;
  onLeave: () => void;
  onClick: (row: number, column: number) => void;
};

function Cell({
  row,
  column,
  isKnight,
  isAllowed,
  isHovered,
  onHover,
  onLeave,
  onClick,
}: CellProps) {
  const classNames = [
    'cell',
    (row + column) % 2 === 0 ? 'cell-light' : 'cell-dark',
    isHovered && isAllowed ? 'cell-hover-valid' : '',
    isHovered && !isAllowed ? 'cell-hover-invalid' : '',
    isKnight ? 'cell-knight' : '',
  ]
    .filter(Boolean)
    .join(' ');

  return (
    <button
      type="button"
      className={classNames}
      aria-label={`Row ${row + 1}, Column ${column + 1}${isKnight ? ', knight position' : ''}`}
      onMouseEnter={() => onHover(row, column)}
      onMouseLeave={onLeave}
      onClick={() => onClick(row, column)}
    >
      {isKnight ? 'K' : ''}
    </button>
  );
}

export default memo(Cell);
