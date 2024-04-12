class_name PlayerManager
extends Node

@export var xp_bar: ExperienceBar
@export var kamas_label: Label
@export var inventory: Inventory
@export var spell_container: VBoxContainer
@export var spell_bar: SpellBar
@export var hp_bar: HPBar
@export var pa_bar: PABar
@export var pm_bar: PMBar

@export var pdv_label: Label
@export var pa_label: Label
@export var pm_label: Label

static var dragged_item: DraggableControl
static var max_pa = 6
static var current_pa: int
static var max_pm = 3
static var current_pm: int
static var max_hp: int = 100
static var current_hp: int = 100

var selected_spell: Spell


func _ready():
	for spell_res in FileLoader.get_spell_resources("Ecaflip"):
		var spell_description = FileLoader.get_packed_scene("spell/spell_description").instantiate()
		spell_container.add_child(spell_description)
		var spell = Spell.instantiate(spell_res, spell_description.get_node("HBC/SpellContainer"), false)
		spell.is_clickable = false
		spell_description.init(spell_bar)
	
	hp_bar.init(max_hp)
	xp_bar.init()
	kamas_label.text = "0"
	current_pa = 0
	
	pa_bar.max_pa = max_pa
	pm_bar.max_pm = max_pm
	update_pdv()
	update_pa()
	update_pm()


func _input(event):
	var size = spell_bar.get_children().size()
	if size >= 1 and event.is_action_pressed("1"):
		spell_bar.get_children()[0].do_action()
	if size >= 2 and event.is_action_pressed("2"):
		spell_bar.get_children()[1].do_action()
	if size >= 3 and event.is_action_pressed("3"):
		spell_bar.get_children()[2].do_action()
	if size >= 4 and event.is_action_pressed("4"):
		spell_bar.get_children()[3].do_action()
	if size >= 5 and event.is_action_pressed("5"):
		spell_bar.get_children()[4].do_action()
	if size >= 6 and event.is_action_pressed("6"):
		spell_bar.get_children()[5].do_action()
	if size >= 7 and event.is_action_pressed("7"):
		spell_bar.get_children()[6].do_action()
	if size >= 8 and event.is_action_pressed("8"):
		spell_bar.get_children()[7].do_action()
	if size >= 9 and event.is_action_pressed("9"):
		spell_bar.get_children()[8].do_action()


func take_damage(amount: int):
	current_hp -= amount
	hp_bar.current_hp = current_hp


func update_pdv():
	pdv_label.text = str(max_hp)

func update_pa():
	pa_label.text = str(max_pa)

func update_pm():
	pm_label.text = str(max_pm)
