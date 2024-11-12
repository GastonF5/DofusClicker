extends AbstractManager


var dungeon_list = [447, 306]

var dungeon_id := -1
var cur_room: int

var dungeon_res: DungeonResource


func reset():
	dungeon_id = -1
	cur_room = 0
	super()


func is_dungeon(area_id: int):
	return dungeon_list.has(area_id)

func is_in_dungeon():
	return dungeon_id >= 0


func get_current_room_monsters():
	if dungeon_res:
		return dungeon_res.get_room_monsters(cur_room)
	return []


func use_dungeon_key() -> bool:
	if is_in_dungeon() and cur_room == 1:
		var key = Globals.inventory.find_item(dungeon_res._key_id)
		if key != null:
			if key.count > 1:
				key.count -= 1
			else:
				Globals.inventory.remove_items([key])
			return true
		return false
	return true


func enter_dungeon(id: int = dungeon_id):
	var area_name = Datas._subareas[id]._name
	var room_name = "Donjon %s - Salle numéro 1" % area_name
	dungeon_res = FileLoader.get_dungeon_resource(id)
	MonsterManager.set_start_fight_button_text(true)
	Globals.console.log_info("Vous entrez dans le donjon %s" % area_name)
	DungeonManager.dungeon_id = id
	DungeonManager.cur_room = 1
	Globals.area_peeker.enter_subarea(FileLoader.get_dungeon_resource(id).get_room(1), room_name, dungeon_res._rooms)


func enter_next_room():
	var area_name = Datas._subareas[dungeon_id]._name
	log.info("Entered in room %d" % cur_room)
	if cur_room == dungeon_res.get_nb_rooms():
		exit_dungeon()
	else:
		cur_room += 1
		MonsterManager.set_start_fight_button_text()
		Globals.area_peeker.set_area_label("Donjon %s - Salle numéro %d" % [area_name, cur_room], true)


func exit_dungeon():
	dungeon_res = null
	Globals.area_peeker.leave_subarea()
	dungeon_id = -1
	cur_room = 0
