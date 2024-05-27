class_name ItemSetResource
extends Resource


@export var id: int
@export var name: String
@export var item_ids: Array


static func create(id: int, name: String, item_ids: Array) -> ItemSetResource:
	var item_set = ItemSetResource.new()
	item_set.id = id
	item_set.name = name
	item_set.item_ids = item_ids
	return item_set
