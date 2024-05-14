class_name PlayerManager
extends Node


@export var spells_container: Panel
var spell_container: VBoxContainer
@export var stats_container: Panel
var pdv_label: Label
@export var inventory_container: Panel
var inventory: Inventory

@export var xp_bar: ExperienceBar
@export var kamas_label: Label
@export var spell_bar: SpellBar
@export var hp_bar: HPBar
@export var pa_bar: PABar
@export var pm_bar: PMBar

@export var console: Console

static var item_description: ItemDescription
static var dragged_item: DraggableControl
var max_pa: int:
	set(value):
		max_pa = value
		update_pa()

var max_pm: int:
	set(value):
		max_pm = value
		update_pm()

var max_hp: int:
	set(value):
		hp_bar.current_hp += value - max_hp
		max_hp = value
		update_pdv()

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
	spell_container = spells_container.get_node("%SpellContainer")
	pdv_label = stats_container.get_node("%HPAmount")
	inventory = inventory_container.get_node("%Inventory")
	
	SpellsService.console = console
	SpellsService.tnode = $"/root/Main/Timers"
	StatsManager.console = console
	
	for spell_res in $"../FileLoader".get_spell_resources("Ecaflip"):
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
	
	init_caracteristiques(50, 6, 3)
	
	xp_bar.init()
	kamas_label.text = "0"
	
	create_item_description()


func init_caracteristiques(hp: int, pa: int, pm: int):
	# HP
	max_hp = hp
	hp_bar.init(max_hp)
	# PA
	max_pa = pa
	pa_bar.init(max_pa)
	# PM
	max_pm = pm
	pm_bar.init(max_pm)


func _input(event):
	if !console.input.has_focus() and !$"../RecipeManager".search_prompt.has_focus():
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
	hp_bar.current_hp -= taken_damage
	return taken_damage


static func select_next_plate():
	var pi = plates.find(selected_plate)
	selected_plate = plates[(pi + 1) % plates.size()]


static func select_previous_plate():
	var pi = plates.find(selected_plate)
	selected_plate = plates[(pi - 1) % plates.size()]


func update_pdv():
	pdv_label.text = str(max_hp)
	hp_bar.update(hp_bar.current_hp, max_hp)

func update_pa():
	StatsManager.get_caracteristique_for_type(Caracteristique.Type.PA).set_base_amount(max_pa)

func update_pm():
	StatsManager.get_caracteristique_for_type(Caracteristique.Type.PM).set_base_amount(max_pm)


func create_item_description():
	item_description = FileLoader.get_packed_scene("item/item_description").instantiate()
	item_description.visible = false
	item_description.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$"%DescriptionContainer".add_child(item_description)
