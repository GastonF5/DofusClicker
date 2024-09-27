extends AbstractManager

var console: Console
var start_fight_button: Button
var auto_start_fight_checkbox: CheckBox

var loading := false

var monsters: Array[Entity] = []
var end_fight_callable: Callable

signal monster_dies

var monsters_res := []

var xp_to_gain := 0

var plates: Array[EntityContainer]


func reset():
	console = null
	start_fight_button = null
	auto_start_fight_checkbox = null
	loading = false
	monsters.clear()
	monsters_res.clear()
	xp_to_gain = 0
	plates.clear()
	super()


func initialize():
	console = Globals.console
	end_fight_callable = end_fight
	start_fight_button = Globals.game.get_node("%StartFightButton")
	auto_start_fight_checkbox = Globals.game.get_node("%AutoStartFight").get_node("HBC/CheckBox")
	start_fight_button.button_up.connect(start_fight)
	start_fight_button.disabled = true
	
	var entity_containers = get_tree().get_nodes_in_group("monster_container")
	entity_containers.sort_custom(func(a, b): return a.id < b.id)
	for entity_container in entity_containers:
		plates.append(entity_container)
	PlayerManager.selected_plate = plates[0]
	
	super()


func start_fight():
	if DungeonManager.use_dungeon_key():
		GameManager.in_fight = true
		GameManager.start_fight.emit()
		PlayerManager.static_max_hp = PlayerManager.max_hp
		for button in Globals.game.get_node("%HeaderButtons").get_children():
			button.disabled = true
		console.log_info("Le combat commence")
		console.output.add_separator()
		Globals.area_peeker.back_button.disabled = true
		Globals.spell_bar.set_weapon_pb_ready(true)
		Globals.spell_bar.reset_spells()
		StatsManager.check_modifiable_on_caracteristiques()
		if DungeonManager.is_in_dungeon():
			for monster_res in DungeonManager.get_current_room_monsters():
				instantiate_monster(monster_res)
			start_fight_button.disabled = true
		else:
			if !monsters_res.is_empty():
				for i in 2:
					instantiate_monster()
				monsters.assign(get_monsters_on_plates())
				start_fight_button.disabled = true
			else:
				console.log_error("No monsters in area")
	else:
		Globals.console.log_error("Vous ne possédez pas la clef du donjon.")
		start_fight_button.disabled = true


func end_fight(lose := false):
	if GameManager.in_fight:
		GameManager.in_fight = false
		GameManager.end_fight.emit()
		PlayerManager.max_hp = PlayerManager.static_max_hp
		PlayerManager.static_max_hp = 0
		for button in Globals.game.get_node("%HeaderButtons").get_children():
			button.disabled = false
		if monsters.filter(func(m): return !m.dying).is_empty():
			console.log_info("Combat terminé")
		Globals.xp_bar.gain_xp(xp_to_gain)
		console.log_info("Vous avez gagné %d d'expérience" % xp_to_gain)
		xp_to_gain = 0
		Globals.area_peeker.back_button.disabled = false
		Globals.spell_bar.set_weapon_pb_ready(false)
		Globals.spell_bar.reset_spells()
		if DungeonManager.is_in_dungeon():
			if !lose:
				DungeonManager.enter_next_room()
			else:
				DungeonManager.enter_dungeon()
		clear_monsters()
		check_dungeon_key()
		if auto_start_fight_checkbox.button_pressed:
			start_fight()
		StatsManager.reset_caracteristiques()
		StatsManager.check_modifiable_on_caracteristiques()
		SpellsService.on_fight_end()


func check_dungeon_key():
	var key
	var in_dungeon_first_room = DungeonManager.is_in_dungeon() and DungeonManager.cur_room == 1
	if in_dungeon_first_room:
		key = Globals.inventory.find_item(DungeonManager.dungeon_res._key_id)
	start_fight_button.disabled = key == null and in_dungeon_first_room


func get_monsters_on_plates():
	return plates.map(func(p): return p.get_entity()).filter(Entity.is_monster)


func instantiate_monster(monster_res: MonsterResource = null) -> Monster:
	var empty_plates = plates.filter(func(plate: EntityContainer): return plate.is_empty() and plate.id == 1)
	if empty_plates.size() == 0:
		console.log_error("Impossible d'instantier le monstre, aucun emplacement n'est disponible.")
		return null
	if !monster_res:
		monster_res = monsters_res[randi_range(0, MonsterManager.monsters_res.size() - 1)]
	var monster = Monster.instantiate(monster_res, empty_plates[randi_range(0, empty_plates.size() - 1)])
	monster.dies.connect(_on_monster_dies)
	monster.clicked.connect(_on_monster_selected)
	monsters.append(monster)
	return monster


func _on_monster_dies(xp: int):
	var multiplicateur := (PlayerManager.player_entity.get_sagesse() + 100) / 100.0
	xp_to_gain += int(xp * multiplicateur)
	monsters.assign(get_monsters_on_plates())
	if monsters.filter(func(m): return !m.dying).is_empty():
		end_fight()


func clear_monsters():
	for monster in monsters:
		if monster.get_parent():
			monster.get_parent().remove_child(monster)
		monster.queue_free()
	monsters.clear()


func _on_monster_selected(monster: Monster):
	PlayerManager.selected_plate = monster.get_parent()


func set_start_fight_button_loading(is_loading: bool):
	start_fight_button.get_child(0).visible = is_loading


func set_start_fight_button_text(first_room_of_dungeon := false):
	if first_room_of_dungeon:
		start_fight_button.text = "Utiliser la clef"
	else:
		start_fight_button.text = "Lancer le combat"


#region plates
func get_distance_plates():
	return plates.filter(func(p): return p.is_distance())

func get_melee_plates():
	return plates.filter(func(p): return p.is_melee())
#endregion
