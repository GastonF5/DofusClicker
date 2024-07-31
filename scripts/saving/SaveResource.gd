class_name SaveResource
extends Resource



var date: String


var class_id: int
var xp_amount := 0

# Les areas sont des arrays contenant : [area_id, is_subarea]
var discovered_areas: Array = []
# [selected_area_id, selected_subarea_id]
var current_areas: Array = []

var inventory: Array = []
var equipment: Dictionary = {}
var characteristics: Dictionary = {}


func set_date_now():
	var time_dict = Time.get_datetime_dict_from_system()
	date = Time.get_datetime_string_from_datetime_dict(time_dict, false)


static func create() -> SaveResource:
	var save = SaveResource.new()
	save.set_date_now()
	return save


func to_dict() -> Dictionary:
	var dict := {}
	for property in get_property_list():
		var pname: String = property["name"]
		if self.get(pname):
			dict[pname] = self.get(pname)
	return dict


static func to_save_res(dict: Dictionary) -> SaveResource:
	var save_res = SaveResource.new()
	for property in dict.keys():
		save_res.set(property, dict[property])
	return save_res
