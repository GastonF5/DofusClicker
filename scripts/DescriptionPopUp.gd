class_name DescriptionPopUp
extends Control


@export var texture: TextureRect
@export var name_label: RichTextLabel
@export var description_label: RichTextLabel
@export var areas_label: Label

@export var effects_label: Label
@export var effects_container: VBoxContainer

@export var pa_cost_label: Label


func init_item(item_res: ItemResource, low: bool, stats: Array[StatResource] = []):
	# Nom et texture
	name = item_res.name.to_pascal_case() + "Description"
	texture.texture = item_res.get_texture(low)
	compute_name_label(item_res.name, item_res.id, item_res.level)
	clear_effect_labels()
	# Statistiques de l'item
	if !stats.is_empty():
		for effect in stats:
			add_effect_label(effect)
	elif item_res.equip_res:
		for effect in item_res.equip_res.stats:
			add_effect_label(effect)
	set_effect_visibility(!stats.is_empty() and !(item_res.equip_res and item_res.equip_res.stats.is_empty()))
	# Zones sur lesquelles l'item est droppable
	if !item_res.get_monsters():
		areas_label.visible = false
	else:
		areas_label.visible = true
		areas_label.text = item_res.get_drop_areas()
	
	set_mouse_ignore()
	visible = true


func init_spell(spell_res: SpellResource):
	name = spell_res.name.to_pascal_case() + "Description"
	texture.texture = spell_res.texture
	pa_cost_label.text = str(spell_res.pa_cost)
	compute_name_label(spell_res.name, spell_res.id)
	compute_description_label(spell_res.description)
	clear_effect_labels()
	for effect in spell_res.effects:
		if effect.visible_in_description and effect.get_effect_label(0) != "ERREUR":
			add_spell_effect_label(effect)
	set_effect_visibility(effects_container.get_child_count() != 0)
	set_mouse_ignore()
	visible = true


func init_entity(entity: Entity):
	if name != "EntityDescription":
		push_error("C'est un problème ça là oh")
		return
	name_label.text = entity.name_label.text
	texture.texture = entity.texture_rect.texture
	for stat_description in get_tree().get_nodes_in_group("stat_description"):
		var icon_path = "res://assets/description_icons/"
		var carac_label := ""
		var stat_lbl = stat_description.name.replace("Description", "")
		match stat_lbl:
			"Vitalite":
				icon_path += "icon_pv.png"
				carac_label = "%d / %d" % [entity.hp_bar.cval, entity.hp_bar.mval]
			"PA":
				icon_path += "icon_pa.png"
			"PM":
				icon_path += "icon_pm.png"
			"Erosion":
				icon_path += "icon_erosion.png"
				carac_label = str(entity.erosion * 100 - 5)
			_:
				icon_path = "res://assets/stats/stat_icon/%s.png" % stat_lbl.to_snake_case().to_lower()
		if carac_label == "":
			var carac = entity.get_caracacteristique_for_type(Caracteristique.Type.get(stat_lbl.to_snake_case().to_upper()))
			carac_label = str(carac.amount) if carac else ""
			if stat_lbl.begins_with("Res") and !(stat_lbl.ends_with("PA") or stat_lbl.ends_with("PM")):
				carac_label += "%"
		stat_description.update(load(icon_path), carac_label)
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


func add_spell_effect_label(effect_res: EffectResource):
	var label = Label.new()
	label.text = effect_res.get_effect_label(0)
	label.add_theme_color_override("font_color", effect_res.get_label_color())
	effects_container.add_child(label)


func set_effect_visibility(is_visible: bool):
	effects_label.get_parent().visible = is_visible
