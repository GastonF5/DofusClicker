class_name PlayerManager
extends Node


var punch_res: SpellResource

@export var spells_container: Panel
var spell_container: VBoxContainer
@export var stats_container: Panel
var pdv_label: Label
@export var inventory_container: Panel
var inventory: Inventory

var player_entity: Entity
var health_timer: Node
var attack_timer: Timer

@export var xp_bar: ExperienceBar
@export var spell_bar: SpellBar
@export var player_bars: EntityBars
var hp_bar: CustomBar:
	get: return player_bars.hp_bar
var pa_bar: CustomBar:
	get: return player_bars.pa_bar
var pm_bar: CustomBar:
	get: return player_bars.pm_bar

@export var console: Console

static var item_description: DescriptionPopUp
static var spell_description: DescriptionPopUp
static var entity_description: DescriptionPopUp
static var dragged_item: Item
static var dragged_spell: Spell

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
		player_entity.hp_bar.cval += value - max_hp
		max_hp = value
		update_pdv()

@export var attack_time: float:
	set(value):
		attack_time = value
		change_attack_timer_wait_time(attack_time)

var selected_spell: Spell

static var selected_plate: EntityContainer:
	set(value):
		if selected_plate != null:
			selected_plate.selected = false
		selected_plate = value
		if selected_plate != null:
			selected_plate.selected = true

static var plates: Array[EntityContainer]
var initialized = false

func initialize(selected_class: String):
	punch_res = load("res://resources/spells/punch.tres")
	spell_container = spells_container.get_node("%SpellContainer")
	pdv_label = stats_container.get_node("%HPAmount")
	inventory = inventory_container.get_node("%Inventory")
	
	SpellsService.console = console
	SpellsService.tnode = $%Timers
	StatsManager.console = console
	
	for spell_res in FileLoader.get_spell_resources(selected_class):
		var spell_button = FileLoader.get_packed_scene("spell/spell_button").instantiate()
		spell_container.add_child(spell_button)
		spell_button.init(spell_bar, Spell.instantiate(spell_res, spell_button.get_node("HBC"), false))
	
	var entity_containers = get_tree().get_nodes_in_group("monster_container")
	entity_containers.sort_custom(func(a, b): return a.id < b.id)
	for entity_container in entity_containers:
		plates.append(entity_container)
	selected_plate = plates[0]
	
	player_entity = Entity.new()
	add_child(player_entity)
	SpellsService.player_entity = player_entity
	player_entity.entity_bar = player_bars
	player_entity.attack_callable = player_attack
	max_hp = 50
	max_pa = 6
	max_pm = 3
	init_bars()
	player_entity.init(true)
	attack_time = 120.0 / player_entity.get_attack_speed()
	
	xp_bar.init()
	
	create_description_popup()
	initialized = true


func _process(_delta):
	if initialized and MonsterManager.monsters.is_empty() and player_entity.hp_bar.cval < max_hp:
		if !health_timer:
			health_timer = SpellsService.create_timer(1.0, "HealthTimer")
			await health_timer.timeout
			player_entity.hp_bar.cval += 1
			health_timer.queue_free()
			health_timer = null


func init_bars():
	hp_bar.mval = max_hp
	hp_bar.reset()
	pa_bar.mval = max_pa
	pa_bar.reset()
	pm_bar.mval = max_pm
	pm_bar.reset()


func _input(event):
	if initialized and !console.input.has_focus() and !$%RecipeManager.prompt_has_focus:
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
	player_entity.hp_bar.mval = max_hp

func update_pa():
	StatsManager.get_caracteristique_for_type(Caracteristique.Type.PA).set_base_amount(max_pa)
	player_entity.pa_bar.mval = max_pa

func update_pm():
	StatsManager.get_caracteristique_for_type(Caracteristique.Type.PM).set_base_amount(max_pm)
	player_entity.pm_bar.mval = max_pm


func create_description_popup():
	item_description = FileLoader.get_packed_scene("item/item_description").instantiate()
	spell_description = FileLoader.get_packed_scene("spell/spell_description").instantiate()
	entity_description = FileLoader.get_packed_scene("entity/entity_description").instantiate()
	for description in [item_description, spell_description, entity_description]:
		description.visible = false
		description.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$%DescriptionContainer.add_child(description)


func create_attack_timer():
	attack_timer = SpellsService.create_timer(attack_time, "PlayerAttackTimer")
	await attack_timer.timeout
	attack_timer.get_parent().remove_child(attack_timer)
	attack_timer.queue_free()
	player_entity.attack_callable.call()
	if GameManager.in_fight():
		create_attack_timer()


func change_attack_timer_wait_time(new_wait_time: float):
	if attack_timer and is_instance_valid(attack_timer):
		var cur_wait_time = attack_timer.wait_time - attack_timer.time_left
		attack_timer.stop()
		attack_timer.wait_time = new_wait_time - cur_wait_time
		attack_timer.start()


func player_attack():
	var weapon_res = $%EquipmentManager.equipment_container.get_weapon_resource()
	if weapon_res:
		SpellsService.perform_weapon_effects(player_entity, PlayerManager.selected_plate.get_entity(), weapon_res, 0)
	else:
		SpellsService.perform_spell(player_entity, PlayerManager.selected_plate.get_entity(), punch_res, 0)
