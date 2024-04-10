class_name Item
extends DraggableControl

const item_scene: PackedScene = preload("res://scenes/inventory/item.tscn")


var count = 1:
	set(value):
		count = value
		update_count_label()
var equip_type

func _ready():
	init_draggable()
	update_count_label()


func init(item_res: ItemResource, _inventory: Inventory):
	name = item_res.name
	self.texture = item_res.texture
	inventory = _inventory
	equip_type = item_res.get("equip_type")


func update_count_label():
	$"Count".text = str(count) if count > 1 else ""


static func create(item_res: ItemResource, _inventory: Inventory) -> Item:
	var item: Item = item_scene.instantiate()
	item.init(item_res, _inventory)
	return item


static func equals(item1: Item, item2: Item) -> bool:
	return (item1.equip_type == null or item2.equip_type == null) and item1.name == item2.name
