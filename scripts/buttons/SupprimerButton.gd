class_name SupprimerButton extends Button


var _mouse_on: bool
var _callable: Callable


func _input(event):
	if event.is_action_released("RMB") or (!_mouse_on and event.is_action_pressed("LMB")):
		queue_free()


static func create(parent: Node, pos: Vector2, node_to_delete: Node, callable: Callable):
	var button = preload("res://scenes/buttons/supprimer_button.tscn").instantiate()
	parent.add_child(button)
	button.global_position = pos
	button.size = node_to_delete.size
	button._callable = callable


func _on_button_up():
	_callable.call()
	queue_free()


func _on_mouse_entered():
	_mouse_on = true


func _on_mouse_exited():
	_mouse_on = false
