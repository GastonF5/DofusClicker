class_name ItemTypeResource
extends Resource


@export var _id: int
@export var _name: String
@export var _category_id: int


static func create(id: int, type_name: String, category_id := 0) -> ItemTypeResource:
	var type = ItemTypeResource.new()
	type._id = id
	type._name = type_name
	type._category_id = category_id
	return type


func get_id():
	return _id

func get_item_type_name():
	return _name

func get_category_id():
	return _category_id
