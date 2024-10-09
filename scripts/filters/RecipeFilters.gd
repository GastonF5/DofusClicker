class_name RecipeFilters
extends Control


const StatType = Caracteristique.Type

var applied_filters = []

signal filter_toggle

var _min: int
var _max: int
var _craftable: bool = false

@export var carac_container1: VBoxContainer
@export var carac_container2: VBoxContainer
@export var craftable_checkbox: CheckBox

func _ready():
	_min = $HBC/LevelFilter/MinSpin.min_value
	_max = $HBC/LevelFilter/MaxSpin.max_value
	_craftable = false
	init()


func init():
	var toggle: ToggleControl
	var _count := 0
	var container: VBoxContainer
	for categorie in StatsManager.stats_categories.keys():
		if categorie != "Favoris":
			toggle = StatsManager.toggle_scene.instantiate()
			toggle.button.text = categorie
			init_toggle_panel(toggle, categorie)
			if _count < 4:
				container = carac_container1
			else:
				container = carac_container2
			container.add_child(toggle)
			toggle.init(true)
			_count += 1


func init_toggle_panel(toggle: ToggleControl, categorie: String):
	for type in StatsManager.stats_categories[categorie]:
		Filter.create(StatType.find_key(type), apply_filter, toggle.stats_container)
		toggle.stats_container.add_child(StatsManager.stat_separator_scene.instantiate())
	toggle.stats_container.get_child(-1).queue_free()


func apply_filter(apply: bool, filter_name: String):
	if apply:
		applied_filters.append(filter_name)
	else:
		applied_filters.remove_at(applied_filters.find(filter_name))
	filter_toggle.emit()


func _on_check_box_toggled(toggled_on):
	_craftable = toggled_on
	filter_toggle.emit()


func _on_min_spin_value_changed(value):
	_min = value
	filter_toggle.emit()


func _on_max_spin_value_changed(value):
	_max = value
	filter_toggle.emit()
