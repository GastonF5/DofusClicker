class_name MonsterResource
extends Resource

const black_list = [494]

@export var id: int
@export var name: String
@export var race_id: int
@export var race: String

@export var texture: Texture2D
@export var image_url: String

@export var boss: bool
@export var archimonstre: bool
@export var corresponding_archimonstre_id: int
@export var corresponding_non_archimonstre_id: int

@export var grades: Array[GradeResource]

@export var spells: Array
@export var drops: Array[DropResource]

@export var areas: Array

var node_texture: TextureRect

func get_id():
	return id

func load_texture():
	var asset = FileLoader.get_asset("monsters/images/", id)
	if asset:
		texture = ImageTexture.create_from_image(asset.get_image())
		return texture
	#console.log_info("Loading texture...")
	await API.await_for_request_completed(await API.request(image_url))
	texture = API.get_texture(image_url)
	FileSaver.save_monster_asset(texture, id)
	#console.log_info("Texture of %s loaded" % name)


func black_listed():
	return black_list.has(id)


func get_areas():
	var available_areas = []
	for area_id in areas:
		if Datas._subareas.has(area_id):
			if Datas._subareas[area_id].white_listed():
				available_areas.append(Datas._subareas[area_id])
	return available_areas
