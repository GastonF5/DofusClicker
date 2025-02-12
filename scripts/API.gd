extends Node


const resolvers_limit := 100
var resolvers_count := 0
var resolver_queue := []

class Resolver:
	signal ready


class CompositeSignal:
	signal finished
	
	var _to_call_before: Callable
	var _to_call_after: Callable
	var _remaining : int
	
	var signals = []

	func add_signal(sig: Signal):
		signals.append(sig.get_object())
		_remaining += 1
		if _to_call_before: _to_call_before.call()
		await sig
		signals.erase(sig.get_object())
		if _to_call_after: _to_call_after.call()
		_remaining -= 1
		if _remaining == 0:
			finished.emit()
	
	func add_method(method: Callable):
		signals.append(method.get_object())
		_remaining += 1
		if _to_call_before: _to_call_before.call()
		await method.call()
		signals.erase(method.get_object())
		if _to_call_after: _to_call_after.call()
		_remaining -= 1
		if _remaining == 0:
			finished.emit()


enum ResourceType {
	ITEMS,
	MONSTERS,
}

const API_SUFFIX = "https://api.dofusdb.fr/"

const IN_REQUEST = "%s[$in][]=%s"
const SELECT_REQUEST = "select[]=%s"

const BAD_REQUEST := 4
const INTERNAL_SERVER_ERROR := 500
const BAD_GATEWAY := 502

