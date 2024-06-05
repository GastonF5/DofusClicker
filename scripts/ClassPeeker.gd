class_name ClassPeeker
extends Control

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

var available := [6]
const button_size := 150

@export var bcontainer1: Control
@export var bcontainer2: Control

var buttons:
	get:
		return bcontainer1.get_children() + bcontainer2.get_children()

var selected_class: int


func _ready():
	for button in buttons:
		button.toggled.connect(_on_button_toggled.bind(button.name.to_int()))


func _on_button_toggled(toggle: bool, id: int):
	if toggle:
		selected_class = id
		for button: Button in buttons:
			if button.name.to_int() != id:
				button.button_pressed = false
