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

@export var console: Console

static var dragged_item: DraggableControl
static var max_pa = 6
static var current_pa: int
static var max_pm = 3
static var current_pm: int
static var max_hp: int = 100
static var current_hp: int = 100

static var taken_damage_rate: int = 100

var selected_spell: Spell

static var selected_plate: EntityContainer:
	set(value):
		if selected_plate != null:
			selected_plate.selected = false
		selected_plate = value
		if selected_plate != null:
			selected_plate.selected = true

static var plates: Array[EntityContainer]


func _ready():
	SpellsService.console = console
	SpellsService.tnode = $"/root/Main/Timers"
	StatsManager.console = console
	
	for spell_res in FileLoader.get_spell_resources("Ecaflip"):
		var spell_description = FileLoader.get_packed_scene("spell/spell_description").instantiate()
		spell_container.add_child(spell_description)
		var spell = Spell.instantiate(spell_res, spell_description.get_node("HBC/SpellContainer"), false)
		spell.is_clickable = false
		spell_description.init(spell_bar)
	
	var entity_containers = get_tree().get_nodes_in_group("monster_container")
	entity_containers.sort_custom(func(a, b): return a.id < b.id)
	for entity_container in entity_containers:
		plates.append(entity_container)
	selected_plate = plates[0]
	
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
	if event.is_action_pressed("right"):
		PlayerManager.select_next_plate()
	if event.is_action_pressed("left"):
		PlayerManager.select_previous_plate()


func take_damage(amount: int) -> int:
	var taken_damage = roundi((amount * taken_damage_rate) / 100.0)
	current_hp -= taken_damage
	hp_bar.current_hp = current_hp
	return taken_damage


static func select_next_plate():
	var pi = plates.find(selected_plate)
	selected_plate = plates[(pi + 1) % plates.size()]


static func select_previous_plate():
	var pi = plates.find(selected_plate)
	selected_plate = plates[(pi - 1) % plates.size()]


func update_pdv():
	pdv_label.text = str(max_hp)

func update_pa():
	pa_label.text = str(max_pa)

func update_pm():
	pm_label.text = str(max_pm)
