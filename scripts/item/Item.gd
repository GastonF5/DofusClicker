class_name Item
extends DraggableControl

var count = 1:
	set(value):
		count = value
		update_count_label()

var resource: ItemResource
var stats: Array[StatResource] = []
var low_texture: bool
var texture_loaded = false

var count_label: Label

signal texture_initialized

func _ready():
	update_count_label()


func _on_mouse_entered():
	super()
	if !PlayerManager.dragged_item:
		var item_description = PlayerManager.item_description
		item_description.visible = true
		item_description.init(resource, stats)


func _on_mouse_exited():
	super()
	if !PlayerManager.dragged_item:
		PlayerManager.item_description.visible = false


func _enter_tree():
	super()
	if !texture_loaded:
		load_texture()


func init(item_res: ItemResource, _inventory: Inventory, _draggable, low):
	count_label = $Count
	low_texture = low
	name = item_res.name
	inventory = _inventory
	resource = item_res
	count = item_res.count
	draggable = _draggable
	if low:
		count_label.position -= count_label.size / 3
		count_label.add_theme_font_size_override("font_size", 20)
	
	if item_res.equip_res:
		for stat in item_res.equip_res.stats:
			var new_stat = stat.duplicate()
			if !low:
				new_stat.init_amount()
			stats.append(new_stat)


func load_texture():
	var api: API = get_tree().current_scene.get_node("%API")
	var url = resource.low_img_url if low_texture else resource.high_img_url
	await api.await_for_request_completed(api.request(url))
	resource.low_texture = api.get_texture(url)
	self.texture = resource.low_texture
	texture_loaded = true
	texture_initialized.emit()


func update_count_label():
	count_label.text = str(count) if count > 1 else ""


static func create(item_res: ItemResource, _inventory: Inventory, _draggable = true, low_texture = false) -> Item:
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
