extends Button

signal card_selected(card)

var pair_id: int = -1
var texture_index: int = -1
var is_revealed: bool = false
var is_matched: bool = false

var back_texture: Texture2D
var glow_texture: Texture2D

var back_rect: TextureRect
var front_image: TextureRect
var glow_rect: TextureRect

func _ready() -> void:
	flat = true
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_apply_transparent_styles()

func setup(new_pair_id: int, new_texture_index: int, picture: Texture2D, desired_size: Vector2, card_back: Texture2D, _front_plate_asset: Texture2D, glow_asset: Texture2D) -> void:
	pair_id = new_pair_id
	texture_index = new_texture_index
	custom_minimum_size = desired_size
	back_texture = card_back
	glow_texture = glow_asset
	_build_visuals()
	set_pair(new_pair_id, new_texture_index, picture)
	call_deferred("_update_pivot")

func set_pair(new_pair_id: int, new_texture_index: int, picture: Texture2D) -> void:
	pair_id = new_pair_id
	texture_index = new_texture_index
	is_revealed = false
	is_matched = false
	disabled = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	modulate = Color.WHITE
	front_image.texture = picture
	front_image.visible = false
	back_rect.visible = true
	glow_rect.visible = false
	scale = Vector2.ONE
	rotation = 0.0

func reveal() -> void:
	if is_revealed or is_matched:
		return
	is_revealed = true
	_flip(true)

func conceal() -> void:
	if not is_revealed or is_matched:
		return
	is_revealed = false
	_flip(false)

func play_match_effect() -> void:
	is_matched = true
	disabled = true
	glow_rect.visible = true
	glow_rect.modulate = Color(1, 1, 1, 0)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(glow_rect, "modulate", Color(1, 1, 1, 1), 0.16)
	tween.chain().tween_property(self, "scale", Vector2.ONE, 0.12)

func play_disappear_effect() -> void:
	disabled = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.72, 0.72), 0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.20)

func play_wrong_effect() -> void:
	var start_x: float = position.x
	var tween: Tween = create_tween()
	tween.tween_property(self, "position:x", start_x - 7.0, 0.05)
	tween.tween_property(self, "position:x", start_x + 7.0, 0.05)
	tween.tween_property(self, "position:x", start_x - 4.0, 0.05)
	tween.tween_property(self, "position:x", start_x, 0.05)

func _build_visuals() -> void:
	if back_rect != null:
		return

	# Back side: no oversized offsets. The source already contains the complete frame,
	# so KEEP_ASPECT_CENTERED guarantees that no right edge is cut off.
	back_rect = TextureRect.new()
	back_rect.anchor_left = 0.02
	back_rect.anchor_top = 0.02
	back_rect.anchor_right = 0.96
	back_rect.anchor_bottom = 0.98
	back_rect.offset_left = 0
	back_rect.offset_top = 0
	back_rect.offset_right = 0
	back_rect.offset_bottom = 0
	back_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	back_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	back_rect.texture = back_texture
	back_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(back_rect)

	# Front side: complete pre-composed card face, including its own premium frame.
	front_image = TextureRect.new()
	front_image.anchor_left = 0.02
	front_image.anchor_top = 0.02
	front_image.anchor_right = 0.98
	front_image.anchor_bottom = 0.98
	front_image.offset_left = 0
	front_image.offset_top = 0
	front_image.offset_right = 0
	front_image.offset_bottom = 0
	front_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	front_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	front_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(front_image)

	glow_rect = TextureRect.new()
	glow_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glow_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glow_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	glow_rect.texture = glow_texture
	glow_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow_rect.visible = false
	add_child(glow_rect)

func _flip(show_front: bool) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale:x", 0.08, 0.085).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void:
		back_rect.visible = not show_front
		front_image.visible = show_front
	)
	tween.tween_property(self, "scale:x", 1.0, 0.11).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_pressed() -> void:
	if is_revealed or is_matched:
		return
	card_selected.emit(self)

func _on_mouse_entered() -> void:
	if is_matched:
		return
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.035, 1.035), 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	if is_matched:
		return
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _apply_transparent_styles() -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.set_corner_radius_all(18)
	add_theme_stylebox_override("normal", style)
	add_theme_stylebox_override("hover", style)
	add_theme_stylebox_override("pressed", style)
	add_theme_stylebox_override("focus", style)
	add_theme_stylebox_override("disabled", style)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_pivot()

func _update_pivot() -> void:
	pivot_offset = size * 0.5
