class_name LevelCatalog
extends RefCounted

const OFFICIAL_LEVELS := [
	{
		"schema_version": 1,
		"id": "official-001",
		"source": "official",
		"name": "First Escape",
		"subtitle": "Clear the outside arrows, then free the center.",
		"board_size": 5,
		"arrows": [
			[2, 0, "U"],
			[2, 2, "U"],
			[0, 2, "L"],
			[4, 2, "R"],
			[1, 4, "D"],
			[3, 4, "D"],
		],
	},
	{
		"schema_version": 1,
		"id": "official-002",
		"source": "official",
		"name": "Queue",
		"subtitle": "Arrows in the same lane have to leave in order.",
		"board_size": 5,
		"arrows": [
			[2, 0, "U"],
			[2, 1, "U"],
			[2, 2, "U"],
			[0, 3, "L"],
			[1, 3, "L"],
			[4, 1, "R"],
			[4, 4, "D"],
		],
	},
	{
		"schema_version": 1,
		"id": "official-003",
		"source": "official",
		"name": "Cross Traffic",
		"subtitle": "Open both lanes before releasing the deeper arrows.",
		"board_size": 5,
		"arrows": [
			[0, 2, "L"],
			[1, 2, "L"],
			[2, 2, "L"],
			[2, 0, "U"],
			[2, 1, "U"],
			[2, 3, "U"],
			[4, 0, "U"],
			[4, 3, "R"],
		],
	},
]


static func official_levels() -> Array:
	return OFFICIAL_LEVELS.duplicate(true)
