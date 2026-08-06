extends Control

const MemoryCardScript = preload("res://scripts/MemoryCard.gd")
const CardImageManagerScript = preload("res://scripts/CardImageManager.gd")
const HighscoreManagerScript = preload("res://scripts/HighscoreManager.gd")

const DIFFICULTIES := {
	"Easy": {
		"pairs": 6,
		"columns": 4,
		"card_size": Vector2(150, 190),
		"base_score": 1600,
		"match_points": 220,
		"mismatch_penalty": 55,
		"time_penalty": 2
	},
	"Medium": {
		"pairs": 10,
		"columns": 5,
		"card_size": Vector2(122, 158),
		"base_score": 3200,
		"match_points": 250,
		"mismatch_penalty": 75,
		"time_penalty": 3
	},
	"Hard": {
		"pairs": 15,
		"columns": 6,
		"card_size": Vector2(100, 132),
		"base_score": 5200,
		"match_points": 280,
		"mismatch_penalty": 90,
		"time_penalty": 4
	}
}

var image_manager
var highscore_manager
var card_textures: Array[Texture2D] = []

var current_difficulty := "Easy"
var first_card = null
var second_card = null
var lock_input := false
var game_running := false
var elapsed_time := 0.0
var moves := 0
var mismatches := 0
var matches_found := 0
var game_round_id := 0

var difficulty_option: OptionButton
var board_grid: GridContainer
var board_center: CenterContainer
var time_value: Label
var moves_value: Label
var matches_value: Label
var score_value: Label
var best_value: Label
var status_label: Label
var highscore_labels: Dictionary = {}
var victory_overlay: ColorRect
var victory_title: Label
var victory_summary: Label
var victory_record: Label

func _ready() -> void:
	image_manager = CardImageManagerScript.new()
	highscore_manager = HighscoreManagerScript.new()
	get_window().mode = Window.MODE_MAXIMIZED
	_build_interface()
	card_textures = image_manager.load_card_textures()
	_refresh_highscore_strip()
	start_new_game()

func _process(delta: float) -> void:
	if not game_running:
		return
	elapsed_time += delta
	_update_stats()

func _build_interface() -> void:
	_build_background()

	var page_margin := MarginContainer.new()
	page_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page_margin.add_theme_constant_override("margin_left", 26)
	page_margin.add_theme_constant_override("margin_top", 22)
	page_margin.add_theme_constant_override("margin_right", 26)
	page_margin.add_theme_constant_override("margin_bottom", 22)
	add_child(page_margin)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	page_margin.add_child(page)

	page.add_child(_build_header())
	page.add_child(_build_highscore_strip())
	page.add_child(_build_stats_bar())
	page.add_child(_build_board_panel())
	page.add_child(_build_footer())

	_build_victory_overlay()

func _build_background() -> void:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.52, 1.0])
	gradient.colors = PackedColorArray([
		Color.from_string("#f8fafc", Color.WHITE),
		Color.from_string("#eef2ff", Color.WHITE),
		Color.from_string("#ecfdf5", Color.WHITE)
	])
	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.width = 1600
	gradient_texture.height = 1000
	gradient_texture.fill_from = Vector2(0.0, 0.0)
	gradient_texture.fill_to = Vector2(1.0, 1.0)

	var background := TextureRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.texture = gradient_texture
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

func _build_header() -> Control:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style("#ffffff", "#dbe4ef", 20, 0.97))

	var margin := MarginContainer.new()
	_set_margins(margin, 18, 14, 18, 14)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	margin.add_child(row)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", 1)
	row.add_child(title_box)

	var title := Label.new()
	title.text = "MEMORY MATCH"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color.from_string("#24364b", Color.WHITE))
	title_box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Find every matching pair and beat your best score."
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", Color.from_string("#64748b", Color.WHITE))
	title_box.add_child(subtitle)

	var control_row := HBoxContainer.new()
	control_row.alignment = BoxContainer.ALIGNMENT_END
	control_row.add_theme_constant_override("separation", 9)
	row.add_child(control_row)

	difficulty_option = OptionButton.new()
	difficulty_option.custom_minimum_size = Vector2(142, 44)
	for difficulty in ["Easy", "Medium", "Hard"]:
		difficulty_option.add_item(difficulty)
	_apply_button_theme(difficulty_option, false)
	difficulty_option.item_selected.connect(_on_difficulty_selected)
	control_row.add_child(difficulty_option)

	var new_game_button := _make_button("New Game", true)
	new_game_button.pressed.connect(start_new_game)
	control_row.add_child(new_game_button)

	var reload_button := _make_button("Reload Images", false)
	reload_button.pressed.connect(_on_reload_images)
	control_row.add_child(reload_button)

	var folder_button := _make_button("Open Card Folder", false)
	folder_button.pressed.connect(_on_open_card_folder)
	control_row.add_child(folder_button)

	return panel

