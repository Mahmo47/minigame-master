extends RefCounted
class_name SnakeRenderer

# SnakeRenderer zeichnet nur das Bild.
# Diese Datei hat keine Spielregeln und keine Eingabe, damit das Layout leicht
# austauschbar bleibt.

const BACKGROUND_COLOR := Color(0.08, 0.09, 0.12)
const GRID_COLOR := Color(0.14, 0.14, 0.16)
const WALL_COLOR := Color(0.42, 0.26, 0.11)
const WALL_DARK_COLOR := Color(0.23, 0.14, 0.06)
const WALL_LIGHT_COLOR := Color(0.60, 0.40, 0.20)
const DRAGON_BONE_COLOR := Color(0.88, 0.86, 0.79)
const DRAGON_BONE_DARK := Color(0.64, 0.60, 0.54)
const DRAGON_EYE_COLOR := Color(0.86, 0.14, 0.12)
const DRAGON_SHADOW := Color(0.20, 0.20, 0.22)
const GOLD_APPLE_COLOR := Color(0.86, 0.70, 0.08)
const GOLD_APPLE_DARK := Color(0.57, 0.43, 0.04)
const KIWI_COLOR := Color(0.43, 0.28, 0.07)
const KIWI_GREEN := Color(0.45, 0.68, 0.19)
const KIWI_SEEDS := Color(0.10, 0.08, 0.05)
const CHERRY_RED := Color(0.79, 0.10, 0.14)
const CHERRY_DARK := Color(0.46, 0.03, 0.06)
const TEXT_COLOR := Color(0.95, 0.95, 0.95)


static func draw_game(canvas: CanvasItem, state: SnakeState, grid_width: int, grid_height: int, cell_size: int, ui_font: Font, ui_font_size: int) -> void:
	# Das Spielfeld startet mit etwas Abstand, damit Wand und HUD sichtbar bleiben.
	var playfield_origin := Vector2(cell_size, cell_size * 2)
	var playfield_size := Vector2(grid_width * cell_size, grid_height * cell_size)
	var outer_rect := Rect2(playfield_origin - Vector2(cell_size, cell_size), playfield_size + Vector2(cell_size * 2, cell_size * 2))

	canvas.draw_rect(Rect2(Vector2.ZERO, Vector2(outer_rect.size.x + outer_rect.position.x, outer_rect.size.y + outer_rect.position.y)), BACKGROUND_COLOR, true)
	_draw_castle_walls(canvas, outer_rect, playfield_origin, playfield_size, cell_size)
	canvas.draw_rect(Rect2(playfield_origin, playfield_size), GRID_COLOR, true)

	for y in range(grid_height):
		for x in range(grid_width):
			if (x + y) % 2 == 0:
				var shade_rect := Rect2(playfield_origin + Vector2(x * cell_size, y * cell_size), Vector2(cell_size - 1, cell_size - 1))
				canvas.draw_rect(shade_rect, Color(0.11, 0.12, 0.15, 0.18), true)

	var dragon_points := _build_dragon_points(state, playfield_origin, cell_size)
	_draw_dragon_silhouette(canvas, dragon_points, cell_size)

	if state.food.x >= 0 and state.food.y >= 0:
		_draw_food(canvas, playfield_origin, state.food, cell_size, state.food_kind)

	if ui_font != null:
		var hud_text := "Punkte: %d   Tempo: %.2fx   Länge: %d" % [state.score, state.speed_multiplier, state.current_length()]
		canvas.draw_string(ui_font, Vector2(16, 24), hud_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, ui_font_size, TEXT_COLOR)
		if not state.alive:
			canvas.draw_string(ui_font, Vector2(16, 48), "Game Over - Enter zum Neustart", HORIZONTAL_ALIGNMENT_LEFT, -1.0, ui_font_size, TEXT_COLOR)


