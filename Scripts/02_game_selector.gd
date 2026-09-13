extends Control

const GAME_DATA: Array[Dictionary] = [
	{
		"number": "01",
		"title": "FRUIT CATCH",
		"description": "Move fast, catch the fruit and keep your perfect run alive.",
		"tags": ["ARCADE", "REFLEX"],
		"accent": Color("ff9f43"),
		"glow": Color("ff6b35"),
		"image": "res://assets/ui/game_cards/fruit_catch_card.png",
		"scene": "res://minigames/fruit-catch/fruitcatch_game.tscn",
	},
	{
		"number": "02",
		"title": "MEMORY CARDS",
		"description": "Find every pair, build combos and protect your focus meter.",
		"tags": ["PUZZLE", "COMBO"],
		"accent": Color("a985ff"),
		"glow": Color("7758ff"),
		"image": "res://assets/ui/game_cards/memory_cards_card.png",
		"scene": "res://minigames/memory/scenes/MemoryGame.tscn",
	},
	{
		"number": "03",
		"title": "SNAKE",
		"description": "Guide the dragon, collect treasures and survive at top speed.",
		"tags": ["CLASSIC", "ENDLESS"],
		"accent": Color("54e68b"),
		"glow": Color("18b86a"),
		"image": "res://assets/ui/game_cards/snake_card.png",
		"scene": "res://minigames/snake/snake_game.tscn",
	},
	{
		"number": "04",
		"title": "FLAPPY BIRD",
		"description": "Thread the gaps, master the rhythm and chase a new record.",
		"tags": ["FLY", "HIGH SCORE"],
		"accent": Color("55c8ff"),
		"glow": Color("277cff"),
		"image": "res://assets/ui/game_cards/flappy_bird_card.png",
		"scene": "res://minigames/flappy-bird/scenes/main.tscn",
	},
]

@onready var backdrop: TextureRect = $Backdrop
@onready var ui_root: MarginContainer = $UI
@onready var transition_overlay: ColorRect = $TransitionOverlay

var card_buttons: Array[Button] = []
var selection_hint: Label
var transitioning := false
var backdrop_origin := Vector2.ZERO


func _ready() -> void:
	backdrop_origin = backdrop.position
	_build_interface()
	_configure_focus()
	_play_intro()
	card_buttons[0].grab_focus()


func _process(delta: float) -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var normalized_mouse := get_viewport().get_mouse_position() / viewport_size - Vector2(0.5, 0.5)
	var target := backdrop_origin - normalized_mouse * 10.0
	backdrop.position = backdrop.position.lerp(target, minf(1.0, delta * 2.5))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not transitioning:
		_transition_to("res://Scenes/01_main_menu.tscn")


func _build_interface() -> void:
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 18)
	ui_root.add_child(page)
	page.add_child(_build_header())
	page.add_child(_build_heading())

	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 22)
	grid.add_theme_constant_override("v_separation", 22)
	page.add_child(grid)

	for index in range(GAME_DATA.size()):
		var card := _build_game_card(index, GAME_DATA[index])
		grid.add_child(card)
		card_buttons.append(card)

	page.add_child(_build_footer())


func _build_header() -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = 56.0
	row.add_theme_constant_override("separation", 14)

	var logo := PanelContainer.new()
	logo.custom_minimum_size = Vector2(48, 48)
	logo.add_theme_stylebox_override("panel", _panel_style("#347ff4", "#9ad8ff", 13, 0.96, 11))
	row.add_child(logo)
	var letter := _label("M", 26, Color.WHITE)
	letter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	letter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	logo.add_child(letter)

	var brand := VBoxContainer.new()
	brand.add_theme_constant_override("separation", 0)
	row.add_child(brand)
	brand.add_child(_label("MINIGAME MASTER", 18, Color("f4f9ff")))
	brand.add_child(_label("SELECT YOUR CHALLENGE", 11, Color("7cafe8")))

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	var back := Button.new()
	back.text = "←  BACK"
	back.custom_minimum_size = Vector2(132, 46)
	back.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	back.add_theme_font_size_override("font_size", 14)
	back.add_theme_color_override("font_color", Color("c7dcf4"))
	back.add_theme_color_override("font_hover_color", Color.WHITE)
	back.add_theme_stylebox_override("normal", _button_style("#07162b", "#41698f", 14, 0.82, 0))
	back.add_theme_stylebox_override("hover", _button_style("#102b4c", "#72b9f4", 14, 0.96, 8))
	back.add_theme_stylebox_override("pressed", _button_style("#061122", "#4d83b3", 14, 1.0, 0))
	back.add_theme_stylebox_override("focus", _focus_style(14))
	back.pressed.connect(func() -> void: _transition_to("res://Scenes/01_main_menu.tscn"))
	row.add_child(back)
	return row


