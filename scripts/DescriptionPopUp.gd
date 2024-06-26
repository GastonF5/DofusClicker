class_name DescriptionPopUp
extends Control


@export var texture: TextureRect
@export var name_label: RichTextLabel
@export var description_label: RichTextLabel

@export var effects_label: Label
@export var effects_container: VBoxContainer


func init_item(item_res: ItemResource, low: bool, stats: Array[StatResource] = []):
	name = item_res.name.to_pascal_case() + "Description"
	texture.texture = item_res.get_texture(low)
	compute_name_label(item_res.name, item_res.id, item_res.level)
	clear_effect_labels()
	if !stats.is_empty():
		for effect in stats:
			add_effect_label(effect)
	elif item_res.equip_res:
		for effect in item_res.equip_res.stats:
			add_effect_label(effect)
	set_mouse_ignore()
	visible = true


func init_spell(spell_res: SpellResource):
	name = spell_res.name.to_pascal_case() + "Description"
	texture.texture = spell_res.texture
	compute_name_label(spell_res.name, spell_res.id)
	compute_description_label(spell_res.description)
	clear_effect_labels()
	set_mouse_ignore()
	visible = true


func set_mouse_ignore():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in get_children(true):
		child.mouse_filter = Control.MOUSE_FILTER_IGNORE


func compute_name_label(_name: String, _id: int, _level: int = -1):
	name_label.clear()
	name_label.push_outline_size(-6)
	name_label.append_text(_name + " (%d)" % _id)
	if _level >= 0:
		name_label.push_color(Color.GRAY)
		name_label.append_text("\n" + "Niveau %d" % _level)
		name_label.pop()


func compute_description_label(_description: String):
	description_label.clear()
	description_label.push_color(Color.LIGHT_GRAY)
	description_label.append_text(_description)


func clear_effect_labels():
	for label in effects_container.get_children():
		effects_container.remove_child(label)
		label.queue_free()


func add_effect_label(stat_res: StatResource):
	var label = Label.new()
	label.text = stat_res.get_effect_label()
	label.add_theme_color_override("font_color", stat_res.get_label_color())
	effects_container.add_child(label)
