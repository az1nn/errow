class_name LocalLevelStore
extends RefCounted

const LevelRulesScript = preload("res://src/levels/level_rules.gd")
const DEFAULT_PATH := "user://community_levels.json"
const SCHEMA_VERSION := 1

var storage_path: String


func _init(path: String = DEFAULT_PATH) -> void:
	storage_path = path


func list_levels() -> Array:
	if not FileAccess.file_exists(storage_path):
		return []

	var file := FileAccess.open(storage_path, FileAccess.READ)
	if file == null:
		return []

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return []

	var raw_levels = parsed.get("levels", [])
	if typeof(raw_levels) != TYPE_ARRAY:
		return []

	var levels: Array = []
	for item in raw_levels:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var normalized := _normalize_level(item)
		if LevelRulesScript.validate_level(normalized).is_empty():
			levels.append(normalized)

	return levels


func upsert_level(level: Dictionary) -> Dictionary:
	var normalized := _normalize_level(level)
	var validation_error := LevelRulesScript.validate_level(normalized)
	if not validation_error.is_empty():
		return {
			"ok": false,
			"error": validation_error,
		}

	var now := int(Time.get_unix_time_from_system())
	if str(normalized["id"]).is_empty():
		normalized["id"] = "local-%d-%04d" % [
			int(Time.get_unix_time_from_system() * 1000.0),
			randi_range(0, 9999),
		]
	if int(normalized.get("created_at", 0)) <= 0:
		normalized["created_at"] = now
	normalized["updated_at"] = now
	normalized["source"] = "player"

	var levels := list_levels()
	var replaced := false
	for index in range(levels.size()):
		if str(levels[index].get("id", "")) == str(normalized["id"]):
			levels[index] = normalized
			replaced = true
			break

	if not replaced:
		levels.append(normalized)

	var file := FileAccess.open(storage_path, FileAccess.WRITE)
	if file == null:
		return {
			"ok": false,
			"error": "Could not open local level storage.",
		}

	var payload := {
		"schema_version": SCHEMA_VERSION,
		"levels": levels,
	}
	if not file.store_string(JSON.stringify(payload, "\t")):
		return {
			"ok": false,
			"error": "Could not write local level storage.",
		}

	return {
		"ok": true,
		"level": normalized,
	}


func clear_levels() -> bool:
	if not FileAccess.file_exists(storage_path):
		return true
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(storage_path)) == OK


func _normalize_level(level: Dictionary) -> Dictionary:
	var arrows: Array = []
	var raw_arrows = level.get("arrows", [])
	if typeof(raw_arrows) == TYPE_ARRAY:
		for item in raw_arrows:
			if typeof(item) != TYPE_ARRAY or item.size() != 3:
				continue
			arrows.append([
				int(item[0]),
				int(item[1]),
				str(item[2]),
			])

	return {
		"schema_version": int(level.get("schema_version", SCHEMA_VERSION)),
		"id": str(level.get("id", "")),
		"source": str(level.get("source", "player")),
		"name": str(level.get("name", "Untitled level")).strip_edges().left(48),
		"subtitle": str(level.get("subtitle", "Created by a player.")).strip_edges().left(96),
		"board_size": int(level.get("board_size", LevelRulesScript.GRID_SIZE)),
		"arrows": arrows,
		"created_at": int(level.get("created_at", 0)),
		"updated_at": int(level.get("updated_at", 0)),
	}
