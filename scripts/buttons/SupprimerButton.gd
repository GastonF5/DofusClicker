class_name SupprimerButton extends Button


var _node_to_delete: Node
var _mouse_on: bool


func _input(event):
	if event.is_action_released("RMB") or (!_mouse_on and event.is_action_pressed("LMB")):
		queue_free()


static func create(parent: Node, pos: Vector2, node_to_delete: Node):
	var button = preload("res://scenes/buttons/supprimer_button.tscn").instantiate()
	parent.add_child(button)
	button.global_position = pos
	button._node_to_delete = node_to_delete
	button.size = node_to_delete.size
	node_to_delete.tree_exited.connect(button.queue_free)


func _on_button_up():
	if _node_to_delete:
		_node_to_delete.get_parent().remove_child(_node_to_delete)
		_node_to_delete.queue_free()
	queue_free()


func _on_mouse_entered():
	_mouse_on = true


func _on_mouse_exited():
	_mouse_on = false
