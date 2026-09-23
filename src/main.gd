extends Control

const GRID_SIZE := 5
const ESCAPE_DURATION := 0.28

const LevelRulesScript = preload("res://src/levels/level_rules.gd")
const LevelCatalogScript = preload("res://src/levels/level_catalog.gd")
const LocalLevelStoreScript = preload("res://src/levels/local_level_store.gd")
const CommunityLevelProviderScript = preload("res://src/community/community_level_provider.gd")
const CommunityAuthSessionScript = preload("res://src/community/community_auth_session.gd")
const LevelCreatorScript = preload("res://src/level_creator.gd")

var levels: Array = []
var level_collection := "official"
var local_level_store: LocalLevelStore
var community_level_provider: CommunityLevelProvider
var community_auth_session: CommunityAuthSession
var current_community_feed := "new"

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
var player_publish_actions: HBoxContainer
var player_publish_hint: Label
var player_publish_button: Button
var community_feed_actions: HBoxContainer
var community_feed_buttons: Dictionary = {}
var community_actions: HBoxContainer
var community_auth_hint: Label
var community_report_reason: OptionButton
var community_like_button: Button
var community_unlike_button: Button
var community_report_button: Button
var grid: GridContainer
var escape_layer: Control
var overlay: ColorRect
var overlay_title: Label
var overlay_copy: Label
var overlay_button: Button
var creator: LevelCreator