func _build_highscore_strip() -> Control:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style("#ffffff", "#dbe4ef", 16, 0.97))

	var margin := MarginContainer.new()
	_set_margins(margin, 14, 10, 14, 10)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	margin.add_child(row)

	var heading := Label.new()
	heading.text = "BEST SCORES"
	heading.add_theme_font_size_override("font_size", 13)
	heading.add_theme_color_override("font_color", Color.from_string("#2563eb", Color.WHITE))
	row.add_child(heading)

	for difficulty in ["Easy", "Medium", "Hard"]:
		var value := Label.new()
		value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		value.add_theme_font_size_override("font_size", 14)
		value.add_theme_color_override("font_color", Color.from_string("#334155", Color.WHITE))
		highscore_labels[difficulty] = value
		row.add_child(value)

	return panel

func _build_stats_bar() -> Control:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style("#ffffff", "#dbe4ef", 16, 0.97))

	var margin := MarginContainer.new()
	_set_margins(margin, 14, 10, 14, 10)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	margin.add_child(row)

	time_value = _add_stat(row, "TIME", "00:00", "#2563eb")
	moves_value = _add_stat(row, "MOVES", "0", "#7c3aed")
	matches_value = _add_stat(row, "PAIRS", "0 / 0", "#16a34a")
	score_value = _add_stat(row, "SCORE", "0", "#d97706")
	best_value = _add_stat(row, "CURRENT BEST", "0", "#be185d")

	return panel

func _build_board_panel() -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style("#f8fafc", "#cbd5e1", 22, 0.98))

	var margin := MarginContainer.new()
	_set_margins(margin, 14, 14, 14, 14)
	panel.add_child(margin)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	margin.add_child(scroll)

	board_center = CenterContainer.new()
	board_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(board_center)

	board_grid = GridContainer.new()
	board_grid.add_theme_constant_override("h_separation", 12)
	board_grid.add_theme_constant_override("v_separation", 12)
	board_center.add_child(board_grid)

	return panel

func _build_footer() -> Control:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style("#ffffff", "#dbe4ef", 14, 0.97))

	var margin := MarginContainer.new()
	_set_margins(margin, 14, 8, 14, 8)
	panel.add_child(margin)

	status_label = Label.new()
	status_label.text = "Choose a card to begin."
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.add_theme_color_override("font_color", Color.from_string("#475569", Color.WHITE))
	margin.add_child(status_label)
	return panel

func _build_victory_overlay() -> void:
	victory_overlay = ColorRect.new()
	victory_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	victory_overlay.color = Color(0.12, 0.18, 0.28, 0.55)
	victory_overlay.z_index = 100
	victory_overlay.visible = false
	add_child(victory_overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	victory_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(470, 330)
	panel.add_theme_stylebox_override("panel", _panel_style("#ffffff", "#3b82f6", 26, 0.99))
	center.add_child(panel)

	var margin := MarginContainer.new()
	_set_margins(margin, 32, 26, 32, 26)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)

	victory_title = Label.new()
	victory_title.text = "YOU WIN!"
	victory_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	victory_title.add_theme_font_size_override("font_size", 34)
	victory_title.add_theme_color_override("font_color", Color.from_string("#1e3a5f", Color.WHITE))
	box.add_child(victory_title)

	victory_summary = Label.new()
	victory_summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	victory_summary.add_theme_font_size_override("font_size", 18)
	victory_summary.add_theme_color_override("font_color", Color.from_string("#334155", Color.WHITE))
	box.add_child(victory_summary)

	victory_record = Label.new()
	victory_record.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	victory_record.add_theme_font_size_override("font_size", 16)
	victory_record.add_theme_color_override("font_color", Color.from_string("#15803d", Color.WHITE))
	box.add_child(victory_record)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 12)
	box.add_child(button_row)

	var again_button := _make_button("Play Again", true)
	again_button.pressed.connect(start_new_game)
	button_row.add_child(again_button)

	var close_button := _make_button("View Board", false)
	close_button.pressed.connect(_hide_victory_overlay)
	button_row.add_child(close_button)

