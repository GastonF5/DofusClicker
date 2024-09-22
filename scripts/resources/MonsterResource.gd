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

@export var favorite_area: int
@export var areas: Array

var node_texture: TextureRect


func load_texture():
	#console.log_info("Loading texture...")
	await API.await_for_request_completed(await API.request(image_url))
	texture = API.get_texture(image_url)
	Datas._monsters[id].texture = texture
	#console.log_info("Texture of %s loaded" % name)


func black_listed():
	return black_list.has(id)