var races = { -1: "Non classés", 0: "Invocations de classe", 2: "Bandits", 3: "Wabbits", 4: "Dragoeufs Immatures", 5: "Bworks d\'Amakna", 6: "Gobelins d\'Amakna", 7: "Gelées", 8: "Bêtes de la nuit", 9: "Bouftous", 10: "Plantes des champs", 11: "Larves", 12: "Kwaks", 13: "Craqueleurs", 16: "Porcos", 17: "Chafers", 18: "Dopeuls de Temple", 19: "Pnjs", 20: "Kannibouls de Moon", 21: "Dragodindes", 22: "Abraknydiens", 23: "Blops", 24: "Animaux des Champs", 25: "Sidimonstres", 26: "Gardes", 28: "Dopeuls", 30: "Brigandins", 31: "Gang de Sphincter Cell", 32: "Avis de recherche", 33: "Pious", 37: "Scarafeuilles", 38: "Araknes", 39: "Mulous", 40: "Tortues de Moon", 41: "Pirates de Moon", 43: "Monstres de la Jungle Interdite", 44: "Gadouilleux", 45: "Champas", 46: "Tofus", 47: "Vermines des champs", 48: "Monstres des marécages", 49: "Animaux de la forêt", 50: "Monstres de quête", 51: "Corbacs", 53: "Fantômes", 60: "Koalaks", 61: "Monstres des cavernes", 62: "Protecteurs des Céréales", 63: "Protecteurs des Minerais", 64: "Protecteurs des Arbres", 65: "Protecteurs des Poissons", 66: "Protecteurs des Plantes", 67: "Minos", 68: "Monstres de Nowel", 69: "Pichons", 71: "Herboricoles", 72: "Colonie du Magistral", 73: "Monstres des Tourbières", 74: "Florifaune obscure", 75: "Peuple de l\'Arbre", 76: "Pirates de l\'Arche d\'Otomaï", 77: "Zoths", 78: "Archimonstres", 79: "Boufmouths", 81: "Bestioles de la Bourgade", 82: "Faune des Pins Perdus", 83: "Mansots", 84: "Gloursons", 85: "Sulfurieux", 86: "Équipage du Grolandais", 87: "Bléros", 88: "Givrefoux", 89: "Sylvesprits", 90: "Avis de recherche de Frigost", 91: "Monstres de Quête de Frigost", 93: "Gobelins de Sakaï", 95: "Bombes", 96: "Monstres de Vulkania", 99: "Épouvantises", 100: "Invocations de Dopeuls", 102: "Fungus", 103: "Cuirassés", 104: "Monstres de Quête de Vulkania", 105: "Monstres de quête de Nowel", 106: "Armutins", 107: "Alchillusions", 108: "Brikoléreux", 109: "Sinistros", 110: "Invocations de monstre", 112: "Prismes d\'alliance", 113: "Monstres de l\'île de Kartonpath", 114: "Monstres de l\'archevêché", 116: "Monstres de quête d\'alignement", 117: "Mercemers", 118: "Monstres événementiels", 120: "Kanigs des Dents de Pierre", 121: "Obscuranti", 122: "Truches", 123: "Porkass", 124: "Phorreurs", 125: "Enutrofors", 126: "Koffrefors", 127: "Avis de recherche des Dimensions", 128: "Cour Sombre", 129: "Malveilleurs", 130: "Nécrotiques", 131: "Krobes", 132: "Égarés", 133: "Hordémons", 134: "Xélomorphes", 135: "Vilinsekts", 136: "Arak-haï", 137: "Chafers d\'Incarnam", 138: "Monstres du Temple Céleste", 139: "Monstres de quête d\'Incarnam", 140: "Feux spirituels", 141: "Bouftous d\'Incarnam", 142: "Monstres des champs d\'Incarnam", 143: "Chapardams", 144: "Gloots", 145: "Champignons d\'Incarnam", 147: "Avis de recherche alignés", 148: "Grand Jeu", 149: "Ecaflipuces", 150: "Matougarous", 152: "Monstres des ruines sous-marines", 153: "Trithons", 154: "Serviteurs de l\'indicible", 155: "Muldos Sauvages", 156: "Avis de recherche de Sufokia", 158: "Gliglis", 159: "Automates des Brigandins", 160: "Troolls de Litneg", 162: "Ruffians de Cania", 163: "Bworks de Cania", 166: "Animaux du désert", 167: "Cacterres", 168: "Vers des sables", 169: "Maudits", 171: "Chassouilleurs", 172: "Magik Riktus", 173: "Goules", 174: "Animalades", 175: "Brûlâmes", 176: "Calcinés", 177: "Submergés", 181: "Monstres des plages", 182: "Sidoas", 183: "Volkornes", 184: "Clan Martegel", 189: "Croquants", 190: "Waddicts", 191: "Gardiens des anomalies", 193: "Chocomanciens", 196: "Monstres de quête de l\'île de Pwâk", 199: "Invocations de classe : Osamodas", 201: "Dragoss", 202: "Dragoeufs Protecteurs", 203: "Crocodailles de Crocuzko", 204: "Invocations de classe : Enutrof", 206: "Invocations de classe : Pandawa", 207: "Invocations de classe : Ecaflip", 209: "Invocations de classe : Ouginak", 210: "Invocations de classe : Sadida", 211: "Invocations de classe : Féca", 212: "Invocations de classe : Eniripsa", 213: "Invocations de classe : Crâ", 215: "Asservis", 216: "Miséreux", 217: "Sanguinaires", 218: "Corrompus", 220: "Invocations de classe : Roublard", 221: "Invocations de classe : Steamer", 224: "Kwapa", 225: "Kozaru", 226: "Tanuki", 228: "Plantalas", 229: "Firefoux", 230: "Armée de brume", 231: "Yokai des Tombeaux", 232: "Yokianzhi de Papier", 233: "Yokianzhi d\'Encre", 236: "Possédés", 240: "Rats Brâkmariens", 241: "Rats Bontariens", 243: "Invocations Boufbowl", 245: "Malters", 192: "Gromorphes", 242: "Ravageurs", 250: "Poutch", 253: "World Boss", 194: "Brutomorphes", 195: "Brikomorphes", 256: "Rats Strubiens", 257: "Rats Maknéens", 258: "Bworks de Gisgoul", 259: "Grosses Larves", 260: "Monstres du repos", 261: "Koalaks mortels", 262: "Koalaks primitifs", 263: "Gawde du Wa", 264: "Wabbits mutants", 265: "Abraknydiens Sombres", 266: "Abraknydiens Irascibles", 267: "Gros Tofus", 268: "Mélomaniaques", 269: "Koalaks sauvages", 273: "Palmikos", 255: "Rebelles de la futaie", 270: "Protecteurs d\'Ephedrya", 274: "Marteaux-Aigris", 275: "Invocation de compagnon", 277: "Gardiens solitaires", 278: "Invocations de classe : Forgelance", 279: "Invocations de classe : Sacrieur", 280: "Invocations de classe : Iop", 281: "Invocations de classe : Huppermage", 282: "Invocations de classe : Xélor", 283: "Invocations de classe : Zobal", 284: "Invocations de classe : Eliotrope", 285: "Invocations communes", 222: "Invocations Temporis", 287: "Pirates naufragés", 306: "Monstres d\'évènement" }
var characteristics = [
	["PA", 1],
	["PM", 23],
	["VITALITE", 11],
	["AGILITE", 14],
	["CHANCE", 13],
	["FORCE", 10],
	["INTELLIGENCE", 15],
	["SAGESSE", 12],
	["PUISSANCE", 25],
	["DOMMAGES", 16],
	["CRITIQUE", 18],
	["DO_CRITIQUES", 86],
	["SOIN", 49],
	["RES_AIR", 36],
	["RES_EAU", 35],
	["RES_TERRE", 33],
	["RES_FEU", 34],
	["RES_NEUTRE", 37],
	["RES_PA", 27],
	["RES_PM", 28],
	["INVOCATIONS", 26],
	["PROSPECTION", 48],
	["DO_AIR", 91],
	["DO_EAU", 90],
	["DO_TERRE", 88],
	["DO_FEU", 89],
	["DO_NEUTRE", 92],
	["MAITRISE_ARME", 31],
	["PUI_PIEGES", 69],
	["DO_PIEGES", 70],
	["EROSION", 75],
	["RET_PA", 82],
	["RET_PM", 83],
	["DO_POU", 84],
	["RES_POU", 85],
	["RES_CRITIQUES", 87],
	["RES_AIR_FIXE", 57],
	["RES_EAU_FIXE", 56],
	["RES_TERRE_FIXE", 54],
	["RES_FEU_FIXE", 55],
	["RES_NEUTRE_FIXE", 58],
	["DO_SORTS", 123],
	["DO_ARME", 122],
	["DO_DISTANCE", 120],
	["DO_MELEE", 125]
]


