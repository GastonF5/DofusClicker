class_name ExperienceBar
extends ProgressBar


@export var lvl_label: Label

var cur_lvl: int

signal lvl_up


func init():
	cur_lvl = 10
	value = 0
	max_value = 10
	update_lvl_label()


func gain_xp(amount: int):
	value += amount
	if value >= max_value:
		value -= max_value
		cur_lvl += 1
		max_value += 10 * cur_lvl
		update_lvl_label()
		lvl_up.emit()


func update_lvl_label():
	lvl_label.text = "Nv. " + str(cur_lvl)
