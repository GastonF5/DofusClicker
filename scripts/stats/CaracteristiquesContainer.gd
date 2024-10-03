class_name CaracteristiquesContainer extends Panel

const stat_scene = preload("res://scenes/stats/stat.tscn")
const toggle_scene = preload("res://scenes/stats/toggle_stat_panel.tscn")

const Stat = Caracteristique.Type

@export var stat_separator: TextureRect
@export var toggle_separator: TextureRect

var toggle_panels: Array:
	get: return get_tree().get_nodes_in_group("toggle_stat_panel")

var caracteristiques = {
	"Favoris": [],
	"Caractéristiques Secondaires": [Stat.PUISSANCE, Stat.DOMMAGES, Stat.SOIN, Stat.INVOCATIONS, Stat.PROSPECTION],
	"Critique": [Stat.CRITIQUE, Stat.DO_CRITIQUES, Stat.RES_CRITIQUES],
	"Dommages élémentaires": [Stat.DO_AIR, Stat.DO_EAU, Stat.DO_TERRE, Stat.DO_FEU, Stat.DO_NEUTRE],
	"Dommages autres": [Stat.DO_MELEE, Stat.DO_DISTANCE, Stat.DO_SORTS, Stat.DO_ARME],
	"Résistances élémentaires (fixe)": [Stat.RES_AIR_FIXE, Stat.RES_EAU_FIXE, Stat.RES_TERRE_FIXE, Stat.RES_FEU_FIXE, Stat.RES_NEUTRE_FIXE],
	"Résistances élémentaires (%)": [Stat.RES_AIR, Stat.RES_EAU, Stat.RES_TERRE, Stat.RES_FEU, Stat.RES_NEUTRE],
	"Poussée": [Stat.DO_POU, Stat.RES_POU],
	"Retrait": [Stat.RET_PA, Stat.RET_PM, Stat.RES_PA, Stat.RES_PM],
}

func init():
	var toggle_container = $MarginContainer/ScrollContainer/VBC
	for categorie in caracteristiques.keys():
		var toggle = toggle_scene.instantiate()
		toggle.button.text = categorie
		init_toggle_panel(toggle, categorie)
		toggle_container.add_child(toggle)
		toggle_container.add_child(toggle_separator.duplicate())
	toggle_container.get_child(-1).queue_free()


func init_toggle_panel(toggle: ToggleControl, categorie: String):
	for type in caracteristiques[categorie]:
		var stat = stat_scene.instantiate()
		stat.name = Stat.find_key(type)
		stat.modifiable = false
		stat.init()
		stat.get_node("Favori").toggled.connect(favori_toggled.bind(stat))
		toggle.stats_container.add_child(stat)
		toggle.stats_container.add_child(stat_separator.duplicate())
	if toggle.stats_container.get_child_count() > 0:
		toggle.stats_container.get_child(-1).queue_free()


func get_toggle_panel(panel_name: String):
	var filtered = toggle_panels.filter(func(p): return p.button.text == panel_name)
	if filtered.is_empty():
		push_error("No toggle stat panel with name %s" % panel_name)
	else:
		return filtered[0]


func favori_toggled(toggled: bool, stat: Caracteristique):
	if toggled:
		print("%s added to favoris" % stat.name)
	else:
		print("%s removed from favoris" % stat.name)