static func _build_dragon_points(state: SnakeState, playfield_origin: Vector2, cell_size: int) -> Array[Vector2]:
	# Mischt alten und aktuellen Zustand, damit die Bewegung zwischen den Rasterzellen weich wirkt.
	var current_snake := state.snake
	var previous_snake := state.previous_snake
	var alpha := clampf(state.render_alpha, 0.0, 1.0)

	if current_snake.is_empty():
		return []

	if previous_snake.is_empty():
		previous_snake = current_snake.duplicate()

	if previous_snake.size() < current_snake.size():
		var tail_cell := previous_snake[previous_snake.size() - 1]
		while previous_snake.size() < current_snake.size():
			previous_snake.append(tail_cell)
	elif previous_snake.size() > current_snake.size():
		while previous_snake.size() > current_snake.size():
			previous_snake.pop_back()

	var points: Array[Vector2] = []
	for index in range(current_snake.size()):
		var previous_center := _cell_center(playfield_origin, previous_snake[index], cell_size)
		var current_center := _cell_center(playfield_origin, current_snake[index], cell_size)
		points.append(previous_center.lerp(current_center, alpha))

	return points


static func _draw_dragon_silhouette(canvas: CanvasItem, points: Array[Vector2], cell_size: int) -> void:
	if points.is_empty():
		return

	var body_thickness := cell_size * 0.46
	var shadow_thickness := body_thickness * 0.45

	for index in range(points.size() - 1):
		var progress: float = float(index) / float(max(1, points.size() - 1))
		var width: float = lerpf(body_thickness, cell_size * 0.24, progress)
		canvas.draw_line(points[index] + Vector2(2, 2), points[index + 1] + Vector2(2, 2), DRAGON_SHADOW, shadow_thickness, true)
		canvas.draw_line(points[index], points[index + 1], DRAGON_BONE_COLOR, width, true)
		canvas.draw_circle(points[index], width * 0.48, DRAGON_BONE_COLOR)

	_draw_dragon_tail_caps(canvas, points, cell_size)
	_draw_dragon_head_silhouette(canvas, points, cell_size)


static func _draw_dragon_tail_caps(canvas: CanvasItem, points: Array[Vector2], cell_size: int) -> void:
	var tail_point := points[points.size() - 1]
	var tail_size := cell_size * 0.18
	canvas.draw_circle(tail_point, tail_size, DRAGON_BONE_COLOR)
	canvas.draw_circle(tail_point + Vector2(1, 1), tail_size * 0.6, DRAGON_SHADOW)


static func _draw_dragon_head_silhouette(canvas: CanvasItem, points: Array[Vector2], cell_size: int) -> void:
	var head_point := points[0]
	var look_point := points[0] if points.size() == 1 else points[1]
	var facing := (head_point - look_point).normalized()
	if facing == Vector2.ZERO:
		facing = Vector2.RIGHT
	var perpendicular := Vector2(-facing.y, facing.x)
	var head_radius := cell_size * 0.40

	canvas.draw_circle(head_point, head_radius, DRAGON_BONE_COLOR)
	canvas.draw_circle(head_point + facing * head_radius * 0.18, head_radius * 0.84, DRAGON_SHADOW)
	canvas.draw_circle(head_point + facing * head_radius * 0.40, head_radius * 0.58, DRAGON_BONE_COLOR)
	canvas.draw_circle(head_point + facing * head_radius * 0.18 + perpendicular * head_radius * 0.14, head_radius * 0.11, DRAGON_EYE_COLOR)
	canvas.draw_circle(head_point + facing * head_radius * 0.18 - perpendicular * head_radius * 0.14, head_radius * 0.11, DRAGON_EYE_COLOR)
	canvas.draw_line(head_point + facing * head_radius * 0.52 + perpendicular * head_radius * 0.10, head_point + facing * head_radius * 0.96, DRAGON_BONE_DARK, 2.0)
	canvas.draw_line(head_point + facing * head_radius * 0.52 - perpendicular * head_radius * 0.10, head_point + facing * head_radius * 0.96, DRAGON_BONE_DARK, 2.0)
	canvas.draw_arc(head_point + facing * head_radius * 0.18, head_radius * 0.26, 0.0, TAU, 20, DRAGON_BONE_DARK, 2.0, true)


static func _cell_center(playfield_origin: Vector2, cell: Vector2i, cell_size: int) -> Vector2:
	return playfield_origin + Vector2(cell.x * cell_size + cell_size * 0.5, cell.y * cell_size + cell_size * 0.5)


