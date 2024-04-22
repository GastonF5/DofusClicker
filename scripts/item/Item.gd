class_name Item
extends DraggableControl

const item_scene: PackedScene = preload("res://scenes/inventory/item.tscn")


var count = 1:
	set(value):
		count = value
		update_count_label()

var resource: ItemResource
var stats: Array[StatResource] = []

func _ready():
	update_count_label()


func init(item_res: ItemResource, _inventory: Inventory, _draggable = true):
	var res = FileLoader.get_equipment_resource(item_res.resource_path)
	name = res.name
	self.texture = res.texture
	inventory = _inventory
	resource = res
	count = res.count
	draggable = _draggable
	
	if res.equip_res:
		for stat in res.equip_res.stats:
			var new_stat = stat.duplicate()
			new_stat.init_amount()
			stats.append(new_stat)


func update_count_label():
	$"Count".text = str(count) if count > 1 else ""


static func create(item_res: ItemResource, _inventory: Inventory, _draggable = true) -> Item:
	var item: Item = item_scene.instantiate()
	item.init(item_res, _inventory, _draggable)
	return item


static func equals(item1, item2) -> bool:
	var item1_res = item1
	var item2_res = item2
	if is_instance_of(item1, Item):
		item1_res = item1.resource
	if is_instance_of(item2, Item):
		item2_res = item2.resource
		
	if item1_res.equip_res:
		return false
	return item1_res.name == item2_res.name
