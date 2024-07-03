class_name DungeonResource
extends Resource


@export var _id: int
@export var _rooms: Array[RoomResource]


func get_nb_rooms():
	return _rooms.size()


func get_room_monsters(room_number: int):
	return _rooms[room_number - 1].get_monster_resources()
