extends AbstractManager


var dungeon_list = [447]

var dungeon_id := -1
var cur_room: int


func reset():
	dungeon_id = -1
	cur_room = 0
	super()


func is_dungeon(area_id: int):
	return dungeon_list.has(area_id)

func is_in_dungeon():
	return dungeon_id >= 0


func get_current_room_monsters():
	var dungeon_res = FileLoader.get_dungeon_resource(dungeon_id)
	if dungeon_res:
		return dungeon_res.get_room_monsters(cur_room)
	return []


func enter_dungeon(id: int):
	var area_name = Datas._subareas[id]._name
	var room_name = "Donjon %s - Salle numéro 1" % area_name
	Globals.console.log_info("Vous entrez dans le donjon %s" % area_name)
	Globals.area_peeker.enter_subarea(FileLoader.get_dungeon_resource(id).get_room(1), room_name)
	DungeonManager.dungeon_id = id
	DungeonManager.cur_room = 1


func enter_next_room():
	var dungeon_res = FileLoader.get_dungeon_resource(dungeon_id)
	var area_name = Datas._subareas[dungeon_id]._name
	print(cur_room)
	if cur_room == dungeon_res.get_nb_rooms():
		exit_dungeon()
	else:
		cur_room += 1
		Globals.area_peeker.set_area_label("Donjon %s - Salle numéro %d" % [area_name, cur_room], true)


func exit_dungeon():
	var dungeon_res = Datas._subareas[DungeonManager.dungeon_id]
	Globals.console.log_info("Vous sortez du donjon %s" % dungeon_res._name)
	DungeonManager.dungeon_id = -1
	DungeonManager.cur_room = 0
	Globals.area_peeker.leave_subarea()