static func _draw_castle_walls(canvas: CanvasItem, outer_rect: Rect2, playfield_origin: Vector2, playfield_size: Vector2, cell_size: int) -> void:
	# Zeichnet eine Burgmauer mit runden Türmen, Zinnen und einem Torbogen.
	canvas.draw_rect(outer_rect, WALL_COLOR, true)
	canvas.draw_rect(Rect2(outer_rect.position + Vector2(1, 1), outer_rect.size - Vector2(2, 2)), WALL_DARK_COLOR, true)

	var battlement_width: int = int(max(4, cell_size / 2))
	var battlement_height: int = int(max(4, cell_size / 2))
	for x in range(int(outer_rect.position.x), int(outer_rect.position.x + outer_rect.size.x), battlement_width):
		canvas.draw_rect(Rect2(Vector2(x, outer_rect.position.y), Vector2(battlement_width - 1, battlement_height)), WALL_LIGHT_COLOR, true)
		canvas.draw_rect(Rect2(Vector2(x, outer_rect.position.y + outer_rect.size.y - battlement_height), Vector2(battlement_width - 1, battlement_height)), WALL_DARK_COLOR, true)

	for y in range(int(outer_rect.position.y), int(outer_rect.position.y + outer_rect.size.y), battlement_width):
		canvas.draw_rect(Rect2(Vector2(outer_rect.position.x, y), Vector2(battlement_height, battlement_width - 1)), WALL_LIGHT_COLOR, true)
		canvas.draw_rect(Rect2(Vector2(outer_rect.position.x + outer_rect.size.x - battlement_height, y), Vector2(battlement_height, battlement_width - 1)), WALL_DARK_COLOR, true)

	var tower_radius := cell_size * 0.95
	var left_tower_center := playfield_origin + Vector2(-cell_size * 0.18, playfield_size.y * 0.5)
	var right_tower_center := playfield_origin + Vector2(playfield_size.x + cell_size * 0.18, playfield_size.y * 0.5)
	canvas.draw_circle(left_tower_center, tower_radius, WALL_LIGHT_COLOR)
	canvas.draw_circle(left_tower_center + Vector2(cell_size * 0.12, 0), tower_radius * 0.72, WALL_COLOR)
	canvas.draw_circle(right_tower_center, tower_radius, WALL_LIGHT_COLOR)
	canvas.draw_circle(right_tower_center + Vector2(-cell_size * 0.12, 0), tower_radius * 0.72, WALL_COLOR)
	canvas.draw_circle(left_tower_center + Vector2(0, -tower_radius * 0.7), tower_radius * 0.42, WALL_LIGHT_COLOR)
	canvas.draw_circle(right_tower_center + Vector2(0, -tower_radius * 0.7), tower_radius * 0.42, WALL_LIGHT_COLOR)

	var gate_width := cell_size * 3
	var gate_height := cell_size * 1.65
	var gate_pos := Vector2(outer_rect.position.x + outer_rect.size.x / 2 - gate_width / 2, outer_rect.position.y + outer_rect.size.y - gate_height)
	var gate_rect := Rect2(gate_pos, Vector2(gate_width, gate_height))
	canvas.draw_rect(gate_rect, WALL_DARK_COLOR, true)
	canvas.draw_arc(gate_rect.position + Vector2(gate_rect.size.x * 0.5, gate_rect.size.y * 0.62), gate_rect.size.x * 0.33, PI, TAU, 24, WALL_LIGHT_COLOR, 3.0, true)
	canvas.draw_line(gate_rect.position + Vector2(gate_rect.size.x * 0.18, gate_rect.size.y * 0.94), gate_rect.position + Vector2(gate_rect.size.x * 0.18, gate_rect.size.y * 0.52), WALL_LIGHT_COLOR, 2.0)
	canvas.draw_line(gate_rect.position + Vector2(gate_rect.size.x * 0.82, gate_rect.size.y * 0.94), gate_rect.position + Vector2(gate_rect.size.x * 0.82, gate_rect.size.y * 0.52), WALL_LIGHT_COLOR, 2.0)


static func _draw_dragon_segment(canvas: CanvasItem, playfield_origin: Vector2, part: Vector2i, previous_part: Vector2i, next_part: Vector2i, cell_size: int) -> void:
	var pos := playfield_origin + Vector2(part.x * cell_size, part.y * cell_size)
	var center := pos + Vector2(cell_size * 0.5, cell_size * 0.5)
	var incoming := _direction_from_cell(previous_part, part)
	var outgoing := _direction_from_cell(part, next_part)

	if previous_part.x == -999 and previous_part.y == -999:
		_draw_dragon_head(canvas, center, cell_size, outgoing)
		return

	if next_part.x == -999 and next_part.y == -999:
		_draw_dragon_tail(canvas, center, cell_size, incoming)
		return

	if incoming == outgoing:
		_draw_dragon_body(canvas, center, cell_size, incoming)
	else:
		_draw_dragon_turn(canvas, center, cell_size, incoming, outgoing)


