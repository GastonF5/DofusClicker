class_name AreaResource
extends Resource


@export var _id: int
@export var _name: String
@export var _super_area_id: int
@export var _monster_ids: Array
@export var _level: int


static func create(id: int, name: String, super_area_id := -1) -> AreaResource:
	var area = AreaResource.new()
	area._id = id
	area._name = name
	area._super_area_id = super_area_id
	area._monster_ids = []
	return area


func has_monsters() -> bool:
	return !_monster_ids.is_empty()


func is_subarea() -> bool:
	return _super_area_id != -1


func get_subareas() -> Array:
	return Datas._subareas.values().filter(func(sa): return sa._super_area_id == _id)


func get_level() -> int:
	if _level:
		return _level
	return 0
