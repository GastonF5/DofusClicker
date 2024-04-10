class_name SpellBar
extends HBoxContainer


@onready var spell_bar2 = $"../SpellBar2"


func add_spell(spell_res: SpellResource):
	if get_children().size() == 5:
		Spell.instantiate(spell_res, spell_bar2)
	else:
		Spell.instantiate(spell_res, self)


func remove_spell(spell: Spell):
	var child_spell = find_spell_in_children(spell.resource.name)
	if child_spell != null:
		remove_child(child_spell)
		child_spell.queue_free()
	child_spell = find_spell_in_bar2_children(spell.resource.name)
	if child_spell != null:
		remove_child(child_spell)
		child_spell.queue_free()


func find_spell_in_children(spell_name: String) -> Spell:
	for spell in get_children():
		if spell.resource.name == spell_name:
			return spell
	return null


func find_spell_in_bar2_children(spell_name: String) -> Spell:
	for spell in spell_bar2.get_children():
		if spell.resource.name == spell_name:
			return spell
	return null
