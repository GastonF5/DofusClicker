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


static func create(minimum: int, maximum: int, minimum_crit: int, maximum_crit: int) -> AmountResource:
	var resource = AmountResource.new()
	resource._min = minimum
	resource._max = maximum
	resource._min_crit = minimum_crit
	resource._max_crit = maximum_crit
	return resource


func add(amount: int):
	_min += amount
	_max += amount
	_min_crit += amount
	_max_crit += amount
