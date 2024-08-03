class_name StatDescription
extends Control


@export var txt: TextureRect
@export var lbl: Label


func update(texture: Texture2D, label: String):
	txt.texture = texture
	lbl.text = label if label != "" else "0"


static func create(stat_res: StatResource):
	var stat_description = load("res://scenes/stats/stat_description.tscn").instantiate()
	var texture = StatResource.load_texture(stat_res.type)
	stat_description.update(texture, stat_res.get_effect_label())
	return stat_description


func update_with_entity(entity: Entity):
	var carac_amount := ""
	var stat_lbl = name.replace("Description", "")
	var texture = StatResource.load_texture(Caracteristique.Type.get(stat_lbl.to_snake_case().to_upper()))
	match stat_lbl:
		"Vitalite":
			carac_amount = "%d / %d" % [entity.hp_bar.cval, entity.hp_bar.mval]
			texture = load("res://assets/description_icons/icon_vitalite.png")
		"Erosion":
			carac_amount = str(entity.erosion * 100 - 5)
	if carac_amount == "":
		var carac = entity.get_caracteristique_for_type(Caracteristique.Type.get(stat_lbl.to_snake_case().to_upper()))
		carac_amount = str(carac.amount) if carac else ""
		if stat_lbl.begins_with("Res") and !(stat_lbl.ends_with("PA") or stat_lbl.ends_with("PM")):
			carac_amount += "%"
	update(texture, carac_amount)