var json_dict = {}


func create_http() -> HTTPRequest:
	var http = HTTPRequest.new()
	add_child(http)
	return http


func request(url: String):
	#print("Perform HTTP request on : " + url)
	var http = create_http()
	http.request_completed.connect(_on_request_completed.bind(url))
	
	# manage resolvers
	resolvers_count += 1
	if resolvers_count > resolvers_limit:
		var resolver = Resolver.new()
		resolver_queue.append(resolver)
		await resolver.ready
	
	# perform request
	var error = http.request(url, PackedStringArray(), HTTPClient.METHOD_GET)
	
	log_error(error, "An error occurred in the HTTP request.")
	return http


func await_for_request_completed(http: HTTPRequest):
	await http.request_completed
	
	# manager waiting resolvers
	resolvers_count -= 1
	var waiting_resolver = resolver_queue.pop_front()
	if waiting_resolver:
		waiting_resolver.ready.emit()
	
	http.queue_free()


func get_data(key):
	if json_dict.get(key) == null:
		return null
	var json = json_dict[key]
	json_dict.erase(key)
	if json.get("data"):
		return json["data"]
	return json


func get_texture(url: String):
	if json_dict.get(url) == null:
		return null
	var texture = json_dict[url]
	json_dict.erase(url)
	return texture


func get_in_request(row: String, value: String) -> String:
	return IN_REQUEST % [row, value]


func get_equals_request(row: String, value: String) -> String:
	return "%s=%s" % [row, value]


func get_select_request(row: String) -> String:
	return SELECT_REQUEST % row


func _on_request_completed(_result, response_code, headers: PackedStringArray, body, _id):
	if check_response_code(response_code) == 0 and !headers.is_empty():
		var type_index = headers.bsearch("Content-Type")
		check_format(headers[type_index].split(" ")[1]).callv([body, _id])
		#print("request %s completed" % _id)
	else:
		log.error(response_code)


func _on_json_received(body, _id):
	#print("JSON received")
	var json = JSON.parse_string(body.get_string_from_utf8())
	if !json: log_error(json, "Error while parsing JSON.")
	else: json_dict[_id] = json


func _on_image_received(body, _id):
	#print("Image received")
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	log_error(error, "Couldn't load the image.")
	var texture = ImageTexture.new()
	texture = ImageTexture.create_from_image(image)
	json_dict[_id] = texture


func log_error(error, message: String):
	if error != OK:
		push_error(message)


