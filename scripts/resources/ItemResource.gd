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

@export var equip_res: EquipmentResource

@export var drop_monster_ids: Array
@export var drop_rate: float

func get_id():
	return id

static func create(_id: int, _name: String) -> ItemResource:
	var item_res = ItemResource.new()
	item_res.id = _id
	item_res.name = _name
	return item_res


func is_resource() -> bool:
	return !equip_res and type_id != 84


func is_key() -> bool:
	return type_id == 84


func get_texture(low: bool) -> Texture2D:
	if low or !high_texture:
		return low_texture
	else:
		return high_texture


func load_texture(low: bool):
	var texture = low_texture if low else high_texture
	if texture:
		return texture
	var url = low_img_url if low else high_img_url
	await API.await_for_request_completed(await API.request(url))
	if low:
		low_texture = API.get_texture(url)
		if is_resource(): Datas._resources[id].low_texture = low_texture
		elif is_key(): Datas._keys[id].low_texture = low_texture
		else: Datas._items[id].low_texture = low_texture
	else:
		high_texture = API.get_texture(url)
		if is_resource(): Datas._resources[id].high_texture = high_texture
		elif is_key(): Datas._keys[id].high_texture = high_texture
		else: Datas._items[id].high_texture = high_texture


func get_monsters():
	if drop_monster_ids.is_empty():
		return []
	return drop_monster_ids\
	.map(func(mid): return Datas._monsters[mid] if Datas._monsters.has(mid) else null)\
	.filter(func(r): return r)


func get_drop_areas() -> String:
	var drop_areas = ""
	for monster in get_monsters():
		for subarea in monster.get_areas():
			if !drop_areas.contains(subarea._name):
				drop_areas += ", " + subarea._name
	return drop_areas.erase(0, 2)


func load_save(data: Dictionary):
	count = data["count"]
	if equip_res:
		equip_res.load_save(data["equip_res"])


static func map(data: Dictionary) -> ItemResource:
	var resource = ItemResource.new()
	resource.name = data["name"]["fr"]
	resource.id = data["id"] as int
	resource.type_id = data["typeId"] as int
	resource.low_img_url = data["imgset"][0]["url"]
	resource.high_img_url = data["imgset"][1]["url"]
	resource.level = data["level"]
	if Datas._types.has(resource.type_id):
		resource.equip_res = EquipmentResource.map(data)
	resource.drop_monster_ids = data["dropMonsterIds"].map(func(i): return i as int)
	resource.drop_monster_ids.append_array(Datas.find_drop_exception_by_object_id(resource.id))
	return resource
