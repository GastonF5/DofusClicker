class_name Console
extends Control


const EQUIPMENT_RESOURCE_PATH = "res://resources/equipment/%s.tres"

const Element = Caracteristique.Element
const CaracType = Caracteristique.Type
const LogType = ConsoleOutput.LogType

const EffectType = EffectResource.Type

const INFO = LogType.INFO
const COMMAND = LogType.COMMAND

@export var output: ConsoleOutput
@export var input: LineEdit

var history: Array[String] = []

var processing = false

var inventory: Inventory


func initialize():
	inventory = Globals.inventory
	input.visible = Globals.debug
	input.focus_entered.connect(Globals.take_focus)
	input.focus_exited.connect(Globals.leave_focus)


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
	
	if input.has_focus():
		if event.is_action_pressed("up"):
			if history.size() != 0:
				input.text = "/" + history[history.size() - 1]


func copy():
	if Globals.focused_node is RichTextLabel:
		DisplayServer.clipboard_set(Globals.focused_node.get_selected_text())


func input_empty() -> bool:
	return input.text == ""


func is_command(text: String) -> bool:
	return text.begins_with("/")


func _log(text: String, type: LogType = LogType.NONE, bold: bool = false):
	output.append_log(text, type, bold)
	output.new_line()


func _log_line(text: String, type: LogType = LogType.NONE, bold: bool = false):
	output.append_log(text, type, bold)


func do_command(command: String, params: Array[String] = []):
	match command:
		"help":
			_log("Commandes possibles :\n- clear\n- histo", COMMAND)
			_log("- monster [{index} set {characteristic} {amount}] [kill {all|index}]", COMMAND)
			_log("- add [item|resource|key] {id}", COMMAND)
			_log("- get [item|monster|resource] {id}", COMMAND)
			_log("- save", COMMAND)
		"save":
			SaveManager.save()
			pass
		"xp":
			var amount = params[0].to_int()
			if params.size() > 1 and params[1] == "lvl":
				Globals.xp_bar.gain_levels(amount)
			if params.size() > 0:
				Globals.xp_bar.gain_xp(amount)
			pass
		"clear":
			clear()
			pass
		"histo":
			if params.has("clear"):
				history = []
			else:
				if !history.is_empty():
					_log("Historique des commandes :", COMMAND)
					for histo in history:
						_log("- " + histo, COMMAND)
				else:
					_log("L'historique est vide", COMMAND)
			return
		"monster":
			if params.size() > 1:
				if params[1] == "set":
					var index = params[0] as int
					if index < MonsterManager.monsters.size():
						var monster = MonsterManager.monsters[index]
						if monster:
							var stat_res: StatResource = monster.get_caracteristique_for_type(Caracteristique.Type.get(params[2].to_upper()))
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
			if ["item", "resource", "key"].has(params[0]):
				var id = params[1].to_int()
				var count = 1
				if params.size() >= 3:
					count = params[2]
				var item_res
				var dict
				match params[0]:
					"item": dict = Datas._items
					"resource": dict = Datas._resources
					"key": dict = Datas._keys
				if dict.has(id):
					item_res = dict[id]
					item_res.count = count
					inventory.add_item(Item.create(item_res))
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
	log.error(text)
	if Globals.debug:
		_log("Erreur : " + text, LogType.ERROR)


func log_equip(item: Item):
	log_info("Informations de %s (%s)" % [item.name, item.resource.equip_res.get_type()])
	for stat: StatResource in item.stats:
		log_info("- %s : %d" % [stat.get_type(), stat.amount])
	output.new_line()


func log_spell_cast(caster: Entity, spell_res: SpellResource, crit: bool):
	output.add_spell_image(spell_res.texture)
	_log_line(get_entity_name(caster), INFO, true)
	var lance = " lance%s " % ("z" if caster.is_player else "")
	_log_line(lance, INFO)
	_log_line(spell_res.name, INFO, true)
	if crit:
		log_critique()
	output.new_line()


