class_name StatResource
extends Resource


@export var type: Caracteristique.Type
@export var min_amount: int
@export var max_amount: int

var amount: int


func get_random_amount():
	return randi_range(min_amount, max_amount)


func init_amount():
	amount = get_random_amount()
