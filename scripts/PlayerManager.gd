class_name PlayerManager
extends Node


const spell_scene = preload("res://scenes/spell.tscn")

@export var xp_bar: ExperienceBar
@export var kamas_label: Label
@export var inventory: Inventory
@export var pa_bar: PABar
@export var spell_container: VBoxContainer
@export var spell_bar: SpellBar

static var dragged_item: DraggableControl
static var current_pa: int
static var current_hp: int

var selected_spell: Spell


func _ready():
	for spell_res in FileLoader.get_spell_resources("Ecaflip"):
		var spell_description = load("res://scenes/spell/spell_description.tscn").instantiate()
		spell_container.add_child(spell_description)
		var spell = Spell.instantiate(spell_res, spell_description.get_node("VBC/HBC/SpellContainer"), false)
		spell.is_clickable = false
		spell_description.init(spell_bar)
	
	xp_bar.init()
	kamas_label.text = "0"
	current_pa = pa_bar.pa_bar_array.size()


func _input(event):
	if event.is_action_pressed("1"):
		spell_bar.get_children()[0].do_action()
	if event.is_action_pressed("2"):
		spell_bar.get_children()[1].do_action()
	if event.is_action_pressed("3"):
		spell_bar.get_children()[2].do_action()
	if event.is_action_pressed("4"):
		spell_bar.get_children()[3].do_action()
	if event.is_action_pressed("5"):
		spell_bar.get_children()[4].do_action()
	if event.is_action_pressed("6"):
		spell_bar.get_children()[5].do_action()
	if event.is_action_pressed("7"):
		spell_bar.get_children()[6].do_action()
	if event.is_action_pressed("8"):
		spell_bar.get_children()[7].do_action()
	if event.is_action_pressed("9"):
		spell_bar.get_children()[8].do_action()
