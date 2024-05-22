class_name EquipmentDicts
extends Node

@onready var api: API = $%API

class ItemSet:
	var _name: String
	var _items: Array
	
	static func create(name: String, items: Array) -> ItemSet:
		var item_set = ItemSet.new()
		item_set._name = name
		item_set._items = items
		return item_set

class Equipment:
	var _id: int
	var _name: String
	
	static func create(id: int, name: String) -> Equipment:
		var equip = Equipment.new()
		equip._id = id
		equip._name = name
		return equip


static var _sets = {}
const NB_SETS = 687


func _ready():
	await init_sets()


func init_sets():
	var composite_signal = API.CompositeSignal.new()
	var base_url = api.API_SUFFIX + "item-sets?$limit=50&$skip=%d"
	base_url += "&$" + api.get_select_request("items")
	base_url += "&$" + api.get_select_request("id")
	base_url += "&$" + api.get_select_request("name.fr")
	var urls = []
	for skip in range(0, NB_SETS, 50):
		var url = base_url % skip
		urls.append(url)
		composite_signal.add_method(api.await_for_request_completed.bind(api.request(url)))
	await composite_signal.finished
	for url in urls:
		var data = api.get_data(url)
		if data and data.size() != 0:
			for item_set in data:
				var item_ids = item_set["items"].map(func(i): return Equipment.create(i["id"] as int, i["name"]["fr"]))
				_sets[item_set["id"] as int] = ItemSet.create(item_set["name"]["fr"], item_ids)
		else:
			print("error on url %s" % url)
