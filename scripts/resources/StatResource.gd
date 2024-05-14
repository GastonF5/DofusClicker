class_name StatResource
extends Resource


@export var type: Caracteristique.Type
@export var min_amount: int
@export var max_amount: int

var amount: int:
	set(value):
		amount = value
		amount_change.emit()

signal amount_change

func get_random_amount():
	return randi_range(min_amount, max_amount)


func init_amount():
	if min_amount > max_amount:
		amount = min_amount
	else:
		amount = get_random_amount()


func get_effect_label() -> String:
	if amount:
		return "%d %s" % [amount, get_type_label()]
	elif min_amount >= max_amount:
		return "%d %s" % [min_amount, get_type_label()]
	else:
		return "%d à %d %s" % [min_amount, max_amount, get_type_label()]


func get_label_color() -> Color:
	const green = Color.LIME_GREEN
	const red = Color.BROWN
	if amount:
		return green if amount >= 0 else red
	else:
		return green if min_amount >= 0 else red


func get_type() -> String:
	return Caracteristique.Type.find_key(type)


func get_type_label() -> String:
	var type_label = get_type()
	if !["PA", "PM"].has(type_label):
		type_label = type_label.to_pascal_case()
	return type_label


static func create(_type: Caracteristique.Type, _min_amount: int, _max_amount: int = 0) -> StatResource:
	var res = StatResource.new()
	res.type = _type
	res.min_amount = _min_amount
	res.max_amount = _max_amount
	return res
