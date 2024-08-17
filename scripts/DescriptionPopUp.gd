class_name DescriptionPopUp
extends Control


const PROBA_CRIT := "Critique %d"
const BONUS_CRIT := "(+%d Dommages)"

@export var texture: TextureRect
@export var name_label: RichTextLabel
@export var description_label: RichTextLabel
@export var areas_label: Label

@export var effects_label: Label
@export var effects_container: VBoxContainer
@export var hit_effects_container: VBoxContainer
@export var crit_container: VBoxContainer

@export var pa_cost_label: Label

@export var separator: TextureRect


func init_item(item_res: ItemResource, low: bool, stats: Array[StatResource] = []):
	# Nom et texture
	separator.visible = false
	set_crit_container()
	name = item_res.name.to_pascal_case() + "Description"
	texture.texture = item_res.get_texture(low)
	compute_name_label(item_res.name, item_res.id, item_res.level)
	clear_effects()
	# Statistiques de l'item
	if !stats.is_empty():
		for effect in stats:
			add_effect_label(effect)
	elif item_res.equip_res:
		for effect in item_res.equip_res.stats:
			add_effect_label(effect)
	if item_res.equip_res and item_res.equip_res.is_weapon() and !item_res.equip_res.weapon_resource._hit_effects.is_empty():
		set_crit_container(item_res.equip_res.weapon_resource)
		separator.visible = true
		for hit_effect in item_res.equip_res.weapon_resource._hit_effects:
			add_hit_effect_label(hit_effect)
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
	clear_effects()
	for effect in spell_res.effects:
		if effect.visible_in_description and effect.get_effect_label(0) != "ERREUR":
			add_spell_effect_label(effect)
	set_effect_visibility(effects_container.get_child_count() != 0)
	set_mouse_ignore()
	visible = true


func init_spell_in_class_peeker(spell_res: SpellResource):
	name = spell_res.name.to_pascal_case() + "DescriptionClassPeeker"
	texture.texture = spell_res.texture
	name_label.text = spell_res.name
	compute_description_label(spell_res.description)


func init_entity(entity: Entity):
	if name != "EntityDescription":
		push_error("C'est un problème ça là oh")
		return
	name_label.text = entity.name_label.text
	texture.texture = entity.texture_rect.texture
	for stat_description in get_tree().get_nodes_in_group("stat_description"):
		stat_description.update_with_entity(entity)
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


func clear_effects():
	for effect in effects_container.get_children():
		effects_container.remove_child(effect)
		effect.queue_free()
	if hit_effects_container:
		for hit_effect in hit_effects_container.get_children():
			hit_effects_container.remove_child(hit_effect)
			hit_effect.queue_free()


func add_effect_label(stat_res: StatResource, hit_effect: HitEffectResource = null):
	var caracteristique = StatDescription.create(stat_res, hit_effect)
	if !hit_effect:
		caracteristique.lbl.add_theme_color_override("font_color", stat_res.get_label_color())
	if hit_effect:
		hit_effects_container.add_child(caracteristique)
	else:
		effects_container.add_child(caracteristique)


func add_hit_effect_label(hit_effect: HitEffectResource):
	var stat_res = StatResource.create(hit_effect.get_characteristic(false), hit_effect._amounts._min, hit_effect._amounts._max)
	add_effect_label(stat_res, hit_effect)


func add_spell_effect_label(effect_res: EffectResource):
	var label = Label.new()
	label.text = effect_res.get_effect_label(0)
	label.add_theme_color_override("font_color", effect_res.get_label_color())
	effects_container.add_child(label)


func set_effect_visibility(is_effect_visible: bool):
	effects_label.get_parent().visible = is_effect_visible


func set_crit_container(weapon_res: WeaponResource = null):
	var proba_crit: Label = crit_container.get_child(0)
	var bonus_crit: Label = crit_container.get_child(1)
	if weapon_res:
		proba_crit.text = PROBA_CRIT % weapon_res._crit_proba + "%"
		var bonus = weapon_res.get_bonus_crit()
		if bonus > 0:
			bonus_crit.text = BONUS_CRIT % bonus
	else:
		proba_crit.text = ""
		bonus_crit.text = ""
