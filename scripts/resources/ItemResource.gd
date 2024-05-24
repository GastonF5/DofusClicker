class_name ItemResource
extends Resource


@export var id: int
@export var name: String

@export var low_texture: Texture2D
@export var low_img_url: String

@export var high_texture: Texture2D
@export var high_img_url: String

@export var count: int = 1
@export var niveau: int
@export var panoplie: String
@export var description: String

@export var equip_res: EquipmentResource

@export var drop_rate: float

@export var type: String
@export var super_type: String


static func create(_id: int, _name: String) -> ItemResource:
	var item_res = ItemResource.new()
	item_res.id = _id
	item_res.name = _name
	return item_res
