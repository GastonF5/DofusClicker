class_name RecipeFilters
extends Control


const CARAC = Caracteristique.Type
const carac_black_list = [CARAC.PV, CARAC.EROSION]
var applied_filters = []

signal filter_toggle

var _min: int
var _max: int
var _craftable: bool = false

@export var carac_container: HBoxContainer
@export var craftable_checkbox: CheckBox

func _ready():
	_min = $LevelFilter/MinSpin.min_value
	_max = $LevelFilter/MaxSpin.max_value
	_craftable = false
	init()


func init():
	var _count := 0
	var container: VBoxContainer
	for carac in CARAC:
		if _count in range(0, 13):
			container = carac_container.get_node("FiltersContainer1")
		elif _count in range(13, 27):
			container = carac_container.get_node("FiltersContainer2")
		else:
			container = carac_container.get_node("FiltersContainer3")
		if !carac_black_list.has(CARAC.get(carac)):
			Filter.create(carac, apply_filter, container)
			_count += 1


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
