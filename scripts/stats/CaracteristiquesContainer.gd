class_name CaracteristiquesContainer extends Panel

const stat_scene = preload("res://scenes/stats/stat.tscn")
const toggle_scene = preload("res://scenes/stats/toggle_stat_panel.tscn")
const favori_scene = preload("res://scenes/stats/stat_favori.tscn")

const Stat = Caracteristique.Type

@export var stat_separator: TextureRect
@export var toggle_separator: TextureRect

var favoris_panel: ToggleControl

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
	var toggle: ToggleControl
	for categorie in caracteristiques.keys():
		toggle = toggle_scene.instantiate()
		toggle.button.text = categorie
		init_toggle_panel(toggle, categorie)
		toggle_container.add_child(toggle)
		toggle_container.add_child(toggle_separator.duplicate())
		toggle.init()
		if categorie == "Favoris":
			favoris_panel = toggle
	toggle_container.get_child(-1).queue_free()
	favoris_panel.content.get_child(0).custom_minimum_size = Vector2(toggle.content.size.x, 0)


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


func favori_toggled(toggled: bool, stat: Caracteristique):
	if toggled:
		stat.favori = favori_scene.instantiate()
		add_favori(stat)
	else:
		remove_favori(stat)


func add_favori(stat: Caracteristique):
	var container = favoris_panel.stats_container
	if container.get_child_count() != 0:
		container.add_child(stat_separator.duplicate())
	else:
		favoris_panel.button.disabled = false
		favoris_panel.button.button_pressed = true
	container.add_child(stat.favori)


func remove_favori(stat: Caracteristique):
	var container = favoris_panel.stats_container
	var index = stat.favori.get_index()
	# on supprime le séparateur si c'est pas le dernier favori
	if index >= 1:
		container.get_child(index - 1).queue_free()
	if index == 0 and container.get_child_count() > 2:
		container.get_child(index + 1).queue_free()
	if container.get_child_count() < 2:
		favoris_panel.button.disabled = true
		favoris_panel.button.set_pressed_no_signal(false)
		await favoris_panel.toggle_content(false)
	container.get_child(index).queue_free()
