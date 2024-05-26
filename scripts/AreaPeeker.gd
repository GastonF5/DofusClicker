class_name AreaPeeker
extends PanelContainer


var api: API
var monster_manager: MonsterManager
var loading_screen: LoadingScreen
@export var back_button: Button

class Area:
	var _id: int
	var _name: String
	var _super_area_id: int
	var _subareas: Array[SubArea] = []
	
	static func create(id: int, area_name: String, super_area_id: int) -> Area:
		var area = Area.new()
		area._id = id
		area._name = area_name
		area._super_area_id = super_area_id
		return area


class SubArea:
	var _id: int
	var _name: String
	var _super_area_id: int
	var _monsters: Array
	
	static func create(id: int, subarea_name: String, super_area_id: int) -> SubArea:
		var subarea = SubArea.new()
		subarea._id = id
		subarea._name = subarea_name
		subarea._super_area_id = super_area_id
		return subarea


static var areas = { 0: { "name": "Amakna", "super_area": 0 }, 1: { "name": "Île des Wabbits", "super_area": 0 }, 2: { "name": "Île de Moon", "super_area": 0 }, 3: { "name": "Prison de Madrestam", "super_area": 0 }, 5: { "name": "Baie de Sufokia", "super_area": 0 }, 6: { "name": "Forêt des Abraknydes", "super_area": 0 }, 7: { "name": "Bonta", "super_area": 0 }, 8: { "name": "Plaines de Cania", "super_area": 0 }, 11: { "name": "Brâkmar", "super_area": 0 }, 12: { "name": "Landes de Sidimote", "super_area": 0 }, 15: { "name": "Foire du Trool", "super_area": 0 }, 18: { "name": "Astrub", "super_area": 0 }, 26: { "name": "Labyrinthe du Dragon Cochon", "super_area": 0 }, 28: { "name": "Montagne des Koalaks", "super_area": 0 }, 30: { "name": "Île du Minotoror", "super_area": 0 }, 42: { "name": "Île de Nowel", "super_area": 0 }, 45: { "name": "Incarnam", "super_area": 3 }, 46: { "name": "Île d\'Otomaï", "super_area": 0 }, 48: { "name": "Île de Frigost", "super_area": 0 }, 49: { "name": "Île de Sakaï", "super_area": 0 }, 50: { "name": "Archipel de Vulkania", "super_area": 0 }, 51: { "name": "Îlots de la mer d\'Asse", "super_area": 0 }, 52: { "name": "Convention", "super_area": 4 }, 53: { "name": "Enutrosor", "super_area": 5 }, 54: { "name": "Srambad", "super_area": 5 }, 55: { "name": "Xélorium", "super_area": 5 }, 56: { "name": "Zone privée", "super_area": 0 }, 57: { "name": "Île de Rok", "super_area": 0 }, 58: { "name": "Havres-Sacs", "super_area": 0 }, 59: { "name": "Ecaflipus", "super_area": 5 }, 60: { "name": "Domaine des fils d\'Ecaflip", "super_area": 5 }, 61: { "name": "Saharach", "super_area": 0 }, 62: { "name": "Nimotopia", "super_area": 0 }, 63: { "name": "Profondeurs de Sufokia", "super_area": 0 }, 64: { "name": "Externam", "super_area": 8 }, 65: { "name": "Dimension Obscure", "super_area": 9 }, 66: { "name": "Mode tactique", "super_area": 0 }, 67: { "name": "Ingloriom", "super_area": 5 }, 68: { "name": "Rêve du Monde des Douze", "super_area": 6 }, 69: { "name": "Archipel des Écailles", "super_area": 0 }, 70: { "name": "Destin du Monde", "super_area": 0 }, 71: { "name": "Île de Pwâk", "super_area": 0 }, 72: { "name": "Anomalies temporelles", "super_area": 0 }, 73: { "name": "Horloge de Xélor", "super_area": 5 }, 74: { "name": "Eliocalypse", "super_area": 0 }, 75: { "name": "Profondeurs d\'Astrub", "super_area": 0 }, 76: { "name": "Éther", "super_area": 7 }, 77: { "name": "Centre du Monde", "super_area": 0 }, 78: { "name": "Île de Pandala", "super_area": 0 }, 79: { "name": "Île de Grobe", "super_area": 0 }, 80: { "name": "Plan Astral", "super_area": 6 }, 81: { "name": "Fleuve vers Externam", "super_area": 6 }, 82: { "name": "Wukin et Wukang", "super_area": 6 }, 83: { "name": "Gelaxième dimension", "super_area": 9 }, 84: { "name": "Dimensions des Cavaliers", "super_area": 9 }, 85: { "name": "Dimension Abyssale", "super_area": 9 }, 86: { "name": "Atoll des Possédés", "super_area": 0 }, 88: { "name": "Cauchemar des Ravageurs", "super_area": 6 }, 91: { "name": "Tour des enclos", "super_area": 0 }, 92: { "name": "Forêt Maléfique", "super_area": 0 }, 93: { "name": "Archipel de Valonia", "super_area": 0 }, 94: { "name": "Kolizéum", "super_area": 0 }, 87: { "name": "Dimension Éphémère", "super_area": 10 } }
var subareas: Dictionary

