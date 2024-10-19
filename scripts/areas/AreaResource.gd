class_name AreaResource
extends Resource


@export var _id: int
@export var _name: String
@export var _super_area_id: int
@export var _monster_ids: Array
@export var _level: int


static func create(id: int, name: String, super_area_id := -1, level := -1) -> AreaResource:
	var area = AreaResource.new()
	area._id = id
	area._name = name
	area._super_area_id = super_area_id
	area._monster_ids = []
	area._level = level
	return area


func get_id() -> int:
	return _id


func get_area_name():
	return _name


func has_monsters() -> bool:
	return !get_monsters().is_empty()


func _get_all_monsters() -> Array:
	if is_subarea():
		var monsters = Datas._monsters.values()
		return monsters.filter(func(m): return _monster_ids.has(m.id) and !m.black_listed())
	return get_subareas().reduce(func(accum, sa):
		return accum + sa.get_monsters(), [])


func get_monsters() -> Array:
	return _get_all_monsters().filter(func(m): return !MonsterResource.is_protecteur(m))


func get_protecteurs() -> Array:
	return _get_all_monsters().filter(MonsterResource.is_protecteur)


func is_subarea() -> bool:
	return _super_area_id != -1


func get_subareas(level := 200) -> Array:
	var subareas = Datas._subareas.values().filter(func(sa): return sa._super_area_id == _id)
	subareas = subareas.filter(func(sa): return sa.white_listed())
	subareas.sort_custom(sort_by_level)
	return subareas.filter(func(sa): return sa.get_level() <= level)


func get_level() -> int:
	if _level != -1:
		return _level
	return get_subareas().reduce(func(accum, subarea): return min(accum, subarea._level), 200)


static func sort_by_level(a: AreaResource, b: AreaResource):
	return a.get_level() <= b.get_level()


func white_listed(cur_lvl := 200) -> bool:
	if is_subarea():
		return Globals.area_white_list.has(_id)
	return get_subareas(cur_lvl).any(func(sa): return sa.white_listed())
