extends Node

@export var pipe_scene : PackedScene

const GAME_ID := "flappy_bird"

var digit_textures = [
	preload("res://minigames/flappy-bird/assets/numbers/0.png"),
	preload("res://minigames/flappy-bird/assets/numbers/1.png"),
	preload("res://minigames/flappy-bird/assets/numbers/2.png"),
	preload("res://minigames/flappy-bird/assets/numbers/3.png"),
	preload("res://minigames/flappy-bird/assets/numbers/4.png"),
	preload("res://minigames/flappy-bird/assets/numbers/5.png"),
	preload("res://minigames/flappy-bird/assets/numbers/6.png"),
	preload("res://minigames/flappy-bird/assets/numbers/7.png"),
	preload("res://minigames/flappy-bird/assets/numbers/8.png"),
	preload("res://minigames/flappy-bird/assets/numbers/9.png")
]

var game_running : bool
var game_over : bool
var scroll
var score: int
var high_score: int
var scroll_speed: float
var difficulty_level: int
var screen_size: Vector2
var ground_height: float
var ground_tile_width: float
var pipes : Array
const BASE_SCROLL_SPEED: float = 240.0
const SPEED_INCREASE_PER_LEVEL: float = 36.0
const BASE_PIPE_SPACING: float = 400.0
const FIRST_PIPE_DISTANCE: float = 480.0
const PIPE_SPACING_INCREASE_PER_LEVEL: float = 0.02
const DIFFICULTY_SCORE_STEP: int = 10
const MAX_DIFFICULTY_LEVEL: int = 10
const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 200
const ORIGINAL_PLAYFIELD_SIZE := Vector2(864.0, 768.0)

func _ready():
	high_score = LocalScore.get_high_score(GAME_ID)
	get_viewport().size_changed.connect(_resize_game)
	_resize_game()
	new_game()


func _resize_game() -> void:
	screen_size = get_viewport().get_visible_rect().size

	var ground_sprite: Sprite2D = $Ground/Sprite2D
	ground_height = float(ground_sprite.texture.get_height())
	ground_tile_width = float(ground_sprite.texture.get_width()) / 2.0
	var playfield_height := maxf(1.0, screen_size.y - ground_height)

	var background: Sprite2D = $Background
	var background_size := background.texture.get_size()
	background.position = Vector2.ZERO
	background.offset = Vector2.ZERO
	background.centered = false
	background.scale = Vector2(
		screen_size.x / background_size.x,
		playfield_height / background_size.y
	)

	ground_sprite.position = Vector2.ZERO
	ground_sprite.offset = Vector2.ZERO
	ground_sprite.centered = false
	ground_sprite.region_enabled = true
	ground_sprite.region_rect = Rect2(
		Vector2.ZERO,
		Vector2(screen_size.x + ground_tile_width, ground_height)
	)
	ground_sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	$Ground.position.y = playfield_height

	var ground_collision: CollisionShape2D = $Ground/CollisionShape2D
	var ground_shape := ground_collision.shape as RectangleShape2D
	ground_shape.size = Vector2(screen_size.x + ground_tile_width * 2.0, ground_height)
	ground_collision.position = Vector2(
		(screen_size.x + ground_tile_width) / 2.0,
		ground_height / 2.0
	)

	$GetReady.offset = Vector2.ZERO
	$GetReady.position = Vector2(screen_size.x / 2.0, playfield_height / 2.0)
	$Bird.start_position = Vector2(
		screen_size.x * 100.0 / ORIGINAL_PLAYFIELD_SIZE.x,
		playfield_height * 400.0 / ORIGINAL_PLAYFIELD_SIZE.y
	)

func new_game():
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	$Ground.position.x = 0.0
	difficulty_level = 0
	_apply_difficulty()
	update_score_display()
	$GameOver.hide()
	$GetReady.show()
	get_tree().call_group("pipes", "queue_free")
	pipes.clear()
	$Bird.reset()
	_populate_initial_pipes()

func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $Bird.flying:
						$Bird.flap()
						$WingSound.play()
						check_top()
					

