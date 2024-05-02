class_name PABar
extends TextureProgressBar


@export var player = true
@export var current_pa_label: Label

var speed = 100.0
var max_pa: int

var current_pa: int:
	set(value):
		if current_pa != value:
			current_pa = value
			update()


func init(mpa: int):
	min_value = 0
	max_value = 100
	max_pa = mpa
	current_pa = 0
	update(mpa, true)
	step = 0.01


func _process(delta):
	if true:
		# partie joueur
		if current_pa != max_pa or (current_pa == max_pa and value < max_value):
			value += float(delta * speed)
			# si la barre est complète, on gagne 1 PA et on reset la barre
			if value >= max_value:
				current_pa += 1
				current_pa_label.text = str(current_pa)
				value = min_value if current_pa < max_pa else max_value


func update(new_pa = current_pa, _max = false):
	if new_pa is Callable: new_pa = new_pa.call()
	current_pa_label.text = str(new_pa)
	if _max:
		value = max_value
		return
	var current_value = 0
	if value < max_value:
		current_value = value
	value = current_value
