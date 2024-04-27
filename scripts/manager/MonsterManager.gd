class_name MonsterManager
extends Node

@onready var console: Console = $"../PlayerManager".console

static var monsters = []

signal monster_dies

var monsters_res: Array[MonsterResource] = []


func _ready():
	for i in 2:
		instantiate_monster()
	monsters = get_monsters_on_plates()


func get_monsters_on_plates():
	return PlayerManager.plates.map(func(p): return p.get_entity()).filter(Monster.is_monster)


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
	var player_manager = $"/root/Main/PlayerManager"
	player_manager.xp_bar.gain_xp(xp)
	player_manager.kamas_label.text = str(int(player_manager.kamas_label.text) + randi_range(5, 10))
	monsters = get_monsters_on_plates()
	if monsters.filter(func(m): return !m.dying).is_empty():
		for monster in monsters:
			monster.queue_free()
		monsters = []
		for i in 2:
			instantiate_monster()
		monsters = get_monsters_on_plates()


func _on_monster_selected(monster: Monster):
	PlayerManager.selected_plate = monster.get_parent()
