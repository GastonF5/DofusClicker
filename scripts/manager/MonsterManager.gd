class_name MonsterManager
extends Node

@onready var console: Console = $%Console
var start_fight_button: Button
var auto_start_fight_checkbox: CheckBox

var loading = false

static var monsters: Array[Entity] = []

signal monster_dies

static var monsters_res := []


func initialize():
	start_fight_button = $%StartFightButton
	auto_start_fight_checkbox = $%AutoStartFight.get_node("HBC/CheckBox")
	start_fight_button.button_up.connect(start_fight)
	start_fight_button.disabled = true
	$%AreaPeeker.subarea_selected.connect(_on_area_changed)


func start_fight():
	if !monsters_res.is_empty():
		for i in 2:
			instantiate_monster()
		monsters.assign(get_monsters_on_plates())
		start_fight_button.disabled = true
	else:
		console.log_error("No monsters in area")


func end_fight():
	for monster in monsters:
		monster.queue_free()
	monsters.assign([])
	start_fight_button.disabled = false
	if auto_start_fight_checkbox.button_pressed: start_fight()
	var player_manager: PlayerManager = $%PlayerManager
	player_manager.pa_bar.reset()
	player_manager.pm_bar.reset()


func get_monsters_on_plates():
	return PlayerManager.plates.map(func(p): return p.get_entity()).filter(Entity.is_monster)


func instantiate_monster() -> Monster:
	var empty_plates = PlayerManager.plates.filter(func(plate: EntityContainer): return plate.is_empty())
	if empty_plates.size() == 0:
		console.log_error("Impossible d'instantier le monstre, aucun emplacement n'est disponible.")
		return null
	var monster = Monster.instantiate(empty_plates[randi_range(0, empty_plates.size() - 1)])
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


func _on_monster_selected(monster: Monster):
	PlayerManager.selected_plate = monster.get_parent()


func _on_area_changed(monster_resources: Array[MonsterResource]):
	monsters_res = monster_resources
	start_fight_button.disabled = false
