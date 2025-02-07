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
	ALWAYS, FIRST, LAST
}

func get_trigger_option_label(code: TriggerOption) -> String:
	match code:
		TriggerOption.ALWAYS: return "Toujours"
		TriggerOption.FIRST: return "En premier"
		TriggerOption.LAST: return "En dernier"
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


static func create() -> Scripter:
	var scripter = preload("res://scenes/scripting/scripter.tscn").instantiate()
	Globals.recipe_script_container.scripting_panel.add_child(scripter)
	return scripter


func _ready():
	for option in TargetOption.values():
		$Options/TargetOptions.add_item(get_target_option_label(option))
	for option in TriggerOption.values():
		$Options/TriggerOptions.add_item(get_trigger_option_label(option))
	for option in ZoneOption.values():
		$Options/ZoneOptions.add_item(get_zone_option_label(option))
	$Options/SpellSlot.icon = PlayerManager.punch_res.texture


func do_action():
	var target = get_target()
	if spell and spell.can_be_cast() and get_trigger() and target:
		PlayerManager.selected_plate = target.get_parent()
		spell.do_action()


func get_target() -> Entity:
	var monsters = MonsterManager.monsters.duplicate()
	match get_zone_option():
		ZoneOption.DISTANCE:
			monsters = monsters.filter(func(m): return m.get_parent().is_distance())
		ZoneOption.MELEE:
			monsters = monsters.filter(func(m): return m.get_parent().is_melee())
		_:
			pass
	match get_target_option():
		TargetOption.MAX_HP:
			monsters.sort_custom(
				func(m1, m2):
					return m1.hp_bar.cval >= m2.hp_bar.cval
			)
			return null if monsters.is_empty() else monsters[0]
		TargetOption.MIN_HP:
			monsters.sort_custom(
				func(m1, m2):
					return m1.hp_bar.cval <= m2.hp_bar.cval
			)
			return null if monsters.is_empty() else monsters[0]
		_:
			return null


func get_trigger() -> bool:
	match get_trigget_option():
		TriggerOption.ALWAYS:
			return PlayerManager.player_entity.pa_bar.cval >= spell.resource.pa_cost
		_:
			return false


func get_target_option() -> TargetOption:
	return $Options/TargetOptions.selected


func get_trigget_option() -> TriggerOption:
	return $Options/TriggerOptions.selected


func get_zone_option() -> ZoneOption:
	return $Options/ZoneOptions.selected


func update_spell_icon():
	if spell:
		$Options/SpellSlot.icon = spell.resource.texture
	else:
		$Options/SpellSlot.icon = PlayerManager.punch_res.texture


func _on_spell_slot_mouse_entered():
	if PlayerManager.dragged_spell:
		PlayerManager.dragged_spell.drop_parent = $Options/SpellSlot


func _on_spell_slot_mouse_exited():
	if PlayerManager.dragged_spell:
		PlayerManager.dragged_spell.drop_parent = PlayerManager.dragged_spell.old_parent


func _on_spell_slot_button_up():
	spell = null
