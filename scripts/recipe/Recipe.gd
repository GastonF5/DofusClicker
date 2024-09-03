class_name Recipe
extends PanelContainer

const plus_texture = preload("res://assets/btn_icon/btnIcon_plus.png")

@export var button: Button
@export var items_container: HBoxContainer

var resource: RecipeResource

signal craft
signal initialized

var count = 0


func init(item_recipe: RecipeResource):
	self.visible = false
	resource = item_recipe
	instantiate_items()
	
	var result_item = Item.create(item_recipe.get_result(), false, true)
	result_item.texture_initialized.connect(_on_item_texture_initialized)
	result_item.custom_minimum_size = Vector2(64, 64)
	items_container.add_sibling(result_item)
	items_container.get_parent().move_child(result_item, 0)
	
	var inventory = Globals.inventory
	inventory.item_entered_tree.connect(check)
	inventory.item_exiting_tree.connect(check)
	check()


func instantiate_items():
	for ingredient in resource.get_ingredients():
		var recipe_item = Item.create(ingredient, false, true)
		recipe_item.texture_initialized.connect(_on_item_texture_initialized)
		recipe_item.custom_minimum_size = Vector2(64, 64)
		recipe_item.get_node("Count").add_theme_font_size_override("FontSize", 16)
		items_container.add_child(recipe_item)


func _on_item_texture_initialized():
	count += 1
	if count == resource._ingredients.size() + 1:
		self.visible = true
		initialized.emit()


func check():
	button.disabled = !check_recipe()


func check_recipe() -> bool:
	var recipe_items = resource.get_ingredients().duplicate()
	var inventory_items = Globals.inventory.get_items()
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



static func create(recipe: RecipeResource, parent) -> Recipe:
	var nrecipe = FileLoader.get_packed_scene("jobs/recipe").instantiate()
	parent.add_child(nrecipe)
	nrecipe.init(recipe)
	return nrecipe


func _on_button_button_up():
	craft.emit(resource)
