extends Node

@export var pipe_scene : PackedScene

var digit_textures = [
	preload("res://assets/numbers/0.png"),
	preload("res://assets/numbers/1.png"),
	preload("res://assets/numbers/2.png"),
	preload("res://assets/numbers/3.png"),
	preload("res://assets/numbers/4.png"),
	preload("res://assets/numbers/5.png"),
	preload("res://assets/numbers/6.png"),
	preload("res://assets/numbers/7.png"),
	preload("res://assets/numbers/8.png"),
	preload("res://assets/numbers/9.png")
]

var game_running : bool
var game_over : bool
var scroll
var score
const SCROLL_SPEED : int = 2
var screen_size : Vector2i
var ground_height : int
var pipes : Array
const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 200

func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()

func new_game():
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	update_score_display()
	$GameOver.hide()
	$GetReady.show()
	get_tree().call_group("pipes", "queue_free")
	pipes.clear()
	generate_pipes()
	$Bird.reset()

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
		scroll += SCROLL_SPEED
		if scroll >= screen_size.x:
			scroll = 0
		$Ground.position.x = -scroll
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED

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

func _on_pipe_timer_timeout() -> void:
	generate_pipes()

func generate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
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
	update_score_display()

func _on_ground_hit() -> void:
	$HitSound.play()
	$Bird.falling = false
	stop_game()


func _on_game_over_restart() -> void:
	AudioManager.play_swoosh()
	new_game()

func _on_game_over_back() -> void:
	AudioManager.play_swoosh()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