func _ready() -> void:
	local_level_store = LocalLevelStoreScript.new()
	community_auth_session = CommunityAuthSessionScript.new()
	community_auth_session.configure_from_environment()

	var community_api_url := str(ProjectSettings.get_setting("errow/community_api_base_url", ""))
	community_level_provider = CommunityLevelProviderScript.new(community_api_url)
	community_level_provider.name = "CommunityLevelProvider"
	community_auth_session.auth_token_changed.connect(_on_community_auth_token_changed)
	community_level_provider.set_auth_token(community_auth_session.bearer_token())
	community_level_provider.feed_loaded.connect(_on_community_feed_loaded)
	community_level_provider.published.connect(_on_community_published)
	community_level_provider.engagement_updated.connect(_on_community_engagement_updated)
	community_level_provider.report_submitted.connect(_on_community_report_submitted)
	community_level_provider.request_failed.connect(_on_community_request_failed)
	add_child(community_level_provider)

	levels = LevelCatalogScript.official_levels()
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
	margin.add_theme_constant_override("margin_top", 48)
	margin.add_theme_constant_override("margin_bottom", 40)
	add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 18)
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
	level_label.add_theme_font_size_override("font_size", 36)
	level_label.add_theme_color_override("font_color", Color("#dff9ee"))
	stack.add_child(level_label)

	subtitle_label = Label.new()
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle_label.add_theme_font_size_override("font_size", 19)
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
	status_label.custom_minimum_size = Vector2(0, 48)
	status_label.add_theme_font_size_override("font_size", 19)
	status_label.add_theme_color_override("font_color", Color("#8d98ab"))
	stack.add_child(status_label)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 16)
	stack.add_child(actions)

	var restart := Button.new()
	restart.text = "Restart level"
	restart.custom_minimum_size = Vector2(250, 60)
	restart.focus_mode = Control.FOCUS_NONE
	restart.add_theme_font_size_override("font_size", 19)
	restart.pressed.connect(_restart_level)
	_apply_action_style(restart)
	actions.add_child(restart)

	var skip := Button.new()
	skip.text = "Next level"
	skip.custom_minimum_size = Vector2(250, 60)
	skip.focus_mode = Control.FOCUS_NONE
	skip.add_theme_font_size_override("font_size", 19)
	skip.pressed.connect(_next_level)
	_apply_action_style(skip)
	actions.add_child(skip)

	var library_actions := HBoxContainer.new()
	library_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	library_actions.add_theme_constant_override("separation", 12)
	stack.add_child(library_actions)

	var original := Button.new()
	original.text = "Original"
	original.custom_minimum_size = Vector2(150, 56)
	original.focus_mode = Control.FOCUS_NONE
	original.add_theme_font_size_override("font_size", 18)
	original.pressed.connect(_show_official_levels)
	_apply_action_style(original)
	library_actions.add_child(original)

	var player_levels := Button.new()
	player_levels.text = "My levels"
	player_levels.custom_minimum_size = Vector2(150, 56)
	player_levels.focus_mode = Control.FOCUS_NONE
	player_levels.add_theme_font_size_override("font_size", 18)
	player_levels.pressed.connect(_show_player_levels)
	_apply_action_style(player_levels)
	library_actions.add_child(player_levels)

	var community := Button.new()
	community.text = "Community"
	community.custom_minimum_size = Vector2(150, 56)
	community.focus_mode = Control.FOCUS_NONE
	community.add_theme_font_size_override("font_size", 18)
	community.pressed.connect(_show_community_levels)
	_apply_action_style(community)
	library_actions.add_child(community)

	var create_level := Button.new()
	create_level.text = "Create"
	create_level.custom_minimum_size = Vector2(150, 56)
	create_level.focus_mode = Control.FOCUS_NONE
	create_level.add_theme_font_size_override("font_size", 18)
	create_level.pressed.connect(_open_creator)
	_apply_action_style(create_level)
	library_actions.add_child(create_level)

	community_feed_actions = HBoxContainer.new()
	community_feed_actions.name = "CommunityFeedActions"
	community_feed_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	community_feed_actions.add_theme_constant_override("separation", 10)
	community_feed_actions.visible = false
	stack.add_child(community_feed_actions)

	for feed_name in CommunityLevelProviderScript.ALLOWED_FEEDS:
		var feed_button := Button.new()
		feed_button.text = str(feed_name).capitalize()
		feed_button.custom_minimum_size = Vector2(120, 48)
		feed_button.focus_mode = Control.FOCUS_NONE
		feed_button.add_theme_font_size_override("font_size", 16)
		feed_button.pressed.connect(_show_community_feed.bind(str(feed_name)))
		_apply_action_style(feed_button)
		community_feed_actions.add_child(feed_button)
		community_feed_buttons[str(feed_name)] = feed_button

	player_publish_hint = Label.new()
	player_publish_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	player_publish_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	player_publish_hint.add_theme_font_size_override("font_size", 16)
	player_publish_hint.add_theme_color_override("font_color", Color("#7f8a9d"))
	player_publish_hint.visible = false
	stack.add_child(player_publish_hint)

	player_publish_actions = HBoxContainer.new()
	player_publish_actions.name = "PlayerPublishActions"
	player_publish_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	player_publish_actions.visible = false
	stack.add_child(player_publish_actions)

	player_publish_button = Button.new()
	player_publish_button.text = "Publish to Community"
	player_publish_button.custom_minimum_size = Vector2(260, 52)
	player_publish_button.focus_mode = Control.FOCUS_NONE
	player_publish_button.pressed.connect(_publish_current_player_level)
	_apply_action_style(player_publish_button)
	player_publish_actions.add_child(player_publish_button)

	community_auth_hint = Label.new()
	community_auth_hint.text = "Authenticated Community actions are unavailable in anonymous mode."
	community_auth_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	community_auth_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	community_auth_hint.add_theme_font_size_override("font_size", 16)
	community_auth_hint.add_theme_color_override("font_color", Color("#7f8a9d"))
	community_auth_hint.visible = false
	stack.add_child(community_auth_hint)

	community_actions = HBoxContainer.new()
	community_actions.name = "CommunityActions"
	community_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	community_actions.add_theme_constant_override("separation", 10)
	community_actions.visible = false
	stack.add_child(community_actions)

	community_like_button = Button.new()
	community_like_button.text = "Like"
	community_like_button.custom_minimum_size = Vector2(120, 52)
	community_like_button.focus_mode = Control.FOCUS_NONE
	community_like_button.pressed.connect(_set_current_community_like.bind(true))
	_apply_action_style(community_like_button)
	community_actions.add_child(community_like_button)

	community_unlike_button = Button.new()
	community_unlike_button.text = "Unlike"
	community_unlike_button.custom_minimum_size = Vector2(120, 52)
	community_unlike_button.focus_mode = Control.FOCUS_NONE
	community_unlike_button.pressed.connect(_set_current_community_like.bind(false))
	_apply_action_style(community_unlike_button)
	community_actions.add_child(community_unlike_button)

	community_report_reason = OptionButton.new()
	community_report_reason.custom_minimum_size = Vector2(170, 52)
	for reason in CommunityLevelProviderScript.ALLOWED_REPORT_REASONS:
		var reason_index := community_report_reason.item_count
		community_report_reason.add_item(str(reason).capitalize())
		community_report_reason.set_item_metadata(reason_index, str(reason))
	community_actions.add_child(community_report_reason)

	community_report_button = Button.new()
	community_report_button.text = "Report"
	community_report_button.custom_minimum_size = Vector2(130, 52)
	community_report_button.focus_mode = Control.FOCUS_NONE
	community_report_button.pressed.connect(_report_current_community)
	_apply_action_style(community_report_button)
	community_actions.add_child(community_report_button)

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

	creator = LevelCreatorScript.new()
	creator.connect("playtest_requested", Callable(self, "_on_creator_playtest_requested"))
	add_child(creator)


