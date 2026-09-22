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
	_check(game.call("_can_exit", Vector2i(2, 0), "U") == true, "outer up arrow must be clear")
	_check(game.call("_can_exit", Vector2i(2, 2), "U") == false, "center up arrow must start blocked")

	game.get("active_arrows").erase(Vector2i(2, 0))
	_check(game.call("_can_exit", Vector2i(2, 2), "U") == true, "center arrow must clear after blocker is removed")

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
