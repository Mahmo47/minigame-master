extends RefCounted

const USER_CARD_DIR := "user://memory_cards_professional"
const DEFAULT_CARD_DIR := "res://assets/cards"
const DEFAULT_CARD_FILES := [
	"compass.png",
	"camera.png",
	"leaf.png",
	"lighthouse.png",
	"mountain.png",
	"globe.png",
	"clock.png",
	"book.png",
	"desk_lamp.png",
	"chess_knight.png",
	"feather.png",
	"telescope.png",
	"tree.png",
	"seashell.png",
	"bicycle.png",
	"paper_plane.png",
	"coffee_cup.png",
	"umbrella.png",
	"sailboat.png",
	"key.png"
]

func ensure_user_card_folder() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(USER_CARD_DIR))
	for file_name in DEFAULT_CARD_FILES:
		var destination: String = USER_CARD_DIR.path_join(file_name)
		if FileAccess.file_exists(destination):
			continue
		var texture: Texture2D = load(DEFAULT_CARD_DIR.path_join(file_name)) as Texture2D
		if texture == null:
			continue
		var image: Image = texture.get_image()
		if image != null and not image.is_empty():
			image.save_png(destination)

func load_card_textures() -> Array[Texture2D]:
	ensure_user_card_folder()
	var file_names: Array[String] = []
	var directory: DirAccess = DirAccess.open(USER_CARD_DIR)
	if directory == null:
		return []

	directory.list_dir_begin()
	var file_name: String = directory.get_next()
	while file_name != "":
		if not directory.current_is_dir():
			var extension: String = file_name.get_extension().to_lower()
			if extension in ["png", "jpg", "jpeg"]:
				file_names.append(file_name)
		file_name = directory.get_next()
	directory.list_dir_end()
	file_names.sort()

	var textures: Array[Texture2D] = []
	for card_file in file_names:
		var image: Image = Image.new()
		var load_error: Error = image.load(USER_CARD_DIR.path_join(card_file))
		if load_error != OK or image.is_empty():
			continue
		_resize_if_needed(image)
		textures.append(ImageTexture.create_from_image(image))
	return textures

func get_card_folder_path() -> String:
	ensure_user_card_folder()
	return ProjectSettings.globalize_path(USER_CARD_DIR)

func open_card_folder() -> void:
	var folder_path: String = get_card_folder_path()
	OS.shell_open(folder_path)

func _resize_if_needed(image: Image) -> void:
	const MAX_WIDTH := 1200
	const MAX_HEIGHT := 1600
	if image.get_width() <= MAX_WIDTH and image.get_height() <= MAX_HEIGHT:
		return
	var width_ratio: float = float(MAX_WIDTH) / float(image.get_width())
	var height_ratio: float = float(MAX_HEIGHT) / float(image.get_height())
	var scale_factor: float = minf(width_ratio, height_ratio)
	var new_width: int = maxi(1, int(round(image.get_width() * scale_factor)))
	var new_height: int = maxi(1, int(round(image.get_height() * scale_factor)))
	image.resize(new_width, new_height, Image.INTERPOLATE_LANCZOS)
