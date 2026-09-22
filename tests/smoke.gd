extends SceneTree

var failures := 0


func _initialize() -> void:
	call_deferred("_run")


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
	_check(game.get("active_arrows").size() == 6, "level 1 must start with 6 arrows")

	var first_button: Button = game.get("arrow_buttons")[Vector2i(2, 0)]
	var first_visual := first_button.get_node_or_null("ArrowVisual")
	_check(first_visual != null, "active arrows must use reusable ArrowVisual")
	if first_visual != null:
		_check(first_visual.call("get_direction") == "U", "ArrowVisual must receive the board direction")

	_check(game.call("_can_exit", Vector2i(2, 0), "U") == true, "outer up arrow must be clear")
	_check(game.call("_can_exit", Vector2i(2, 2), "U") == false, "center up arrow must start blocked")

	var escape_start := first_button.global_position
	game.call("_on_arrow_pressed", Vector2i(2, 0))
	_check(game.get("is_animating_escape") == true, "successful move must enter escape animation state")
	_check(game.get("active_arrows").size() == 6, "arrow state must remain until escape animation completes")
	_check(first_button.get_parent().name == "EscapeLayer", "escaping arrow must move to the dedicated overlay layer")
	await create_timer(0.08).timeout
	_check(first_button.global_position.y < escape_start.y, "up arrow must animate upward")
	await create_timer(0.30).timeout
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
	if failures > 0:
		push_error("Godot smoke tests failed: %d" % failures)
		quit(1)
		return

	print("Godot smoke tests passed.")
	quit(0)
