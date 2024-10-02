class_name RecipeResource
extends Resource


@export var _result_id: int
@export var _ingredients: Array
@export var _quantities: Array

func get_id():
	return _result_id

static func create(resultId: int, ingredient_ids: Array, quantities: Array) -> RecipeResource:
		var recipe = RecipeResource.new()
		recipe._result_id = resultId
		recipe._ingredients = ingredient_ids.map(func(id): return id as int)
		recipe._quantities = quantities.map(func(id): return id as int)
		return recipe


func get_result() -> ItemResource:
	if Datas._items.has(_result_id):
		return Datas._items[_result_id]
	elif Datas._keys.has(_result_id):
		return Datas._keys[_result_id]
	return null


func get_ingredients() -> Array:
	var result = []
	for i in range(_ingredients.size()):
		var ingredient = Datas._resources[_ingredients[i]]
		ingredient.count = _quantities[i]
		result.append(ingredient)
	return result


func _to_string():
	var text = "Recette de " + Datas._items[_result_id].name
	for i in range(_ingredients.size()):
		var id = _ingredients[i]
		var item = Datas._resources.get(id)
		text += "\n - %d x %s (%d)" % [_quantities[i], "non identifié" if !item else item.name, id]
	return text
