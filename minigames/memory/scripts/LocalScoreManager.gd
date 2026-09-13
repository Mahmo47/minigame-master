extends RefCounted

const SAVE_PATH: String = "user://minigames/memory/memory_scores.json"

func _load() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {"players": {}}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {"players": {}}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {"players": {}}

func _save(data: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data, "\t"))

func get_personal_best(player_name: String) -> int:
	var data: Dictionary = _load()
	var players: Dictionary = data.get("players", {})
	var key: String = _safe_name(player_name)
	if players.has(key):
		var entry: Dictionary = players[key]
		return int(entry.get("best_score", 0))
	return 0

func save_result(player_name: String, score: int, matches: int, best_combo: int) -> bool:
	var data: Dictionary = _load()
	var players: Dictionary = data.get("players", {})
	var key: String = _safe_name(player_name)
	var old_score: int = 0
	if players.has(key):
		var old_entry: Dictionary = players[key]
		old_score = int(old_entry.get("best_score", 0))
	var is_record: bool = score > old_score
	if is_record:
		players[key] = {
			"best_score": score,
			"matches": matches,
			"best_combo": best_combo
		}
		data["players"] = players
		_save(data)
	return is_record

func _safe_name(player_name: String) -> String:
	var value: String = player_name.strip_edges()
	if value == "":
		return "Player"
	return value
