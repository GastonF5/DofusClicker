class_name Item
extends DraggableControl

var count = 1:
	set(value):
		count = value
		update_count_label()

var resource: ItemResource
var stats: Array[StatResource] = []

var count_label: Label

var is_ingredient: bool:
	get: return $IngredientCount.visible

signal texture_initialized

func _ready():
	update_count_label()


func _on_mouse_entered():
	if !PlayerManager.dragged_item:
		PlayerManager.item_description.init_item(resource, stats)


func _on_mouse_exited():
	if !PlayerManager.dragged_item:
		PlayerManager.item_description.visible = false


func _enter_tree():
	super()
	if draggable and get_parent() is Button:
		get_parent().mouse_entered.connect(_on_mouse_entered)
		get_parent().mouse_exited.connect(_on_mouse_exited)


func _exit_tree():
	if draggable and get_parent() is Button:
		if get_parent().mouse_entered.is_connected(_on_mouse_entered):
			get_parent().mouse_entered.disconnect(_on_mouse_entered)
		if get_parent().mouse_exited.is_connected(_on_mouse_exited):
			get_parent().mouse_exited.disconnect(_on_mouse_exited)


func change_parent():
	super()
	Globals.inventory.add_item(self, drop_parent)


func init(item_res: ItemResource, _draggable, recipe_item):
	self.texture = null
	count_label = $Count
	name = item_res.name
	resource = item_res
	count = item_res.count
	draggable = _draggable
	mouse_filter = Control.MOUSE_FILTER_IGNORE if draggable else MOUSE_FILTER_PASS
	
	if recipe_item:
		if item_res.is_resource():
			count_label.position -= count_label.size / 3
			count_label.add_theme_font_size_override("font_size", 20)
	else:
		$Background.visible = false
	
	if item_res.equip_res:
		for stat in item_res.equip_res.stats:
			var new_stat = stat.duplicate()
			if !recipe_item:
				new_stat.init_amount()
			stats.append(new_stat)
	
	await resource.load_texture()
	self.texture = resource.texture
	texture_initialized.emit()


func get_save() -> Dictionary:
	var data := { "id": resource.id, "count": count }
	var equip_res_data := {}
	for stat in stats:
		equip_res_data[stat.type] = stat.amount
	data["equip_res"] = equip_res_data
	return data


func update_count_label():
	count_label.text = str(count) if count > 1 else ""


static func create(item_res: ItemResource, _draggable = true, recipe_item = false, callable: Callable = func(): pass) -> Item:
	var item: Item = FileLoader.get_packed_scene("item/item").instantiate()
	item.texture_initialized.connect(callable)
	item.init(item_res, _draggable, recipe_item)
	return item


static func equals(item1, item2) -> bool:
	if !item1 or !item2:
		return false
	var item1_res = item1
	var item2_res = item2
	if is_instance_of(item1, Item):
		item1_res = item1.resource
	if is_instance_of(item2, Item):
		item2_res = item2.resource
	return item1_res.id == item2_res.id


func update_recipe_count(amount: int):
	toggle_recipe_ok(amount >= 0)
	$IngredientCount/CountLabel.text = "%d/%d" % [amount + count, count]


func toggle_recipe_ok(enough: bool):
	$IngredientCount/OkTexture.visible = enough
	$IngredientCount/CountLabel.visible = !enough


func is_ingredient_ok():
	return $IngredientCount/OkTexture.visible
