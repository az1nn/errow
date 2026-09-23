extends SceneTree

const LevelRulesScript = preload("res://src/levels/level_rules.gd")
const LocalLevelStoreScript = preload("res://src/levels/local_level_store.gd")
const CommunityLevelProviderScript = preload("res://src/community/community_level_provider.gd")
const CommunityAuthSessionScript = preload("res://src/community/community_auth_session.gd")

var failures := 0
var finished := false


func _initialize() -> void:
	var watchdog := create_timer(8.0)
	watchdog.timeout.connect(_on_watchdog_timeout)
	call_deferred("_run")


func _on_watchdog_timeout() -> void:
	if finished:
		return
	failures += 1
	push_error("Godot smoke tests timed out before completion.")
	quit(1)


func _run() -> void:
	var packed := load("res://src/main.tscn") as PackedScene
	_check(packed != null, "main.tscn must load as PackedScene")

	if packed == null:
		_finish()
		return

	var game := packed.instantiate()
	root.add_child(game)
	await process_frame

	_check(game != null, "main scene must instantiate")
	_check(game.get("levels").size() == 3, "official catalog must expose three starter levels")
	_check(game.get("active_arrows").size() == 6, "level 1 must start with 6 arrows")
	_check(LevelRulesScript.is_solvable(game.get("levels")[0]), "official level 1 must be solvable")
	_check(game.get_node_or_null("LevelCreator") != null, "main scene must include the player level creator")
	_check(game.get_node_or_null("CommunityLevelProvider") != null, "main scene must include the community provider boundary")
	_check(game.get("community_actions") != null, "main scene must expose the authenticated Community action surface")
	_check(game.get("community_actions").visible == false, "Community actions must stay hidden for Original levels")
	_check(game.get("player_publish_actions") != null, "main scene must expose the Player publication surface")
	_check(game.get("player_publish_actions").visible == false, "Player publication must stay hidden for Original levels")

	var auth_session := CommunityAuthSessionScript.new()
	_check(auth_session.is_authenticated() == false, "community auth session must start anonymous")
	auth_session.set_auth_token("  smoke-token  ")
	_check(auth_session.is_authenticated(), "community auth session must become authenticated after token injection")
	_check(auth_session.bearer_token() == "smoke-token", "community auth session must normalize surrounding token whitespace")
	auth_session.clear()
	_check(auth_session.is_authenticated() == false, "community auth session clear must restore anonymous mode")

	var deadlocked_level := {
		"schema_version": 1,
		"board_size": 5,
		"name": "Deadlock fixture",
		"arrows": [
			[1, 2, "R"],
			[3, 2, "L"],
		],
	}
	_check(LevelRulesScript.is_solvable(deadlocked_level) == false, "opposing arrows must be detected as a deadlock")

	var community_feed_result: Dictionary = CommunityLevelProviderScript.parse_feed_document({
		"levels": [
			{
				"public_id": "ERROW-SMOKE",
				"revision": 2,
				"creator_id": "creator-smoke",
				"published_at": 123456,
				"stats": {
					"plays": 12,
					"likes": 4,
				},
				"level": {
					"schema_version": 1,
					"name": "Remote smoke",
					"subtitle": "Valid remote level",
					"board_size": 5,
					"arrows": [
						[2, 0, "U"],
						[2, 2, "U"],
					],
				},
			},
			{
				"public_id": "ERROW-DEADLOCK",
				"revision": 1,
				"creator_id": "creator-smoke",
				"level": deadlocked_level,
			},
		],
	})
	_check(bool(community_feed_result.get("ok", false)), "community feed envelope must parse")
	var community_entries: Array = community_feed_result.get("entries", [])
	_check(community_entries.size() == 1, "community feed must discard deadlocked remote levels")
	if community_entries.size() == 1:
		var community_entry: Dictionary = community_entries[0]
		var community_level: Dictionary = community_entry.get("level", {})
		_check(str(community_entry.get("public_id", "")) == "ERROW-SMOKE", "community metadata must remain outside level schema")
		_check(int(community_entry.get("revision", 0)) == 2, "community revision must be preserved")
		_check(str(community_level.get("source", "")) == "community", "downloaded level must use community provenance")
		_check(str(community_level.get("id", "")) == "ERROW-SMOKE@r2", "runtime level id must include immutable revision")

	var valid_publish: Dictionary = CommunityLevelProviderScript.build_publish_document({
		"schema_version": 1,
		"id": "local-smoke",
		"source": "player",
		"name": "Publish smoke",
		"subtitle": "Client validation",
		"board_size": 5,
		"arrows": [
			[2, 0, "U"],
			[2, 2, "U"],
		],
	})
	_check(bool(valid_publish.get("ok", false)), "solvable saved Player level must produce a publish document")
	_check(str(valid_publish.get("body", {}).get("client_level_id", "")) == "local-smoke", "publication must preserve the stable local ID as client_level_id")
	var unsaved_publish: Dictionary = CommunityLevelProviderScript.build_publish_document({
		"schema_version": 1,
		"source": "player",
		"name": "Unsaved publish",
		"board_size": 5,
		"arrows": [[2, 0, "U"]],
	})
	_check(bool(unsaved_publish.get("ok", false)) == false, "unsaved Player levels must be rejected before publication")
	var official_publish: Dictionary = CommunityLevelProviderScript.build_publish_document({
		"schema_version": 1,
		"id": "official-smoke",
		"source": "official",
		"name": "Official publish",
		"board_size": 5,
		"arrows": [[2, 0, "U"]],
	})
	_check(bool(official_publish.get("ok", false)) == false, "non-Player provenance must be rejected before publication")
	var deadlocked_publish: Dictionary = CommunityLevelProviderScript.build_publish_document(deadlocked_level)
	_check(bool(deadlocked_publish.get("ok", false)) == false, "deadlocked level must be rejected before publication")

	var test_store_path := "user://errow-smoke-community-levels.json"
	var test_store: LocalLevelStore = LocalLevelStoreScript.new(test_store_path)
	test_store.clear_levels()
	var saved_result: Dictionary = test_store.upsert_level({
		"schema_version": 1,
		"board_size": 5,
		"name": "Smoke player level",
		"subtitle": "Round trip",
		"arrows": [
			[2, 0, "U"],
			[2, 2, "U"],
		],
	})
	_check(bool(saved_result.get("ok", false)), "player level store must save a valid level")
	var stored_levels: Array = test_store.list_levels()
	_check(stored_levels.size() == 1, "player level store must load the saved level")
	if stored_levels.size() == 1:
		_check(str(stored_levels[0].get("source", "")) == "player", "stored player level must keep player provenance")
		_check(LevelRulesScript.is_solvable(stored_levels[0]), "stored player level must remain solvable after JSON round trip")
	test_store.clear_levels()

	var first_button: Button = game.get("arrow_buttons")[Vector2i(2, 0)]
	var first_visual := first_button.get_node_or_null("ArrowVisual")
	_check(first_visual != null, "active arrows must use reusable ArrowVisual")
	if first_visual != null:
		_check(first_visual.call("get_direction") == "U", "ArrowVisual must receive the board direction")

	_check(game.call("_can_exit", Vector2i(2, 0), "U") == true, "outer up arrow must be clear")
	_check(game.call("_can_exit", Vector2i(2, 2), "U") == false, "center up arrow must start blocked")

	var escape_start := first_button.global_position
	var escape_target: Vector2 = game.call("_escape_target_position", first_button, "U")
	_check(escape_target.y < escape_start.y, "up arrow escape target must be above its start position")
	game.call("_on_arrow_pressed", Vector2i(2, 0))
	_check(game.get("is_animating_escape") == true, "successful move must enter escape animation state")
	_check(game.get("active_arrows").size() == 6, "arrow state must remain until escape animation completes")
	_check(first_button.get_parent().name == "EscapeLayer", "escaping arrow must move to the dedicated overlay layer")
	await create_timer(0.34).timeout
	_check(game.get("active_arrows").size() == 5, "arrow state must update after escape animation completes")
	_check(game.get("is_animating_escape") == false, "escape animation state must clear after completion")
	_check(game.call("_can_exit", Vector2i(2, 2), "U") == true, "center arrow must clear after blocker escapes")

	game.call("_load_level", 0)
	var restart_button: Button = game.get("arrow_buttons")[Vector2i(2, 0)]
	game.call("_on_arrow_pressed", Vector2i(2, 0))
	await process_frame
	_check(restart_button.get_parent().name == "EscapeLayer", "restart fixture must begin an escape")
	game.call("_restart_level")
	await create_timer(0.34).timeout
	_check(game.get("active_arrows").size() == 6, "restart must prevent stale escape callback from mutating the reloaded board")
	_check(game.get("is_animating_escape") == false, "restart must cancel escape animation state")

	game.call("_load_level", 1)
	_check(game.get("active_arrows").size() == 7, "level 2 must start with 7 arrows")
	_check(game.call("_can_exit", Vector2i(2, 2), "U") == false, "deep queue arrow must start blocked")

	game.call("_load_level", 2)
	_check(game.get("active_arrows").size() == 8, "level 3 must start with 8 arrows")
	_check(game.call("_can_exit", Vector2i(2, 2), "L") == false, "cross-traffic inner arrow must start blocked")

	var runtime_auth_session = game.get("community_auth_session")
	var runtime_provider = game.get("community_level_provider")
	runtime_auth_session.clear()
	runtime_provider.configure("")
	game.call("_set_level_collection", [valid_publish["body"]["level"]], "player")
	_check(game.get("player_publish_actions").visible == false, "Player publication must stay unavailable without a configured service")
	_check(game.get("player_publish_hint").visible, "Player publication must explain unavailable service state")
	runtime_provider.configure("https://community.example")
	game.call("_refresh_player_publish_actions")
	_check(game.get("player_publish_actions").visible == false, "anonymous Player sessions must not expose publication")
	runtime_auth_session.set_auth_token("smoke-token")
	_check(runtime_provider.auth_token == "smoke-token", "runtime auth changes must propagate to the Community provider")
	_check(game.get("player_publish_actions").visible, "configured authenticated Player sessions must expose publication")
	_check(game.get("player_publish_hint").visible == false, "publication hint must hide when publishing is available")

	runtime_auth_session.clear()
	game.call("_on_community_feed_loaded", community_entries)
	_check(str(game.get("level_collection")) == "community", "community entries must switch the runtime collection")
	_check(game.get("community_actions").visible == false, "anonymous Community play must keep authenticated actions hidden")
	var active_community_level: Dictionary = game.get("levels")[0]
	_check(str(active_community_level.get("_community_public_id", "")) == "ERROW-SMOKE", "community runtime level must retain its public ID for engagement")
	_check(int(active_community_level.get("_community_revision", 0)) == 2, "community runtime level must retain its immutable revision")
	runtime_auth_session.set_auth_token("smoke-token")
	_check(game.get("community_level_provider").auth_token == "smoke-token", "runtime auth changes must propagate to the Community provider")
	game.call("_refresh_community_actions")
	_check(game.get("community_actions").visible, "authenticated Community play must expose engagement controls")
	game.call("_show_official_levels")
	_check(str(game.get("level_collection")) == "official", "official levels must remain available after community browsing")
	_check(game.get("community_actions").visible == false, "Community actions must hide again outside Community play")

	game.queue_free()
	await process_frame
	_finish()


func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
		return

	failures += 1
	push_error("FAIL: " + message)


func _finish() -> void:
	finished = true
	if failures > 0:
		push_error("Godot smoke tests failed: %d" % failures)
		quit(1)
		return

	print("Godot smoke tests passed.")
	quit(0)