func check_format(type_header: String) -> Callable:
	if type_header.contains("json"):
		return _on_json_received
	if type_header.begins_with("image"):
		return _on_image_received
	return func(): pass


func check_response_code(response_code: int) -> int:
	var code = int(response_code / 100.0)
	# 4XX
	if code == BAD_REQUEST:
		push_error("Bad request")
		return 1
	# 500
	if response_code == INTERNAL_SERVER_ERROR:
		push_error("Internal serveur error")
		return 1
	# 502
	if response_code == BAD_GATEWAY:
		push_error("Bad gateway")
		return 1
	return 0


func get_monster_resource(data):
	var res = MonsterResource.new()
	res.name = data["name"]["fr"]
	res.id = data["id"]
	res.boss = data["isBoss"]
	res.archimonstre = data["isMiniBoss"]
	#var archimonstre = data["correspondingMiniBoss"]
	#res.corresponding_archimonstre_id = 0 if !archimonstre else archimonstre["id"]
	#var non_archimonstre = data["correspondingNonMiniBoss"]
	#res.corresponding_non_archimonstre_id = 0 if !non_archimonstre else non_archimonstre["id"]
	
	res.drops = [] as Array[DropResource]
	for drop in data["drops"]:
		var drop_res = DropResource.new()
		drop_res.id = drop["dropId"]
		drop_res.monster_id = drop["monsterId"]
		drop_res.object_id = drop["objectId"]
		drop_res.percent_drop = [drop["percentDropForGrade1"], drop["percentDropForGrade2"], drop["percentDropForGrade3"], drop["percentDropForGrade4"], drop["percentDropForGrade5"]]
		res.drops.append(drop_res)
	res.drops.append_array(Datas.find_drop_exception_by_monster_id(res.id))
	
	res.spells.assign(data["spells"])
	
	res.race_id = data["race"]
	var race = "Not found" if !races.keys().has(res.race_id) else races[res.race_id]
	res.race = race
	
	res.areas.assign(data["subareas"].map(func(id): return id as int))
	res.image_url = Renderer.get_url(data)
	
	res.grades = [] as Array[GradeResource]
	for grade in data["grades"]:
		var grade_res = GradeResource.create(grade["grade"], grade["monsterId"], grade["level"], grade["gradeXp"])
		grade_res.characteristics.append(StatResource.create(Caracteristique.Type.VITALITE, grade["lifePoints"]))
		grade_res.characteristics.append(StatResource.create(Caracteristique.Type.PA, grade["actionPoints"]))
		grade_res.characteristics.append(StatResource.create(Caracteristique.Type.PM, grade["movementPoints"]))
		grade_res.characteristics.append(StatResource.create(Caracteristique.Type.RES_PA, grade["paDodge"]))
		grade_res.characteristics.append(StatResource.create(Caracteristique.Type.RES_PM, grade["pmDodge"]))
		grade_res.characteristics.append(StatResource.create(Caracteristique.Type.SAGESSE, grade["wisdom"]))
		grade_res.characteristics.append(StatResource.create(Caracteristique.Type.FORCE, grade["strength"]))
		grade_res.characteristics.append(StatResource.create(Caracteristique.Type.INTELLIGENCE, grade["intelligence"]))
		grade_res.characteristics.append(StatResource.create(Caracteristique.Type.CHANCE, grade["chance"]))
		grade_res.characteristics.append(StatResource.create(Caracteristique.Type.AGILITE, grade["agility"]))
		grade_res.characteristics.append(StatResource.create(Caracteristique.Type.RES_TERRE, grade["earthResistance"]))
		grade_res.characteristics.append(StatResource.create(Caracteristique.Type.RES_FEU, grade["fireResistance"]))
		grade_res.characteristics.append(StatResource.create(Caracteristique.Type.RES_EAU, grade["waterResistance"]))
		grade_res.characteristics.append(StatResource.create(Caracteristique.Type.RES_AIR, grade["airResistance"]))
		grade_res.characteristics.append(StatResource.create(Caracteristique.Type.RES_NEUTRE, grade["neutralResistance"]))
		res.grades.append(grade_res)
	return res


func get_carach_type_from_id(carac_id: int) -> Caracteristique.Type:
	var result = characteristics.filter(func(ch): return ch[1] == carac_id)
	return -1 if result.size() == 0 else Caracteristique.Type.get(result[0][0])
