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
	DOMMAGES_CRITIQUES,
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
}

@export var modifiable = true

@onready var icon_texture: TextureRect = $"Left/Icon"
@onready var label: Label = $"Left/Label"
@onready var amount_label: Label = $"Right/Amount"

@onready var plus_btn: Button = $"Right/PlusButton"
@onready var minus_btn: Button = $"Right/MinusButton"

var tooltip: Tooltip

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


func _ready():
	type = Type.get(get_type_label())
	icon_texture.texture = FileLoader.get_stat_asset(self)
	label.text = name
	if modifiable: tooltip = Tooltip.create(name, $"TooltipContainer", self)
	update_tooltip()
	add(0)
	check_modifiable()


func get_type_label():
	var type_label = name.to_snake_case().to_upper()
	if name.begins_with("Résistance"):
		var name_split = name.split(" ")
		type_label = "RES_" + name_split[name_split.size() - 1].to_upper()
	return type_label


func check_modifiable():
	plus_btn.visible = modifiable
	minus_btn.visible = modifiable


func add(_amount: int):
	base_amount += _amount


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
	if tooltip:
		tooltip.update_text("Base : %d\nEquipement : %d" % [base_amount, equip_amount])


static func create(_type: Type, _label: Label):
	var carac = Caracteristique.new()
	carac.type = _type
	carac.amount_label = _label
	return carac
