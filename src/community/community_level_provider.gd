class_name CommunityLevelProvider
extends Node

signal feed_loaded(entries)
signal level_loaded(entry)
signal published(entry)
signal request_failed(message)

const LevelRulesScript = preload("res://src/levels/level_rules.gd")

const API_VERSION := 1
const ALLOWED_FEEDS := ["new", "popular", "trending", "curated"]
const MAX_NAME_LENGTH := 48
const MAX_SUBTITLE_LENGTH := 96

var base_url := ""
var auth_token := ""
var active_operation := ""
var http: HTTPRequest


func _init(api_base_url: String = "") -> void:
	configure(api_base_url)


func _ready() -> void:
	http = HTTPRequest.new()
	http.name = "HTTPRequest"
	add_child(http)
	http.request_completed.connect(_on_request_completed)


func configure(api_base_url: String) -> void:
	base_url = api_base_url.strip_edges()
	while base_url.ends_with("/"):
		base_url = base_url.left(base_url.length() - 1)


func set_auth_token(token: String) -> void:
	auth_token = token.strip_edges()


func is_configured() -> bool:
	return not base_url.is_empty()


func fetch_feed(feed: String = "new") -> bool:
	var normalized_feed := feed.to_lower()
	if not ALLOWED_FEEDS.has(normalized_feed):
		_emit_failure("Unsupported community feed.")
		return false

	return _request(
		"feed:%s" % normalized_feed,
		"/v1/levels?feed=%s" % normalized_feed,
		HTTPClient.METHOD_GET
	)


func download_level(public_id: String, revision: int) -> bool:
	if public_id.strip_edges().is_empty() or revision < 1:
		_emit_failure("A public level ID and positive revision are required.")
		return false

	return _request(
		"download",
		"/v1/levels/%s/revisions/%d" % [public_id.uri_encode(), revision],
		HTTPClient.METHOD_GET
	)


func publish_level(level: Dictionary) -> bool:
	var document := build_publish_document(level)
	if not bool(document.get("ok", false)):
		_emit_failure(str(document.get("error", "Level cannot be published.")))
		return false

	return _request(
		"publish",
		"/v1/levels",
		HTTPClient.METHOD_POST,
		JSON.stringify(document["body"])
	)


func _request(operation: String, path: String, method: HTTPClient.Method, body: String = "") -> bool:
	if active_operation != "":
		_emit_failure("A community request is already in progress.")
		return false
	if not is_configured():
		_emit_failure("Community service is not configured yet.")
		return false
	if http == null:
		_emit_failure("Community HTTP transport is not ready.")
		return false

	var headers := PackedStringArray()
	headers.append("Accept: application/json")
	if method != HTTPClient.METHOD_GET:
		headers.append("Content-Type: application/json")
	if not auth_token.is_empty():
		headers.append("Authorization: Bearer %s" % auth_token)

	active_operation = operation
	var request_error := http.request(base_url + path, headers, method, body)
	if request_error != OK:
		active_operation = ""
		_emit_failure("Community request could not start: %s" % error_string(request_error))
		return false

	return true


