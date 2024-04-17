class_name Item
extends DraggableControl

const item_scene: PackedScene = preload("res://scenes/inventory/item.tscn")


var count = 1:
	set(value):
		count = value
		update_count_label()

var resource: ItemResource

func _ready():
	update_count_label()


func init(item_res: ItemResource, _inventory: Inventory, _draggable = true):
	name = item_res.name
	self.texture = item_res.texture
	inventory = _inventory
	resource = item_res
	count = item_res.count
	draggable = _draggable


func update_count_label():
	$"Count".text = str(count) if count > 1 else ""


static func create(item_res: ItemResource, _inventory: Inventory, _draggable = true) -> Item:
	var item: Item = item_scene.instantiate()
	item.init(item_res, _inventory, _draggable)
	return item


static func equals(item1, item2) -> bool:
	return item1.name == item2.name
