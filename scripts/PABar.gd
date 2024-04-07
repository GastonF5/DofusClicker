class_name PABar
extends HBoxContainer


static var pa_bar_array: Array[ProgressBar] = []
var completing_pa_bar: ProgressBar

var speed = 50


func _ready():
	var count = 1
	for progress_bar in get_children():
		progress_bar.get_child(0).text = str(count)
		progress_bar.value = 0
		count += 1
		pa_bar_array.append(progress_bar)
	completing_pa_bar = pa_bar_array[0]


func _process(delta):
	var completing_bar_is_last = pa_bar_array.find(completing_pa_bar) + 1 == pa_bar_array.size()
	var completing_bar_is_complete = completing_pa_bar.value >= completing_pa_bar.max_value
	if !(completing_bar_is_last and completing_bar_is_complete):
		completing_pa_bar.value += delta * speed
		# si la barre est complète, on gagne 1 PA et on passe à la barre suivante
		if completing_pa_bar.value >= completing_pa_bar.max_value:
			PlayerManager.current_pa += 1
			completing_pa_bar.value = completing_pa_bar.max_value
			var next_index = pa_bar_array.find(completing_pa_bar) + 1
			if next_index != pa_bar_array.size():
				completing_pa_bar = pa_bar_array[next_index]


func update(current_pa: int):
	var current_value = 0
	if completing_pa_bar.value < completing_pa_bar.max_value:
		current_value = completing_pa_bar.value
	var bars_to_empty = pa_bar_array.slice(current_pa)
	for progress_bar in bars_to_empty:
		progress_bar.value = 0
	completing_pa_bar = bars_to_empty[0]
	completing_pa_bar.value = current_value
