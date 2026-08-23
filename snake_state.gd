extends RefCounted
class_name SnakeState

enum FoodKind { GOLDEN_APPLE, KIWI, CHERRY }

# SnakeState hält nur Daten.
# Hier liegen keine Zeichnungs- oder Eingabelogik, damit andere Module die
# Spielwerte sauber lesen und verändern können.

var snake: Array[Vector2i] = []
var direction: Vector2i = Vector2i.RIGHT
var next_direction: Vector2i = Vector2i.RIGHT
var food: Vector2i = Vector2i.ZERO
var food_kind: FoodKind = FoodKind.GOLDEN_APPLE
var score: int = 0
var alive: bool = true
var step_accumulator: float = 0.0
var speed_accumulator: float = 0.0
var speed_multiplier: float = 1.0
var previous_snake: Array[Vector2i] = []
var render_alpha: float = 0.0


func reset(grid_width: int, grid_height: int) -> void:
	# Setzt die komplette Spielwelt in den Startzustand zurück.
	snake.clear()
	var center := Vector2i(grid_width / 2, grid_height / 2)
	snake.append(center)
	snake.append(center - Vector2i(1, 0))
	snake.append(center - Vector2i(2, 0))
	direction = Vector2i.RIGHT
	next_direction = Vector2i.RIGHT
	food = Vector2i.ZERO
	food_kind = FoodKind.GOLDEN_APPLE
	score = 0
	alive = true
	step_accumulator = 0.0
	speed_accumulator = 0.0
	speed_multiplier = 1.0
	previous_snake.clear()
	render_alpha = 0.0


func current_length() -> int:
	return snake.size()
