class_name PABar
extends TextureProgressBar


@export var current_pa_label: Label

var speed = 100
var max_pa = 6


func _ready():
	current_pa_label.text = "0"


func _process(delta):
	var current_pa = PlayerManager.current_pa
	if current_pa != max_pa or (current_pa == max_pa and value < max_value):
		value += delta * speed
		# si la barre est complète, on gagne 1 PA et on reset la barre
		if value >= max_value:
			PlayerManager.current_pa += 1
			current_pa_label.text = str(PlayerManager.current_pa)
			value = min_value if PlayerManager.current_pa < max_pa else max_value


func update(current_pa: int):
	current_pa_label.text = str(current_pa)
	var current_value = 0
	if value < max_value:
		current_value = value
	value = current_value
