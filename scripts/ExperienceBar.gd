class_name ExperienceBar
extends ProgressBar


@export var lvl_label: Label
@export var label: Label

var cur_lvl: int


func init():
	cur_lvl = 1
	value = 0
	max_value = 10
	update_label()
	update_lvl_label()


func gain_xp(amount: int):
	value += amount
	if value >= max_value:
		value -= max_value
		cur_lvl += 1
		max_value += 10 * cur_lvl
		update_lvl_label()
	update_label()


func update_lvl_label():
	lvl_label.text = "Nv. " + str(cur_lvl)


func update_label():
	label.text = "%d/%d" % [value, max_value]