func start_new_game() -> void:
	game_round_id += 1
	victory_overlay.visible = false
	_clear_board()

	current_difficulty = difficulty_option.get_item_text(difficulty_option.selected)
	var settings: Dictionary = DIFFICULTIES[current_difficulty]
	var pair_count := int(settings["pairs"])

	if card_textures.size() < pair_count:
		game_running = false
		status_label.text = "Not enough images. Add at least %d PNG/JPG files to the card folder." % pair_count
		return

	var available_indices: Array[int] = []
	for index in range(card_textures.size()):
		available_indices.append(index)
	available_indices.shuffle()

	var deck: Array = []
	for pair_index in range(pair_count):
		var texture := card_textures[available_indices[pair_index]]
		deck.append({"pair_id": pair_index, "texture": texture})
		deck.append({"pair_id": pair_index, "texture": texture})
	deck.shuffle()

	board_grid.columns = int(settings["columns"])
	var desired_size: Vector2 = settings["card_size"]
	for entry in deck:
		var card = MemoryCardScript.new()
		board_grid.add_child(card)
		card.setup(int(entry["pair_id"]), entry["texture"], desired_size)
		card.card_selected.connect(_on_card_selected)

	var total_cards := pair_count * 2
	var columns := int(settings["columns"])
	var rows := int(ceil(float(total_cards) / float(columns)))
	var board_width: float = float(columns) * desired_size.x + float(maxi(0, columns - 1) * 12)
	var board_height: float = float(rows) * desired_size.y + float(maxi(0, rows - 1) * 12)
	board_center.custom_minimum_size = Vector2(
		maxf(610.0, board_width + 30.0),
		maxf(410.0, board_height + 30.0)
	)

	first_card = null
	second_card = null
	lock_input = false
	elapsed_time = 0.0
	moves = 0
	mismatches = 0
	matches_found = 0
	game_running = true
	status_label.text = "%s mode: find all %d matching pairs." % [current_difficulty, pair_count]
	_update_stats()

func _on_card_selected(card) -> void:
	if lock_input or not game_running or card == first_card:
		return

	card.reveal()
	if first_card == null:
		first_card = card
		status_label.text = "Now choose a second card."
		return

	second_card = card
	moves += 1
	lock_input = true
	var card_a = first_card
	var card_b = second_card
	var active_round := game_round_id
	_update_stats()

	if card_a.pair_id == card_b.pair_id:
		status_label.text = "Great match!"
		await get_tree().create_timer(0.38).timeout
		if active_round != game_round_id:
			return
		card_a.mark_matched()
		card_b.mark_matched()
		matches_found += 1
		first_card = null
		second_card = null
		lock_input = false
		_update_stats()
		if matches_found >= int(DIFFICULTIES[current_difficulty]["pairs"]):
			_finish_game()
	else:
		mismatches += 1
		status_label.text = "Not a match. Keep going!"
		await get_tree().create_timer(0.72).timeout
		if active_round != game_round_id:
			return
		card_a.conceal()
		card_b.conceal()
		first_card = null
		second_card = null
		lock_input = false
		_update_stats()

func _finish_game() -> void:
	game_running = false
	lock_input = true
	var final_score := _calculate_score()
	var result: Dictionary = highscore_manager.submit_result(current_difficulty, final_score, elapsed_time)
	_refresh_highscore_strip()
	_update_stats()

	victory_summary.text = "%s Mode\nTime: %s   Moves: %d\nFinal Score: %s" % [
		current_difficulty,
		_format_time(elapsed_time),
		moves,
		_format_number(final_score)
	]

	var record_messages: Array[String] = []
	if bool(result["new_high_score"]):
		record_messages.append("New high score!")
	if bool(result["new_best_time"]):
		record_messages.append("New best time!")
	if record_messages.is_empty():
		record_messages.append("Excellent memory work!")
	victory_record.text = "  ".join(record_messages)
	victory_overlay.visible = true
	status_label.text = "Board completed. Congratulations!"

func _update_stats() -> void:
	if time_value == null:
		return
	var pair_count := int(DIFFICULTIES[current_difficulty]["pairs"])
	time_value.text = _format_time(elapsed_time)
	moves_value.text = str(moves)
	matches_value.text = "%d / %d" % [matches_found, pair_count]
	score_value.text = _format_number(_calculate_score())
	var record: Dictionary = highscore_manager.get_record(current_difficulty)
	best_value.text = _format_number(int(record["score"]))

func _calculate_score() -> int:
	var settings: Dictionary = DIFFICULTIES[current_difficulty]
	var score := int(settings["base_score"])
	score += matches_found * int(settings["match_points"])
	score -= mismatches * int(settings["mismatch_penalty"])
	score -= int(floor(elapsed_time)) * int(settings["time_penalty"])
	return maxi(0, score)