func log_effects(effects_to_log: Array):
	var targets = {}
	for effect in effects_to_log:
		if effect[1] != null:
			var target: Entity = effect[1]
			if !targets.has(target):
				targets[target] = [effect]
			else:
				targets[target].append(effect)
	for target_effects in targets.values():
		var target = targets.find_key(target_effects)
		for type in EffectType.values():
			var effects: Array = target_effects.filter(func(e): return e[0] == type)
			if !effects.is_empty():
				match type:
					EffectType.DAMAGE:
						# [type, target, amount, element, dead, is_poison]
						var amounts = effects.map(func(e): return e[2])
						var elements = effects.map(func(e): return e[3])
						var dead = effects.reduce(func(accum, e): return accum or e[4], false)
						var poison = effects.reduce(func(accum, e): return accum or e[5], false)
						log_damage(target, amounts, elements, dead, poison)
					EffectType.BONUS:
						# [type, target, effect_label]
						for bonus in effects:
							log_bonus(target, bonus[2])
					EffectType.RETRAIT:
						# [type, target, amount, characteristic]
						for retrait in effects:
							log_retrait(target, retrait[2], retrait[3])
					EffectType.BOUCLIER:
						# [type, target, amount, time]
						for shield in effects:
							log_shield(target, shield[2], shield[3])
					EffectType.POISON:
						# [type, target, amount, element, time, characteristic, nb_hits]
						for poison in effects:
							log_poison(target, poison[2], poison[3], poison[4], poison[5], poison[6])
					EffectType.INVISIBILITE:
						# [type, target, time]
						for invi in effects:
							log_invisibilite(target, invi[2])
					EffectType.AVEUGLE:
						# [type, target, time]
						for aveugle in effects:
							log_aveuglement(target, aveugle[2])


func log_weapon_cast(caster: Entity, weapon_name: String, crit: bool):
	_log_line(get_entity_name(caster), INFO, true)
	_log_line(" attaquez avec ", INFO)
	_log_line(weapon_name, INFO, true)
	if crit:
		log_critique()
	output.new_line()


func log_damage(target: Entity, amounts: Array, elements: Array, dead: bool, poison := false):
	if amounts.size() != elements.size():
		log_error("in log_damage : amounts size != elements size")
	if !amounts.is_empty():
		_log_line(get_entity_name(target), INFO, true)
		_log_line(" : ", INFO)
		output.append_damages(amounts, elements)
		_log_line(" PV", INFO)
		if poison:
			_log_line(" (Poison)", INFO)
		if dead:
			_log_line(" (mort)", INFO)
		output.new_line()


func log_bonus(target: Entity, effect_label: String):
	_log_line(get_entity_name(target), INFO, true)
	_log_line(" : " + effect_label, INFO)
	output.new_line()


func log_other_bonus(target: Entity, amount: int, caracteristic: String, time: float):
	if amount != 0:
		_log_line(get_entity_name(target), INFO, true)
		_log_line(" : %d %s" % [amount, caracteristic], INFO)
		if time != 0.0:
			_log_line(" (%d secondes)" % time, INFO)
		output.new_line()


func log_critique():
	_log_line(" (Critique)", INFO)


func log_retrait(target: Entity, amount: int, characteristic: String):
	log_other_bonus(target, -amount, characteristic, 0.0)


func log_shield(target: Entity, amount: int, time: float):
	log_other_bonus(target, amount, "Bouclier", time)


func log_poison(target: Entity, amount: int, element: Element, time: float, characteristic: String, nb_hits: int):
	if amount != 0:
		_log_line(get_entity_name(target), INFO, true)
		_log_line(" : ", INFO)
		output.append_poison_apply(amount, element)
		_log_line(" Poison", INFO)
		if characteristic != "":
			_log_line(" (%s)" % characteristic, INFO)
		if time != 0.0:
			_log_line(" (%d secondes)" % time, INFO)
		if characteristic == "":
			_log_line(" (%d fois)" % nb_hits, INFO)


func log_invisibilite(target: Entity, time: float):
	_log_line(get_entity_name(target), INFO, true)
	_log_line(" : devient invisible", INFO)
	_log_line(" (%d secondes)" % time, INFO)


func log_aveuglement(target: Entity, time: float):
	_log_line(get_entity_name(target), INFO, true)
	_log_line(" : devient aveugle", INFO)
	_log_line(" (%d secondes)" % time, INFO)


func get_entity_name(entity: Entity):
	var entity_name = entity.name
	if entity.is_player:
		entity_name = "Vous"
	return entity_name