func _set_level_collection(new_levels: Array, collection: String) -> void:
	if new_levels.is_empty():
		return

	levels = new_levels.duplicate(true)
	level_collection = collection
	_set_community_feed_controls_visible(level_collection == "community")
	_load_level(0)


func _show_official_levels() -> void:
	_set_level_collection(LevelCatalogScript.official_levels(), "official")


func _show_player_levels() -> void:
	var saved_levels: Array = local_level_store.list_levels()
	var playable_levels: Array = []
	for level in saved_levels:
		if LevelRulesScript.is_solvable(level):
			playable_levels.append(level)

	if playable_levels.is_empty():
		overlay.visible = false
		status_label.text = "No playable player levels yet. Create and playtest one first."
		return

	_set_level_collection(playable_levels, "player")


func _show_community_levels() -> void:
	_show_community_feed("new")


func _show_community_feed(feed: String) -> void:
	var normalized_feed := feed.strip_edges().to_lower()
	if not CommunityLevelProviderScript.ALLOWED_FEEDS.has(normalized_feed):
		status_label.text = "Unsupported Community feed."
		return

	overlay.visible = false
	current_community_feed = normalized_feed
	_set_community_feed_controls_visible(true)
	status_label.text = "Loading Community · %s..." % normalized_feed.capitalize()
	community_level_provider.fetch_feed(normalized_feed)


func _set_community_feed_controls_visible(visible: bool) -> void:
	if community_feed_actions == null:
		return

	community_feed_actions.visible = visible
	for feed_name_variant in community_feed_buttons:
		var feed_name := str(feed_name_variant)
		var feed_button := community_feed_buttons.get(feed_name) as Button
		if feed_button != null:
			feed_button.disabled = visible and feed_name == current_community_feed


func _on_community_feed_loaded(entries: Array) -> void:
	var community_levels: Array = []
	for entry_variant in entries:
		if typeof(entry_variant) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = entry_variant
		var level_variant = entry.get("level", {})
		if typeof(level_variant) != TYPE_DICTIONARY:
			continue
		var runtime_level: Dictionary = level_variant.duplicate(true)
		runtime_level["_community_public_id"] = str(entry.get("public_id", ""))
		runtime_level["_community_revision"] = int(entry.get("revision", 0))
		community_levels.append(runtime_level)

	if community_levels.is_empty():
		status_label.text = "Community feed is online, but no playable levels were returned."
		return

	_set_level_collection(community_levels, "community")
	status_label.text = "Community · %s feed loaded." % current_community_feed.capitalize()


func _on_community_request_failed(message: String) -> void:
	overlay.visible = false
	_set_player_publish_enabled(true)
	_set_community_actions_enabled(true)
	status_label.text = message


func _on_community_auth_token_changed(token: String) -> void:
	if community_level_provider != null:
		community_level_provider.set_auth_token(token)
	_refresh_player_publish_actions()
	_refresh_community_actions()