func _refresh_highscore_strip() -> void:
	for difficulty in ["Easy", "Medium", "Hard"]:
		var record: Dictionary = highscore_manager.get_record(difficulty)
		var best_time := "--:--"
		if float(record["time"]) > 0.0:
			best_time = _format_time(float(record["time"]))
		highscore_labels[difficulty].text = "%s  %s  (%s)" % [
			difficulty,
			_format_number(int(record["score"])),
			best_time
		]

func _on_difficulty_selected(index: int) -> void:
	current_difficulty = difficulty_option.get_item_text(index)
	start_new_game()

func _on_reload_images() -> void:
	card_textures = image_manager.load_card_textures()
	status_label.text = "Loaded %d card images from the custom card folder." % card_textures.size()
	start_new_game()

func _on_open_card_folder() -> void:
	image_manager.open_card_folder()
	status_label.text = "Card folder: %s" % image_manager.get_card_folder_path()

func _hide_victory_overlay() -> void:
	victory_overlay.visible = false

func _clear_board() -> void:
	for child in board_grid.get_children():
		board_grid.remove_child(child)
		child.queue_free()

func _add_stat(parent: HBoxContainer, heading_text: String, initial_value: String, accent_hex: String) -> Label:
	var stat_panel := PanelContainer.new()
	stat_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stat_panel.add_theme_stylebox_override("panel", _panel_style("#f8fafc", "#dbe4ef", 12, 0.99))
	parent.add_child(stat_panel)

	var margin := MarginContainer.new()
	_set_margins(margin, 10, 7, 10, 7)
	stat_panel.add_child(margin)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(box)

	var heading := Label.new()
	heading.text = heading_text
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 10)
	heading.add_theme_color_override("font_color", Color.from_string("#64748b", Color.WHITE))
	box.add_child(heading)

	var value := Label.new()
	value.text = initial_value
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value.add_theme_font_size_override("font_size", 17)
	value.add_theme_color_override("font_color", Color.from_string(accent_hex, Color.WHITE))
	box.add_child(value)
	return value

func _make_button(text: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(116, 44)
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_apply_button_theme(button, primary)
	return button

func _apply_button_theme(button: BaseButton, primary: bool) -> void:
	var normal_color := "#2563eb" if primary else "#ffffff"
	var hover_color := "#1d4ed8" if primary else "#eff6ff"
	var pressed_color := "#1e40af" if primary else "#dbeafe"
	var border_color := "#1d4ed8" if primary else "#cbd5e1"
	button.add_theme_stylebox_override("normal", _button_style(normal_color, border_color))
	button.add_theme_stylebox_override("hover", _button_style(hover_color, "#3b82f6"))
	button.add_theme_stylebox_override("pressed", _button_style(pressed_color, border_color))
	button.add_theme_stylebox_override("focus", _button_style(hover_color, "#60a5fa"))
	button.add_theme_stylebox_override("disabled", _button_style("#e2e8f0", "#cbd5e1"))
	var text_color := "#ffffff" if primary else "#334155"
	button.add_theme_color_override("font_color", Color.from_string(text_color, Color.WHITE))
	button.add_theme_color_override("font_hover_color", Color.from_string(text_color, Color.WHITE))
	button.add_theme_color_override("font_pressed_color", Color.from_string(text_color, Color.WHITE))
	button.add_theme_font_size_override("font_size", 13)

func _button_style(background_hex: String, border_hex: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color.from_string(background_hex, Color.DARK_BLUE)
	style.border_color = Color.from_string(border_hex, Color.WHITE)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 9
	style.content_margin_bottom = 9
	return style

func _panel_style(background_hex: String, border_hex: String, radius: int, alpha: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var background := Color.from_string(background_hex, Color.DARK_BLUE)
	background.a = alpha
	style.bg_color = background
	style.border_color = Color.from_string(border_hex, Color.WHITE)
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.15, 0.23, 0.34, 0.14)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 5)
	return style

func _set_margins(container: MarginContainer, left: int, top: int, right: int, bottom: int) -> void:
	container.add_theme_constant_override("margin_left", left)
	container.add_theme_constant_override("margin_top", top)
	container.add_theme_constant_override("margin_right", right)
	container.add_theme_constant_override("margin_bottom", bottom)

func _format_time(seconds_value: float) -> String:
	var total_seconds: int = maxi(0, int(floor(seconds_value)))
	var minutes := int(total_seconds / 60)
	var seconds := total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]

func _format_number(value: int) -> String:
	var raw: String = str(maxi(0, value))
	var formatted := ""
	var count := 0
	for index in range(raw.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			formatted = "," + formatted
		formatted = raw[index] + formatted
		count += 1
	return formatted
