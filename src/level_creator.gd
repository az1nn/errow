class_name LevelCreator
extends ColorRect

signal playtest_requested(level: Dictionary)
signal closed

const LevelRulesScript = preload("res://src/levels/level_rules.gd")
const LocalLevelStoreScript = preload("res://src/levels/local_level_store.gd")
const ArrowVisualScript = preload("res://src/arrow_visual.gd")

const CYCLE := ["", "U", "R", "D", "L"]

var store: LocalLevelStore = LocalLevelStoreScript.new()
var editor_arrows: Dictionary = {}
var cell_buttons: Dictionary = {}
var saved_levels: Array = []
var editing_id := ""
var editing_created_at := 0

var title_edit: LineEdit
var status_label: Label
var saved_picker: OptionButton


func _ready() -> void:
	name = "LevelCreator"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color = Color(0.02, 0.03, 0.05, 0.98)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_ui()
	visible = false


func open_creator() -> void:
	_refresh_saved_levels()
	_new_level()
	visible = true


func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 52)
	margin.add_theme_constant_override("margin_right", 52)
	margin.add_theme_constant_override("margin_top", 44)
	margin.add_theme_constant_override("margin_bottom", 44)
	add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 18)
	margin.add_child(stack)

	var heading := Label.new()
	heading.text = "CREATE LEVEL"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 42)
	heading.add_theme_color_override("font_color", Color("#f6f7fb"))
	stack.add_child(heading)

	var helper := Label.new()
	helper.text = "Tap a cell to cycle: empty → up → right → down → left."
	helper.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	helper.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	helper.add_theme_font_size_override("font_size", 18)
	helper.add_theme_color_override("font_color", Color("#9ba5b7"))
	stack.add_child(helper)

	title_edit = LineEdit.new()
	title_edit.placeholder_text = "Level name"
	title_edit.max_length = 48
	title_edit.custom_minimum_size = Vector2(0, 58)
	title_edit.add_theme_font_size_override("font_size", 20)
	stack.add_child(title_edit)

	var board_center := CenterContainer.new()
	board_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_child(board_center)

	var editor_grid := GridContainer.new()
	editor_grid.columns = LevelRulesScript.GRID_SIZE
	editor_grid.add_theme_constant_override("h_separation", 10)
	editor_grid.add_theme_constant_override("v_separation", 10)
	board_center.add_child(editor_grid)

	for row in range(LevelRulesScript.GRID_SIZE):
		for column in range(LevelRulesScript.GRID_SIZE):
			var cell := Vector2i(column, row)
			var button := Button.new()
			button.custom_minimum_size = Vector2(108, 108)
			button.focus_mode = Control.FOCUS_NONE
			button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			button.pressed.connect(_cycle_cell.bind(cell))
			_apply_cell_style(button)
			editor_grid.add_child(button)
			cell_buttons[cell] = button

	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.custom_minimum_size = Vector2(0, 48)
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color("#a9b4c5"))
	stack.add_child(status_label)

	var saved_row := HBoxContainer.new()
	saved_row.alignment = BoxContainer.ALIGNMENT_CENTER
	saved_row.add_theme_constant_override("separation", 12)
	stack.add_child(saved_row)

	saved_picker = OptionButton.new()
	saved_picker.custom_minimum_size = Vector2(390, 56)
	saved_picker.add_theme_font_size_override("font_size", 18)
	saved_row.add_child(saved_picker)

	var load_button := Button.new()
	load_button.text = "Load draft"
	load_button.custom_minimum_size = Vector2(170, 56)
	load_button.focus_mode = Control.FOCUS_NONE
	load_button.pressed.connect(_load_selected)
	_apply_action_style(load_button)
	saved_row.add_child(load_button)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 12)
	stack.add_child(actions)

	for definition in [
		["New", _new_level],
		["Save draft", _save_level],
		["Playtest", _playtest],
		["Close", _close],
	]:
		var button := Button.new()
		button.text = str(definition[0])
		button.custom_minimum_size = Vector2(170, 60)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(definition[1])
		_apply_action_style(button)
		actions.add_child(button)


func _new_level() -> void:
	editing_id = ""
	editing_created_at = 0
	editor_arrows.clear()
	title_edit.text = "Untitled level"
	for cell in cell_buttons.keys():
		_render_cell(cell)
	_update_validation_status()


