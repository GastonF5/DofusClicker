class_name Recipe
extends PanelContainer

const plus_texture = preload("res://assets/stats/btn_icon/btnIcon_plus.png")

@export var button: Button
@export var items_container: HBoxContainer
@export var test_resource: ItemResource

var recipe: Dicts.ItemRecipe
var result: ItemResource

signal craft


#func _ready():
	#if test_resource != null:
		#init(test_resource)


func init(item_recipe: Dicts.ItemRecipe):
	instantiate_items(item_recipe.get_ingredients())
	recipe = item_recipe
	
	result = item_recipe.get_item()
	var result_item = Item.create(result, null, false)
	result_item.custom_minimum_size = Vector2(64, 64)
	items_container.add_sibling(result_item)
	items_container.get_parent().move_child(result_item, 0)
	
	var inventory = get_tree().current_scene.get_node("%PlayerManager").inventory
	inventory.item_entered_tree.connect(check)
	inventory.item_exiting_tree.connect(check)
	check(inventory.get_items())


func instantiate_items(items_res: Array):
	for item_res in items_res:
		var recipe_item = Item.create(item_res, null, false)
		recipe_item.custom_minimum_size = Vector2(64, 64)
		recipe_item.get_node("Count").add_theme_font_size_override("FontSize", 16)
		items_container.add_child(recipe_item)


func check(items: Array):
	button.disabled = !check_recipe(items)


func check_recipe(inventory_items: Array) -> bool:
	var recipe_items = recipe.get_ingredients().duplicate()
	if inventory_items.size() < recipe_items.size():
		return false
	for item_recipe in recipe_items:
		if !item_match(item_recipe, inventory_items):
			return false
	return true


func item_match(recipe_item: ItemResource, inventory_items: Array):
	for item in inventory_items:
		if item.name == recipe_item.name and item.count >= recipe_item.count:
			return true
	return false



static func create(recipe: Dicts.ItemRecipe, parent) -> Recipe:
	var nrecipe = FileLoader.get_packed_scene("jobs/recipe").instantiate()
	parent.add_child(nrecipe)
	nrecipe.init(recipe)
	return nrecipe


func _on_button_button_up():
	craft.emit(result)
