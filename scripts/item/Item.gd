class_name Item
extends DraggableControl

var count = 1:
	set(value):
		count = value
		update_count_label()

var resource: ItemResource
var stats: Array[StatResource] = []
var low_texture: bool

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


func _on_entered_tree():
	load_texture()


func init(item_res: ItemResource, _inventory: Inventory, _draggable = true, low = true):
	low_texture = low
	name = item_res.name
	inventory = _inventory
	resource = item_res
	count = item_res.count
	draggable = _draggable
	
	if item_res.equip_res:
		for stat in item_res.equip_res.stats:
			var new_stat = stat.duplicate()
			new_stat.init_amount()
			stats.append(new_stat)


func load_texture():
	var api: API = $%API
	var url = resource.low_img_url if low_texture else resource.high_img_url
	print(url)
	await api.await_for_request_completed(api.request(url))
	print(url)
	self.texture = api.get_texture(url)


func update_count_label():
	$"Count".text = str(count) if count > 1 else ""


static func create(item_res: ItemResource, _inventory: Inventory, _draggable = true, low_texture = true) -> Item:
	var item: Item = FileLoader.get_packed_scene("item/item").instantiate()
	item.init(item_res, _inventory, _draggable, low_texture)
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
