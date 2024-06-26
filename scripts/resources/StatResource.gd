class_name StatResource
extends Resource


@export var type: Caracteristique.Type
@export var min_amount: int
@export var max_amount: int

var amount: int:
	set(value):
		amount = value
		amount_change.emit(amount)

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
		return "%d %s" % [amount, get_type_label(get_type())]
	elif min_amount >= max_amount:
		return "%d %s" % [min_amount, get_type_label(get_type())]
	else:
		return "%d à %d %s" % [min_amount, max_amount, get_type_label(get_type())]


func get_label_color() -> Color:
	const green = Color.LIME_GREEN
	const red = Color.BROWN
	if amount:
		return green if amount >= 0 else red
	else:
		return green if min_amount >= 0 else red


func get_type() -> String:
	return Caracteristique.Type.find_key(type)


static func get_type_label(type_label: String) -> String:
	if !["PA", "PM"].has(type_label):
		if type_label == "RES_POU":
			return "Résistance Poussée"
		if type_label == "PUI_PIEGES":
			return "Puissance Pièges"
		if type_label == "MAITRISE_ARME":
			return "Maîtrise Armes"
		if type_label.begins_with("RES_"):
			return "Résistance %s" % type_label.split("_")[1].to_pascal_case()
		if type_label.begins_with("DO_"):
			return "Dommages %s" % type_label.split("_")[1].to_pascal_case()
		if type_label.begins_with("RET_"):
			return "Retrait %s" % type_label.split("_")[1].to_upper()
		type_label = type_label.to_pascal_case()
	return type_label


static func create(_type: Caracteristique.Type, _min_amount: int, _max_amount: int = 0) -> StatResource:
	var res = StatResource.new()
	res.type = _type
	res.min_amount = _min_amount
	res.max_amount = _max_amount
	return res
