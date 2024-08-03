extends Node

signal init_done

enum DataType {
	TYPE,
	ITEM,
	RECIPE,
	RESOURCE,
	MONSTER,
	AREA,
	SUBAREA,
}


@export var _types = {}
@export var _items = {}
@export var _resources = {}
@export var _recipes = {}
@export var _monsters = {}
@export var _areas = {}
@export var _subareas = {}

var dir: DirAccess


func load_data():
	Globals.loading_screen.loading = true
	if !DirAccess.dir_exists_absolute(FileSaver.DATA_PATH):
		DirAccess.make_dir_absolute(FileSaver.DATA_PATH)
	dir = DirAccess.open(FileSaver.DATA_PATH)
	for data_type in DataType.values():
		await get_data(data_type)
	check_areas()
	init_done.emit()
	Globals.loading_screen.loading = false


func get_data(data_type: DataType):
	var data_name = get_data_name(data_type)
	var file_path = FileSaver.DATA_PATH + data_name + ".tres"
	if dir.file_exists(file_path):
		var file = FileLoader.load_file(file_path)
		self.set("_%ss" % data_name, file.data)
	else:
		await request_data(data_type)
		FileSaver.save_data(self.get("_%ss" % data_name), data_name)


func get_data_name(data_type: DataType) -> String:
	return DataType.find_key(data_type).to_lower()

func perform_setter_for_data_type(data_type: DataType, data):
	self.get("set_%s" % get_data_name(data_type)).call(data)

func get_url(data_type: DataType) -> String:
	var url = API.API_SUFFIX + "%s?"
	match data_type:
		DataType.RESOURCE:
			return url % "items"
		DataType.TYPE:
			return url % "item-types"
		_:
			return url % (get_data_name(data_type) + "s")

func get_url_params(data_type: DataType) -> String:
	var params := ""
	match data_type:
		DataType.TYPE:
			params += "&categoryId=0"
			params += "&$" + API.get_select_request("name.fr")
			params += "&$" + API.get_select_request("id")
		DataType.ITEM:
			for type in _types.values():
				params += "&typeId=%d" % type._id
		DataType.RECIPE:
			params += "&$" + API.get_select_request("resultId")
			params += "&$" + API.get_select_request("ingredientIds")
			params += "&$" + API.get_select_request("quantities")
		DataType.RESOURCE:
			pass
		DataType.MONSTER:
			pass
		DataType.AREA:
			params += "&$" + API.get_select_request("id")
			params += "&$" + API.get_select_request("name.fr")
		DataType.SUBAREA:
			params += "&$" + API.get_select_request("id")
			params += "&$" + API.get_select_request("name.fr")
			params += "&$" + API.get_select_request("areaId")
			params += "&$" + API.get_select_request("monsters")
			params += "&$" + API.get_select_request("level")
	return params

func get_in_values(data_type: DataType) -> Array:
	match data_type:
		DataType.RECIPE:
			return ["resultId"] + _items.values().map(func(item): return item.id)
		DataType.RESOURCE:
			var resource_ids = []
			for recipe in _recipes.values():
				for ingredient_id in recipe._ingredients:
					if !resource_ids.has(ingredient_id):
						resource_ids.append(ingredient_id)
			return ["id"] + resource_ids
		DataType.MONSTER:
			var monster_ids = []
			for resource in _resources.values():
				for monster_id in resource.drop_monster_ids:
					if !monster_ids.has(monster_id):
						monster_ids.append(monster_id)
			return ["id"] + monster_ids
	return []

func get_loading_text(data_type: DataType) -> String:
	var text := "Chargement des "
	match data_type:
		DataType.TYPE:
			text += "types"
		DataType.ITEM:
			text += "équipements"
		DataType.RECIPE:
			text += "recettes"
		DataType.RESOURCE:
			text += "ressources"
		DataType.MONSTER:
			text += "monstres"
		DataType.AREA:
			text += "zones"
		DataType.SUBAREA:
			text += "sous-zones"
	return text


