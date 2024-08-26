class_name DungeonResource
extends Resource


@export var _id: int
@export var _rooms: Array[RoomResource]


func get_nb_rooms():
	return _rooms.size()


func get_room_monsters(room_number: int):
	return _rooms[room_number - 1].get_monsters()


func get_room(num: int) -> RoomResource:
	return _rooms[num - 1]


func get_id():
	return _id
