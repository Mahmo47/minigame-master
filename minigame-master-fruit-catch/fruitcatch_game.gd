extends Node2D

@export var apple_speed_min: float = 150.0
@export var apple_speed_max: float = 300.0
@export var spawn_interval_min: float = 0.5
@export var spawn_interval_max: float = 1.2
@export var basket_speed: float = 500.0

var score: int = 0
var is_game_over: bool = false
var apples: Array = []
var floor_y: float
var screen_size: Vector2

@onready var basket: Area2D = $Basket
@onready var line_2d: Line2D = $Line2D
@onready var spawn_timer: Timer = $SpawnTimer
@onready var score_label: Label = $CanvasLayer/UI/ScoreLabel
@onready var game_over_panel: Control = $CanvasLayer/UI/GameOverPanel
@onready var final_score_label: Label = $CanvasLayer/UI/GameOverPanel/VBoxContainer/FinalScoreLabel
@onready var restart_button: Button = $CanvasLayer/UI/GameOverPanel/VBoxContainer/RestartButton


func _ready() -> void:
	basket.area_entered.connect(_on_basket_area_entered)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	restart_button.pressed.connect(_on_restart_pressed)
	get_viewport().size_changed.connect(_update_layout)
	_update_layout()
	_start_game()


func _start_game() -> void:
	score = 0
	is_game_over = false
	_update_score_label()
	game_over_panel.visible = false
	for apple in apples.duplicate():
		apple.queue_free()
	apples.clear()
	basket.position.x = screen_size.x / 2.0
	_schedule_next_spawn()


func _update_layout() -> void:
	screen_size = get_viewport_rect().size
	floor_y = screen_size.y - 80.0
	line_2d.clear_points()
	line_2d.add_point(Vector2(0, floor_y + 40))
	line_2d.add_point(Vector2(screen_size.x, floor_y + 40))
	basket.position.y = floor_y
	basket.position.x = clamp(basket.position.x, 40.0, screen_size.x - 40.0)


func _process(delta: float) -> void:
	if is_game_over:
		return
	_handle_input(delta)
	_update_apples(delta)


func _handle_input(delta: float) -> void:
	var direction := 0.0
	if Input.is_action_pressed("ui_left"):
		direction -= 1.0
	if Input.is_action_pressed("ui_right"):
		direction += 1.0
	basket.position.x = clamp(basket.position.x + direction * basket_speed * delta, 40.0, screen_size.x - 40.0)


func _update_apples(delta: float) -> void:
	# Iterate over a copy since a miss can free the apple and end the loop early.
	for apple in apples.duplicate():
		if not is_instance_valid(apple):
			apples.erase(apple)
			continue
		apple.position.y += apple.get_meta("speed") * delta
		if apple.position.y > floor_y + 60.0:
			apples.erase(apple)
			apple.queue_free()
			_trigger_game_over()
			return


func _schedule_next_spawn() -> void:
	spawn_timer.wait_time = randf_range(spawn_interval_min, spawn_interval_max)
	spawn_timer.start()


func _on_spawn_timer_timeout() -> void:
	if is_game_over:
		return
	_spawn_apple()
	_schedule_next_spawn()


func _spawn_apple() -> void:
	var apple := _create_apple()
	apple.position = Vector2(randf_range(40.0, screen_size.x - 40.0), -30.0)
	apple.set_meta("speed", randf_range(apple_speed_min, apple_speed_max))
	add_child(apple)
	apples.append(apple)


func _create_apple() -> Area2D:
	var apple := Area2D.new()
	apple.add_to_group("apples")
	apple.collision_layer = 2
	apple.collision_mask = 0

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16.0
	shape.shape = circle
	apple.add_child(shape)

	var visual := Polygon2D.new()
	visual.color = Color(0.85, 0.1, 0.1)
	visual.polygon = _make_circle_points(16.0, 16)
	apple.add_child(visual)

	return apple


func _make_circle_points(radius: float, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(segments):
		var angle := TAU * i / segments
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points


func _on_basket_area_entered(area: Area2D) -> void:
	if is_game_over:
		return
	if area.is_in_group("apples") and apples.has(area):
		apples.erase(area)
		area.queue_free()
		score += 1
		_update_score_label()


func _update_score_label() -> void:
	score_label.text = "Score: %d" % score


func _trigger_game_over() -> void:
	is_game_over = true
	spawn_timer.stop()
	final_score_label.text = "Final Score: %d" % score
	game_over_panel.visible = true


func _on_restart_pressed() -> void:
	_start_game()
