class_name SpellBar
extends SlotContainer


@export var grid: GridContainer


func _ready():
	slot_group_name = "spell_slot"
	super()


func connect_slot_signals(slot):
	super(slot)
	slot.button_up.connect(cast_spell_button.bind(slot))


func cast_spell_button(slot):
	var spell = null if slot.get_child_count() == 0 else slot.get_child(0)
	if spell and spell is Spell:
		spell.do_action()


func add_spell(spell_res: SpellResource):
	var empty_slot = get_next_empty_slot()
	if empty_slot:
		Spell.instantiate(spell_res, empty_slot)


func remove_spell(spell: Spell):
	var child_spell = find_spell_in_children(spell.resource.name)
	if child_spell:
		child_spell.get_parent().remove_child(child_spell)
		child_spell.queue_free()


func find_spell_in_children(spell_name: String) -> Spell:
	for slot in grid.get_children():
		if slot.get_child_count() != 0 and slot.get_child(0).resource.name == spell_name:
			return slot.get_child(0)
	return null


func get_next_empty_slot():
	for slot in grid.get_children():
		if slot.get_child_count() == 0:
			return slot
	return null


func get_spell(index: int):
	return grid.get_child(index).get_child(0)


func has_spell(index: int):
	return grid.get_child(index).get_child_count() != 0


func set_dragged_entering_drop_parent(slot):
	dragged = PlayerManager.dragged_spell
	super(slot)


func set_dragged_exited_drop_parent():
	dragged = PlayerManager.dragged_spell
	super()
