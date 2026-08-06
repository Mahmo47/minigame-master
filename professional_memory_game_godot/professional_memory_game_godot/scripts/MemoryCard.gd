extends Button

signal card_selected(card)

var pair_id: int = -1
var is_revealed := false
var is_matched := false

var front_texture_rect: TextureRect
var back_panel: PanelContainer

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	flat = true
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_apply_transparent_button_styles()

func setup(new_pair_id: int, texture: Texture2D, desired_size: Vector2) -> void:
	pair_id = new_pair_id
	custom_minimum_size = desired_size
	_build_visuals_if_needed()
	front_texture_rect.texture = texture
	conceal_immediately()
	call_deferred("_update_pivot")

func reveal() -> void:
	if is_matched or is_revealed:
		return
	is_revealed = true
	front_texture_rect.visible = true
	back_panel.visible = false
	_animate_pop()

func conceal() -> void:
	if is_matched or not is_revealed:
		return
	is_revealed = false
	front_texture_rect.visible = false
	back_panel.visible = true
	_animate_pop()

func conceal_immediately() -> void:
	is_revealed = false
	is_matched = false
	disabled = false
	modulate = Color.WHITE
	if front_texture_rect != null:
		front_texture_rect.visible = false
	if back_panel != null:
		back_panel.visible = true

func mark_matched() -> void:
	is_matched = true
	is_revealed = true
	disabled = true
	front_texture_rect.visible = true
	back_panel.visible = false
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.12).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.58), 0.35)
	tween.chain().tween_property(self, "scale", Vector2.ONE, 0.12)

func _build_visuals_if_needed() -> void:
	if front_texture_rect != null:
		return

	back_panel = PanelContainer.new()
	back_panel.name = "CardBack"
	back_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	back_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back_panel.add_theme_stylebox_override("panel", _make_back_style())
	add_child(back_panel)

	var back_margin := MarginContainer.new()
	back_margin.add_theme_constant_override("margin_left", 8)
	back_margin.add_theme_constant_override("margin_top", 8)
	back_margin.add_theme_constant_override("margin_right", 8)
	back_margin.add_theme_constant_override("margin_bottom", 8)
	back_panel.add_child(back_margin)

	var back_center := CenterContainer.new()
	back_margin.add_child(back_center)

	var back_text := VBoxContainer.new()
	back_text.alignment = BoxContainer.ALIGNMENT_CENTER
	back_text.add_theme_constant_override("separation", 2)
	back_center.add_child(back_text)

	var symbol := Label.new()
	symbol.text = "◇"
	symbol.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	symbol.add_theme_font_size_override("font_size", 34)
	symbol.add_theme_color_override("font_color", Color.from_string("#ffffff", Color.WHITE))
	back_text.add_child(symbol)

	var title := Label.new()
	title.text = "MATCH"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", Color.from_string("#dbeafe", Color.WHITE))
	back_text.add_child(title)

	front_texture_rect = TextureRect.new()
	front_texture_rect.name = "CardFront"
	front_texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	front_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	front_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	front_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(front_texture_rect)

func _make_back_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color.from_string("#315b82", Color.DARK_BLUE)
	style.border_color = Color.from_string("#8fb3d1", Color.WHITE)
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(0.15, 0.23, 0.34, 0.20)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 5)
	return style

func _apply_transparent_button_styles() -> void:
	var transparent := StyleBoxFlat.new()
	transparent.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	transparent.set_corner_radius_all(18)
	add_theme_stylebox_override("normal", transparent)
	add_theme_stylebox_override("hover", transparent)
	add_theme_stylebox_override("pressed", transparent)
	add_theme_stylebox_override("disabled", transparent)
	add_theme_stylebox_override("focus", transparent)

func _on_pressed() -> void:
	if is_matched or is_revealed:
		return
	card_selected.emit(self)

func _on_mouse_entered() -> void:
	if is_matched or is_revealed:
		return
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.035, 1.035), 0.12).set_trans(Tween.TRANS_QUAD)

func _on_mouse_exited() -> void:
	if is_matched:
		return
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_QUAD)

func _animate_pop() -> void:
	scale = Vector2(0.92, 0.92)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.17).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_pivot()

func _update_pivot() -> void:
	pivot_offset = size * 0.5
