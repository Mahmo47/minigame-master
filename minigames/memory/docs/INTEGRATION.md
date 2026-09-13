# Integrating Infinite Memory into another GDScript main menu

Use this scene in the final project:

`res://scenes/MemoryGame.tscn`

## Minimal example
```gdscript
const MEMORY_SCENE := preload("res://scenes/MemoryGame.tscn")
var memory_instance

func open_memory_game() -> void:
    memory_instance = MEMORY_SCENE.instantiate()
    add_child(memory_instance)
    memory_instance.request_exit_to_host.connect(_on_memory_closed)

func _on_memory_closed(_score: int, _matches: int, _best_combo: int) -> void:
    if memory_instance != null:
        memory_instance.queue_free()
        memory_instance = null
```
