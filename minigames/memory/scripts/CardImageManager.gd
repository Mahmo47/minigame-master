extends RefCounted

# Consistent high-quality card faces cropped from the approved visual reference.
const CARD_FOLDER := "res://minigames/memory/assets/card_faces_hq"
const FACE_FILES := [
	"camera.png",
	"coffee.png",
	"compass.png",
	"globe.png",
	"knight.png",
	"telescope.png"
]

func load_card_textures() -> Array[Texture2D]:
	var textures: Array[Texture2D] = []
	for file_name in FACE_FILES:
		var texture: Texture2D = load(CARD_FOLDER + "/" + file_name)
		if texture != null:
			textures.append(texture)
	return textures
