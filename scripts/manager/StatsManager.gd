extends AbstractManager


const StatType = Caracteristique.Type
const Element = Caracteristique.Element

const stat_scene = preload("res://scenes/stats/stat.tscn")
const toggle_scene = preload("res://scenes/stats/toggle_stat_panel.tscn")
const favori_scene = preload("res://scenes/stats/stat_favori.tscn")

const stat_separator_scene = preload("res://scenes/separators/stat_separator.tscn")
const container_separator_scene = preload("res://scenes/separators/container_separator.tscn")

var stats_categories = {
	"Favoris": [],
	"Caractéristiques Secondaires": [StatType.PUISSANCE, StatType.DOMMAGES, StatType.SOIN, StatType.INVOCATIONS, StatType.PROSPECTION],
	"Critique": [StatType.CRITIQUE, StatType.DO_CRITIQUES, StatType.RES_CRITIQUES],
	"Dommages élémentaires": [StatType.DO_AIR, StatType.DO_EAU, StatType.DO_TERRE, StatType.DO_FEU, StatType.DO_NEUTRE],
	"Dommages autres": [StatType.DO_MELEE, StatType.DO_DISTANCE, StatType.DO_SORTS, StatType.DO_ARME],
	"Résistances élémentaires (fixe)": [StatType.RES_AIR_FIXE, StatType.RES_EAU_FIXE, StatType.RES_TERRE_FIXE, StatType.RES_FEU_FIXE, StatType.RES_NEUTRE_FIXE],
	"Résistances élémentaires (%)": [StatType.RES_AIR, StatType.RES_EAU, StatType.RES_TERRE, StatType.RES_FEU, StatType.RES_NEUTRE],
	"Poussée": [StatType.DO_POU, StatType.RES_POU],
	"Retrait": [StatType.RET_PA, StatType.RET_PM, StatType.RES_PA, StatType.RES_PM],
}

var stats_container: Panel
var reset_button: Button
var points_label: Label

var caracteristiques: Array[Caracteristique] = []

var points = 0
var max_points = 0


func reset():
	stats_container = null
	reset_button = null
	points_label = null
	caracteristiques.clear()
	points = 0
	max_points = 0
	super()


func initialize():
	stats_container = Globals.stats_container
	reset_button = stats_container.get_node("%ResetButton")
	points_label = stats_container.get_node("%PointsLabel")
	Globals.stats_container.init()
	create_caracteristiques()
	reset_button.button_up.connect(reset_points)
	update_points_label()
	Globals.xp_bar.lvl_up.connect(on_lvl_up)
	if !EquipmentManager.equiped.is_connected(on_equiped):
		EquipmentManager.equiped.connect(on_equiped)
	if !EquipmentManager.desequiped.is_connected(on_desequiped):
		EquipmentManager.desequiped.connect(on_desequiped)
	super()


func create_caracteristiques():
	var carac_nodes = get_tree().get_nodes_in_group("caracteristique")
	for carac in carac_nodes:
		if !carac.initialized:
			carac.init()
		caracteristiques.append(carac)
		if carac.modifiable:
			carac.consume_point.connect(on_point_consumed)


func reset_caracteristiques():
	for carac in caracteristiques.filter(func(c): return c.type != StatType.VITALITE):
		carac.amount = carac.base_amount + carac.equip_amount
	PlayerManager.pa_bar.reset()
	PlayerManager.pm_bar.reset()
	PlayerManager.player_entity.hp_bar.shield_val = 0


func on_point_consumed(amount: int, type: StatType):
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


func apply_carac_bonus(type: StatType, amount: int):
	match type:
		StatType.VITALITE:
			PlayerManager.max_hp += amount


func _process(_delta):
	if !Globals.quitting:
		if reset_button and is_instance_valid(reset_button):
			reset_button.disabled = points == max_points or GameManager.in_fight


func reset_points():
	points = max_points
	for carac in caracteristiques:
		if carac.modifiable:
			var diff = -carac.base_amount
			carac.base_amount = 0
			apply_carac_bonus(carac.type, diff)
	update_points_label()


func update_points_label():
	points_label.text = str(points)


func on_lvl_up():
	max_points += 5
	points += 5
	PlayerManager.max_hp += 5
	PlayerManager.hp_bar.reset()
	update_points_label()
	for spell_button: SpellButton in Globals.spells_container.get_node("%SpellContainer").get_children():
		spell_button._set_disabled()


func get_caracteristique_for_type(type: StatType) -> Caracteristique:
	var carac = caracteristiques.filter(func(c): return c.type == type)
	if carac.size() != 1:
		#Globals.console.log_error("Plus d'une caractéristique a été trouvée pour le type : " + StatType.find_key(type))
		return null
	return carac[0]


func get_caracteristique_for_element(element: Element, dommages := false) -> Caracteristique:
	return get_caracteristique_for_type(get_type_for_element(element, dommages))


func get_type_for_element(element: Element, dommages := false):
	match element:
		Element.AIR: return StatType.AGILITE if !dommages else StatType.DO_AIR
		Element.EAU: return StatType.CHANCE if !dommages else StatType.DO_EAU
		Element.FEU: return StatType.INTELLIGENCE if !dommages else StatType.DO_FEU
		Element.TERRE, Element.NEUTRE: return StatType.FORCE if !dommages else StatType.DO_TERRE
		_:
			push_error("Element not found")


func check_modifiable_on_caracteristiques():
	for carac in caracteristiques:
		if carac.modifiable:
			carac.check_modifiable()


func get_carac_amount(carac) -> int:
	if carac is StatResource:
		return get_stat_amount(carac)
	return 0 if !carac else carac.amount


func get_stat_amount(stat: StatResource) -> int:
	return 0 if !stat else stat.amount
