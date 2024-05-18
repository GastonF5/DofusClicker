class_name Item
extends DraggableControl


var count = 1:
	set(value):
		count = value
		update_count_label()

var resource: ItemResource
var stats: Array[StatResource] = []

func _ready():
	update_count_label()


func _on_mouse_entered():
	if !PlayerManager.dragged_item:
		var item_description = PlayerManager.item_description
		item_description.visible = true
		item_description.init(resource, stats)


func _on_mouse_exited():
	if !PlayerManager.dragged_item:
		PlayerManager.item_description.visible = false


func init(item_res: ItemResource, _inventory: Inventory, _draggable = true):
	#var res = FileLoader.get_equipment_resource(item_res.resource_path)
	name = item_res.name
	inventory = _inventory
	resource = item_res
	self.texture = item_res.texture
	count = item_res.count
	draggable = _draggable
	
	if item_res.equip_res:
		for stat in item_res.equip_res.stats:
			var new_stat = stat.duplicate()
			new_stat.init_amount()
			stats.append(new_stat)


func update_count_label():
	$"Count".text = str(count) if count > 1 else ""


static func create(item_res: ItemResource, _inventory: Inventory, _draggable = true) -> Item:
	var item: Item = FileLoader.get_packed_scene("item/item").instantiate()
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
