class_name ItemDescription
extends PanelContainer


@export var item_texture: TextureRect
@export var name_label: RichTextLabel

@export var effects_label: Label
@export var effects_container: VBoxContainer


func init(item_res: ItemResource, low: bool, stats: Array[StatResource] = []):
	name = item_res.name.to_pascal_case() + "Description"
	item_texture.texture = item_res.get_texture(low)
	compute_name_label(item_res)
	clear_effect_labels()
	if !stats.is_empty():
		for effect in stats:
			add_effect_label(effect)
	elif item_res.equip_res:
		for effect in item_res.equip_res.stats:
			add_effect_label(effect)
	set_mouse_ignore()


func set_mouse_ignore():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in get_children(true):
		child.mouse_filter = Control.MOUSE_FILTER_IGNORE


func compute_name_label(item_res: ItemResource):
	name_label.clear()
	name_label.push_outline_size(-6)
	name_label.append_text(item_res.name + " (%d)" % item_res.id + "\n")
	name_label.push_color(Color.GRAY)
	name_label.append_text("Niveau %s" % item_res.level)
	name_label.pop()


func clear_effect_labels():
	for label in effects_container.get_children():
		effects_container.remove_child(label)
		label.queue_free()


func add_effect_label(stat_res: StatResource):
	var label = Label.new()
	label.text = stat_res.get_effect_label()
	label.add_theme_color_override("font_color", stat_res.get_label_color())
	effects_container.add_child(label)
