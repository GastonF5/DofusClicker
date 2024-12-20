extends AbstractManager


var punch_res: SpellResource

var spell_container: VBoxContainer
var pdv_label: Label

var player_entity: Entity
var health_timer: Node

var hp_bar: CustomBar
var pa_bar: CustomBar
var pm_bar: CustomBar

var item_description: DescriptionPopUp
var spell_description: DescriptionPopUp
var entity_description: DescriptionPopUp
var buff_description: DescriptionPopUp
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
		var cur_max_hp = max_hp
		max_hp = value
		if GameManager.in_fight or value >= cur_max_hp:
			player_entity.hp_bar.cval += value - cur_max_hp
		update_pdv()

var static_max_hp: int

var selected_spell: Spell

var selected_plate: EntityContainer:
	set(value):
		if selected_plate != null:
			selected_plate.selected = false
		selected_plate = value
		if selected_plate != null:
			selected_plate.selected = true


func reset():
	player_entity = null
	punch_res = null
	spell_container = null
	pdv_label = null
	selected_spell = null
	selected_plate = null
	item_description = null
	spell_description = null
	entity_description = null
	buff_description = null
	dragged_item = null
	dragged_spell = null
	super()


func initialize():
	punch_res = preload("res://resources/spells/punch.tres")
	spell_container = Globals.spells_container.get_node("%SpellContainer")
	pdv_label = Globals.stats_container.get_node("%HPAmount")
	
	init_spells()
	
	init_player_entity()
	
	Globals.xp_bar.init()
	
	create_description_popup()
	super()


func init_spells():
	for spell in spell_container.get_children():
		spell_container.remove_child(spell)
		spell.queue_free()
	var selected_class = Globals.class_peeker.classes[Globals.selected_class]
	var spells = FileLoader.get_spell_resources(selected_class)
	spells.sort_custom(
		func(a, b):
			if a.level == b.level:
				return a.priority > b.priority
			return a.level <= b.level)
	var spell_bar_spells = Globals.spell_bar.get_spells()
	for spell_res in spells:
		var spell_button: SpellButton = FileLoader.get_packed_scene("spell/spell_button").instantiate()
		spell_container.add_child(spell_button)
		spell_button.init(Globals.spell_bar, Spell.instantiate(spell_res, spell_button.get_node("HBC"), false))
		if spell_bar_spells.map(func(s): return s.resource.id).has(spell_res.id):
			spell_button.selected = true
			spell_button.theme = SpellButton.selected_theme


func _process(_delta):
	if !Globals.quitting:
		if is_initialized and MonsterManager.monsters.is_empty() and player_entity.hp_bar.cval < max_hp:
			if !health_timer:
				health_timer = SpellsService.create_timer(0.5, "HealthTimer")
				await health_timer.timeout
				player_entity.hp_bar.cval += 1
				health_timer.queue_free()
				health_timer = null


func init_player_entity():
	hp_bar = Globals.player_bars.hp_bar
	pa_bar = Globals.player_bars.pa_bar
	pm_bar = Globals.player_bars.pm_bar
	player_entity = Entity.new()
	player_entity.buffs_container = Globals.buffs_container
	player_entity.name = "Player"
	player_entity.is_player = true
	player_entity.is_ally = true
	player_entity.init()
	max_hp = 50
	max_pa = 6
	max_pm = 3
	init_bars()
	add_child(player_entity)
	player_entity.attack_callable = player_attack


func init_bars():
	hp_bar.mval = max_hp
	hp_bar.reset()
	pa_bar.mval = max_pa
	pa_bar.reset()
	pm_bar.mval = max_pm
	pm_bar.reset()


func _input(event):
	if is_initialized and !Globals.has_focus:
		if event.is_action_pressed("right"):
			PlayerManager.select_next_plate()
		if event.is_action_pressed("left"):
			PlayerManager.select_previous_plate()
		if event.is_action_pressed("up") or event.is_action_pressed("down"):
			PlayerManager.select_other_line()


func select_next_plate():
	var plates = selected_plate.get_line()
	var pi = plates.find(selected_plate)
	selected_plate = plates[(pi + 1) % plates.size()]


func select_previous_plate():
	var plates = selected_plate.get_line()
	var pi = plates.find(selected_plate)
	selected_plate = plates[(pi - 1) % plates.size()]


func select_other_line():
	var other_line = selected_plate.get_line(true)
	var pi = selected_plate.get_line().find(selected_plate)
	selected_plate = other_line[pi]


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
	buff_description = FileLoader.get_packed_scene("spell/buff_description").instantiate()
	for description in [item_description, spell_description, entity_description, buff_description]:
		description.visible = false
		description.mouse_filter = Control.MOUSE_FILTER_IGNORE
		description.z_index = 5
		Globals.description_container.add_child(description)


func player_attack():
	var weapon: ItemResource = EquipmentManager.equipment_container.get_weapon()
	if weapon:
		SpellsService.perform_weapon(player_entity, PlayerManager.selected_plate, weapon.equip_res.weapon_resource, weapon.name)
	else:
		SpellsService.perform_spell(player_entity, PlayerManager.selected_plate, punch_res, 0)


func previsualize_spell_zone(target_types: Array):
	var target_plates = target_types.reduce(
		func(accum, type):
			var plates = selected_plate.get_plates_for_target_type(type)
			for plate in plates:
				if plate and !accum.has(plate):
					accum.append(plate)
			return accum, [])
	for plate in target_plates:
		plate.set_spell_previsualization(true)
