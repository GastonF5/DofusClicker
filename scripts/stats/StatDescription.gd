class_name StatDescription
extends Control


static var scene = preload("res://scenes/stats/stat_description.tscn")

static func create(stat_res: StatResource, hit_effect: HitEffectResource = null):
	var stat_description = StatDescription.scene.instantiate()
	var texture
	if hit_effect:
		texture = FileLoader.get_stat_asset(Caracteristique.Type.find_key(hit_effect.get_characteristic()))
		stat_description.update(texture, hit_effect.get_effect_label())
	else:
		texture = FileLoader.get_stat_asset(Caracteristique.Type.find_key(stat_res.type))
		stat_description.update(texture, stat_res.get_effect_label())
	return stat_description


static func create_with_conso_effect(effect: ConsommableEffect):
	var stat_description = StatDescription.scene.instantiate()
	var charac_label = Caracteristique.Type.find_key(effect.characteristic)
	var texture = FileLoader.get_stat_asset(charac_label)
	var label = "%d %s" % [effect.amount, StatResource.get_type_label(charac_label)]
	stat_description.update(texture, label)
	return stat_description


@export var txt: TextureRect
@export var lbl: Label


func update(texture: Texture2D, label: String):
	txt.texture = texture
	lbl.text = label if label != "" else "0"


func update_with_entity(entity: Entity):
	var carac_amount := ""
	var stat_lbl = name.replace("Description", "")
	var texture = StatResource.load_texture(Caracteristique.Type.get(stat_lbl.to_snake_case().to_upper()))
	match stat_lbl:
		"Vitalite":
			carac_amount = "%d / %d" % [entity.hp_bar.cval, entity.hp_bar.mval]
			texture = preload("res://assets/description_icons/icon_vitalite.png")
		"Erosion":
			carac_amount = str(entity.erosion * 100 - 5)
	if carac_amount == "":
		var carac = entity.get_caracteristique_for_type(Caracteristique.Type.get(stat_lbl.to_snake_case().to_upper()))
		carac_amount = str(carac.amount) if carac else ""
		if stat_lbl.begins_with("Res") and !(stat_lbl.ends_with("PA") or stat_lbl.ends_with("PM")):
			carac_amount += "%"
	update(texture, carac_amount)
