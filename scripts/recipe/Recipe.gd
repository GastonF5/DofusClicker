class_name Recipe
extends PanelContainer

const plus_texture = preload("res://assets/btn_icon/btnIcon_plus.png")

@export var button: Button
@export var items_container: HBoxContainer
@export var name_label: Label
@export var level_label: Label

const items_size := 80

static var scene = preload("res://scenes/jobs/recipe.tscn")

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


func init(item_recipe: RecipeResource = resource):
	resource = item_recipe
	instantiate_result()
	instantiate_ingredients()
	check(null)
	add_to_parent()


func reset():
	if get_parent():
		get_parent().remove_child(self)
	is_initialized = false
	_result_item = null
	for item in items:
		if is_instance_valid(item):
			if item.texture_initialized.is_connected(_on_item_texture_initialized):
				item.texture_initialized.disconnect(_on_item_texture_initialized)
			item.queue_free()


func instantiate_result(result_res: ItemResource, callable: Callable):
	var result_item = Item.create(result_res, false, true, callable)
	init_result.call_deferred(result_item)


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
		if ingredient.get_drop_areas() == "":
			recipe_item.modulate = Color.RED


func _on_item_texture_initialized():
	if items.filter(func(i): return is_instance_valid(i)).all(func(i): return i.texture != null):
		is_initialized = true


func check(item_to_check: Item):
	craftable = check_recipe(item_to_check)
	if _result_item:
		_result_item.count = calculate_result_count()


func calculate_result_count():
	var amounts = []
	for ingredient in get_ingredients_items():
		var count = ingredient.get_node("IngredientCount/CountLabel").text.split("/")
		@warning_ignore("integer_division")
		amounts.append(int(count[0]) / int(count[1]))
	return amounts.min()


## Renvoie true si la recette est craftable, false sinon
func check_recipe(item_to_check: Item) -> bool:
	var ingredients = get_ingredients_items()
	var matching_ingredients = ingredients.filter(func(i): return Item.equals(i, item_to_check))
	# Si aucun ingrédient ne correspond à l'item à vérifier, on ne fait rien
	if item_to_check and matching_ingredients.is_empty():
		return craftable
	# Si un ingrédient match avec item_to_check, on ne met à jour que cet ingrédient
	if !matching_ingredients.is_empty():
		var ingredient = matching_ingredients[0]
		var diff = item_to_check.count - ingredient.count
		griser_ingredient(ingredient, diff)
	# Sinon, on vérifie tous les ingrédients par rapports aux items dans l'inventaire
	else:
		for ingredient in ingredients:
			var diff = diff_inventory_recipe_item(ingredient)
			griser_ingredient(ingredient, diff)
	return ingredients.all(func(i): return i.is_ingredient_ok())


func get_ingredients_items():
	return items.filter(
		func(i):
			if is_instance_valid(i):
				return i.resource.id != resource.get_result().id
			return false)


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


static func create(recipe: RecipeResource, new_parent) -> Recipe:
	var nrecipe = Recipe.scene.instantiate()
	nrecipe.parent = new_parent
	nrecipe.resource = recipe
	return nrecipe


func add_to_parent():
	if !get_parent() and parent:
		parent.recipe_container.add_child(self)


func _on_button_button_up():
	craft.emit(resource)


func _on_visible_on_screen_notifier_screen_entered():
	for item in items:
		if is_instance_valid(item):
			item.visible = true


func _on_visible_on_screen_notifier_screen_exited():
	for item in items:
		if is_instance_valid(item):
			item.visible = true
