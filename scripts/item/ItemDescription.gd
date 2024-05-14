class_name ItemDescription
extends PanelContainer


@export var item_texture: TextureRect
@export var name_label: RichTextLabel

@export var effects_label: Label
@export var effects_container: VBoxContainer

@export var description: Label

@export var item_resource_test: ItemResource


func _ready():
	if item_resource_test:
		init(item_resource_test)


func init(item_res: ItemResource, stats: Array[StatResource] = []):
	name = item_res.name.to_pascal_case() + "Description"
	item_texture.texture = item_res.texture
	compute_name_label(item_res)
	clear_effect_labels()
	if !stats.is_empty():
		for effect in stats:
			add_effect_label(effect)
	elif item_res.equip_res:
		for effect in item_res.equip_res.stats:
			add_effect_label(effect)
	else:
		effects_label.visible = false
		effects_container.visible = false
	#description.text = item_res.description
	set_mouse_ignore()


func set_mouse_ignore():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in get_children(true):
		child.mouse_filter = Control.MOUSE_FILTER_IGNORE


func compute_name_label(item_res: ItemResource):
	name_label.clear()
	name_label.push_outline_size(-6)
	name_label.append_text(item_res.name + "\n")
	name_label.push_color(Color.GRAY)
	name_label.append_text("Niveau %s" % item_res.niveau)
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
