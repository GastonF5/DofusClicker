class_name ItemResource
extends ThreadedLoadingTexture

@export var id: int
@export var name: String
@export var type_id: int

@export var img_url: String

@export var count: int = 1
@export var level: int
@export var item_set_id: int

@export var equip_res: EquipmentResource

@export var drop_monster_ids: Array
@export var drop_rate: float

@export var consommable: ConsommableResource

func get_id():
	return id


func is_resource() -> bool:
	return !equip_res and !consommable and type_id != 84

func is_key() -> bool:
	return type_id == 84

func is_equipment() -> bool:
	return equip_res != null

func is_consommable() -> bool:
	return consommable != null


func get_data_type() -> Datas.DataType:
	if is_resource():
		return Datas.DataType.RESOURCE
	elif is_key():
		return Datas.DataType.KEY
	else:
		return Datas.DataType.ITEM


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


func is_trouvable():
	return get_drop_areas() != ""


func load_save(data: Dictionary):
	count = data["count"]
	if equip_res:
		equip_res.load_save(data["equip_res"])


static func map(data: Dictionary) -> ItemResource:
	var resource = ItemResource.new()
	resource.name = data["name"]["fr"]
	resource.id = data["id"] as int
	resource.type_id = data["typeId"] as int
	resource.img_url = data["imgset"][1]["url"]
	resource.level = data["level"]
	if Datas._types.has(resource.type_id):
		resource.equip_res = EquipmentResource.map(data)
	resource.drop_monster_ids = data["dropMonsterIds"].map(func(i): return i as int)
	resource.drop_monster_ids.append_array(Datas.find_drop_exception_by_object_id(resource.id))
	return resource


func load_texture() -> void:
	if !texture:
		var success = _load("items/images/", id)
		if !success:
			if Globals.debug:
				await API.await_for_request_completed(await API.request(img_url))
				texture = API.get_texture(img_url)
				FileSaver.save_item_asset(texture, id)
			else:
				log.error("Failed to load item texture (id: %d)" % id)


func _duplicate() -> ItemResource:
	var new_resource = self.duplicate(true)
	if is_equipment():
		new_resource.equip_res = new_resource.equip_res._duplicate()
	return new_resource
