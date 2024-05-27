class_name ItemResource
extends Resource


@export var id: int
@export var name: String
@export var type_id: int

@export var low_texture: Texture2D
@export var low_img_url: String

@export var high_texture: Texture2D
@export var high_img_url: String

@export var count: int = 1
@export var level: int
@export var item_set_id: int
@export var description: String

@export var equip_res: EquipmentResource

@export var drop_monster_ids: Array
@export var drop_rate: float


static func create(_id: int, _name: String) -> ItemResource:
	var item_res = ItemResource.new()
	item_res.id = _id
	item_res.name = _name
	return item_res


func is_resource() -> bool:
	return !equip_res


func get_texture(low: bool) -> Texture2D:
	if low or !high_texture:
		return low_texture
	else:
		return high_texture


func load_texture(api: API, low: bool):
	var texture = low_texture if low else high_texture
	if texture:
		return texture
	var url = low_img_url if low else high_img_url
	await api.await_for_request_completed(api.request(url))
	if low:
		low_texture = api.get_texture(url)
		if is_resource(): Datas._resources[id].low_texture = low_texture
		else: Datas._items[id].low_texture = low_texture
	else:
		high_texture = api.get_texture(url)
		if is_resource(): Datas._resources[id].high_texture = high_texture
		else: Datas._items[id].high_texture = high_texture
