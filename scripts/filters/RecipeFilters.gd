class_name RecipeFilters
extends Control


const CARAC = Caracteristique.Type
var applied_filters = []

signal filter_toggle


func _ready():
	init()


func init():
	for carac in CARAC:
		Filter.create(carac, apply_filter, self)


func apply_filter(apply: bool, filter_name: String):
	if apply:
		applied_filters.append(filter_name)
	else:
		applied_filters.remove_at(applied_filters.find(filter_name))
	filter_toggle.emit(applied_filters)
