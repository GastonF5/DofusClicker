class_name Console
extends Control


enum LogType {
	INFO,
	LOG,
	ERROR,
	COMMAND,
	NONE
}


@export var output: RichTextLabel
@export var input: LineEdit

var history: Array[String] = []

var processing = false


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
	var command_str = command
	for param in params:
		command_str += " " + param
	history.append(command_str)


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
