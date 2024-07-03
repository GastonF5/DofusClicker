class_name DungeonManager
extends Node


static var dungeon_list = [447]

@onready var console: Console = $%Console

static var dungeon_id := -1
static var cur_room: int


static func is_dungeon(area_id: int):
	return dungeon_list.has(area_id)

static func is_in_dungeon():
	return dungeon_id >= 0


static func get_current_room_monsters():
	var dungeon_res = FileLoader.get_dungeon_resource(dungeon_id)
	if dungeon_res:
		return dungeon_res.get_room_monsters(cur_room)
	return []


func enter_dungeon(dungeon_id: int):
	var area_name = Datas._subareas[dungeon_id]._name
	console.log_info("Vous entrez dans le donjon %s" % area_name)
	var area_peeker = $%AreaPeeker
	area_peeker.clear_buttons()
	area_peeker.back_button.disabled = true
	area_peeker.set_dungeon_room_label("Donjon %s - Salle numéro 1" % area_name, true)
	DungeonManager.dungeon_id = dungeon_id
	DungeonManager.cur_room = 1


func enter_next_room():
	var dungeon_res = FileLoader.get_dungeon_resource(dungeon_id)
	var area_name = Datas._subareas[dungeon_id]._name
	var area_peeker = $%AreaPeeker
	print(cur_room)
	if cur_room == dungeon_res.get_nb_rooms():
		exit_dungeon()
		area_peeker.set_dungeon_room_label("", false)
	else:
		cur_room += 1
		area_peeker.set_dungeon_room_label("Donjon %s - Salle numéro %d" % [area_name, cur_room], true)


func exit_dungeon():
	var dungeon_res = Datas._subareas[DungeonManager.dungeon_id]
	console.log_info("Vous sortez du donjon %s" % dungeon_res._name)
	DungeonManager.dungeon_id = -1
	DungeonManager.cur_room = 0
	var area_peeker = $%AreaPeeker
	area_peeker.back_button.disabled = false
	area_peeker.set_dungeon_room_label("", false)
	area_peeker.init_subareas(Datas._areas[area_peeker.selected_area_id])
