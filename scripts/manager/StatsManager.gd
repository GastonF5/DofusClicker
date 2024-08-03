extends AbstractManager


const stat_type = Caracteristique.Type

var stats_container: Panel
var reset_button: Button
var points_label: Label

var caracteristiques: Array[Caracteristique] = []

static var points = 0
static var max_points = 0


func initialize():
	stats_container = Globals.stats_container
	reset_button = stats_container.get_node("%ResetButton")
	points_label = stats_container.get_node("%PointsLabel")
	create_caracteristiques()
	reset_button.button_up.connect(reset_points)
	update_points_label()
	Globals.xp_bar.lvl_up.connect(on_lvl_up)
	EquipmentManager.equiped.connect(on_equiped)
	EquipmentManager.desequiped.connect(on_desequiped)
	super()


func create_caracteristiques():
	var carac_nodes = get_tree().get_nodes_in_group("caracteristique")
	for carac in carac_nodes:
		var node_name = carac.name
		if node_name.begins_with("Résistance "):
			var node_name_split = node_name.split(" ")
			node_name = "RES_" + node_name_split[node_name_split.size() - 1]
		if node_name.begins_with("Dommages "):
			node_name = "DO_" + node_name.split(" ")[1]
		if node_name.begins_with("Retrait "):
			node_name = "RET_" + node_name.split(" ")[1]
		if Caracteristique.Type.keys().has(node_name.to_upper()) and !caracteristiques.has(carac):
			carac.init()
			carac.type = Caracteristique.Type.get(node_name.to_upper())
			caracteristiques.append(carac)
			if carac.modifiable:
				carac.consume_point.connect(on_point_consumed)


func reset_caracteristiques():
	for carac in caracteristiques.filter(func(c): return c.type != Caracteristique.Type.VITALITE):
		carac.amount = carac.base_amount + carac.equip_amount
	PlayerManager.pa_bar.reset()
	PlayerManager.pm_bar.reset()


func on_point_consumed(amount: int, type: stat_type):
	points -= amount
	update_points_label()
	apply_carac_bonus(type, amount)


func on_equiped(item: Item):
	for stat: StatResource in item.stats:
		var carac: Caracteristique = StatsManager.get_caracteristique_for_type(stat.type)
		if carac:
			carac.equip_amount += stat.amount
			apply_carac_bonus(stat.type, stat.amount)


func on_desequiped(item: Item):
	for stat: StatResource in item.stats:
		var carac: Caracteristique = StatsManager.get_caracteristique_for_type(stat.type)
		if carac:
			carac.equip_amount -= stat.amount
			apply_carac_bonus(stat.type, -stat.amount)


func apply_carac_bonus(type: Caracteristique.Type, amount: int):
	match type:
		stat_type.VITALITE:
			PlayerManager.max_hp += amount
		stat_type.CHANCE:
			StatsManager.get_caracteristique_for_type(stat_type.PROSPECTION).add(amount)


func _process(_delta):
	if reset_button: reset_button.disabled = points == max_points


func reset_points():
	points = max_points
	for carac in caracteristiques:
		if carac.modifiable:
			carac.base_amount = 0
	update_points_label()


func update_points_label():
	points_label.text = str(points)


func on_lvl_up():
	max_points += 5
	points += 5
	PlayerManager.max_hp += 5
	update_points_label()


func get_caracteristique_for_type(type: Caracteristique.Type) -> Caracteristique:
	var carac = caracteristiques.filter(func(c): return c.type == type)
	if carac.size() != 1:
		Globals.console.log_error("Aucune ou plus d'une caractéristique a été trouvée pour le type : " + Caracteristique.Type.find_key(type))
		return null
	return carac[0]
