class_name RecipeContainer
extends Control


static var scene = preload("res://scenes/jobs/recipe_container.tscn")

static func create(recipe_res: RecipeResource, parent: Node) -> RecipeContainer:
	var recipe_container = RecipeContainer.scene.instantiate()
	recipe_container._resource = recipe_res
	parent.add_child(recipe_container)
	return recipe_container


var _resource: RecipeResource
var _recipe: Recipe

signal crafted


func _on_visible_on_screen_notifier_screen_entered():
	_recipe = Recipe.create(_resource, self)
	_recipe.craft.connect(_on_recipe_craft)


func _on_visible_on_screen_notifier_screen_exited():
	_recipe.craft.disconnect(_on_recipe_craft)
	remove_child(_recipe)
	_recipe.queue_free()
	_recipe = null


func _on_recipe_craft():
	crafted.emit(_resource)


## Renvoie true si la recette est craftable, false sinon
func is_craftable() -> bool:
	return _resource.get_ingredients().all(inventory_satisfies_ingredient)


## Indique si il y a assez d'objets dans l'inventaire pour l'ingrédient
func inventory_satisfies_ingredient(ingredient: ItemResource) -> bool:
	for item in Globals.inventory.get_items():
		if Item.equals(item, ingredient):
			return item.count >= ingredient.count
	return false


func is_trouvable() -> bool:
	return _resource.get_ingredients().all(func(i): return i.is_trouvable())
