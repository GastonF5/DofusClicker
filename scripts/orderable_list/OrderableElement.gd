class_name OrderableElement
extends Control

var parent_list: OrderableList
var empty_control: Control

var dragged := false
var mouse_on := false

var last_y: float

signal reordered

static func create(parent: OrderableList, content: Control) -> OrderableElement:
	var orderable = preload("res://scenes/orderable_list/orderable_element.tscn").instantiate()
	orderable.parent_list = parent
	parent.add_child(orderable)
	orderable.get_node("HBC/Content").add_child(content)
	orderable.update_drag_element_texture()
	return orderable


func get_content():
	if $HBC/Content.get_child_count() == 0:
		return null
	return $HBC/Content.get_child(0)


func _input(event):
	if (mouse_on and !dragged and event.is_action_pressed("LMB"))\
	or (dragged and event.is_action_released("LMB")):
		toggle_dragged()


func _process(_delta):
	if parent_list:
		if dragged:
			var min_y = parent_list.global_position.y
			var max_y = min_y + parent_list.size.y
			var mouse_y = get_global_mouse_position().y - size.y / 2
			set_y_position(clamp(mouse_y, min_y, max_y))
		else:
			check_position()


func check_position():
	if !dragged and parent_list.dragged_element:
		var local_mouse_y = get_local_mouse_position().y
		var middle = size.y / 2
		var mouse_in = local_mouse_y >= 0 and local_mouse_y <= size.y
		var mouse_up = mouse_in and local_mouse_y <= middle
		var up = get_index() < parent_list.dragged_element.get_index()
		if (up and !mouse_up) or (!up and mouse_up):
			parent_list.dragged_element.update_drag_element_texture(get_index())
			parent_list.move_child(parent_list.dragged_element.empty_control, get_index())
			update_drag_element_texture()


func _on_drag_button_button_down():
	toggle_dragged()


func toggle_dragged():
	dragged = !dragged
	if dragged:
		parent_list.dragged_element = self
		var my_index = get_index()
		reparent(parent_list.layer_up)
		create_empty(my_index)
	else:
		parent_list.dragged_element = null
		var empty_index = empty_control.get_index()
		parent_list.remove_child(empty_control)
		empty_control.queue_free()
		empty_control = null
		
		reparent(parent_list)
		parent_list.move_child(self, empty_index)
		position = Vector2.ZERO
		dragged = false
		reordered.emit()


func create_empty(index: int) -> void:
	empty_control = Control.new()
	empty_control.custom_minimum_size = size
	parent_list.add_child(empty_control)
	parent_list.move_child(empty_control, index)


func set_y_position(y: int) -> void:
	global_position = Vector2(global_position.x, y)


func _on_drag_element_mouse_entered():
	mouse_on = true


func _on_drag_element_mouse_exited():
	mouse_on = false


func update_drag_element_texture(index: int = get_index()):
	var content = get_content()
	if is_instance_of(content, Scripter):
		content.update_priority_texture(index)
