class_name AmountResource
extends Resource


@export var min: int
@export var max: int
@export var min_crit: int
@export var max_crit: int


func get_random(crit: bool = false):
	randomize()
	if crit:
		return randi_range(min_crit, max_crit)
	else:
		return randi_range(min, max)
