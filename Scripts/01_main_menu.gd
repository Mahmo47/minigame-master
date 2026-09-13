extends Control

@onready var backdrop: TextureRect = $Backdrop
@onready var header: MarginContainer = $Header
@onready var menu_panel: PanelContainer = $MainArea/Center/MenuPanel
@onready var start_button: Button = $MainArea/Center/MenuPanel/Margin/Content/BtnStart
@onready var exit_button: Button = $MainArea/Center/MenuPanel/Margin/Content/BtnExit
@onready var transition_overlay: ColorRect = $TransitionOverlay

var transitioning := false
var backdrop_origin := Vector2.ZERO


func _ready() -> void:
	backdrop_origin = backdrop.position
	_bind_button_animation(start_button)
	_bind_button_animation(exit_button)
	_play_intro()
	start_button.grab_focus()


func _process(delta: float) -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var normalized_mouse := get_viewport().get_mouse_position() / viewport_size - Vector2(0.5, 0.5)
	var target := backdrop_origin - normalized_mouse * 12.0
	backdrop.position = backdrop.position.lerp(target, minf(1.0, delta * 2.5))


func _play_intro() -> void:
	var header_target := header.position
	header.position = header_target + Vector2(0.0, -20.0)
	menu_panel.modulate = Color(1, 1, 1, 0)
	menu_panel.pivot_offset = menu_panel.size / 2.0
	menu_panel.scale = Vector2(0.975, 0.975)
	header.modulate = Color(1, 1, 1, 0)
	backdrop.modulate = Color(0.62, 0.7, 0.88, 1)

	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(backdrop, "modulate", Color.WHITE, 0.9)
	tween.tween_property(header, "position", header_target, 0.55).set_delay(0.08)
	tween.tween_property(header, "modulate", Color.WHITE, 0.42).set_delay(0.08)
	tween.tween_property(menu_panel, "scale", Vector2.ONE, 0.65).set_delay(0.16)
	tween.tween_property(menu_panel, "modulate", Color.WHITE, 0.5).set_delay(0.16)


func _bind_button_animation(button: Button) -> void:
	button.mouse_entered.connect(func() -> void: _animate_button(button, Vector2(1.018, 1.018)))
	button.mouse_exited.connect(func() -> void: _animate_button(button, Vector2.ONE))
	button.focus_entered.connect(func() -> void: _animate_button(button, Vector2(1.012, 1.012)))
	button.focus_exited.connect(func() -> void: _animate_button(button, Vector2.ONE))
	button.resized.connect(func() -> void: button.pivot_offset = button.size / 2.0)
	button.pivot_offset = button.size / 2.0


func _animate_button(button: Button, target_scale: Vector2) -> void:
	var tween := button.create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, 0.12)


func _on_btn_start_pressed() -> void:
	if transitioning:
		return
	transitioning = true
	start_button.disabled = true
	exit_button.disabled = true
	var tween := create_tween()
	tween.tween_property(transition_overlay, "modulate:a", 1.0, 0.28)
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/02_game_selector.tscn")


func _on_btn_exit_pressed() -> void:
	if transitioning:
		return
	transitioning = true
	start_button.disabled = true
	exit_button.disabled = true
	var tween := create_tween()
	tween.tween_property(transition_overlay, "modulate:a", 1.0, 0.22)
	await tween.finished
	get_tree().quit()
