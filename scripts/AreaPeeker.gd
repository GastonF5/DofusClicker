class_name AreaPeeker
extends PanelContainer


class Area:
	var _name: String
	var _super_area_id: int
	
	static func create(area_name: String, super_area_id: int) -> Area:
		var area = Area.new()
		area._name = area_name
		area._super_area_id = super_area_id
		return area

class SubArea:
	var _name: String
	var _area_id: int


static var areas = { 0: { "name": "Amakna", "super_area": 0 }, 1: { "name": "Île des Wabbits", "super_area": 0 }, 2: { "name": "Île de Moon", "super_area": 0 }, 3: { "name": "Prison de Madrestam", "super_area": 0 }, 5: { "name": "Baie de Sufokia", "super_area": 0 }, 6: { "name": "Forêt des Abraknydes", "super_area": 0 }, 7: { "name": "Bonta", "super_area": 0 }, 8: { "name": "Plaines de Cania", "super_area": 0 }, 11: { "name": "Brâkmar", "super_area": 0 }, 12: { "name": "Landes de Sidimote", "super_area": 0 }, 15: { "name": "Foire du Trool", "super_area": 0 }, 18: { "name": "Astrub", "super_area": 0 }, 26: { "name": "Labyrinthe du Dragon Cochon", "super_area": 0 }, 28: { "name": "Montagne des Koalaks", "super_area": 0 }, 30: { "name": "Île du Minotoror", "super_area": 0 }, 42: { "name": "Île de Nowel", "super_area": 0 }, 45: { "name": "Incarnam", "super_area": 3 }, 46: { "name": "Île d\'Otomaï", "super_area": 0 }, 48: { "name": "Île de Frigost", "super_area": 0 }, 49: { "name": "Île de Sakaï", "super_area": 0 }, 50: { "name": "Archipel de Vulkania", "super_area": 0 }, 51: { "name": "Îlots de la mer d\'Asse", "super_area": 0 }, 52: { "name": "Convention", "super_area": 4 }, 53: { "name": "Enutrosor", "super_area": 5 }, 54: { "name": "Srambad", "super_area": 5 }, 55: { "name": "Xélorium", "super_area": 5 }, 56: { "name": "Zone privée", "super_area": 0 }, 57: { "name": "Île de Rok", "super_area": 0 }, 58: { "name": "Havres-Sacs", "super_area": 0 }, 59: { "name": "Ecaflipus", "super_area": 5 }, 60: { "name": "Domaine des fils d\'Ecaflip", "super_area": 5 }, 61: { "name": "Saharach", "super_area": 0 }, 62: { "name": "Nimotopia", "super_area": 0 }, 63: { "name": "Profondeurs de Sufokia", "super_area": 0 }, 64: { "name": "Externam", "super_area": 8 }, 65: { "name": "Dimension Obscure", "super_area": 9 }, 66: { "name": "Mode tactique", "super_area": 0 }, 67: { "name": "Ingloriom", "super_area": 5 }, 68: { "name": "Rêve du Monde des Douze", "super_area": 6 }, 69: { "name": "Archipel des Écailles", "super_area": 0 }, 70: { "name": "Destin du Monde", "super_area": 0 }, 71: { "name": "Île de Pwâk", "super_area": 0 }, 72: { "name": "Anomalies temporelles", "super_area": 0 }, 73: { "name": "Horloge de Xélor", "super_area": 5 }, 74: { "name": "Eliocalypse", "super_area": 0 }, 75: { "name": "Profondeurs d\'Astrub", "super_area": 0 }, 76: { "name": "Éther", "super_area": 7 }, 77: { "name": "Centre du Monde", "super_area": 0 }, 78: { "name": "Île de Pandala", "super_area": 0 }, 79: { "name": "Île de Grobe", "super_area": 0 }, 80: { "name": "Plan Astral", "super_area": 6 }, 81: { "name": "Fleuve vers Externam", "super_area": 6 }, 82: { "name": "Wukin et Wukang", "super_area": 6 }, 83: { "name": "Gelaxième dimension", "super_area": 9 }, 84: { "name": "Dimensions des Cavaliers", "super_area": 9 }, 85: { "name": "Dimension Abyssale", "super_area": 9 }, 86: { "name": "Atoll des Possédés", "super_area": 0 }, 88: { "name": "Cauchemar des Ravageurs", "super_area": 6 }, 91: { "name": "Tour des enclos", "super_area": 0 }, 92: { "name": "Forêt Maléfique", "super_area": 0 }, 93: { "name": "Archipel de Valonia", "super_area": 0 }, 94: { "name": "Kolizéum", "super_area": 0 }, 87: { "name": "Dimension Éphémère", "super_area": 10 } }

var selected_area: Area

signal sub_area_selected


func _ready():
	for area in areas.values():
		var button = Button.new()
		button.text = area["name"]
		button.name = str(areas.find_key(area))
		button.button_up.connect(_on_area_clicked.bind(button))
		button.focus_mode = Control.FOCUS_NONE
		$ScrollContainer/VBC.add_child(button)


func _on_area_clicked(button: Button):
	var area = areas[button.name.to_int()]
	selected_area = Area.create(area["name"], area["super_area"])


func api() -> API:
	return get_tree().current_scene.get_node("%API")
