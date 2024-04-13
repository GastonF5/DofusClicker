class_name Recipe
extends PanelContainer

const plus_texture = preload("res://assets/stats/btn_icon/btnIcon_plus.png")

@export var button: Button
@export var test_resource: RecipeResource

var items: HBoxContainer
var slots = []
var resource: RecipeResource


func _ready():
	items = $"MarginContainer/HBC/Items"
	if test_resource != null:
		init(test_resource)


func init(recipe_res: RecipeResource):
	var nb_items = recipe_res.items.size()
	for i in range(nb_items - 1):
		instantiate_slot()
	slots = items.get_children()
	init_slots()
	resource = recipe_res


func instantiate_slot():
	var slot = load("res://scenes/inventory/inventory_slot.tscn").instantiate()
	items.add_child(slot)


func init_slots():
	for slot in slots:
		slot.mouse_entered.connect(Inventory._on_mouse_entered_slot.bind(slot))
		slot.mouse_exited.connect(Inventory._on_mouse_exited_slot)
		slot.child_entered_tree.connect(check)
		slot.child_exiting_tree.connect(check)


func check(_item):
	print(check_recipe())
	button.disabled = !check_recipe()


func check_recipe() -> bool:
	var index = 0
	for item in resource.items:
		var item_in_slot = slots[index].get_child(0)
		if item_in_slot == null or item.name != item_in_slot.name or item.count != item_in_slot.count:
			return false
		index += 1
	return true
