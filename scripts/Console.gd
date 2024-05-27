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
	if event.is_action_pressed("copy"):
		copy()
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
	if output.has_focus() and (event.is_action_pressed("esc") or event.is_action_pressed("LMB")):
		output.release_focus()
	
	if input.has_focus():
		if event.is_action_pressed("up"):
			if history.size() != 0:
				input.text = "/" + history[history.size() - 1]


func copy():
	DisplayServer.clipboard_set(output.get_selected_text())


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
			if ["item", "resource"].has(params[0]):
				var id = params[1].to_int()
				var count = 1
				if params.size() >= 3:
					count = params[2]
				var item_res
				var dict
				match params[0]:
					"item": dict = Datas._items
					"resource": dict = Datas._resources
				if dict.has(id):
					item_res = dict[id]
					item_res.count = count
					inventory.add_item(Item.create(item_res, inventory))
				else:
					log_error("%s not found" % params[0].to_pascal_case())
				pass
			else:
				log_error("Command not found")
		"get":
			if params.size() <= 1: return
			var id = params[1].to_int()
			match params[0]:
				"item":
					if Datas._items.has(id) and params.size() <= 2:
						log_info(Datas._items[id].name)
						pass
					elif params.size() >= 3:
						if params[2] == "recipe":
							if Datas._recipes.has(id):
								log_info(Datas._recipes[id].to_string())
							else:
								log_error("Il n'existe pas de recette pour l'item %s (%d)" % [Datas._items[id].name, id])
					else:
						log_error("L'item d'id %d n'existe pas" % id)
				"monster":
					if Datas._monsters.has(id):
						var monster_res: MonsterResource = Datas._monsters[id]
						log_info(monster_res.name)
						if params.size() == 3:
							var property = params[2]
							if property in monster_res:
								log_info(" - %s" % str(monster_res.get(property)))
							else:
								log_error("La ressource MonsterResource ne contient pas la propriété %s" % property)
						pass
					else:
						log_error("Le monstre d'id %d n'existe pas" % id)
				"ressource":
					if Datas._resources.has(id) and params.size() <= 2:
						log_info(Datas._resources[id].name)
						pass
					else:
						log_error("La ressource d'id %d n'existe pas" % id)
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
