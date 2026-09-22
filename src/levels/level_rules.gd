class_name LevelRules
extends RefCounted

const GRID_SIZE := 5
const DIRECTIONS := {
	"U": Vector2i(0, -1),
	"R": Vector2i(1, 0),
	"D": Vector2i(0, 1),
	"L": Vector2i(-1, 0),
}


static func validate_level(level: Dictionary) -> String:
	if int(level.get("schema_version", 1)) != 1:
		return "Unsupported level schema."

	if int(level.get("board_size", GRID_SIZE)) != GRID_SIZE:
		return "Only 5x5 levels are supported."

	var raw_arrows = level.get("arrows", [])
	if typeof(raw_arrows) != TYPE_ARRAY:
		return "Level arrows must be an array."

	var arrows: Array = raw_arrows
	if arrows.is_empty():
		return "Add at least one arrow."
	if arrows.size() > GRID_SIZE * GRID_SIZE:
		return "A 5x5 board can contain at most 25 arrows."

	var occupied := {}
	for item in arrows:
		if typeof(item) != TYPE_ARRAY or item.size() != 3:
			return "Each arrow must be [x, y, direction]."

		var cell := Vector2i(int(item[0]), int(item[1]))
		var direction := str(item[2])
		if not _inside_grid(cell, GRID_SIZE):
			return "Arrow coordinates must stay inside the 5x5 board."
		if not DIRECTIONS.has(direction):
			return "Arrow direction must be U, R, D or L."
		if occupied.has(cell):
			return "Only one arrow can occupy a cell."
		occupied[cell] = true

	return ""


static func to_active_arrows(level: Dictionary) -> Dictionary:
	var active := {}
	var raw_arrows = level.get("arrows", [])
	if typeof(raw_arrows) != TYPE_ARRAY:
		return active

	for item in raw_arrows:
		if typeof(item) != TYPE_ARRAY or item.size() != 3:
			continue
		active[Vector2i(int(item[0]), int(item[1]))] = str(item[2])

	return active


static func can_exit(active_arrows: Dictionary, cell: Vector2i, direction_code: String, grid_size: int = GRID_SIZE) -> bool:
	if not DIRECTIONS.has(direction_code):
		return false

	var direction: Vector2i = DIRECTIONS[direction_code]
	var cursor: Vector2i = cell + direction
	while _inside_grid(cursor, grid_size):
		if active_arrows.has(cursor):
			return false
		cursor += direction

	return true


static func is_solvable(level: Dictionary) -> bool:
	if not validate_level(level).is_empty():
		return false

	var active := to_active_arrows(level)
	while not active.is_empty():
		var removable = null
		for cell_variant in active.keys():
			var cell: Vector2i = cell_variant
			var direction: String = active[cell]
			if can_exit(active, cell, direction, GRID_SIZE):
				removable = cell
				break

		if removable == null:
			return false

		active.erase(removable)

	return true


static func _inside_grid(cell: Vector2i, grid_size: int) -> bool:
	return (
		cell.x >= 0
		and cell.y >= 0
		and cell.x < grid_size
		and cell.y < grid_size
	)
