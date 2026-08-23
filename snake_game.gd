extends Node2D
class_name SnakeGame

# SnakeGame ist der einzige Node, der in eine Godot-Scene gehängt wird.
# Er verbindet Eingabe, Spielzustand, Regeln und Rendering.

signal score_changed(score: int)
signal game_over(score: int)

@export var grid_width: int = 24
@export var grid_height: int = 18
@export var cell_size: int = 24
@export var base_step_time: float = 0.18
@export var speedup_interval: float = 10.0
@export var speedup_amount: float = 0.25
@export var max_speed_multiplier: float = 5.0
@export var max_snake_length: int = 40

var state: SnakeState = SnakeState.new()
var ui_font: Font
var ui_font_size: int = 18


func _ready() -> void:
	randomize()
	ui_font = ThemeDB.fallback_font
	ui_font_size = ThemeDB.fallback_font_size
	start_game()


func start_game() -> void:
	# Startet ein neues Spiel und stellt alle Werte zurück.
	state.reset(grid_width, grid_height)
	SnakeRules.spawn_food(state, grid_width, grid_height)
	state.previous_snake = state.snake.duplicate()
	state.render_alpha = 0.0
	score_changed.emit(state.score)
	queue_redraw()


func restart_game() -> void:
	start_game()


func stop_game() -> void:
	state.alive = false


func get_score() -> int:
	return state.score


func _unhandled_input(event: InputEvent) -> void:
	if not state.alive:
		if event.is_action_pressed("ui_accept"):
			restart_game()
		return

	if event.is_action_pressed("ui_up"):
		SnakeRules.set_next_direction(state, Vector2i.UP)
	elif event.is_action_pressed("ui_down"):
		SnakeRules.set_next_direction(state, Vector2i.DOWN)
	elif event.is_action_pressed("ui_left"):
		SnakeRules.set_next_direction(state, Vector2i.LEFT)
	elif event.is_action_pressed("ui_right"):
		SnakeRules.set_next_direction(state, Vector2i.RIGHT)


func _process(delta: float) -> void:
	if not state.alive:
		queue_redraw()
		return

	# Die Schlange wird alle 10 Sekunden etwas schneller, aber nie schneller als 5x.
	state.speed_accumulator += delta
	while state.speed_accumulator >= speedup_interval:
		state.speed_accumulator -= speedup_interval
		state.speed_multiplier = min(max_speed_multiplier, state.speed_multiplier + speedup_amount)

	state.step_accumulator += delta
	var step_time := base_step_time / state.speed_multiplier
	state.render_alpha = clampf(state.step_accumulator / step_time, 0.0, 1.0)
	while state.step_accumulator >= step_time and state.alive:
		state.step_accumulator -= step_time
		state.previous_snake = state.snake.duplicate()
		var previous_score := state.score
		var ate_food := SnakeRules.step(state, grid_width, grid_height, max_snake_length)

		if not state.alive:
			game_over.emit(state.score)
			break

		if ate_food and state.score != previous_score:
			score_changed.emit(state.score)
			SnakeRules.spawn_food(state, grid_width, grid_height)

	state.render_alpha = clampf(state.step_accumulator / step_time, 0.0, 1.0)

	queue_redraw()


func _draw() -> void:
	SnakeRenderer.draw_game(self, state, grid_width, grid_height, cell_size, ui_font, ui_font_size)