static func _draw_dragon_body(canvas: CanvasItem, center: Vector2, cell_size: int, direction: Vector2i) -> void:
	var thickness := cell_size * 0.30
	var length := cell_size * 0.72

	if direction.x != 0:
		canvas.draw_line(center + Vector2(-length * 0.5, 0), center + Vector2(length * 0.5, 0), DRAGON_BONE_COLOR, thickness * 2.0)
		canvas.draw_circle(center + Vector2(-length * 0.5, 0), thickness, DRAGON_BONE_COLOR)
		canvas.draw_circle(center + Vector2(length * 0.5, 0), thickness, DRAGON_BONE_COLOR)
		canvas.draw_line(center + Vector2(-length * 0.45, -thickness * 0.35), center + Vector2(length * 0.45, -thickness * 0.35), DRAGON_SHADOW, 1.0)
	else:
		canvas.draw_line(center + Vector2(0, -length * 0.5), center + Vector2(0, length * 0.5), DRAGON_BONE_COLOR, thickness * 2.0)
		canvas.draw_circle(center + Vector2(0, -length * 0.5), thickness, DRAGON_BONE_COLOR)
		canvas.draw_circle(center + Vector2(0, length * 0.5), thickness, DRAGON_BONE_COLOR)
		canvas.draw_line(center + Vector2(-thickness * 0.35, -length * 0.45), center + Vector2(-thickness * 0.35, length * 0.45), DRAGON_SHADOW, 1.0)

	canvas.draw_circle(center + Vector2(-cell_size * 0.14, -cell_size * 0.10), cell_size * 0.06, DRAGON_BONE_DARK)
	canvas.draw_circle(center + Vector2(cell_size * 0.14, cell_size * 0.10), cell_size * 0.06, DRAGON_BONE_DARK)


static func _draw_dragon_turn(canvas: CanvasItem, center: Vector2, cell_size: int, incoming: Vector2i, outgoing: Vector2i) -> void:
	_draw_dragon_body(canvas, center, cell_size, incoming if incoming.x != 0 else outgoing)
	canvas.draw_circle(center, cell_size * 0.18, DRAGON_SHADOW)


static func _draw_dragon_head(canvas: CanvasItem, center: Vector2, cell_size: int, direction: Vector2i) -> void:
	var facing := Vector2(direction)
	if facing == Vector2.ZERO:
		facing = Vector2(1, 0)
	var perpendicular := Vector2(-facing.y, facing.x)
	var head_radius := cell_size * 0.42

	canvas.draw_circle(center, head_radius * 0.98, DRAGON_BONE_COLOR)
	canvas.draw_circle(center + facing * head_radius * 0.12, head_radius * 0.82, DRAGON_SHADOW)
	canvas.draw_circle(center + facing * head_radius * 0.42, head_radius * 0.58, DRAGON_BONE_COLOR)
	canvas.draw_line(center + facing * head_radius * 0.70 + perpendicular * head_radius * 0.16, center + facing * head_radius * 1.08, DRAGON_BONE_DARK, 2.0)
	canvas.draw_line(center + facing * head_radius * 0.70 - perpendicular * head_radius * 0.16, center + facing * head_radius * 1.08, DRAGON_BONE_DARK, 2.0)
	canvas.draw_circle(center + facing * head_radius * 0.24 + perpendicular * head_radius * 0.16, head_radius * 0.11, DRAGON_EYE_COLOR)
	canvas.draw_circle(center + facing * head_radius * 0.24 - perpendicular * head_radius * 0.16, head_radius * 0.11, DRAGON_EYE_COLOR)
	canvas.draw_arc(center + facing * head_radius * 0.22, head_radius * 0.28, 0.0, TAU, 24, DRAGON_BONE_DARK, 2.0, true)
	canvas.draw_line(center + facing * head_radius * 0.90, center + facing * head_radius * 1.30, DRAGON_BONE_DARK, 2.0)


