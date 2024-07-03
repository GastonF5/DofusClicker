class_name DungeonResource
extends Resource


@export var _id: int
@export var _rooms: Array[RoomResource]


func get_nb_rooms():
	return _rooms.size()


func get_room_monsters(room_number: int) -> Array[MonsterResource]:
	return _rooms[room_number].get_monster_resources()