func _current_player_level() -> Dictionary:
	if level_collection != "player" or levels.is_empty():
		return {}
	return levels[level_index]


func _publish_current_player_level() -> void:
	if community_level_provider == null or not community_level_provider.is_configured():
		status_label.text = "Community service is not configured yet."
		return
	if community_auth_session == null or not community_auth_session.is_authenticated():
		status_label.text = "Authentication is required to publish Player levels."
		return

	var level := _current_player_level()
	if level.is_empty():
		return

	_set_player_publish_enabled(false)
	status_label.text = "Publishing Player level to Community..."
	if not community_level_provider.publish_level(level):
		_set_player_publish_enabled(true)


func _on_community_published(entry: Dictionary) -> void:
	_set_player_publish_enabled(true)
	var public_id := str(entry.get("public_id", "")).strip_edges()
	var revision := int(entry.get("revision", 0))
	if public_id.is_empty() or revision < 1:
		status_label.text = "Community publication succeeded."
		return
	status_label.text = "Published to Community · %s · revision %d." % [public_id, revision]


func _set_player_publish_enabled(enabled: bool) -> void:
	if player_publish_button != null:
		player_publish_button.disabled = not enabled


func _refresh_player_publish_actions() -> void:
	if player_publish_actions == null or player_publish_hint == null:
		return

	var is_player := level_collection == "player"
	var configured := community_level_provider != null and community_level_provider.is_configured()
	var authenticated := community_auth_session != null and community_auth_session.is_authenticated()

	player_publish_actions.visible = is_player and configured and authenticated
	player_publish_hint.visible = is_player and (not configured or not authenticated)

	if player_publish_hint.visible:
		if not configured:
			player_publish_hint.text = "Community publishing is unavailable until the service is configured."
		else:
			player_publish_hint.text = "Authentication is required to publish Player levels."

	_set_player_publish_enabled(true)


func _current_community_public_id() -> String:
	if level_collection != "community" or levels.is_empty():
		return ""
	var current_level: Dictionary = levels[level_index]
	return str(current_level.get("_community_public_id", "")).strip_edges()


func _set_current_community_like(liked: bool) -> void:
	if community_auth_session == null or not community_auth_session.is_authenticated():
		status_label.text = "Authentication is required for Community likes."
		return
	var public_id := _current_community_public_id()
	if public_id.is_empty():
		return
	_set_community_actions_enabled(false)
	status_label.text = "Updating Community like..."
	if not community_level_provider.set_like(public_id, liked):
		_set_community_actions_enabled(true)


func _report_current_community() -> void:
	if community_auth_session == null or not community_auth_session.is_authenticated():
		status_label.text = "Authentication is required to report Community levels."
		return
	var public_id := _current_community_public_id()
	if public_id.is_empty() or community_report_reason == null:
		return
	var selected_index := community_report_reason.selected
	var reason := str(community_report_reason.get_item_metadata(selected_index))
	_set_community_actions_enabled(false)
	status_label.text = "Submitting Community report..."
	if not community_level_provider.report_level(public_id, reason):
		_set_community_actions_enabled(true)


func _on_community_engagement_updated(operation: String, public_id: String, stats: Dictionary) -> void:
	if operation != "like":
		return
	_set_community_actions_enabled(true)
	if public_id != _current_community_public_id():
		return
	var liked := bool(stats.get("liked", false))
	var likes := maxi(0, int(stats.get("likes", 0)))
	status_label.text = "Community like %s · %d likes." % ["saved" if liked else "cleared", likes]


func _on_community_report_submitted(public_id: String) -> void:
	_set_community_actions_enabled(true)
	if public_id == _current_community_public_id():
		status_label.text = "Report submitted for moderator review."


func _set_community_actions_enabled(enabled: bool) -> void:
	if community_like_button != null:
		community_like_button.disabled = not enabled
	if community_unlike_button != null:
		community_unlike_button.disabled = not enabled
	if community_report_reason != null:
		community_report_reason.disabled = not enabled
	if community_report_button != null:
		community_report_button.disabled = not enabled


