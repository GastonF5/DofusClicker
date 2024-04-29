class_name SpellBar
extends GridContainer


func _ready():
	size = size * 1.5


func add_spell(spell_res: SpellResource):
	Spell.instantiate(spell_res, self)


func remove_spell(spell: Spell):
	var child_spell = find_spell_in_children(spell.resource.name)
	if child_spell != null:
		remove_child(child_spell)
		child_spell.queue_free()


func find_spell_in_children(spell_name: String) -> Spell:
	for spell in get_children():
		if spell.resource.name == spell_name:
			return spell
	return null
