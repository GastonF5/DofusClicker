class_name ClassPeeker
extends CanvasLayer

const ASSETS_PATH = "res://assets/classes/logo/"

var classes = {
	1: "Féca",
	2: "Osamodas",
	3: "Enutrof",
	4: "Sram",
	5: "Xelor",
	6: "Ecaflip",
	7: "Eniripsa",
	8: "Iop",
	9: "Cra",
	10: "Sadida",
	11: "Sacrieur",
	12: "Panda",
	13: "Roublard",
	14: "Zobal",
	15: "Steamer",
	16: "Eliotrope",
	17: "Huppermage",
	18: "Ouginak",
	19: "Forgelance"
}

var available := [6, 8]
const button_size := 150

@export var bselect: Button

@export var bcontainer1: Control
@export var bcontainer2: Control

@export var clogo: TextureRect
@export var clabel: Label

var buttons:
	get:
		return bcontainer1.get_children() + bcontainer2.get_children()

var selected_class: int


func _ready():
	clogo.texture = null
	clabel.text = ""
	for button in buttons:
		button.toggled.connect(_on_button_toggled.bind(button.name.to_int()))
		button.disabled = !available.has(button.name.to_int())


func _on_button_toggled(toggle: bool, id: int):
	bselect.disabled = !toggle
	if toggle:
		selected_class = id
		select_class()
		for button: Button in buttons:
			if button.name.to_int() != id:
				button.set_pressed_no_signal(false)
	else:
		select_class(0)


func select_class(id: int = selected_class):
	if classes.keys().has(id):
		clogo.texture = load("res://assets/classes/logo_transparent/logo_transparent_%d.png" % id)
		clabel.text = classes[id]
	else:
		clogo.texture = null
		clabel.text = ""


func _on_select_button_button_up():
	print(classes[selected_class])
