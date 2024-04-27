class_name MonsterManager
extends Node

@onready var console: Console = $"../PlayerManager".console

var plates: Array[MonsterContainer]

static var monsters = []

signal monster_dies


static var selected_monster: Monster:
	set(value):
		if selected_monster != null:
			selected_monster.unselect()
		selected_monster = value
		if value != null:
			selected_monster.select()

var monsters_res: Array[MonsterResource] = []


func _ready():
	var monster_containers = get_tree().get_nodes_in_group("monster_container")
	monster_containers.sort_custom(func(a, b): return a.id < b.id)
	for monster_container in monster_containers:
		plates.append(monster_container)
	for i in 4:
		instantiate_monster()
	monsters = get_monsters_on_plates()
	selected_monster = monsters[0]


func get_monsters_on_plates():
	return plates.map(func(n): return null if n.get_children().size() == 0 else n.get_child(0)).filter(func(m): return m != null and Monster.is_monster(m))


func _input(event):
	if event.is_action_pressed("right"):
		select_next_monster()
	if event.is_action_pressed("left"):
		select_previous_monster()


func instantiate_monster() -> Monster:
	var empty_plates = plates.filter(func(p): return p.is_empty())
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
		for i in 4:
			instantiate_monster()
	if MonsterManager.monsters.size() != 0:
		select_next_monster()


func select_next_monster():
	if selected_monster != null:
		var index = monsters.find(selected_monster)
		selected_monster = monsters[(index + 1) % monsters.size()]
	else:
		selected_monster = monsters[0]


func select_previous_monster():
	if selected_monster != null:
		var index = monsters.find(selected_monster)
		selected_monster = monsters[(index - 1) % monsters.size()]
	else:
		selected_monster = monsters[monsters.size() - 1]


func _on_monster_selected(monster: Monster):
	selected_monster = monster
