class_name PABar
extends TextureProgressBar


@onready var player_manager: PlayerManager = $"%PlayerManager"

@export var current_pa_label: Label

var speed = 100
var max_pa: int


func _ready():
	max_pa = player_manager.max_pa
	current_pa_label.text = "0"


func _process(delta):
	var current_pa = player_manager.current_pa
	if current_pa != max_pa or (current_pa == max_pa and value < max_value):
		value += delta * speed
		# si la barre est complète, on gagne 1 PA et on reset la barre
		if value >= max_value:
			player_manager.current_pa += 1
			current_pa_label.text = str(player_manager.current_pa)
			value = min_value if player_manager.current_pa < max_pa else max_value


func update(current_pa: int):
	current_pa_label.text = str(current_pa)
	var current_value = 0
	if value < max_value:
		current_value = value
	value = current_value