func start_game():
	game_running = true
	$Bird.flying = true
	$Bird.flap()
	$WingSound.play()
	$PipeTimer.start()
	$GetReady.hide()

func _process(delta):
	if game_running:
		scroll = fmod(scroll + scroll_speed * delta, ground_tile_width)
		$Ground.position.x = -scroll
		for pipe in pipes.duplicate():
			if not is_instance_valid(pipe):
				pipes.erase(pipe)
				continue
			pipe.position.x -= scroll_speed * delta
			if pipe.position.x < -100.0:
				pipes.erase(pipe)
				pipe.queue_free()

func update_score_display():
	for child in $ScoreContainer.get_children():
		child.queue_free()

	var score_string = str(score)

	for character in score_string:
		var digit = TextureRect.new()
		digit.texture = digit_textures[int(character)]
		digit.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		digit.custom_minimum_size = Vector2(32, 48)
		digit.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		$ScoreContainer.add_child(digit)
	$HighScoreLabel.text = "HIGH SCORE  %d" % maxi(high_score, score)

func _on_pipe_timer_timeout() -> void:
	generate_pipes()

func _populate_initial_pipes() -> void:
	var next_pipe_x: float = float($Bird.start_position.x) + FIRST_PIPE_DISTANCE
	var spacing: float = _current_pipe_spacing()
	while true:
		generate_pipes(next_pipe_x)
		if next_pipe_x >= screen_size.x + PIPE_DELAY:
			break
		next_pipe_x += spacing


func generate_pipes(spawn_x: float = -1.0):
	var pipe = pipe_scene.instantiate()
	if spawn_x < 0.0:
		spawn_x = screen_size.x + PIPE_DELAY
		for existing_pipe in pipes:
			if is_instance_valid(existing_pipe):
				spawn_x = maxf(spawn_x, existing_pipe.position.x + _current_pipe_spacing())
	pipe.position.x = spawn_x
	var playfield_height := screen_size.y - ground_height
	var safe_pipe_range := mini(PIPE_RANGE, maxi(0, floori(playfield_height / 2.0 - 140.0)))
	pipe.position.y = playfield_height / 2.0 + randi_range(-safe_pipe_range, safe_pipe_range)
	pipe.hit.connect(bird_hit)
	pipe.scored.connect(scored)
	add_child(pipe)
	pipes.append(pipe)

func check_top():
	if $Bird.position.y < 0:
		$DieSound.play()
		$Bird.falling = true
		stop_game()

func stop_game():
	$PipeTimer.stop()
	LocalScore.submit_score(GAME_ID, score)
	high_score = maxi(high_score, score)
	$GameOver.set_scores(score, high_score)
	update_score_display()
	$GameOver.show()
	$Bird.flying = false
	game_running = false
	game_over = true

func bird_hit():
	$HitSound.play()
	$DieSound.play()
	$Bird.falling = true
	stop_game()

func scored():
	score += 1
	$PointSound.play()
	_update_difficulty()
	update_score_display()


func _update_difficulty() -> void:
	var new_level := mini(
		floori(float(score) / DIFFICULTY_SCORE_STEP),
		MAX_DIFFICULTY_LEVEL
	)
	if new_level == difficulty_level:
		return

	difficulty_level = new_level
	_apply_difficulty()


func _apply_difficulty() -> void:
	scroll_speed = BASE_SCROLL_SPEED + SPEED_INCREASE_PER_LEVEL * difficulty_level
	$PipeTimer.wait_time = _current_pipe_spacing() / scroll_speed


func _current_pipe_spacing() -> float:
	return BASE_PIPE_SPACING * (1.0 + PIPE_SPACING_INCREASE_PER_LEVEL * difficulty_level)

func _on_ground_hit() -> void:
	$HitSound.play()
	$Bird.falling = false
	stop_game()


func _on_game_over_restart() -> void:
	#AudioManager.play_swoosh()
	new_game()

func _on_game_over_back() -> void:
	#AudioManager.play_swoosh()
	get_tree().change_scene_to_file("res://Scenes/02_game_selector.tscn")
