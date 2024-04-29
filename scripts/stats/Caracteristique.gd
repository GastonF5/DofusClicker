class_name Caracteristique
extends Control


enum Type {
	VITALITE,
	AGILITE,
	CHANCE,
	FORCE,
	INTELLIGENCE,
	SAGESSE,
	PUISSANCE
}

@export var icon_texture: TextureRect
@export var label: Label
@export var amount_label: Label

@export var plus_btn: Button
@export var minus_btn: Button

@export var tooltip: Tooltip

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


func _ready():
	type = Type.get(name.to_upper())
	icon_texture.texture = FileLoader.get_stat_asset(self)
	label.text = get_type().to_pascal_case()
	tooltip = Tooltip.create(name, $"/root/Main/OverUI/Main", self, get_parent().global_position)
	update_tooltip()


func _process(_delta):
	plus_btn.disabled = StatsManager.points == 0
	minus_btn.disabled = base_amount == 0


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
		if points >= x:
			add(x)
			StatsManager.points -= x
			consume_point.emit()


func _on_minus_button_button_up():
	var points = StatsManager.points
	var x
	if Input.is_action_pressed("CTRL"):
		x = -10
		if Input.is_action_pressed("SHIFT"):
			x = -amount
	else:
		x = -1
	base_amount += x
	if base_amount < 0:
		add(x)
	else:
		StatsManager.points -= x
		consume_point.emit()


func update_tooltip():
	if tooltip:
		tooltip.update_text("Base : %d\nEquipement : %d" % [base_amount, equip_amount])
