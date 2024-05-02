class_name PMBar
extends TextureProgressBar


@export var player = true
@export var current_pm_label: Label

var speed = 20.0
var max_pm: int

var current_pm: int:
	set(val):
		if current_pm != val:
			current_pm = val
			update()


func init(mpm: int):
	min_value = 0
	max_value = 100
	value = max_value
	max_pm = mpm
	current_pm = mpm
	update(max_pm, true)
	step = 0.01


func get_amount():
	return current_pm_label.text as int


func _process(delta):
	if current_pm < max_pm or (current_pm == max_pm and value < max_value):
		value += delta * speed
		# si la barre est complète, on gagne 1 PA et on reset la barre
		if value >= max_value:
			current_pm += 1
			value = min_value if current_pm < max_pm else max_value


func update(new_pm = current_pm, _max = false):
	if new_pm is Callable: new_pm = new_pm.call()
	current_pm_label.text = str(new_pm)
	if _max:
		value = max_value
		return
	var current_value = 0
	if value < max_value:
		current_value = value
	value = current_value



func change_max_pm(new_mpm, also_current_pm = false):
	if new_mpm is Callable: new_mpm = new_mpm.call()
	if new_mpm == max_pm: return
	if new_mpm < max_pm:
		max_pm = new_mpm
		current_pm = new_mpm
	if also_current_pm:
		current_pm = new_mpm
	max_pm = new_mpm
	update(current_pm, true)
