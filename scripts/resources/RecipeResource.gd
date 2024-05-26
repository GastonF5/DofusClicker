class_name RecipeResource
extends Resource


@export var result_id: int
@export var ingredients: Array
@export var quantities: Array


static func create(resultId: int, ingredientIds: Array, quantities: Array) -> RecipeResource:
		var recipe = RecipeResource.new()
		recipe.result_id = resultId
		recipe.ingredients = ingredientIds.map(func(id): return id as int)
		recipe.quantities = quantities
		return recipe


func get_result() -> ItemResource:
	return Dicts._items[result_id]


func get_ingredients() -> Array:
	var result = []
	for i in range(ingredients.size()):
		var ingredient = Dicts._resources[ingredients[i]]
		ingredient.count = quantities[i]
		result.append(ingredient)
	return result


func _to_string():
	var text = "Recette de " + Dicts._items[result_id].name
	for i in range(ingredients.size()):
		var id = ingredients[i]
		var item = Dicts._resources.get(id)
		text += "\n - %d x %s (%d)" % [quantities[i], "non identifié" if !item else item.name, id]
	return text
