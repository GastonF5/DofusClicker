class_name ClassPeeker
extends CanvasLayer

const ASSETS_PATH = "res://assets/classes/logo/"

var classes = {
	1: "Féca", 2: "Osamodas", 3: "Enutrof", 4: "Sram", 5: "Xelor", 6: "Ecaflip",
	7: "Eniripsa", 8: "Iop", 9: "Cra", 10: "Sadida", 11: "Sacrieur", 12: "Panda",
	13: "Roublard", 14: "Zobal", 15: "Steamer", 16: "Eliotrope", 17: "Huppermage",
	18: "Ouginak", 19: "Forgelance"
}

var passifs = {
	1: "",
	2: "",
	3: "",
	4: "",
	5: "",
	6: "Passif : + X critique pendant 60 secondes chaque fois qu'un sort de dégâts est lancé",
	7: "",
	8: "Passif : dommages plus importants en fonction des PV max",
	9: "",
	10: "",
	11: "",
	12: "",
	13: "",
	14: "",
	15: "",
	16: "",
	17: "",
	18: "",
	19: ""
}

var roles_par_classe = {
	1: [], 2: [], 3: [],
	4: [], 5: [], 6: [6, 5, 8],
	7: [], 8: [5, 8, 3], 9: [],
	10: [], 11: [], 12: [],
	13: [], 14: [], 15: [],
	16: [], 17: [], 18: [],
	19: [],
}

var available := [6, 8]
const button_size := 150

@export var bselect: Button

@export var bcontainer1: Control
@export var bcontainer2: Control

@export var clogo: TextureRect
@export var clabel: Label

@export var role_container: HBoxContainer
@export var spell_container1: HBoxContainer
@export var spell_container2: HBoxContainer

@export var passif_label: Label
@export var description: DescriptionPopUp

var nspells = []

var buttons:
	get:
		return bcontainer1.get_children() + bcontainer2.get_children()

var selected_class: int


func _ready():
	$ClassPanel/HBC.visible = false
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
	$ClassPanel/HBC.visible = classes.keys().has(id)
	$ClassPanel/SelectionnerLabel.visible = not $ClassPanel/HBC.visible
	empty_container("role_container")
	empty_container("spell_container1")
	empty_container("spell_container2")
	passif_label.text = ""
	if classes.keys().has(id):
		clogo.texture = get_logo_transparent(id)
		clabel.text = classes[id]
		passif_label.text = passifs[id]
		init_roles(id)
		init_spells(id)
	else:
		clogo.texture = null
		clabel.text = ""


func _on_select_button_button_up():
	print(classes[selected_class])


func get_logo_transparent(id: int = selected_class) -> Texture2D:
	return load("res://assets/classes/logo_transparent/logo_transparent_%d.png" % id)


func init_roles(class_id: int):
	for role_id in roles_par_classe[class_id]:
		role_container.add_child(ClassRole.create(role_id))


func init_spells(class_id: int):
	for spell_res in FileLoader.get_spell_resources(classes[class_id].to_lower()):
		var nspell = TextureRect.new()
		nspell.texture = spell_res.texture
		nspell.custom_minimum_size = Vector2i(60, 60)
		nspell.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		nspell.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		nspell.mouse_entered.connect(show_description.bind(spell_res))
		nspell.mouse_exited.connect(hide_description)
		nspells.append(nspell)
		if spell_container1.get_child_count() < 5:
			spell_container1.add_child(nspell)
		else:
			spell_container2.add_child(nspell)


func empty_container(container_name: String):
	var container = self.get(container_name)
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()


func show_description(spell_res: SpellResource):
	description.init_spell_in_class_peeker(spell_res)
	description.visible = true


func hide_description():
	description.visible = false
