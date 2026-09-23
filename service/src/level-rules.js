export const GRID_SIZE = 5;
export const DIRECTIONS = Object.freeze({
  U: [0, -1],
  R: [1, 0],
  D: [0, 1],
  L: [-1, 0],
});

const MAX_NAME = 60;
const MAX_SUBTITLE = 160;

export function validateLevel(level) {
  if (!level || typeof level !== "object" || Array.isArray(level)) {
    return "Level must be an object.";
  }
  if (Number(level.schema_version ?? 1) !== 1) {
    return "Unsupported level schema.";
  }
  if (Number(level.board_size ?? GRID_SIZE) !== GRID_SIZE) {
    return "Only 5x5 levels are supported.";
  }
  if (typeof level.name !== "string" || level.name.trim().length === 0 || level.name.length > MAX_NAME) {
    return `Level name must contain 1-${MAX_NAME} characters.`;
  }
  if (level.subtitle != null && (typeof level.subtitle !== "string" || level.subtitle.length > MAX_SUBTITLE)) {
    return `Level subtitle must contain at most ${MAX_SUBTITLE} characters.`;
  }
  if (!Array.isArray(level.arrows)) {
    return "Level arrows must be an array.";
  }
  if (level.arrows.length === 0) {
    return "Add at least one arrow.";
  }
  if (level.arrows.length > GRID_SIZE * GRID_SIZE) {
    return "A 5x5 board can contain at most 25 arrows.";
  }

  const occupied = new Set();
  for (const item of level.arrows) {
    if (!Array.isArray(item) || item.length !== 3) {
      return "Each arrow must be [x, y, direction].";
    }
    const [x, y, direction] = item;
    if (!Number.isInteger(x) || !Number.isInteger(y)) {
      return "Arrow coordinates must be integers.";
    }
    if (!insideGrid(x, y)) {
      return "Arrow coordinates must stay inside the 5x5 board.";
    }
    if (!(direction in DIRECTIONS)) {
      return "Arrow direction must be U, R, D or L.";
    }
    const key = `${x},${y}`;
    if (occupied.has(key)) {
      return "Only one arrow can occupy a cell.";
    }
    occupied.add(key);
  }

  return "";
}

export function isSolvable(level) {
  if (validateLevel(level)) return false;

  const active = new Map(level.arrows.map(([x, y, direction]) => [`${x},${y}`, { x, y, direction }]));
  while (active.size > 0) {
    let removable = null;
    for (const [key, arrow] of active) {
      if (canExit(active, arrow)) {
        removable = key;
        break;
      }
    }
    if (removable == null) return false;
    active.delete(removable);
  }
  return true;
}

export function sanitizeLevel(level) {
  return {
    schema_version: 1,
    name: level.name.trim(),
    subtitle: typeof level.subtitle === "string" ? level.subtitle.trim() : "",
    board_size: GRID_SIZE,
    arrows: level.arrows.map(([x, y, direction]) => [x, y, direction]),
  };
}

function canExit(active, arrow) {
  const [dx, dy] = DIRECTIONS[arrow.direction];
  let x = arrow.x + dx;
  let y = arrow.y + dy;
  while (insideGrid(x, y)) {
    if (active.has(`${x},${y}`)) return false;
    x += dx;
    y += dy;
  }
  return true;
}

function insideGrid(x, y) {
  return x >= 0 && y >= 0 && x < GRID_SIZE && y < GRID_SIZE;
}
