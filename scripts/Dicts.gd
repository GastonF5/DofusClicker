class_name Dicts
extends Node

@onready var api: API = $%API

signal init_done

class ItemSet:
	var _id: int
	var _name: String
	var _items: Array
	
	static func create(id: int, name: String, items: Array) -> ItemSet:
		var item_set = ItemSet.new()
		item_set._id = id
		item_set._name = name
		item_set._items = items
		return item_set

class ItemRecipe:
	var _resultId: int
	var _ingredientIds: Array
	var _quantities: Array
	
	static func create(resultId: int, ingredientIds: Array, quantities: Array) -> ItemRecipe:
		var recipe = ItemRecipe.new()
		recipe._resultId = resultId
		recipe._ingredientIds = ingredientIds.map(func(id): return id as int)
		recipe._quantities = quantities
		return recipe
	
	func get_result() -> ItemResource:
		return Dicts._items[_resultId]
	
	func get_ingredients() -> Array:
		var result = []
		for i in range(_ingredientIds.size()):
			var ingredient = Dicts._ressources[_ingredientIds[i]]
			ingredient.count = _quantities[i]
			result.append(ingredient)
		return result
	
	func _to_string():
		var text = "Recette de " + Dicts._items[_resultId].name
		for i in range(_ingredientIds.size()):
			var id = _ingredientIds[i]
			var item = Dicts._ressources.get(id)
			text += "\n - %d x %s (%d)" % [_quantities[i], "non identifié" if !item else item.name, id]
		return text


class ItemType:
	var _id: int
	var _name: String
	var _category_id: int
	
	static func create(id: int, name: String, category_id: int) -> ItemType:
		var type = ItemType.new()
		type._id = id
		type._name = name
		type._category_id = category_id
		return type


const NB_SETS := 687
static var _sets = {}
static var _items = {}
static var _ressources = {}
static var _recipes = {}
static var _monsters = {}
static var _types = {}

var loading_screen: LoadingScreen


func _ready():
	loading_screen = $%LoadingScreen
	loading_screen.loading = true
	loading_screen.set_loading_label("Chargement des équipements")
	await init_types()
	await init_items()
	loading_screen.set_loading_label("Chargement des recettes")
	loading_screen.set_max_value(_items.size())
	loading_screen.reset()
	await init_recipes()
	loading_screen.set_loading_label("Chargement des ressources")
	loading_screen.reset()
	await init_resources()
	init_done.emit()
	loading_screen.set_loading_label("Chargement des monstres")
	loading_screen.reset()
	await init_monsters()
	loading_screen.loading = false


func init_types():
	var url = api.API_SUFFIX + "item-types?$limit=36&categoryId=0"
	url += "&$" + api.get_select_request("id")
	url += "&$" + api.get_select_request("name.fr")
	url += "&$" + api.get_select_request("categoryId")
	await api.await_for_request_completed(api.request(url))
	for data in api.get_data(url):
		var id = data["id"] as int
		_types[id] = ItemType.create(id, data["name"]["fr"], data["categoryId"] as int)


func init_items():
	var composite_signal = API.CompositeSignal.new()
	composite_signal._increment_loading_screen = loading_screen.increment_loading.bind(50)
	var base_url = api.API_SUFFIX + "items?$limit=50&$skip=%d"
	for type_id in _types.keys():
		base_url += "&" + api.get_equals_request("typeId", str(type_id))
	var urls = []
	await api.await_for_request_completed(api.request(base_url % 0))
	var total = api.json_dict[base_url % 0]["total"] as int
	loading_screen.set_max_value(total)
	urls.append(base_url % 0)
	for skip in range(50, total, 50):
		var url = base_url % skip
		urls.append(url)
		composite_signal.add_method(api.await_for_request_completed.bind(api.request(url)))
	await composite_signal.finished
	for url in urls:
		var data = api.get_data(url)
		if data and data.size() != 0:
			for item in data:
				_items[item["id"] as int] = api.get_item_resource(item)
		else:
			print("error on url %s" % url)


func init_recipes():
	var composite_signal = API.CompositeSignal.new()
	composite_signal._increment_loading_screen = loading_screen.increment_loading.bind(50)
	var base_url = api.API_SUFFIX + "recipes?$limit=50"
	base_url += "&$" + api.get_select_request("ingredientIds")
	base_url += "&$" + api.get_select_request("quantities")
	base_url += "&$" + api.get_select_request("resultId")
	var url = base_url
	var count = 0
	var urls = []
	for item in _items.values():
		url += "&" + api.get_in_request("resultId", str(item.id))
		count += 1
		if count == 50:
			composite_signal.add_method(api.await_for_request_completed.bind(api.request(url)))
			urls.append(url)
			url = base_url
			count = 0
	if count > 0:
		composite_signal.add_method(api.await_for_request_completed.bind(api.request(url)))
		urls.append(url)
	await composite_signal.finished
	for u in urls:
		var datas = api.get_data(u)
		if is_instance_of(datas, TYPE_DICTIONARY): datas = datas["data"]
		for data in datas:
			var result_id = data["resultId"] as int
			_recipes[result_id] = ItemRecipe.create(result_id, data["ingredientIds"], data["quantities"])


func init_resources():
	var composite_signal = API.CompositeSignal.new()
	composite_signal._increment_loading_screen = loading_screen.increment_loading.bind(50)
	var ressource_ids = []
	for recipe: ItemRecipe in _recipes.values():
		for ingredient_id in recipe._ingredientIds:
			if !ressource_ids.has(ingredient_id):
				ressource_ids.append(ingredient_id)
	loading_screen.set_max_value(ressource_ids.size())
	var base_url = api.API_SUFFIX + "items?$limit=50"
	var url = base_url
	var count = 0
	var urls = []
	for rid in ressource_ids:
		url += "&" + api.get_in_request("id", str(rid))
		count += 1
		if count == 50:
			composite_signal.add_method(api.await_for_request_completed.bind(api.request(url)))
			urls.append(url)
			url = base_url
			count = 0
	if count > 0:
		composite_signal.add_method(api.await_for_request_completed.bind(api.request(url)))
		urls.append(url)
	await composite_signal.finished
	for u in urls:
		var datas = api.get_data(u)
		if is_instance_of(datas, TYPE_DICTIONARY): datas = datas["data"]
		for data in datas:
			_ressources[data["id"] as int] = api.get_item_resource(data)


func init_monsters():
	var composite_signal = API.CompositeSignal.new()
	composite_signal._increment_loading_screen = loading_screen.increment_loading.bind(50)
	var monster_ids = []
	for ressource: ItemResource in _ressources.values():
		for monster_id in ressource.drop_monster_ids:
			if !monster_ids.has(monster_id):
				monster_ids.append(monster_id)
	loading_screen.set_max_value(monster_ids.size())
	var base_url = api.API_SUFFIX + "monsters?$limit=50"
	var url = base_url
	var count = 0
	var urls = []
	for mid in monster_ids:
		url += "&" + api.get_in_request("id", str(mid))
		count += 1
		if count == 50:
			composite_signal.add_method(api.await_for_request_completed.bind(api.request(url)))
			urls.append(url)
			url = base_url
			count = 0
	if count > 0:
		composite_signal.add_method(api.await_for_request_completed.bind(api.request(url)))
		urls.append(url)
	await composite_signal.finished
	for u in urls:
		var datas = api.get_data(u)
		if is_instance_of(datas, TYPE_DICTIONARY): datas = datas["data"]
		for data in datas:
			var monster_res: MonsterResource = api.get_monster_resource(data)
			_monsters[monster_res.monster_id] = monster_res
