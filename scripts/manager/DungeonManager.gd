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


static func get_current_room_monsters() -> Array[MonsterResource]:
	var monsters = Datas._subareas[DungeonManager.dungeon_id].get_monsters()
	return []


func enter_dungeon(dungeon_id: int):
	var dungeon_res = Datas._subareas[dungeon_id]
	console.log_info("Vous entrez dans le donjon %s" % dungeon_res._name)
	$%AreaPeeker.clear_buttons()
	$%AreaPeeker.back_button.disabled = true
	DungeonManager.dungeon_id = dungeon_id
	DungeonManager.cur_room = 1


func exit_dungeon():
	var dungeon_res = Datas._subareas[DungeonManager.dungeon_id]
	console.log_info("Vous sortez du donjon %s" % dungeon_res._name)
	DungeonManager.dungeon_id = -1
	DungeonManager.cur_room = 0
	$%AreaPeeker.back_button.disabled = false
	var area_peeker: AreaPeeker = $%AreaPeeker
	area_peeker.init_subareas(Datas._areas[area_peeker.selected_area_id])
