class_name PlayerManager
extends Node


const spell_scene = preload("res://scenes/spell.tscn")

@export var xp_bar: ExperienceBar
@export var kamas_label: Label
@export var inventory: Inventory
@export var pa_bar: PABar
@export var spell_container: HBoxContainer

static var dragged_item: DraggableControl
static var current_pa: int
static var current_hp: int

var spells = []
var selected_spell: Spell


func _ready():
	var spell_resource_paths = FileLoader.get_all_file_paths("res://resources/spells")
	for path in spell_resource_paths:
		var spell_res: SpellResource = load(path)
		var spell = Spell.instantiate(spell_res, spell_container)
		spell.cast.connect(_on_cast_spell)
		spells.append(spell)
	
	xp_bar.init()
	kamas_label.text = "0"
	current_pa = pa_bar.pa_bar_array.size()


func _input(event):
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


func _on_cast_spell(spell: SpellResource):
	Callable(SpellsService, spell.name.to_snake_case()).bind(MonsterManager.selected_monster).call()
