class_name DungeonResource
extends Resource


@export var _id: int
@export var _key_id: int
@export var _rooms: Array[RoomResource]


func get_nb_rooms():
	return _rooms.size()


func get_room_monsters(room_number: int):
	return _rooms[room_number - 1].get_monsters()


func get_room(num: int) -> RoomResource:
	return _rooms[num - 1]


func get_id():
	return _id


func get_key() -> ItemResource:
	if Datas._keys.has(_key_id):
		return Datas._keys[_key_id]
	push_error("Le donjon d'id %d ne contient pas la bonne clé" % _id)
	return null
