class_name SpellDescription
extends ClickableControl


@export var spell_container: PanelContainer
@export var spell_name: Label
@export var check_box: CheckBox
@export var description: RichTextLabel

var spell: Spell
var spell_bar: SpellBar
var collapsed = true


func init(_spell_bar: SpellBar):
	init_clickable($"VBC/HBC")
	spell = spell_container.get_child(0)
	spell_name.text = spell.resource.name
	description.text = spell.resource.description if spell.resource.description != "" else "non renseignée"
	spell_bar = _spell_bar
	clicked.connect(_on_clicked)


func _on_check_box_toggled(toggled_on):
	if toggled_on:
		spell_bar.add_spell(spell.resource)
	else:
		spell_bar.remove_spell(spell)


func _on_clicked(_self):
	collapsed = !collapsed
	$"VBC/DescriptionContainer".visible = !collapsed
	print(collapsed)
