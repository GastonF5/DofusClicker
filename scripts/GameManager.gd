class_name GameManager
extends Node


const monster_scene = preload("res://scenes/monster.tscn")
const spell_scene = preload("res://scenes/spell.tscn")

@export var xp_bar: ExperienceBar
@export var kamas_label: Label
@export var inventory: Inventory

static var monsters = []
static var spells = []
static var instance = self

static var dragged_item: DraggableControl


static var selected_monster: Monster:
	set(value):
		if selected_monster != null:
			selected_monster.selected_arrow.visible = false
		selected_monster = value
		if value != null:
			selected_monster.selected_arrow.visible = true

var selected_spell: Spell

var monsters_res: Array[MonsterResource] = []
var spells_res: Array[SpellResource] = []


func _ready():
	var monster_resource_paths = FileLoader.get_all_file_paths("res://resources/monsters")
	for path in monster_resource_paths:
		monsters_res.append(load(path))
	for i in 4:
		instantiate_monster()
	monsters = $"../GUI/Main/MiddleBackground/MonstersContainer".get_children()
	selected_monster = monsters[0]
	
	var spell_resource_paths = FileLoader.get_all_file_paths("res://resources/spells")
	for path in spell_resource_paths:
		var spell: SpellResource = load(path)
		spells_res.append(spell)
		instantiate_spell_ui(spell)
	
	xp_bar.init()
	kamas_label.text = "0"


func _input(event):
	if event.is_action_pressed("right"):
		select_next_monster()
	if event.is_action_pressed("left"):
		select_previous_monster()
	if event.is_action_pressed("1"):
		spells[0].do_action(null)
	if event.is_action_pressed("2"):
		spells[1].do_action(null)
	if event.is_action_pressed("3"):
		spells[2].do_action(null)
	if event.is_action_pressed("4"):
		spells[3].do_action(null)
	if event.is_action_pressed("5"):
		spells[4].do_action(null)
	if event.is_action_pressed("6"):
		spells[5].do_action(null)
	if event.is_action_pressed("7"):
		spells[6].do_action(null)
	if event.is_action_pressed("8"):
		spells[7].do_action(null)
	if event.is_action_pressed("9"):
		spells[8].do_action(null)


func instantiate_spell_ui(res: SpellResource):
	var spell = spell_scene.instantiate()
	spell.init(res)
	spell.cast.connect(_on_cast_spell)
	$"../GUI/Main/MiddleBackground/SpellsContainer/VBoxContainer".add_child(spell)
	spells.append(spell)


func instantiate_monster() -> Monster:
	var monster_resource: MonsterResource = monsters_res[randi_range(0, monsters_res.size() - 1)]
	var monster = monster_scene.instantiate()
	$"../GUI/Main/MiddleBackground/MonstersContainer".add_child(monster)
	monster.init(monster_resource)
	monster.dies.connect(_on_monster_dies)
	monster.clicked.connect(_on_monster_selected)
	monsters.append(monster)
	return monster


func _on_monster_dies(xp: int):
	xp_bar.gain_xp(xp)
	kamas_label.text = str(int(kamas_label.text) + randi_range(5, 10))
	monsters = $"../GUI/Main/MiddleBackground/MonstersContainer".get_children()
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


func _on_cast_spell(spell: SpellResource):
	Callable(SpellsService, spell.name.to_snake_case()).bind(selected_monster).call()


func _on_monster_selected(monster: Monster):
	selected_monster = monster