var selected_area: Area

signal subarea_selected


func _ready():
	for key in areas.keys():
		areas[key] = Area.create(key, areas[key]["name"], areas[key]["super_area"])
	loading_screen = $%LoadingScreen
	var composite_signal = API.CompositeSignal.new()
	for area in areas.values():
		create_area_button(area)
		composite_signal.add_method(build_subareas.bind(area))
	await composite_signal.finished
	areas.values().all(func(a):
		if a._subareas.is_empty():
			areas.erase(a._id)
			erase_button(a))


func get_area_lvl(area: Area):
	var url = api.API_SUFFIX + "subareas?areaId=%d&$%s" % [area._id, api.get_select_request("level")]
	await api.await_for_request_completed(api.request(url))
	var data = api.get_data(url)
	var min_lvl = 200
	for subarea in data:
		var sa_lvl = subarea["level"]
		min_lvl = min_lvl if min_lvl < sa_lvl else sa_lvl
	prints(area._name, min_lvl)


func build_subareas(area: Area):
	var url = api.API_SUFFIX + "subareas?areaId=%s" % str(area._id)
	url += "&$%s" % api.get_select_request("name.fr")
	url += "&$%s" % api.get_select_request("id")
	url += "&$%s" % api.get_select_request("monsters")
	await api.await_for_request_completed(api.request(url))
	var data = api.get_data(url)
	if is_instance_of(data, TYPE_DICTIONARY):
		areas.erase(area._id)
		erase_button(area)
		return
	for subarea in data:
		if !subarea["monsters"].is_empty():
			var sa := SubArea.create(subarea["id"], subarea["name"]["fr"], area._id)
			sa._monsters = subarea["monsters"]
			area._subareas.append(sa)


func _on_area_clicked(button: Button):
	clear_buttons()
	back_button.disabled = false
	var area: Area = areas[button.name.to_int()]
	area._subareas.all(func(sa): create_subarea_button(sa))


func _on_subarea_clicked(button: Button):
	var subarea = subareas[button.name.to_int()]
	loading_screen.set_loading_label("Chargement des monstres de la zone %s" % subarea._name)
	loading_screen.loading = true
	monster_manager.start_fight_button.disabled = true
	var monster_resources = await api.get_monsters_by_ids(subarea._monsters)
	loading_screen.loading_pb.value = loading_screen.loading_pb.max_value
	MonsterManager.monsters_res = monster_resources
	monster_manager.start_fight_button.disabled = false
	loading_screen.loading = false


func create_area_button(area: Area):
	var button = Button.new()
	button.text = area._name
	button.name = str(area._id)
	button.button_up.connect(_on_area_clicked.bind(button))
	button.focus_mode = Control.FOCUS_NONE
	$HBC/ScrollContainer/HBC.add_child(button)


func create_subarea_button(subarea: SubArea):
	var button = Button.new()
	button.text = subarea._name
	button.name = str(subarea._id)
	button.button_up.connect(_on_subarea_clicked.bind(button))
	button.focus_mode = Control.FOCUS_NONE
	$HBC/ScrollContainer/HBC.add_child(button)


func erase_button(area: Area):
	var button = $HBC/ScrollContainer/HBC.get_node(str(area._id))
	$HBC/ScrollContainer/HBC.remove_child(button)
	button.queue_free()


func clear_buttons():
	for button in $HBC/ScrollContainer/HBC.get_children():
		$HBC/ScrollContainer/HBC.remove_child(button)
		button.queue_free()


func _enter_tree():
	api = get_tree().current_scene.get_node("%API")
	monster_manager = get_tree().current_scene.get_node("%MonsterManager")


func _on_back_button_button_up():
	clear_buttons()
	selected_area = null
	back_button.disabled = true
	for a in areas.values():
		create_area_button(a)