static func _draw_dragon_tail(canvas: CanvasItem, center: Vector2, cell_size: int, direction: Vector2i) -> void:
	var facing := Vector2(direction)
	if facing == Vector2.ZERO:
		facing = Vector2(1, 0)
	canvas.draw_line(center - facing * cell_size * 0.28, center + facing * cell_size * 0.28, DRAGON_BONE_COLOR, cell_size * 0.22)
	canvas.draw_circle(center - facing * cell_size * 0.28, cell_size * 0.17, DRAGON_BONE_COLOR)
	canvas.draw_line(center + facing * cell_size * 0.30, center + facing * cell_size * 0.65, DRAGON_BONE_DARK, 2.0)


static func _draw_food(canvas: CanvasItem, playfield_origin: Vector2, food: Vector2i, cell_size: int, food_kind: int) -> void:
	var pos := playfield_origin + Vector2(food.x * cell_size, food.y * cell_size)
	var center := pos + Vector2(cell_size * 0.5, cell_size * 0.5)
	var radius := cell_size * 0.28

	match food_kind:
		SnakeState.FoodKind.GOLDEN_APPLE:
			canvas.draw_circle(center, radius * 0.98, GOLD_APPLE_COLOR)
			canvas.draw_circle(center + Vector2(-radius * 0.20, -radius * 0.18), radius * 0.55, Color(1, 0.92, 0.45, 0.35))
			canvas.draw_circle(center + Vector2(radius * 0.18, radius * 0.18), radius * 0.30, Color(0.52, 0.38, 0.05, 0.22))
			canvas.draw_line(center + Vector2(0, -radius * 0.95), center + Vector2(0, -radius * 1.42), GOLD_APPLE_DARK, 2.0)
			canvas.draw_arc(center + Vector2(0, radius * 0.04), radius * 0.96, 0.0, TAU, 20, GOLD_APPLE_DARK, 2.0, true)
			canvas.draw_circle(center + Vector2(-radius * 0.15, -radius * 0.18), radius * 0.18, Color(1, 1, 1, 0.18))
		SnakeState.FoodKind.KIWI:
			canvas.draw_circle(center, radius * 1.00, KIWI_COLOR)
			canvas.draw_circle(center, radius * 0.80, KIWI_GREEN)
			canvas.draw_circle(center, radius * 0.52, Color(0.96, 0.94, 0.86))
			for i in range(7):
				var angle := TAU * float(i) / 7.0
				var seed_center := center + Vector2(cos(angle), sin(angle)) * radius * 0.30
				canvas.draw_circle(seed_center, radius * 0.05, KIWI_SEEDS)
			canvas.draw_line(center + Vector2(0, -radius * 1.00), center + Vector2(0, -radius * 1.45), KIWI_SEEDS, 2.0)
			canvas.draw_circle(center + Vector2(-radius * 0.20, -radius * 0.15), radius * 0.12, Color(1, 1, 1, 0.16))
		SnakeState.FoodKind.CHERRY:
			canvas.draw_circle(center + Vector2(-radius * 0.16, 0), radius * 0.74, CHERRY_DARK)
			canvas.draw_circle(center + Vector2(radius * 0.18, 0), radius * 0.74, CHERRY_RED)
			canvas.draw_circle(center + Vector2(-radius * 0.24, -radius * 0.22), radius * 0.22, Color(1, 1, 1, 0.16))
			canvas.draw_circle(center + Vector2(radius * 0.10, -radius * 0.18), radius * 0.20, Color(1, 1, 1, 0.12))
			canvas.draw_line(center + Vector2(-radius * 0.10, -radius * 0.62), center + Vector2(-radius * 0.44, -radius * 1.24), WALL_LIGHT_COLOR, 2.0)
			canvas.draw_line(center + Vector2(radius * 0.12, -radius * 0.62), center + Vector2(radius * 0.46, -radius * 1.20), WALL_LIGHT_COLOR, 2.0)


static func _direction_from_cell(from_cell: Vector2i, to_cell: Vector2i) -> Vector2i:
	if from_cell.x == -999 and from_cell.y == -999:
		return Vector2i.ZERO
	return Vector2i(sign(to_cell.x - from_cell.x), sign(to_cell.y - from_cell.y))
