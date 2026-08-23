extends RefCounted
class_name SnakeRules

# SnakeRules enthält die eigentlichen Spielregeln.
# Diese Funktionen entscheiden nur über Bewegung, Kollision, Punkte und Nahrung.

static func set_next_direction(state: SnakeState, new_direction: Vector2i) -> void:
	# Richtungswechsel direkt in die Gegenrichtung werden blockiert.
	if new_direction == -state.direction:
		return
	state.next_direction = new_direction


static func step(state: SnakeState, grid_width: int, grid_height: int, max_snake_length: int) -> bool:
	# Führt genau einen Bewegungs-Schritt aus.
	state.direction = state.next_direction
	var new_head := state.snake[0] + state.direction
	var body_limit := state.snake.size()
	var ate_food := new_head == state.food
	if not ate_food:
		body_limit -= 1

	if is_outside_playfield(new_head, grid_width, grid_height) or _is_in_body(new_head, state.snake, body_limit):
		state.alive = false
		return false

	state.snake.insert(0, new_head)

	if ate_food:
		state.score += 1

	# Die Schlange wächst nur bis zur Maximal-Länge.
	# Danach bleibt sie konstant lang, damit das Spiel unendlich weiterlaufen kann.
	if not ate_food or state.snake.size() > max_snake_length:
		state.snake.pop_back()

	return ate_food


static func spawn_food(state: SnakeState, grid_width: int, grid_height: int) -> void:
	# Sucht ein freies Feld für die nächste Frucht.
	var free_cells: Array[Vector2i] = []
	for y in range(grid_height):
		for x in range(grid_width):
			var cell := Vector2i(x, y)
			if not cell in state.snake:
				free_cells.append(cell)

	if free_cells.is_empty():
		state.food = Vector2i(-1, -1)
		return

	state.food = free_cells[randi() % free_cells.size()]
	state.food_kind = randi() % 3


static func is_outside_playfield(cell: Vector2i, grid_width: int, grid_height: int) -> bool:
	return cell.x < 0 or cell.y < 0 or cell.x >= grid_width or cell.y >= grid_height


static func _is_in_body(cell: Vector2i, snake: Array[Vector2i], body_limit: int) -> bool:
	for index in range(body_limit):
		if snake[index] == cell:
			return true
	return false
