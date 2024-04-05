class_name Item
extends DraggableControl

const item_scene = preload("res://scenes/inventory/item.tscn")


var count = 1:
	set(value):
		count = value
		update_count()


func _ready():
	init_draggable()
	update_count()


func init(item_res: ItemResource):
	name = item_res.name
	self.texture = item_res.texture


func update_count():
	$"Count".text = str(count) if count > 1 else ""


static func create(item_res: ItemResource) -> Item:
	var item = item_scene.instantiate()
	item.init(item_res)
	return item