func _build_heading() -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = 92.0

	var title_box := VBoxContainer.new()
	title_box.add_theme_constant_override("separation", 1)
	row.add_child(title_box)
	var eyebrow := _label("ARCADE COLLECTION  /  04 GAMES", 12, Color("65bfff"))
	title_box.add_child(eyebrow)
	var title := _label("CHOOSE YOUR GAME", 38, Color.WHITE)
	title.add_theme_color_override("font_shadow_color", Color(0.05, 0.3, 0.8, 0.55))
	title.add_theme_constant_override("shadow_offset_y", 4)
	title_box.add_child(title)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	selection_hint = _label("Select a card to begin", 15, Color("aac6e4"))
	selection_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	selection_hint.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	selection_hint.custom_minimum_size.x = 360.0
	row.add_child(selection_hint)
	return row


func _build_game_card(index: int, data: Dictionary) -> Button:
	var accent: Color = data["accent"]
	var glow: Color = data["glow"]
	var card := Button.new()
	card.custom_minimum_size = Vector2(0, 255)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.add_theme_stylebox_override("normal", _card_style(accent, glow, false))
	card.add_theme_stylebox_override("hover", _card_style(accent, glow, true))
	card.add_theme_stylebox_override("pressed", _button_style("#07162d", accent.to_html(), 24, 0.98, 4))
	card.add_theme_stylebox_override("focus", _focus_style(24))

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_set_margins(margin, 30, 24, 26, 24)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(content)

	var number := _label(str(data["number"]), 12, accent)
	content.add_child(number)
	var title := _label(str(data["title"]), 28, Color("f5f9ff"))
	content.add_child(title)
	var description := _label(str(data["description"]), 14, Color("a9c1dc"))
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(description)

	var tags := HBoxContainer.new()
	tags.add_theme_constant_override("separation", 8)
	tags.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(tags)
	for tag_text in data["tags"]:
		var tag := PanelContainer.new()
		tag.add_theme_stylebox_override("panel", _chip_style(accent))
		tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tags.add_child(tag)
		tag.add_child(_label(str(tag_text), 10, Color("dceaff")))

	row.add_child(_build_card_art(str(data["image"]), accent, glow))

	card.resized.connect(func() -> void: card.pivot_offset = card.size / 2.0)
	card.mouse_entered.connect(func() -> void:
		selection_hint.text = str(data["title"]) + "  ·  Press Enter to play"
		_animate_card(card, Vector2(1.012, 1.012))
	)
	card.mouse_exited.connect(func() -> void:
		selection_hint.text = "Select a card to begin"
		_animate_card(card, Vector2.ONE)
	)
	card.focus_entered.connect(func() -> void:
		selection_hint.text = str(data["title"]) + "  ·  Press Enter to play"
		_animate_card(card, Vector2(1.008, 1.008))
	)
	card.focus_exited.connect(func() -> void: _animate_card(card, Vector2.ONE))
	card.pressed.connect(func() -> void: _transition_to(str(data["scene"])))
	card.set_meta("card_index", index)
	return card


func _build_card_art(image_path: String, accent: Color, glow: Color) -> PanelContainer:
	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(285, 170)
	frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	frame.clip_contents = true
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", _art_frame_style(accent, glow))

	var canvas := Control.new()
	canvas.custom_minimum_size = Vector2(285, 170)
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(canvas)

	var artwork := TextureRect.new()
	artwork.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var image_texture := load(image_path) as Texture2D
	if image_texture:
		artwork.texture = image_texture
	canvas.add_child(artwork)

	var tint := ColorRect.new()
	tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tint.color = Color(accent, 0.055)
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(tint)

	var play_bar := ColorRect.new()
	play_bar.anchor_right = 1.0
	play_bar.anchor_top = 1.0
	play_bar.anchor_bottom = 1.0
	play_bar.offset_top = -40.0
	play_bar.color = Color(0.015, 0.035, 0.085, 0.82)
	play_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(play_bar)

	var play := _label("PLAY  →", 12, Color.WHITE)
	play.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	play.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	play.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	play.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	play.add_theme_constant_override("shadow_offset_y", 2)
	play_bar.add_child(play)
	return frame


