class_name AmountResource
extends Resource


@export var _min: int
@export var _max: int
@export var _min_crit: int
@export var _max_crit: int


func get_random(crit: bool = false):
	randomize()
	if crit:
		return randi_range(_min_crit, _max_crit)
	else:
		return randi_range(_min, _max)