func _cycle_cell(cell: Vector2i) -> void:
	var current := str(editor_arrows.get(cell, ""))
	var current_index := CYCLE.find(current)
	var next_direction: String = CYCLE[(current_index + 1) % CYCLE.size()]

	if next_direction.is_empty():
		editor_arrows.erase(cell)
	else:
		editor_arrows[cell] = next_direction

	_render_cell(cell)
	_update_validation_status()


func _render_cell(cell: Vector2i) -> void:
	var button: Button = cell_buttons[cell]
	var previous := button.get_node_or_null("EditorArrow")
	if previous != null:
		previous.free()

	if not editor_arrows.has(cell):
		button.tooltip_text = "Empty"
		return

	var direction: String = editor_arrows[cell]
	var visual := ArrowVisualScript.new()
	visual.name = "EditorArrow"
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual.configure(direction)
	button.add_child(visual)
	visual.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.tooltip_text = direction


func _draft_level() -> Dictionary:
	var arrows: Array = []
	for row in range(LevelRulesScript.GRID_SIZE):
		for column in range(LevelRulesScript.GRID_SIZE):
			var cell := Vector2i(column, row)
			if editor_arrows.has(cell):
				arrows.append([cell.x, cell.y, str(editor_arrows[cell])])

	var title := title_edit.text.strip_edges()
	if title.is_empty():
		title = "Untitled level"

	return {
		"schema_version": 1,
		"id": editing_id,
		"source": "player",
		"name": title,
		"subtitle": "Created by a player.",
		"board_size": LevelRulesScript.GRID_SIZE,
		"arrows": arrows,
		"created_at": editing_created_at,
	}


func _save_level() -> Dictionary:
	var draft := _draft_level()
	var result: Dictionary = store.upsert_level(draft)
	if not bool(result.get("ok", false)):
		status_label.text = str(result.get("error", "Could not save level."))
		return {}

	var saved: Dictionary = result["level"]
	editing_id = str(saved["id"])
	editing_created_at = int(saved["created_at"])
	var suffix := "solvable" if LevelRulesScript.is_solvable(saved) else "deadlocked"
	status_label.text = "Draft saved locally · %s." % suffix
	_refresh_saved_levels(editing_id)
	return saved


func _playtest() -> void:
	var draft := _draft_level()
	var validation_error := LevelRulesScript.validate_level(draft)
	if not validation_error.is_empty():
		status_label.text = validation_error
		return

	if not LevelRulesScript.is_solvable(draft):
		status_label.text = "Deadlock detected. Re-orient or remove arrows before playtesting."
		return

	var saved := _save_level()
	if saved.is_empty():
		return

	visible = false
	playtest_requested.emit(saved)


func _close() -> void:
	visible = false
	closed.emit()


func _refresh_saved_levels(selected_id: String = "") -> void:
	saved_levels = store.list_levels()
	saved_picker.clear()

	if saved_levels.is_empty():
		saved_picker.add_item("No saved drafts")
		saved_picker.disabled = true
		return

	saved_picker.disabled = false
	var selected_index := 0
	for index in range(saved_levels.size()):
		var level: Dictionary = saved_levels[index]
		var suffix := "✓" if LevelRulesScript.is_solvable(level) else "!"
		saved_picker.add_item("%s  %s" % [suffix, str(level.get("name", "Untitled level"))])
		if not selected_id.is_empty() and str(level.get("id", "")) == selected_id:
			selected_index = index
	saved_picker.select(selected_index)


func _load_selected() -> void:
	if saved_levels.is_empty() or saved_picker.disabled:
		status_label.text = "No saved drafts yet."
		return

	var index := saved_picker.get_selected_id()
	if index < 0 or index >= saved_levels.size():
		return

	var level: Dictionary = saved_levels[index]
	editing_id = str(level.get("id", ""))
	editing_created_at = int(level.get("created_at", 0))
	title_edit.text = str(level.get("name", "Untitled level"))
	editor_arrows = LevelRulesScript.to_active_arrows(level)

	for cell in cell_buttons.keys():
		_render_cell(cell)
	_update_validation_status()


func _update_validation_status() -> void:
	var draft := _draft_level()
	var error := LevelRulesScript.validate_level(draft)
	if not error.is_empty():
		status_label.text = error
		return

	if LevelRulesScript.is_solvable(draft):
		status_label.text = "%d arrows · solvable · ready to playtest." % editor_arrows.size()
	else:
		status_label.text = "%d arrows · deadlock detected." % editor_arrows.size()


func _apply_cell_style(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#121721")
	normal.border_color = Color("#283244")
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(14)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("#192331")

	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("#223044")

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)


func _apply_action_style(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#192331")
	normal.border_color = Color("#34445a")
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(14)

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
