class_name HPBar
extends TextureProgressBar


@export var curr_hp_label: Label
@export var max_hp_label: Label

var current_hp: int:
	set(value):
		current_hp = value
		update()


func init(max_hp: int):
	min_value = 0
	max_value = max_hp
	update_max_hp_label()
	current_hp = max_hp
	value = max_value
	update_current_hp_label()


func update(hp = current_hp, max_hp = max_value):
	value = hp
	update_current_hp_label()
	max_value = max_hp
	update_max_hp_label()


func update_max_hp_label():
	max_hp_label.text = str(max_value)


func update_current_hp_label():
	curr_hp_label.text = str(value)
