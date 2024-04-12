class_name PMBar
extends TextureProgressBar


@export var current_pm_label: Label

var speed = 100
var max_pm: int


func _ready():
	current_pm_label.text = "0"


func _process(delta):
	var current_pm = PlayerManager.current_pm
	if current_pm != max_pm or (current_pm == max_pm and value < max_value):
		value += delta * speed
		# si la barre est complète, on gagne 1 PA et on reset la barre
		if value >= max_value:
			PlayerManager.current_pm += 1
			current_pm_label.text = str(PlayerManager.current_pm)
			value = min_value if PlayerManager.current_pm < max_pm else max_value


func update(current_pm: int):
	current_pm_label.text = str(current_pm)
	var current_value = 0
	if value < max_value:
		current_value = value
	value = current_value
