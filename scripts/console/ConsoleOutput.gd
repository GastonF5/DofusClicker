class_name ConsoleOutput extends RichTextLabel

const SCENE_PATH := "res://scenes/console/console_log.tscn"
const SEPARATOR_PATH = "res://assets/common/separator/window_separator_green_horizontal.png"
const LOG_GROUP := "console_output"
const SPELL_SIZE := 45

const Element = Caracteristique.Element

enum LogType {
	INFO,
	LOG,
	ERROR,
	COMMAND,
	NONE
}


func append_log(new_text: String, type: LogType, bold := false):
	if bold: push_bold()
	_apply_color(type)
	add_text(new_text)
	pop_all()


func append_damages(amounts: Array, elements: Array):
	if amounts.size() == 1:
		_append_damage(amounts[0], elements[0])
	else:
		var total = amounts.reduce(func(sum, a): return sum + a, 0)
		_append_damage(total, Element.NONE)
		append_log(" (", LogType.INFO)
		_append_damage(amounts[0], elements[0], false)
		for i in range(1, amounts.size()):
			append_log(" + ", LogType.INFO)
			_append_damage(amounts[i], elements[i], false)
		append_log(")", LogType.INFO)


func _append_damage(amount: int, element: Element, with_sign := true):
	var new_text := ""
	if with_sign:
		new_text += "-" if amount > 0 else "+"
	new_text += str(abs(amount))
	push_bold()
	_apply_element_color(element)
	add_text(new_text)
	pop_all()


func new_line():
	add_text("\n")


func add_separator():
	add_image(preload(SEPARATOR_PATH), get_parent().get_parent().size.x)


func add_spell_image(spell_image: Texture2D):
	if spell_image:
		add_image(spell_image, SPELL_SIZE, SPELL_SIZE)
	add_text("  ")


func _apply_color(type: LogType):
	var color = Color.WHITE
	match type:
		LogType.INFO:
			color = Color.LIME_GREEN
		LogType.ERROR:
			color = Color.CRIMSON
		LogType.LOG:
			color = Color.ORANGE
		LogType.COMMAND:
			color = Color.SKY_BLUE
	push_color(color)


func _apply_element_color(element: Element):
	var color = Color.WHITE
	match element:
		Element.AIR:
			color = Color.GREEN
		Element.EAU:
			color = Color.DODGER_BLUE
		Element.FEU:
			color = Color.CRIMSON
		Element.TERRE:
			color = Color.SADDLE_BROWN
		Element.NEUTRE:
			color = Color.GRAY
		Element.POUSSEE:
			color = Color.GOLD
		Element.NONE:
			color = Color.MAGENTA
	push_color(color)
