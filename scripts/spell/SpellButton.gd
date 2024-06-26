class_name SpellButton
extends Button


const unselected_theme = preload("res://resources/themes/spell_button/unselected.tres")
const selected_theme = preload("res://resources/themes/spell_button/selected.tres")

@export var spell_name: Label

var _spell: Spell
var spell_bar: SpellBar
var selected = false


func init(_spell_bar: SpellBar, spell: Spell):
	_spell = spell
	$HBC.move_child(_spell, 1)
	spell_name.text = _spell.resource.name
	spell_bar = _spell_bar


func _on_button_up():
	selected = !selected
	if selected:
		theme = selected_theme
		spell_bar.add_new_spell(_spell.resource)
	else:
		theme = unselected_theme
		spell_bar.delete_spell(_spell)


func _on_mouse_entered():
	if !PlayerManager.dragged_item:
		PlayerManager.spell_description.init_spell(_spell.resource)


func _on_mouse_exited():
	if !PlayerManager.dragged_item:
		PlayerManager.spell_description.visible = false
