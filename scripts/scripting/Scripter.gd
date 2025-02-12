class_name Scripter
extends Control


enum TargetOption {
	MAX_HP, MIN_HP
}

func get_target_option_label(code: TargetOption) -> String:
	match code:
		TargetOption.MAX_HP: return "Max HP"
		TargetOption.MIN_HP: return "Min HP"
		_: return "ERROR_%s" % TargetOption.find_key(code)

enum TriggerOption {
	ALWAYS
}

func get_trigger_option_label(code: TriggerOption) -> String:
	match code:
		TriggerOption.ALWAYS: return "Toujours"
		_: return "ERROR_%" % TriggerOption.find_key(code)

enum ZoneOption {
	EVERYWHERE, DISTANCE, MELEE, CENTER
}

func get_zone_option_label(code: ZoneOption) -> String:
	match code:
		ZoneOption.EVERYWHERE: return "Partout"
		ZoneOption.DISTANCE: return "Distance"
		ZoneOption.MELEE: return "Mêlée"
		ZoneOption.CENTER: return "Centre"
		_: return "ERROR_%" % ZoneOption.find_key(code)

var spell: Spell:
	set(val):
		spell = val
		update_spell_icon()
		if mouse_on_spell_slot and spell:
			PlayerManager.spell_description.init_spell(spell.resource)

var mouse_on_spell_slot := false

static func create() -> Scripter:
	var scripter = preload("res://scenes/scripting/scripter.tscn").instantiate()
	return scripter


func _ready():
	for option in TargetOption.values():
		$HBC/Options/TargetOptions.add_item(get_target_option_label(option))
	for option in TriggerOption.values():
		$HBC/Options/TriggerOptions.add_item(get_trigger_option_label(option))
	for option in ZoneOption.values():
		$HBC/Options/ZoneOptions.add_item(get_zone_option_label(option))
	$HBC/Options/SpellSlot.icon = PlayerManager.punch_res.texture


func do_action() -> void:
	PlayerManager.selected_plate = get_target_plate()
	spell.do_action()


func can_do_action() -> bool:
	return spell and spell.can_be_cast() and get_trigger() and get_target_plate()


func get_target_plate() -> EntityContainer:
	var available_plates = get_available_plates()
	match get_zone_option():
		ZoneOption.DISTANCE:
			available_plates = available_plates.filter(func(p): return p.is_distance())
		ZoneOption.MELEE:
			available_plates = available_plates.filter(func(p): return p.is_melee())
		_:
			pass
	match get_target_option():
		TargetOption.MAX_HP:
			available_plates.sort_custom(
				func(p1, p2):
					return p1._entity.hp_bar.cval >= p2._entity.hp_bar.cval
			)
			return null if available_plates.is_empty() else available_plates[0]
		TargetOption.MIN_HP:
			available_plates.sort_custom(
				func(p1, p2):
					return p1._entity.hp_bar.cval <= p2._entity.hp_bar.cval
			)
			return null if available_plates.is_empty() else available_plates[0]
		_:
			return null


func get_available_plates() -> Array[EntityContainer]:
	var _min = get_min_targets()
	if _min == 1:
		return MonsterManager.plates.filter(func(p): return is_instance_valid(p._entity))
	var available_plates: Array[EntityContainer] = []
	var effects: Array[EffectResource] = spell.resource.effects
	for plate: EntityContainer in MonsterManager.plates:
		var nb_targets = 0
		for effect in effects:
			var spell_targets = SpellsService.get_targets(PlayerManager.player_entity, plate, effect.target_type)
			nb_targets = max(nb_targets, spell_targets.size())
		if nb_targets >= _min:
			available_plates.append(plate)
	return available_plates


func get_trigger() -> bool:
	match get_trigget_option():
		TriggerOption.ALWAYS:
			return PlayerManager.player_entity.pa_bar.cval >= spell.resource.pa_cost
		_:
			return false


func get_target_option() -> TargetOption:
	return $HBC/Options/TargetOptions.selected


func get_trigget_option() -> TriggerOption:
	return $HBC/Options/TriggerOptions.selected


func get_zone_option() -> ZoneOption:
	return $HBC/Options/ZoneOptions.selected


func get_min_targets() -> int:
	return $HBC/Options/NbMinTarget.value as int


func get_priority() -> int:
	# on va chercher l'orderable element
	return get_parent().get_parent().get_parent().get_index()


func update_spell_icon() -> void:
	if spell:
		$HBC/Options/SpellSlot.icon = spell.resource.texture
	else:
		$HBC/Options/SpellSlot.icon = PlayerManager.punch_res.texture


func update_priority_texture(index: int) -> void:
	$HBC/Priority.texture = Globals.get_number_asset(index)


func _on_spell_slot_mouse_entered():
	if PlayerManager.dragged_spell:
		PlayerManager.dragged_spell.drop_parent = $HBC/Options/SpellSlot
	mouse_on_spell_slot = true
	if spell:
		PlayerManager.spell_description.init_spell(spell.resource)


func _on_spell_slot_mouse_exited():
	if PlayerManager.dragged_spell:
		PlayerManager.dragged_spell.drop_parent = PlayerManager.dragged_spell.old_parent
	mouse_on_spell_slot = false
	PlayerManager.spell_description.visible = false


func _on_spell_slot_button_up():
	spell = null
	PlayerManager.spell_description.visible = false