func _on_request_completed(
	result: int,
	response_code: int,
	_response_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	var operation := active_operation
	active_operation = ""

	if result != HTTPRequest.RESULT_SUCCESS:
		_emit_failure("Community request failed before a response was received.")
		return
	if response_code < 200 or response_code >= 300:
		_emit_failure("Community service returned HTTP %d." % response_code)
		return

	var payload = JSON.parse_string(body.get_string_from_utf8())
	if payload == null:
		_emit_failure("Community service returned invalid JSON.")
		return

	if operation.begins_with("feed:"):
		var feed_result := parse_feed_document(payload)
		if not bool(feed_result.get("ok", false)):
			_emit_failure(str(feed_result.get("error", "Invalid community feed.")))
			return
		feed_loaded.emit(feed_result.get("entries", []))
		return

	if operation == "download":
		var level_result := parse_single_entry_document(payload)
		if not bool(level_result.get("ok", false)):
			_emit_failure(str(level_result.get("error", "Invalid community level.")))
			return
		level_loaded.emit(level_result["entry"])
		return

	if operation == "publish":
		var publish_result := parse_single_entry_document(payload)
		if not bool(publish_result.get("ok", false)):
			_emit_failure(str(publish_result.get("error", "Invalid publication response.")))
			return
		published.emit(publish_result["entry"])
		return

	_emit_failure("Community response did not match an active operation.")


func _emit_failure(message: String) -> void:
	request_failed.emit(message)


static func build_publish_document(level: Dictionary) -> Dictionary:
	var normalized := _normalize_publish_level(level)
	var validation_error := LevelRulesScript.validate_level(normalized)
	if not validation_error.is_empty():
		return {
			"ok": false,
			"error": validation_error,
		}
	if not LevelRulesScript.is_solvable(normalized):
		return {
			"ok": false,
			"error": "Only solvable levels can be published.",
		}

	return {
		"ok": true,
		"body": {
			"schema_version": API_VERSION,
			"client_level_id": str(level.get("id", "")),
			"level": normalized,
		},
	}


static func parse_feed_document(payload: Variant) -> Dictionary:
	if typeof(payload) != TYPE_DICTIONARY:
		return {
			"ok": false,
			"error": "Community feed must be a JSON object.",
			"entries": [],
		}

	var payload_dict: Dictionary = payload
	var raw_entries = payload_dict.get("levels", [])
	if typeof(raw_entries) != TYPE_ARRAY:
		return {
			"ok": false,
			"error": "Community feed levels must be an array.",
			"entries": [],
		}

	var entries: Array = []
	for raw_entry_variant in raw_entries:
		if typeof(raw_entry_variant) != TYPE_DICTIONARY:
			continue
		var raw_entry: Dictionary = raw_entry_variant
		var normalized_entry := _normalize_published_entry(raw_entry)
		if not normalized_entry.is_empty():
			entries.append(normalized_entry)

	return {
		"ok": true,
		"entries": entries,
	}


static func parse_single_entry_document(payload: Variant) -> Dictionary:
	if typeof(payload) != TYPE_DICTIONARY:
		return {
			"ok": false,
			"error": "Community level response must be a JSON object.",
		}

	var payload_dict: Dictionary = payload
	var raw_entry = payload_dict.get("entry", payload_dict)
	if typeof(raw_entry) != TYPE_DICTIONARY:
		return {
			"ok": false,
			"error": "Community level entry must be an object.",
		}

	var entry_dict: Dictionary = raw_entry
	var normalized_entry := _normalize_published_entry(entry_dict)
	if normalized_entry.is_empty():
		return {
			"ok": false,
			"error": "Community level failed schema or solvability validation.",
		}

	return {
		"ok": true,
		"entry": normalized_entry,
	}


static func _normalize_published_entry(entry: Dictionary) -> Dictionary:
	var public_id := str(entry.get("public_id", "")).strip_edges()
	var revision := int(entry.get("revision", 0))
	var creator_id := str(entry.get("creator_id", "")).strip_edges()
	if public_id.is_empty() or revision < 1 or creator_id.is_empty():
		return {}

	var raw_level = entry.get("level", {})
	if typeof(raw_level) != TYPE_DICTIONARY:
		return {}

	var source_level: Dictionary = raw_level
	var normalized_level := _normalize_publish_level(source_level)
	normalized_level["id"] = "%s@r%d" % [public_id, revision]
	normalized_level["source"] = "community"

	var validation_error := LevelRulesScript.validate_level(normalized_level)
	if not validation_error.is_empty():
		return {}
	if not LevelRulesScript.is_solvable(normalized_level):
		return {}

	var stats := {
		"plays": 0,
		"likes": 0,
	}
	var raw_stats = entry.get("stats", {})
	if typeof(raw_stats) == TYPE_DICTIONARY:
		var stats_dict: Dictionary = raw_stats
		stats["plays"] = maxi(0, int(stats_dict.get("plays", 0)))
		stats["likes"] = maxi(0, int(stats_dict.get("likes", 0)))

	return {
		"public_id": public_id,
		"revision": revision,
		"creator_id": creator_id,
		"published_at": maxi(0, int(entry.get("published_at", 0))),
		"stats": stats,
		"level": normalized_level,
	}


static func _normalize_publish_level(level: Dictionary) -> Dictionary:
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

	var name := str(level.get("name", "Untitled level")).strip_edges().left(MAX_NAME_LENGTH)
	if name.is_empty():
		name = "Untitled level"

	return {
		"schema_version": int(level.get("schema_version", API_VERSION)),
		"id": str(level.get("id", "")),
		"source": str(level.get("source", "player")),
		"name": name,
		"subtitle": str(level.get("subtitle", "Created by a player.")).strip_edges().left(MAX_SUBTITLE_LENGTH),
		"board_size": int(level.get("board_size", LevelRulesScript.GRID_SIZE)),
		"arrows": arrows,
	}
