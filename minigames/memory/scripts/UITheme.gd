extends RefCounted
class_name MemoryUITheme

static func set_margins(container: MarginContainer, left: int, top: int, right: int, bottom: int) -> void:
	container.add_theme_constant_override("margin_left", left)
	container.add_theme_constant_override("margin_top", top)
	container.add_theme_constant_override("margin_right", right)
	container.add_theme_constant_override("margin_bottom", bottom)

static func panel_style(bg_hex: String, border_hex: String, radius: int = 18, alpha: float = 0.96, shadow_size: int = 12) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	var bg: Color = Color.from_string(bg_hex, Color.DARK_BLUE)
	bg.a = alpha
	style.bg_color = bg
	style.border_color = Color.from_string(border_hex, Color.WHITE)
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.36)
	style.shadow_size = shadow_size
	style.shadow_offset = Vector2(0, 6)
	return style

static func button_style(bg_hex: String, border_hex: String, radius: int = 14, alpha: float = 1.0) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	var bg: Color = Color.from_string(bg_hex, Color.DARK_BLUE)
	bg.a = alpha
	style.bg_color = bg
	style.border_color = Color.from_string(border_hex, Color.WHITE)
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 4)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 9
	style.content_margin_bottom = 9
	return style

static func apply_button(button: BaseButton, primary: bool = false, compact: bool = false) -> void:
	var normal_bg: String = "#2b62dd" if primary else "#102038"
	var hover_bg: String = "#3775f2" if primary else "#182d4a"
	var pressed_bg: String = "#234fb5" if primary else "#0c1829"
	var border: String = "#8bbcff" if primary else "#3b6592"
	button.add_theme_stylebox_override("normal", button_style(normal_bg, border, 14))
	button.add_theme_stylebox_override("hover", button_style(hover_bg, "#9ac8ff", 14))
	button.add_theme_stylebox_override("pressed", button_style(pressed_bg, border, 14))
	button.add_theme_stylebox_override("focus", button_style(hover_bg, "#b4d6ff", 14))
	button.add_theme_stylebox_override("disabled", button_style("#1c2a3d", border, 14, 0.55))
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_font_size_override("font_size", 12 if compact else 15)
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
