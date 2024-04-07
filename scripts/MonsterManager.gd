class_name MonsterManager
extends Node


const monster_scene = preload("res://scenes/monster.tscn")

@export var monster_container: HBoxContainer

static var monsters = []

signal monster_dies


static var selected_monster: Monster:
	set(value):
		if selected_monster != null:
			selected_monster.selected_arrow.visible = false
		selected_monster = value
		if value != null:
			selected_monster.selected_arrow.visible = true

var monsters_res: Array[MonsterResource] = []


func _ready():
	for i in 4:
		instantiate_monster()
	monsters = monster_container.get_children()
	selected_monster = monsters[0]


func _input(event):
	if event.is_action_pressed("right"):
		select_next_monster()
	if event.is_action_pressed("left"):
		select_previous_monster()


func instantiate_monster() -> Monster:
	var monster = Monster.instantiate(monster_container)
	monster.dies.connect(_on_monster_dies)
	monster.clicked.connect(_on_monster_selected)
	monsters.append(monster)
	return monster


func _on_monster_dies(xp: int):
	var player_manager = $"/root/Main/PlayerManager"
	player_manager.xp_bar.gain_xp(xp)
	player_manager.kamas_label.text = str(int(player_manager.kamas_label.text) + randi_range(5, 10))
	monsters = monster_container.get_children()
	if monsters.size() == 0:
		for i in 4:
			instantiate_monster()
	else:
		selected_monster = monsters[0]


func select_next_monster():
	var index = monsters.find(selected_monster)
	selected_monster = monsters[(index + 1) % monsters.size()]


func select_previous_monster():
	var index = monsters.find(selected_monster)
	selected_monster = monsters[(index - 1) % monsters.size()]


func _on_monster_selected(monster: Monster):
	selected_monster = monster