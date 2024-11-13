class_name Recipe
extends PanelContainer

const plus_texture = preload("res://assets/btn_icon/btnIcon_plus.png")

static var scene = preload("res://scenes/jobs/recipe.tscn")

static func create(recipe: RecipeResource, new_parent) -> Recipe:
	var nrecipe: Recipe = Recipe.scene.instantiate()
	nrecipe.resource = recipe
	nrecipe.init()
	new_parent.add_child(nrecipe)
	return nrecipe

@export var button: Button
@export var items_container: HBoxContainer
@export var name_label: Label
@export var level_label: Label

const items_size := 80

var resource: RecipeResource

signal craft
signal initialized

var items = []
var is_initialized := false
var craftable: bool:
	get: return !button.disabled
	set(val):
		button.disabled = !val
		if _result_item:
			if val:
				_result_item.modulate = Color.WHITE
			else:
				_result_item.modulate = Color.DIM_GRAY

var _result_item: Item
var parent: JobPanel


func init():
	instantiate_result()
	instantiate_ingredients()
	button.mouse_entered.connect(_result_item._on_mouse_entered)
	button.mouse_exited.connect(_result_item._on_mouse_exited)
	update_recipe()


func update_recipe():
	for ingredient in get_ingredients_items():
		var diff = diff_inventory_recipe_item(ingredient)
		griser_ingredient(ingredient, diff)
	_result_item.count = calculate_result_count()
	craftable = _result_item.count > 0 or Globals.debug


func instantiate_result():
	var result_item = Item.create(resource.get_result(), false, true, _on_item_texture_initialized)
	init_result(result_item)


func init_result(result_item: Item):
	_result_item = result_item
	result_item.custom_minimum_size = Vector2(items_size, items_size)
	items.append(result_item)
	$MarginContainer/HBC.add_child(result_item)
	$MarginContainer/HBC.move_child(result_item, 0)
	name_label.text = resource.get_result().name
	level_label.text = "Niveau %d" % resource.get_result().level


func instantiate_ingredients():
	for ingredient: ItemResource in resource.get_ingredients():
		var recipe_item = Item.create(ingredient, false, true, _on_item_texture_initialized)
		recipe_item.get_node("IngredientCount").visible = true
		recipe_item.custom_minimum_size = Vector2(items_size, items_size)
		recipe_item.get_node("Count").add_theme_font_size_override("FontSize", 16)
		items.append(recipe_item)
		items_container.add_child(recipe_item)
		# Permet de repérer les items non droppables dans le jeu
		if !ingredient.is_trouvable():
			recipe_item.modulate = Color.RED


func _on_item_texture_initialized():
	if items.filter(func(i): return is_instance_valid(i)).all(func(i): return i.texture != null):
		is_initialized = true


func calculate_result_count():
	var amounts = []
	for ingredient in get_ingredients_items():
		var count = ingredient.get_node("IngredientCount/CountLabel").text.split("/")
		@warning_ignore("integer_division")
		amounts.append(int(count[0]) / int(count[1]))
	return amounts.min()


func get_ingredients_items():
	return items.filter(func(i): return i.resource.id != resource.get_result().id)


func griser_ingredient(item: Item, diff: int):
	if item.modulate != Color.RED:
		item.update_recipe_count(diff)
		if diff < 0:
			item.modulate = Color.DIM_GRAY
		else:
			item.modulate = Color.WHITE


func diff_inventory_recipe_item(ingredient: Item) -> int:
	for item in Globals.inventory.get_items():
		if Item.equals(item, ingredient):
			return item.count - ingredient.count
	return -ingredient.count


func _on_button_button_up():
	craft.emit()
	update_recipe()
