class_name Caracteristique
extends Control


enum Type {
	PA,
	PM,
	VITALITE,
	AGILITE,
	CHANCE,
	FORCE,
	INTELLIGENCE,
	SAGESSE,
	PUISSANCE,
	DOMMAGES,
	CRITIQUE,
	DO_CRITIQUES,
	SOIN,
	RES_AIR,
	RES_EAU,
	RES_TERRE,
	RES_FEU,
	RES_NEUTRE,
	RES_PA,
	RES_PM,
	INVOCATIONS,
	PROSPECTION,
	DO_AIR,
	DO_EAU,
	DO_TERRE,
	DO_FEU,
	DO_NEUTRE,
	MAITRISE_ARME,
	PUI_PIEGES,
	DO_PIEGES,
	EROSION,
	RET_PA,
	RET_PM,
	DO_POU,
	RES_POU,
	RES_CRITIQUES,
	RES_DOMMAGES,
	PV,
	DO_SORTS,
}

enum Element {
	NEUTRE,
	TERRE,
	FEU,
	EAU,
	AIR,
	NONE,
	BEST,
	RANDOM,
	POUSSEE,
}

static func get_element(id: int):
	return Element.get(id)

static func type_to_element(carac_type: Type) -> Element:
	match carac_type:
		Type.AGILITE: return Element.AIR
		Type.CHANCE: return Element.EAU
		Type.INTELLIGENCE: return Element.FEU
		Type.FORCE: return Element.TERRE
		_: return Element.NONE

static func element_to_type(element: Element) -> Type:
	match element:
		Element.AIR: return Type.AGILITE
		Element.EAU: return Type.CHANCE
		Element.FEU: return Type.INTELLIGENCE
		Element.TERRE: return Type.FORCE
		_: push_error("Element %s not supported in this function" % Element.find_key(element))
	# retourne PA par défaut, qui n'est pas une bonne valeur
	return Type.PA

@export var modifiable = true

var icon_texture: TextureRect
var label: Label
var amount_label: Label

var plus_btn: Button
var minus_btn: Button

@export var init_label: String

var tooltip: Tooltip
@export var static_tooltip_text: String
@export var info: TextureRect

var type: Type
var base_amount = 0:
	set(value):
		base_amount = value
		amount = base_amount + equip_amount

var equip_amount = 0:
	set(value):
		equip_amount = value
		amount = base_amount + equip_amount

var amount = 0:
	set(value):
		var changed = amount != value
		amount = value
		amount_label.text = str(amount)
		update_tooltip()
		if changed: amount_change.emit()

signal consume_point
signal amount_change


func _process(_delta):
	update_buttons_visibility()


func init():
	init_child_nodes()
	type = Type.get(get_type_label())
	icon_texture.texture = FileLoader.get_stat_asset(get_type())
	if init_label:
		label.text = init_label
	else:
		label.text = name
	init_tooltip()
	update_tooltip()
	add(0)
	check_modifiable()


func init_child_nodes():
	icon_texture = $"Left/Icon"
	label = $"Left/Label"
	amount_label = $"Right/Amount"
	plus_btn = $"Right/PlusButton"
	minus_btn = $"Right/MinusButton"


func init_tooltip():
	var over_ui = Globals.over_ui
	if modifiable:
		tooltip = Tooltip.create(name, over_ui, self)
	elif static_tooltip_text:
		info.visible = true
		info.tooltip_text = static_tooltip_text


func get_type_label():
	var type_label = name.to_snake_case().to_upper()
	if name.begins_with("Résistance "):
		var name_split = name.split(" ")
		type_label = "RES_" + name_split[name_split.size() - 1].to_upper()
	if name.begins_with("Dommages "):
		var name_split = name.split(" ")
		type_label = "DO_" + name_split[name_split.size() - 1].to_upper()
	if name.begins_with("Retrait "):
		var name_split = name.split(" ")
		type_label = "RET_" + name_split[name_split.size() - 1].to_upper()
	return type_label


func check_modifiable():
	plus_btn.visible = modifiable and !GameManager.in_fight
	minus_btn.visible = modifiable and !GameManager.in_fight


func add(_amount: int):
	base_amount += _amount


func set_base_amount(_amount: int):
	base_amount = _amount


func get_type() -> String:
	return Type.find_key(type)


func _on_plus_button_button_up():
	var points = StatsManager.points
	var x
	if points > 0:
		if Input.is_action_pressed("CTRL"):
			x = 10
			if Input.is_action_pressed("SHIFT"):
				x = points
		else:
			x = 1
		if points < x:
			x = points
		add(x)
		consume_point.emit(x, type)


func _on_minus_button_button_up():
	var x
	if Input.is_action_pressed("CTRL"):
		x = -10
		if Input.is_action_pressed("SHIFT"):
			x = -base_amount
	else:
		x = -1
	base_amount += x
	consume_point.emit(x, type)


func update_buttons_visibility():
	if plus_btn: plus_btn.disabled = StatsManager.points == 0
	if minus_btn: minus_btn.disabled = base_amount == 0


func update_tooltip():
	if tooltip and modifiable:
		tooltip.update_text("Base : %d\nEquipement : %d" % [base_amount, equip_amount])
