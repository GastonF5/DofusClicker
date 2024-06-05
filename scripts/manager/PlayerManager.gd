class_name PlayerManager
extends Node


@export var spells_container: Panel
var spell_container: VBoxContainer
@export var stats_container: Panel
var pdv_label: Label
@export var inventory_container: Panel
var inventory: Inventory

var player_entity: Entity
var health_timer: Node

@export var xp_bar: ExperienceBar
@export var kamas_label: Label
@export var spell_bar: SpellBar
@export var player_bars: EntityBars
var hp_bar: CustomBar
var pa_bar: CustomBar
var pm_bar: CustomBar

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
		hp_bar.cval += value - max_hp
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
	hp_bar = player_bars.hp_bar
	pa_bar = player_bars.pa_bar
	pm_bar = player_bars.pm_bar
	spell_container = spells_container.get_node("%SpellContainer")
	pdv_label = stats_container.get_node("%HPAmount")
	inventory = inventory_container.get_node("%Inventory")
	
	SpellsService.console = console
	SpellsService.tnode = $%Timers
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
	
	player_entity = Entity.new()
	add_child(player_entity)
	SpellsService.player_entity = player_entity
	init_caracteristiques(50, 100, 3)
	player_entity.entity_bar = player_bars
	player_entity.init()
	
	xp_bar.init()
	kamas_label.text = "0"
	
	create_item_description()


func _process(_delta):
	if MonsterManager.monsters.is_empty() and hp_bar.cval < max_hp:
		if !health_timer:
			health_timer = SpellsService.create_timer(1.0, "HealthTimer")
			await health_timer.timeout
			hp_bar.cval += 1
			health_timer.queue_free()
			health_timer = null


func init_caracteristiques(hp: int = max_hp, pa: int = max_pa, pm: int = max_pm):
	# HP
	max_hp = hp
	player_entity.hp_bar = hp_bar
	# PA
	max_pa = pa
	player_entity.pa_bar = pa_bar
	# PM
	max_pm = pm
	player_entity.pm_bar = pm_bar


func _input(event):
	if !console.input.has_focus() and !$"../RecipeManager".current_tab.search_prompt.has_focus():
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


static func select_next_plate():
	var pi = plates.find(selected_plate)
	selected_plate = plates[(pi + 1) % plates.size()]


static func select_previous_plate():
	var pi = plates.find(selected_plate)
	selected_plate = plates[(pi - 1) % plates.size()]


func update_pdv():
	pdv_label.text = str(max_hp)
	hp_bar.mval = max_hp

func update_pa():
	StatsManager.get_caracteristique_for_type(Caracteristique.Type.PA).set_base_amount(max_pa)
	pa_bar.mval = max_pa

func update_pm():
	StatsManager.get_caracteristique_for_type(Caracteristique.Type.PM).set_base_amount(max_pm)
	pm_bar.mval = max_pm


func create_item_description():
	item_description = FileLoader.get_packed_scene("item/item_description").instantiate()
	item_description.visible = false
	item_description.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$%DescriptionContainer.add_child(item_description)
