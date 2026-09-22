extends Control

const GRID_SIZE := 5
const ESCAPE_DURATION := 0.28

const DIRECTIONS := {
	"U": Vector2i(0, -1),
	"R": Vector2i(1, 0),
	"D": Vector2i(0, 1),
	"L": Vector2i(-1, 0),
}

const LEVELS := [
	{
		"name": "First Escape",
		"subtitle": "Clear the outside arrows, then free the center.",
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
		"name": "Queue",
		"subtitle": "Arrows in the same lane have to leave in order.",
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
		"name": "Cross Traffic",
		"subtitle": "Open both lanes before releasing the deeper arrows.",
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

var level_index := 0
var moves := 0
var active_arrows: Dictionary = {}
var arrow_buttons: Dictionary = {}
var is_animating_escape := false
var escape_tween: Tween

var level_label: Label
var subtitle_label: Label
var remaining_label: Label
var moves_label: Label
var status_label: Label
var grid: GridContainer
var escape_layer: Control
var overlay: ColorRect
var overlay_title: Label
var overlay_copy: Label
var overlay_button: Button


func _ready() -> void:
	_build_ui()
	_load_level(0)


func _build_ui() -> void:
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("#0b0e14")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 56)
	margin.add_theme_constant_override("margin_right", 56)
	margin.add_theme_constant_override("margin_top", 58)
	margin.add_theme_constant_override("margin_bottom", 44)
	add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 24)
	margin.add_child(stack)

	var brand := Label.new()
	brand.text = "ERROW"
	brand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	brand.add_theme_font_size_override("font_size", 52)
	brand.add_theme_color_override("font_color", Color("#f6f7fb"))
	stack.add_child(brand)

	var rule := Label.new()
	rule.text = "Tap an arrow only when its path to the edge is clear."
	rule.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rule.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rule.add_theme_font_size_override("font_size", 22)
	rule.add_theme_color_override("font_color", Color("#9ba5b7"))
	stack.add_child(rule)

	level_label = Label.new()
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 38)
	level_label.add_theme_color_override("font_color", Color("#dff9ee"))
	stack.add_child(level_label)

	subtitle_label = Label.new()
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle_label.add_theme_font_size_override("font_size", 20)
	subtitle_label.add_theme_color_override("font_color", Color("#8d98ab"))
	stack.add_child(subtitle_label)

	var stats := HBoxContainer.new()
	stats.alignment = BoxContainer.ALIGNMENT_CENTER
	stats.add_theme_constant_override("separation", 42)
	stack.add_child(stats)

	remaining_label = Label.new()
	remaining_label.add_theme_font_size_override("font_size", 20)
	remaining_label.add_theme_color_override("font_color", Color("#c9d1de"))
	stats.add_child(remaining_label)

	moves_label = Label.new()
	moves_label.add_theme_font_size_override("font_size", 20)
	moves_label.add_theme_color_override("font_color", Color("#c9d1de"))
	stats.add_child(moves_label)

	var board_center := CenterContainer.new()
	board_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_child(board_center)

	grid = GridContainer.new()
	grid.columns = GRID_SIZE
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	board_center.add_child(grid)

	status_label = Label.new()
	status_label.text = "Find a clear path."
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.custom_minimum_size = Vector2(0, 56)
	status_label.add_theme_font_size_override("font_size", 21)
	status_label.add_theme_color_override("font_color", Color("#8d98ab"))
	stack.add_child(status_label)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 16)
	stack.add_child(actions)

	var restart := Button.new()
	restart.text = "Restart level"
	restart.custom_minimum_size = Vector2(250, 64)
	restart.focus_mode = Control.FOCUS_NONE
	restart.add_theme_font_size_override("font_size", 20)
	restart.pressed.connect(_restart_level)
	_apply_action_style(restart)
	actions.add_child(restart)

	var skip := Button.new()
	skip.text = "Next level"
	skip.custom_minimum_size = Vector2(250, 64)
	skip.focus_mode = Control.FOCUS_NONE
	skip.add_theme_font_size_override("font_size", 20)
	skip.pressed.connect(_next_level)
	_apply_action_style(skip)
	actions.add_child(skip)

	escape_layer = Control.new()
	escape_layer.name = "EscapeLayer"
	escape_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	escape_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(escape_layer)

	overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.02, 0.03, 0.05, 0.88)
	overlay.visible = false
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var overlay_center := CenterContainer.new()
	overlay_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(overlay_center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(620, 390)
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color("#151b25")
	card_style.border_color = Color("#283244")
	card_style.set_border_width_all(2)
	card_style.set_corner_radius_all(28)
	card_style.content_margin_left = 44
	card_style.content_margin_right = 44
	card_style.content_margin_top = 40
	card_style.content_margin_bottom = 40
	card.add_theme_stylebox_override("panel", card_style)
	overlay_center.add_child(card)

	var overlay_stack := VBoxContainer.new()
	overlay_stack.alignment = BoxContainer.ALIGNMENT_CENTER
	overlay_stack.add_theme_constant_override("separation", 24)
	card.add_child(overlay_stack)

	overlay_title = Label.new()
	overlay_title.text = "Level cleared"
	overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_title.add_theme_font_size_override("font_size", 42)
	overlay_title.add_theme_color_override("font_color", Color("#dff9ee"))
	overlay_stack.add_child(overlay_title)

	overlay_copy = Label.new()
	overlay_copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay_copy.add_theme_font_size_override("font_size", 22)
	overlay_copy.add_theme_color_override("font_color", Color("#a9b4c5"))
	overlay_stack.add_child(overlay_copy)

	overlay_button = Button.new()
	overlay_button.custom_minimum_size = Vector2(280, 72)
	overlay_button.focus_mode = Control.FOCUS_NONE
	overlay_button.add_theme_font_size_override("font_size", 22)
	overlay_button.pressed.connect(_next_level)
	_apply_action_style(overlay_button)
	overlay_stack.add_child(overlay_button)


func _load_level(index: int) -> void:
	_cancel_escape_animation()
	level_index = clampi(index, 0, LEVELS.size() - 1)
	moves = 0
	active_arrows.clear()
	arrow_buttons.clear()
	overlay.visible = false

	var level: Dictionary = LEVELS[level_index]
	for item in level["arrows"]:
		var cell := Vector2i(int(item[0]), int(item[1]))
		active_arrows[cell] = str(item[2])

	level_label.text = "Level %d · %s" % [level_index + 1, level["name"]]
	subtitle_label.text = str(level["subtitle"])
	status_label.text = "Find a clear path."
	_rebuild_board()
	_update_stats()


func _rebuild_board() -> void:
	for child in grid.get_children():
		child.free()
	arrow_buttons.clear()

	for row in range(GRID_SIZE):
		for column in range(GRID_SIZE):
			var cell := Vector2i(column, row)
			var slot := PanelContainer.new()
			slot.custom_minimum_size = Vector2(126, 126)
			slot.add_theme_stylebox_override("panel", _cell_style())
			grid.add_child(slot)

			if not active_arrows.has(cell):
				continue

			var direction: String = active_arrows[cell]
			var button := Button.new()
			button.text = ""
			button.focus_mode = Control.FOCUS_NONE
			button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			_apply_arrow_style(button)
			button.pressed.connect(_on_arrow_pressed.bind(cell))
			slot.add_child(button)

			var visual := ArrowVisual.new()
			visual.name = "ArrowVisual"
			visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
			visual.configure(direction)
			button.add_child(visual)
			visual.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

			arrow_buttons[cell] = button


func _on_arrow_pressed(cell: Vector2i) -> void:
	if not active_arrows.has(cell):
		return
	if is_animating_escape:
		return

	var direction_code: String = active_arrows[cell]
	if not _can_exit(cell, direction_code):
		status_label.text = "Blocked. Clear the arrow in front first."
		var blocked_button: Button = arrow_buttons[cell]
		blocked_button.modulate = Color("#ff8d96")
		var blocked_tween := create_tween()
		blocked_tween.tween_property(blocked_button, "modulate", Color.WHITE, 0.28)
		return

	status_label.text = "Clear path — arrow escaped."
	moves += 1
	is_animating_escape = true

	var button: Button = arrow_buttons[cell]
	button.disabled = true
	var direction := Vector2(DIRECTIONS[direction_code])
	var start_position := button.global_position
	var target_position := start_position + direction * _escape_distance(button)

	button.reparent(escape_layer, true)
	button.global_position = start_position

	escape_tween = create_tween()
	escape_tween.tween_property(button, "global_position", target_position, ESCAPE_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	escape_tween.parallel().tween_property(button, "modulate:a", 0.0, ESCAPE_DURATION)
	escape_tween.tween_callback(_finish_escape.bind(cell, button))


func _finish_escape(cell: Vector2i, button: Button) -> void:
	escape_tween = null
	if is_instance_valid(button):
		button.free()
	is_animating_escape = false
	_remove_arrow(cell)


func _cancel_escape_animation() -> void:
	if escape_tween != null:
		escape_tween.kill()
		escape_tween = null

	is_animating_escape = false
	if escape_layer == null:
		return

	for child in escape_layer.get_children():
		child.free()


func _escape_distance(button: Control) -> float:
	return maxf(grid.size.x, grid.size.y) + maxf(button.size.x, button.size.y)


func _remove_arrow(cell: Vector2i) -> void:
	active_arrows.erase(cell)
	_update_stats()

	if active_arrows.is_empty():
		_show_complete()
		return

	_rebuild_board()


func _can_exit(cell: Vector2i, direction_code: String) -> bool:
	var direction: Vector2i = DIRECTIONS[direction_code]
	var cursor := cell + direction

	while _inside_grid(cursor):
		if active_arrows.has(cursor):
			return false
		cursor += direction

	return true


func _inside_grid(cell: Vector2i) -> bool:
	return (
		cell.x >= 0
		and cell.y >= 0
		and cell.x < GRID_SIZE
		and cell.y < GRID_SIZE
	)


func _show_complete() -> void:
	overlay.visible = true
	if level_index == LEVELS.size() - 1:
		overlay_title.text = "Starter set cleared"
		overlay_copy.text = "You cleared all three MVP levels in %d successful moves." % moves
		overlay_button.text = "Replay from level 1"
	else:
		overlay_title.text = "Level cleared"
		overlay_copy.text = "Solved in %d successful moves. Ready for the next board?" % moves
		overlay_button.text = "Next level"


func _restart_level() -> void:
	_load_level(level_index)


func _next_level() -> void:
	if level_index >= LEVELS.size() - 1:
		_load_level(0)
	else:
		_load_level(level_index + 1)


func _update_stats() -> void:
	remaining_label.text = "Arrows: %d" % active_arrows.size()
	moves_label.text = "Moves: %d" % moves


func _cell_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#121721")
	style.border_color = Color("#202938")
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	return style


func _apply_arrow_style(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#eef4f7")
	normal.set_corner_radius_all(16)
	normal.content_margin_left = 8
	normal.content_margin_right = 8
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("#dff9ee")

	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("#bcebd7")

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", normal)
	button.add_theme_color_override("font_color", Color("#111820"))
	button.add_theme_color_override("font_hover_color", Color("#111820"))
	button.add_theme_color_override("font_pressed_color", Color("#111820"))
	button.add_theme_color_override("font_disabled_color", Color("#111820"))


func _apply_action_style(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#192331")
	normal.border_color = Color("#34445a")
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(16)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("#223044")

	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("#101824")

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", Color("#e8edf5"))
	button.add_theme_color_override("font_hover_color", Color("#ffffff"))
	button.add_theme_color_override("font_pressed_color", Color("#d8e1ed"))
