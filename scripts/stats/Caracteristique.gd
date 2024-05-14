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
	RES_CRITIQUES
}

enum Element {
	NEUTRE,
	AIR,
	EAU,
	TERRE,
	FEU,
}

@export var modifiable = true

var icon_texture: TextureRect
var label: Label
var amount_label: Label

var plus_btn: Button
var minus_btn: Button

@export var init_label: String

var tooltip: Tooltip
@export var static_tooltip_text: String

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
		amount = value
		amount_label.text = str(amount)
		update_tooltip()

signal consume_point


func _process(_delta):
	update_buttons_visibility()


func init():
	init_child_nodes()
	type = Type.get(get_type_label())
	icon_texture.texture = FileLoader.get_stat_asset(self)
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
	if modifiable:
		tooltip = Tooltip.create(name, $"TooltipContainer", self)
	elif static_tooltip_text:
		tooltip = Tooltip.create(static_tooltip_text, $"TooltipContainer", self)


func get_type_label():
	var type_label = name.to_snake_case().to_upper()
	if name.begins_with("Résistance "):
		var name_split = name.split(" ")
		type_label = "RES_" + name_split[name_split.size() - 1].to_upper()
	if name.begins_with("Dommages "):
		var name_split = name.split(" ")
		type_label = "DO_" + name_split[name_split.size() - 1].to_upper()
	return type_label


func check_modifiable():
	plus_btn.visible = modifiable
	minus_btn.visible = modifiable


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
			x = -amount
	else:
		x = -1
	base_amount += x
	if base_amount < 0:
		x -= base_amount
		base_amount = 0
	consume_point.emit(x, type)


func update_buttons_visibility():
	plus_btn.disabled = StatsManager.points == 0
	minus_btn.disabled = base_amount == 0


func update_tooltip():
	if tooltip and modifiable:
		tooltip.update_text("Base : %d\nEquipement : %d" % [base_amount, equip_amount])
