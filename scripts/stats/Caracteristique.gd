class_name Caracteristique
extends Control


enum Type {
	VITALITE,
	AGILITE,
	CHANCE,
	FORCE,
	INTELLIGENCE,
	SAGESSE
}

@export var icon_texture: TextureRect
@export var label: Label
@export var amount_label: Label

@export var plus_btn: Button
@export var minus_btn: Button

var type: Type
var base_amount = 0:
	set(value):
		base_amount = value
		amount = base_amount

var amount = 0:
	set(value):
		amount = value
		amount_label.text = str(amount)

signal consume_point


func _ready():
	type = Type.get(name.to_upper())
	icon_texture.texture = FileLoader.get_stat_asset(self)
	label.text = get_type().to_pascal_case()


func _process(_delta):
	plus_btn.disabled = StatsManager.points == 0
	minus_btn.disabled = base_amount == 0


func get_type() -> String:
	return Type.find_key(type)


func _on_plus_button_button_up():
	var points = StatsManager.points
	var x
	if points > 0:
		if Input.is_action_pressed("CTRL"):
			x = 10
		else:
			x = 1
		if points >= x:
			base_amount += x
			StatsManager.points -= x
			consume_point.emit()


func _on_minus_button_button_up():
	var points = StatsManager.points
	var x
	if Input.is_action_pressed("CTRL"):
		x = -10
	else:
		x = -1
	base_amount += x
	if base_amount < 0:
		base_amount -= x
	else:
		StatsManager.points -= x
		consume_point.emit()
