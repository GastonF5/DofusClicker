class_name Console
extends Control


const EQUIPMENT_RESOURCE_PATH = "res://resources/equipment/%s.tres"

enum LogType {
	INFO,
	LOG,
	ERROR,
	COMMAND,
	NONE
}

@onready var api: API = $%API

@export var output: RichTextLabel
@export var input: LineEdit

var history: Array[String] = []

var processing = false

var inventory: Inventory


func _ready():
	inventory = $%PlayerManager.inventory


func _input(event):
	if !processing and !input_empty() and event.is_action_pressed("enter"):
		processing = true
		var input_text = input.text
		if input_text[0] == "":
			input_text = input_text.erase(0)
		if is_command(input_text):
			var command_line = input_text.rstrip("\n").split(" ", false)
			var command = command_line[0].lstrip("/")
			var params = command_line.slice(1)
			do_command(command, params)
		else:
			_log(input_text)
		input.clear()
		processing = false
	
	if input.has_focus() and (event.is_action_pressed("esc") or event.is_action_pressed("LMB")):
		input.release_focus()
	
	if input.has_focus():
		if event.is_action_pressed("up"):
			if history.size() != 0:
				input.text = "/" + history[history.size() - 1]


func input_empty() -> bool:
	return input.text == ""


func is_command(text: String) -> bool:
	return text.begins_with("/")


func _log(text: String, type: LogType = LogType.NONE, bold: bool = false):
	if bold: output.push_bold()
	apply_color(type)
	output.add_text(text + "\n")
	output.pop_all()


func apply_color(type: LogType):
	var color = Color.WHITE
	match type:
		LogType.INFO:
			color = Color.LIME_GREEN
		LogType.ERROR:
			color = Color.RED
		LogType.LOG:
			color = Color.ORANGE
		LogType.COMMAND:
			color = Color.SKY_BLUE
	output.push_color(color)


func do_command(command: String, params: Array[String] = []):
	match command:
		"clear":
			clear()
			pass
		"histo":
			if params.has("clear"):
				history = []
			else:
				if !history.is_empty():
					_log("Historique des commandes :", LogType.COMMAND)
					for histo in history:
						_log("- " + histo, LogType.COMMAND)
				else:
					_log("L'historique est vide", LogType.COMMAND)
			return
		"monster":
			if params.size() > 1:
				if params[1] == "set":
					var index = params[0] as int
					if index < MonsterManager.monsters.size():
						var monster = MonsterManager.monsters[index]
						if monster:
							var stat_res: StatResource = monster.get_caracacteristique_for_type(Caracteristique.Type.get(params[2].to_upper()))
							if stat_res: stat_res.amount = params[3] as int
							pass
				if params[1] == "kill":
					if params[0] == "all":
						for monster in MonsterManager.monsters:
							monster.die()
					else:
						var index = params[0] as int
						var monster: Monster = MonsterManager.monsters[index]
						monster.die()
		"add":
			if params[0] == "equip":
				var equip_res = FileLoader.get_equipment_resource(EQUIPMENT_RESOURCE_PATH % params[1])
				if equip_res:
					inventory.add_item(Item.create(equip_res, inventory))
				else:
					log_error("Equipment not found")
				pass
			if params[0] == "item":
				var time = Time.get_ticks_msec()
				log_info("Loading...")
				var id = params[1].to_int()
				await api.request_item_by_id(id)
				var item_res = api.get_data(id)
				inventory.add_item(Item.create(item_res, inventory))
				log_info("Request completed in %d ms" % (Time.get_ticks_msec() - time))
				pass
		"itemset":
			var id = params[0].to_int()
			if id and Dicts._sets.has(id):
				var item_set = Dicts._sets[id]
				var log = item_set._name
				if params.size() >= 2 and params[1] == "items":
					for item_id in item_set._items:
						var item = Dicts._items.get(item_id)
						log += "\n - %d : %s" % [item_id, "non trouvé" if !item else item._name]
				log_info(log)
			else:
				log_error("Il n'existe pas de panoplie avec l'id %d" % id)
		"item":
			if params.size() < 2: return
			var id = params[0].to_int()
			match params[1]:
				"get":
					if Dicts._items.has(id):
						if params.size() < 3:
							log_info(Dicts._items[id]._name)
							return
						match params[2]:
							"recipe":
								if Dicts._recipes.has(id):
									log_info(Dicts._recipes[id].to_string())
								else:
									log_error("Il n'existe pas de recette pour l'item %s (%d)" % [Dicts._items[id]._name, id])
					else:
						log_error("L'item d'id %d n'existe pas" % id)
	var command_histo = command
	for param in params:
		command_histo += " " + param
	history.append(command_histo)


func clear():
	output.clear()


func log_info(text: String, bold: bool = false):
	_log(text, LogType.INFO, bold)


func log_error(text: String):
	push_error(text)
	_log("ERROR : " + text, LogType.ERROR)


func log_equip(item: Item):
	log_info("Informations de %s (%s)" % [item.name, item.resource.equip_res.get_type()])
	for stat: StatResource in item.stats:
		log_info("- %s : %d" % [stat.get_type(), stat.amount])