func _refresh_community_actions() -> void:
	if community_actions == null or community_auth_hint == null:
		return
	var is_community := level_collection == "community"
	var authenticated := community_auth_session != null and community_auth_session.is_authenticated()
	community_actions.visible = is_community and authenticated
	community_auth_hint.visible = is_community and not authenticated
	_set_community_actions_enabled(true)


func _open_creator() -> void:
	overlay.visible = false
	creator.call("open_creator")


func _on_creator_playtest_requested(level: Dictionary) -> void:
	_set_level_collection([level], "player")


func _load_level(index: int) -> void:
	if levels.is_empty():
		return

	_cancel_escape_animation()
	level_index = clampi(index, 0, levels.size() - 1)
	moves = 0
	active_arrows.clear()
	arrow_buttons.clear()
	overlay.visible = false

	var level: Dictionary = levels[level_index]
	for item in level["arrows"]:
		var cell := Vector2i(int(item[0]), int(item[1]))
		active_arrows[cell] = str(item[2])

	var collection_label := "Level"
	match level_collection:
		"official":
			collection_label = "Original"
		"player":
			collection_label = "Player"
		"community":
			collection_label = "Community · %s" % current_community_feed.capitalize()

	level_label.text = "%s %d · %s" % [
		collection_label,
		level_index + 1,
		str(level.get("name", "Untitled level")),
	]
	subtitle_label.text = str(level.get("subtitle", ""))
	status_label.text = "Find a clear path."
	_rebuild_board()
	_update_stats()
	_refresh_player_publish_actions()
	_refresh_community_actions()


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
	var start_position := button.global_position
	var target_position := _escape_target_position(button, direction_code)

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


func _escape_target_position(button: Control, direction_code: String) -> Vector2:
	var direction := Vector2(LevelRulesScript.DIRECTIONS[direction_code])
	return button.global_position + direction * _escape_distance(button)


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
	return LevelRulesScript.can_exit(active_arrows, cell, direction_code, GRID_SIZE)


func _show_complete() -> void:
	overlay.visible = true

	if level_collection == "community":
		_record_community_completion()
		if levels.size() == 1:
			overlay_title.text = "Community level cleared"
			overlay_copy.text = "Solved in %d successful moves." % moves
			overlay_button.text = "Replay level"
		elif level_index == levels.size() - 1:
			overlay_title.text = "Community set cleared"
			overlay_copy.text = "You cleared every level in the %s feed." % current_community_feed.capitalize()
			overlay_button.text = "Replay Community"
		else:
			overlay_title.text = "Community level cleared"
			overlay_copy.text = "Solved in %d successful moves. Ready for the next Community level?" % moves
			overlay_button.text = "Next Community level"
		return

	if level_collection == "player":
		if levels.size() == 1:
			overlay_title.text = "Player level cleared"
			overlay_copy.text = "Solved in %d successful moves. Your level uses the same runtime as the originals." % moves
			overlay_button.text = "Replay level"
		elif level_index == levels.size() - 1:
			overlay_title.text = "Player set cleared"
			overlay_copy.text = "You cleared all saved player levels."
			overlay_button.text = "Replay player levels"
		else:
			overlay_title.text = "Player level cleared"
			overlay_copy.text = "Solved in %d successful moves. Ready for the next player level?" % moves
			overlay_button.text = "Next player level"
		return

	if level_index == levels.size() - 1:
		overlay_title.text = "Starter set cleared"
		overlay_copy.text = "You cleared all three original levels in %d successful moves." % moves
		overlay_button.text = "Replay from level 1"
	else:
		overlay_title.text = "Level cleared"
		overlay_copy.text = "Solved in %d successful moves. Ready for the next board?" % moves
		overlay_button.text = "Next level"


func _record_community_completion() -> void:
	if community_level_provider == null or levels.is_empty():
		return
	var current_level: Dictionary = levels[level_index]
	var public_id := str(current_level.get("_community_public_id", "")).strip_edges()
	if public_id.is_empty():
		return
	community_level_provider.record_play(public_id)


func _restart_level() -> void:
	_load_level(level_index)


func _next_level() -> void:
	if levels.is_empty():
		return

	if level_index >= levels.size() - 1:
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
