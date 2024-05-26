class_name ItemTypeResource
extends Resource


@export var _id: int
@export var _name: String
@export var _category_id: int

static func create(id: int, name: String, category_id: int) -> ItemTypeResource:
	var type = ItemTypeResource.new()
	type._id = id
	type._name = name
	type._category_id = category_id
	return type
