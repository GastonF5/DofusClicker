class_name SpellBar
extends SlotContainer


const WTYPE = WeaponResource.WeaponType

@export var grid: GridContainer
@export var weapon_slot: TextureRect
var weapon_pb: ProgressBar:
	get: return weapon_slot.get_node("ProgressBar")
var weapon_pb_ready := false

func _ready():
	slot_group_name = "spell_slot"
	update_weapon_slot(WTYPE.NONE)
	weapon_pb.max_value = 100
	weapon_pb.value = 0
	super()


func _input(event):
	if GameManager.in_fight:
		for i in range(slots.size() - 1):
			if event.is_action_pressed(str(i + 1)):
				if slot_contains_spell(i):
					get_spell(i).do_action()


func _process(delta):
	if GameManager.in_fight and weapon_pb_ready:
		weapon_pb.value -= float(PlayerManager.player_entity.get_attack_speed() * delta) / 3
		if weapon_pb.value <= 0:
			weapon_pb.value = weapon_pb.max_value
			PlayerManager.player_attack()


func set_weapon_pb_ready(is_ready: bool):
	if is_ready:
		weapon_pb.value = weapon_pb.max_value
	else:
		weapon_pb.value = 0
	weapon_pb_ready = is_ready


func connect_slot_signals(slot):
	super(slot)
	slot.button_up.connect(cast_spell_button.bind(slot))


func cast_spell_button(slot):
	var spell = null if slot.get_child_count() == 0 else slot.get_child(0)
	if GameManager.in_fight and spell and spell is Spell:
		spell.do_action()


func add_new_spell(spell_res: SpellResource):
	var empty_slot = get_next_empty_slot()
	if empty_slot:
		Spell.instantiate(spell_res, empty_slot)


func delete_spell(spell: Spell):
	var child_spell = find_spell_in_children(spell.resource.name)
	if child_spell:
		child_spell.get_parent().remove_child(child_spell)
		child_spell.queue_free()


func delete_spells():
	for slot in slots:
		if slot.get_child_count() == 1:
			delete_spell(slot.get_child(0))


func find_spell_in_children(spell_name: String) -> Spell:
	for slot in slots:
		if slot.get_child_count() != 0 and slot.get_child(0).resource.name == spell_name:
			return slot.get_child(0)
	return null


func get_next_empty_slot():
	for slot in slots:
		if slot.get_child_count() == 0:
			return slot
	return null


func get_spell(index: int):
	return grid.get_child(index).get_child(0)


func get_spells() -> Array:
	var spells = []
	for i in range(slots.size()):
		if slot_contains_spell(i):
			spells.append(get_spell(i))
	return spells


func slot_contains_spell(index: int):
	return grid.get_child(index).get_child_count() != 0


func set_dragged_entering_drop_parent(slot):
	dragged = PlayerManager.dragged_spell
	super(slot)


func set_dragged_exited_drop_parent():
	dragged = PlayerManager.dragged_spell
	super()


func reset_spells():
	for spell in grid.get_children()\
	.filter(func(n): return n is Button)\
	.map(func(slot):
		return slot.get_child(0) if slot.get_child_count() == 1 else null)\
		.filter(func(s): return s):
		spell.reset()


func update_weapon_slot(weapon_type: WTYPE):
	var texture: Texture2D
	match weapon_type:
		WTYPE.NONE:
			texture = load("res://assets/spells/punch.png")
	weapon_slot.texture = texture
