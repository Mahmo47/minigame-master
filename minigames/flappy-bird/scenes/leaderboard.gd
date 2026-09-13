extends Control

const LOCAL_ROW_COLOR := Color(1.0, 0.82, 0.25)
const DEFAULT_ROW_COLOR := Color.WHITE


func _ready() -> void:
	_populate_leaderboard()


func _populate_leaderboard() -> void:
	var entries := ScoreManager.get_leaderboard_entries()
	entries.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
		return int(first.get("score", 0)) > int(second.get("score", 0))
	)

	for index in entries.size():
		var entry: Dictionary = entries[index]
		var entry_uid := str(entry.get("uid", ""))
		var display_name := ScoreManager.get_display_name(
			entry_uid,
			str(entry.get("nickname", "Player"))
		)
		var is_local_player := entry_uid == ScoreManager.player_uid
		_add_row(index + 1, display_name, int(entry.get("score", 0)), is_local_player)


func _add_row(rank: int, display_name: String, score: int, is_local_player: bool) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = 58
	row.add_theme_constant_override("separation", 12)
	$LeaderboardPanel/Margin/Content/Rows.add_child(row)

	var color := LOCAL_ROW_COLOR if is_local_player else DEFAULT_ROW_COLOR
	row.add_child(_create_cell(str(rank), 90, HORIZONTAL_ALIGNMENT_CENTER, color))
	row.add_child(_create_cell(display_name, 300, HORIZONTAL_ALIGNMENT_LEFT, color))
	row.add_child(_create_cell(str(score), 170, HORIZONTAL_ALIGNMENT_RIGHT, color))


func _create_cell(text: String, width: float, alignment: HorizontalAlignment, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size.x = width
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 24)
	return label


func _on_back_pressed() -> void:
	AudioManager.play_swoosh()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
