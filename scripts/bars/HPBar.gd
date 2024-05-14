class_name HPBar
extends TextureProgressBar


@export var curr_hp_label: Label
@export var max_hp_label: Label

var current_hp: int:
	set(value):
		if current_hp != value:
			current_hp = value
			update()


func init(max_hp: int, _first_init := true):
	min_value = 0
	max_value = max_hp
	update_max_hp_label()
	current_hp = max_hp
	value = max_value
	update_current_hp_label()
	step = 0.01


func update(hp = current_hp, max_hp = max_value):
	if hp is Callable: hp = hp.call()
	if max_hp is Callable: max_hp = max_hp.call()
	max_value = max_hp
	update_max_hp_label()
	value = hp
	current_hp = hp
	update_current_hp_label()


func update_max_hp_label():
	max_hp_label.text = str(max_value)


func update_current_hp_label():
	curr_hp_label.text = str(value)
