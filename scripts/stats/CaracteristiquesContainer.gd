class_name CaracteristiquesContainer extends Panel

const Stat = Caracteristique.Type

var favoris_panel: ToggleControl

func init():
	var toggle_container = $MarginContainer/ScrollContainer/VBC
	var toggle: ToggleControl
	for categorie in StatsManager.stats_categories.keys():
		if categorie != "Caractéristiques primaires":
			toggle = StatsManager.toggle_scene.instantiate()
			toggle.button.text = categorie
			init_toggle_panel(toggle, categorie)
			toggle_container.add_child(toggle)
			toggle.init(categorie != "Favoris")
			if categorie == "Favoris":
				favoris_panel = toggle
	favoris_panel.content.get_child(0).custom_minimum_size = Vector2(toggle.content.size.x, 0)


func init_toggle_panel(toggle: ToggleControl, categorie: String):
	for type in StatsManager.stats_categories[categorie]:
		var stat = StatsManager.stat_scene.instantiate()
		stat.name = Stat.find_key(type)
		stat.modifiable = false
		stat.init()
		stat.get_node("Favori").toggled.connect(favori_toggled.bind(stat))
		toggle.stats_container.add_child(stat)
		toggle.stats_container.add_child(StatsManager.stat_separator_scene.instantiate())
	if toggle.stats_container.get_child_count() > 0:
		toggle.stats_container.get_child(-1).queue_free()


func favori_toggled(toggled: bool, stat: Caracteristique):
	if toggled:
		stat.favori = StatsManager.favori_scene.instantiate()
		add_favori(stat)
	else:
		remove_favori(stat)


func add_favori(stat: Caracteristique):
	var container = favoris_panel.stats_container
	if container.get_child_count() != 0:
		container.add_child(StatsManager.stat_separator_scene.instantiate())
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
