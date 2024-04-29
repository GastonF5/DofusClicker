class_name StatsManager
extends Node


@export var stats_container: VBoxContainer
@export var points_label: Label
@export var reset_button: Button

static var caracteristiques: Array[Caracteristique] = []
static var console: Console

static var points = 0
static var max_points = 0

func _ready():
	for node in stats_container.get_children():
		if Caracteristique.Type.keys().has(node.name.to_upper()):
			caracteristiques.append(node)
			node.consume_point.connect(update_points_label)
	reset_button.button_up.connect(reset_points)
	reset_points()
	$"../PlayerManager".xp_bar.lvl_up.connect(on_lvl_up)
	$"../EquipmentManager".equiped.connect(on_equiped)
	$"../EquipmentManager".desequiped.connect(on_desequiped)


func on_equiped(item: Item):
	for stat: StatResource in item.stats:
		var carac: Caracteristique = StatsManager.get_caracteristique_for_type(stat.type)
		if carac:
			carac.equip_amount += stat.amount


func on_desequiped(item: Item):
	for stat: StatResource in item.stats:
		var carac: Caracteristique = StatsManager.get_caracteristique_for_type(stat.type)
		if carac:
			carac.equip_amount -= stat.amount


func _process(_delta):
	reset_button.disabled = points == max_points


func reset_points():
	points = max_points
	for carac in caracteristiques:
		carac.base_amount = 0
	update_points_label()


func update_points_label():
	points_label.text = str(points)


func on_lvl_up():
	max_points += 5
	points += 5
	update_points_label()


static func get_caracteristique_for_type(type: Caracteristique.Type) -> Caracteristique:
	var carac = caracteristiques.filter(func(c): return c.type == type)
	if carac.size() != 1:
		console.log_error("Aucune ou plus d'une caractéristique a été trouvée pour le type : " + Caracteristique.Type.find_key(type))
		return null
	return carac[0]