func _build_footer() -> Control:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = 28.0
	row.add_child(_label("ENTER  Play      ↑ ↓ ← →  Navigate      ESC  Back", 11, Color("7898b9")))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	row.add_child(_label("PICK A WORLD · SET A RECORD", 11, Color("7898b9")))
	return row


func _configure_focus() -> void:
	if card_buttons.size() != 4:
		return
	card_buttons[0].focus_neighbor_right = card_buttons[1].get_path()
	card_buttons[0].focus_neighbor_bottom = card_buttons[2].get_path()
	card_buttons[1].focus_neighbor_left = card_buttons[0].get_path()
	card_buttons[1].focus_neighbor_bottom = card_buttons[3].get_path()
	card_buttons[2].focus_neighbor_right = card_buttons[3].get_path()
	card_buttons[2].focus_neighbor_top = card_buttons[0].get_path()
	card_buttons[3].focus_neighbor_left = card_buttons[2].get_path()
	card_buttons[3].focus_neighbor_top = card_buttons[1].get_path()


func _play_intro() -> void:
	backdrop.modulate = Color(0.68, 0.76, 0.92, 1)
	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(backdrop, "modulate", Color.WHITE, 0.75)
	for index in range(card_buttons.size()):
		var card := card_buttons[index]
		card.modulate = Color(1, 1, 1, 0)
		card.scale = Vector2(0.97, 0.97)
		var delay := 0.1 + float(index) * 0.07
		tween.tween_property(card, "modulate", Color.WHITE, 0.38).set_delay(delay)
		tween.tween_property(card, "scale", Vector2.ONE, 0.46).set_delay(delay)


func _transition_to(scene_path: String) -> void:
	if transitioning:
		return
	transitioning = true
	for button in card_buttons:
		button.disabled = true
	var tween := create_tween()
	tween.tween_property(transition_overlay, "modulate:a", 1.0, 0.24)
	await tween.finished
	get_tree().change_scene_to_file(scene_path)


func _animate_card(card: Button, target_scale: Vector2) -> void:
	var tween := card.create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "scale", target_scale, 0.12)


func _label(text_value: String, font_size: int, color: Color) -> Label:
	var result := Label.new()
	result.text = text_value
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return result


func _card_style(accent: Color, glow: Color, hovered: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.065, 0.14, 0.94 if hovered else 0.87)
	style.border_color = Color(accent, 0.9 if hovered else 0.42)
	style.set_border_width_all(2 if hovered else 1)
	style.set_corner_radius_all(24)
	style.shadow_color = Color(glow, 0.34 if hovered else 0.2)
	style.shadow_size = 20 if hovered else 12
	style.shadow_offset = Vector2(0, 8)
	return style


func _art_frame_style(accent: Color, glow: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("07152d")
	style.border_color = Color(accent, 0.82)
	style.set_border_width_all(1)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(glow, 0.32)
	style.shadow_size = 14
	return style


func _chip_style(accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(accent, 0.12)
	style.border_color = Color(accent, 0.42)
	style.set_border_width_all(1)
	style.set_corner_radius_all(9)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style


func _panel_style(bg_hex: String, border_hex: String, radius: int, alpha: float, shadow: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var bg := Color(bg_hex)
	bg.a = alpha
	style.bg_color = bg
	style.border_color = Color(border_hex)
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0, 0.05, 0.16, 0.5)
	style.shadow_size = shadow
	return style


func _button_style(bg_hex: String, border_hex: String, radius: int, alpha: float, shadow: int) -> StyleBoxFlat:
	var style := _panel_style(bg_hex, border_hex, radius, alpha, shadow)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _focus_style(radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_color = Color("ffd166")
	style.set_border_width_all(3)
	style.set_corner_radius_all(radius)
	return style


func _set_margins(container: MarginContainer, left: int, top: int, right: int, bottom: int) -> void:
	container.add_theme_constant_override("margin_left", left)
	container.add_theme_constant_override("margin_top", top)
	container.add_theme_constant_override("margin_right", right)
	container.add_theme_constant_override("margin_bottom", bottom)