func request_data(data_type: DataType):
	Globals.loading_screen.reset()
	Globals.loading_screen.set_loading_label(get_loading_text(data_type))
	var base_url: String = get_url(data_type)
	var urls
	var in_values = get_in_values(data_type)
	if !in_values.is_empty():
		urls = await perform_in_requests(data_type, base_url, in_values)
	else:
		urls = await perform_skip_requests(data_type, base_url)
	for u in urls:
		var datas = API.get_data(u)
		if is_instance_of(datas, TYPE_DICTIONARY):
			datas = datas["data"]
		for data in datas:
			perform_setter_for_data_type(data_type, data)


func perform_skip_requests(data_type: DataType, base_url: String) -> Array:
	if data_type == DataType.ITEM:
		base_url += get_url_params(data_type)
	var url := base_url + "&$limit=1"
	await API.await_for_request_completed(await API.request(url))
	var total = API.json_dict[url]["total"]
	Globals.loading_screen.set_max_value(total)
	API.json_dict.erase(url)
	var composite_signal = API.CompositeSignal.new()
	var urls = []
	composite_signal._to_call_after = Globals.loading_screen.increment_loading.bind(50.0)
	for skip in range(0, total, 50):
		url = base_url + "&$limit=50&$skip=%s" % skip + get_url_params(data_type)
		composite_signal.add_method(API.await_for_request_completed.bind(await API.request(url)))
		urls.append(url)
	await composite_signal.finished
	return urls


func perform_in_requests(data_type: DataType, base_url: String, in_values: Array):
	Globals.loading_screen.set_max_value(in_values.size())
	var composite_signal = API.CompositeSignal.new()
	composite_signal._to_call_after = Globals.loading_screen.increment_loading.bind(50.0)
	var urls = []
	var url = base_url
	var count := 0
	var value_to_check = in_values.front()
	in_values.erase(value_to_check)
	for value in in_values:
		url += "&" + API.get_in_request(value_to_check, str(value))
		count += 1
		if count == 50:
			url += "&$limit=50" + get_url_params(data_type)
			composite_signal.add_method(API.await_for_request_completed.bind(await API.request(url)))
			urls.append(url)
			url = base_url
			count = 0
	if count > 0:
		composite_signal.add_method(API.await_for_request_completed.bind(await API.request(url)))
		urls.append(url)
	await composite_signal.finished
	return urls


func set_type(data: Dictionary):
	var id = data["id"] as int
	_types[id] = ItemTypeResource.create(id, data["name"]["fr"])


func set_item(data: Dictionary):
	var item_res = API.get_item_resource(data)
	if item_res.equip_res and !item_res.equip_res.stats.is_empty():
		_items[item_res.id] = item_res


func set_recipe(data: Dictionary):
	var result_id = data["resultId"] as int
	_recipes[result_id] = RecipeResource.create(result_id, data["ingredientIds"], data["quantities"])


func set_resource(data: Dictionary):
	var resource_res = API.get_item_resource(data)
	_resources[resource_res.id as int] = resource_res


func set_monster(data: Dictionary):
	var monster_res: MonsterResource = API.get_monster_resource(data)
	_monsters[monster_res.id] = monster_res


func set_area(data: Dictionary):
	var id = data["id"] as int
	var area = AreaResource.create(id, data["name"]["fr"])
	_areas[id] = area


func set_subarea(data: Dictionary):
	if !data["monsters"].is_empty():
		var id = data["id"] as int
		var subarea = AreaResource.create(id, data["name"]["fr"], data["areaId"], data["level"])
		subarea._monster_ids = data["monsters"].map(func(i): return i as int)
		_subareas[id] = subarea


func check_areas():
	for area: AreaResource in _areas.values():
		if area.is_subarea():
			_areas.erase(area.id)


func _on_reload_data_button_up():
	for file in dir.get_files():
		dir.remove(file.get_file())
	load_data()
