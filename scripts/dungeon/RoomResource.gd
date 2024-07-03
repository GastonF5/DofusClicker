class_name RoomResource
extends Resource


@export var _number: int
@export var _monster_ids: Array[int]


func get_monster_resources():
	return _monster_ids.map(func(id): return Datas._monsters[id])
