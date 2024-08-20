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


func reset():
	console = null
	start_fight_button = null
	auto_start_fight_checkbox = null
	loading = false
	monsters.clear()
	monsters_res.clear()
	xp_to_gain = 0
	super()


func initialize():
	console = Globals.console
	end_fight_callable = end_fight
	start_fight_button = get_tree().current_scene.get_node("%StartFightButton")
	auto_start_fight_checkbox = get_tree().current_scene.get_node("%AutoStartFight").get_node("HBC/CheckBox")
	start_fight_button.button_up.connect(start_fight)
	start_fight_button.disabled = true
	super()


func start_fight():
	GameManager.in_fight = true
	for button in get_tree().current_scene.get_node("%HeaderButtons").get_children():
		button.disabled = true
	console.log_info("Le combat commence")
	Globals.area_peeker.back_button.disabled = true
	Globals.spell_bar.set_weapon_pb_ready(true)
	StatsManager.check_modifiable_on_caracteristiques()
	if DungeonManager.is_in_dungeon():
		for monster_res in DungeonManager.get_current_room_monsters():
			instantiate_monster(monster_res)
		#%DungeonManager.exit_dungeon()
		start_fight_button.disabled = true
	else:
		if !monsters_res.is_empty():
			for i in 2:
				instantiate_monster()
			monsters.assign(get_monsters_on_plates())
			start_fight_button.disabled = true
		else:
			console.log_error("No monsters in area")


func end_fight():
	if GameManager.in_fight:
		GameManager.in_fight = false
		for button in get_tree().current_scene.get_node("%HeaderButtons").get_children():
			button.disabled = false
		if monsters.filter(func(m): return !m.dying).is_empty():
			console.log_info("Combat terminé")
		Globals.xp_bar.gain_xp(xp_to_gain)
		console.log_info("Vous avez gagné %d d'expérience" % xp_to_gain)
		xp_to_gain = 0
		Globals.area_peeker.back_button.disabled = false
		Globals.spell_bar.set_weapon_pb_ready(false)
		if DungeonManager.is_in_dungeon():
			DungeonManager.enter_next_room()
		clear_monsters()
		start_fight_button.disabled = false
		if auto_start_fight_checkbox.button_pressed:
			start_fight()
		StatsManager.reset_caracteristiques()
		for timer in SpellsService.tnode.get_children():
			timer.queue_free()
		Globals.spell_bar.reset_spells()
		StatsManager.check_modifiable_on_caracteristiques()


func get_monsters_on_plates():
	return PlayerManager.plates.map(func(p): return p.get_entity()).filter(Entity.is_monster)


func instantiate_monster(monster_res: MonsterResource = null) -> Monster:
	var empty_plates = PlayerManager.plates.filter(func(plate: EntityContainer): return plate.is_empty())
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
