class_name MonsterManager
extends Node

@onready var console: Console = $%Console
var start_fight_button: Button
var auto_start_fight_checkbox: CheckBox

var loading = false

static var monsters: Array[Entity] = []
static var end_fight_callable: Callable

signal monster_dies

static var monsters_res := []


func initialize():
	end_fight_callable = end_fight
	start_fight_button = $%StartFightButton
	auto_start_fight_checkbox = $%AutoStartFight.get_node("HBC/CheckBox")
	start_fight_button.button_up.connect(start_fight)
	start_fight_button.disabled = true


func start_fight():
	GameManager.in_fight = true
	console.log_info("Le combat commence")
	$%AreaPeeker.back_button.disabled = true
	$%PlayerManager.spell_bar.set_weapon_pb_ready(true)
	if DungeonManager.is_in_dungeon():
		for monster_res in DungeonManager.get_current_room_monsters():
			instantiate_monster(monster_res)
		#$%DungeonManager.exit_dungeon()
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
		if monsters.filter(func(m): return !m.dying).is_empty():
			console.log_info("Combat terminé")
		$%AreaPeeker.back_button.disabled = false
		$%PlayerManager.spell_bar.set_weapon_pb_ready(false)
		if DungeonManager.is_in_dungeon():
			$%DungeonManager.enter_next_room()
		for monster in monsters:
			monster.queue_free()
		monsters.assign([])
		start_fight_button.disabled = false
		if auto_start_fight_checkbox.button_pressed:
			start_fight()
		$%StatsManager.reset_caracteristiques()
		for timer in SpellsService.tnode.get_children():
			timer.queue_free()
		$%PlayerManager.spell_bar.reset_spells()


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
	var player_manager = get_tree().current_scene.get_node("%PlayerManager")
	player_manager.xp_bar.gain_xp(xp)
	monsters.assign(get_monsters_on_plates())
	if monsters.filter(func(m): return !m.dying).is_empty():
		end_fight()


func clear_monsters():
	for monster in monsters:
		monster.get_parent().remove_child(monster)
		monster.queue_free()
	monsters.clear()


func _on_monster_selected(monster: Monster):
	PlayerManager.selected_plate = monster.get_parent()
