extends AbstractManager


var punch_res: SpellResource

var spell_container: VBoxContainer
var pdv_label: Label

var player_entity: Entity
var health_timer: Node

var player_bars: EntityBars
var hp_bar: CustomBar:
	get: return player_bars.hp_bar
var pa_bar: CustomBar:
	get: return player_bars.pa_bar
var pm_bar: CustomBar:
	get: return player_bars.pm_bar

var item_description: DescriptionPopUp
var spell_description: DescriptionPopUp
var entity_description: DescriptionPopUp
var dragged_item: Item
var dragged_spell: Spell

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

var selected_spell: Spell

var selected_plate: EntityContainer:
	set(value):
		if selected_plate != null:
			selected_plate.selected = false
		selected_plate = value
		if selected_plate != null:
			selected_plate.selected = true

var plates: Array[EntityContainer]
var is_initialized = false

func initialize():
	var selected_class = Globals.class_peeker.classes[Globals.selected_class]
	player_bars = get_tree().current_scene.get_node("%EntityBars")
	punch_res = load("res://resources/spells/punch.tres")
	spell_container = Globals.spells_container.get_node("%SpellContainer")
	pdv_label = Globals.stats_container.get_node("%HPAmount")
	
	for spell_res in FileLoader.get_spell_resources(selected_class):
		var spell_button = FileLoader.get_packed_scene("spell/spell_button").instantiate()
		spell_container.add_child(spell_button)
		spell_button.init(Globals.spell_bar, Spell.instantiate(spell_res, spell_button.get_node("HBC"), false))
	
	var entity_containers = get_tree().get_nodes_in_group("monster_container")
	entity_containers.sort_custom(func(a, b): return a.id < b.id)
	for entity_container in entity_containers:
		plates.append(entity_container)
	selected_plate = plates[0]
	
	init_player_entity()
	
	Globals.xp_bar.init()
	
	create_description_popup()
	is_initialized = true
	super()


func _process(_delta):
	if is_initialized and MonsterManager.monsters.is_empty() and player_entity.hp_bar.cval < max_hp:
		if !health_timer:
			health_timer = SpellsService.create_timer(1.0, "HealthTimer")
			await health_timer.timeout
			player_entity.hp_bar.cval += 1
			health_timer.queue_free()
			health_timer = null


func init_player_entity():
	player_entity = Entity.new()
	player_entity.name = "Player"
	player_entity.init()
	add_child(player_entity)
	player_entity.attack_callable = player_attack
	max_hp = 50
	max_pa = 6
	max_pm = 3
	init_bars()


func init_bars():
	hp_bar.mval = max_hp
	hp_bar.reset()
	pa_bar.mval = max_pa
	pa_bar.reset()
	pm_bar.mval = max_pm
	pm_bar.reset()


func _input(event):
	if is_initialized and !Globals.console.input.has_focus() and !RecipeManager.prompt_has_focus:
		if event.is_action_pressed("right"):
			PlayerManager.select_next_plate()
		if event.is_action_pressed("left"):
			PlayerManager.select_previous_plate()


func select_next_plate():
	var pi = plates.find(selected_plate)
	selected_plate = plates[(pi + 1) % plates.size()]


func select_previous_plate():
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
		var description_container = get_tree().current_scene.get_node("%DescriptionContainer")
		description_container.add_child(description)


func player_attack():
	var weapon: ItemResource = EquipmentManager.equipment_container.get_weapon()
	if weapon:
		SpellsService.perform_weapon(player_entity, PlayerManager.selected_plate.get_entity(), weapon.equip_res.weapon_resource, weapon.name)
	else:
		SpellsService.perform_spell(player_entity, PlayerManager.selected_plate.get_entity(), punch_res, 0)
