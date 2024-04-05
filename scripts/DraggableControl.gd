class_name DraggableControl
extends ClickableControl

var parent
var draggable = false
var dragged = false:
	set(value):
		dragged = value
		if value:
			z_index = 10
			GameManager.dragged_item = self
		else:
			z_index = 0
			GameManager.dragged_item = null

signal dropped


func init_draggable():
	if !get_parent().is_class("Window"):
		get_parent().button_down.connect(_on_button_down)
	draggable = true
	parent = get_parent()


func _process(_delta):
	if dragged:
		global_position = get_global_mouse_position() - size / 2


func _input(event):
	if dragged and event.is_action_released("LMB"):
		drop()


func _on_button_down():
	if draggable:
		dragged = true


func drop():
	dragged = false
	position = Vector2.ZERO
	dropped.emit()
	change_parent()


func change_parent():
	get_parent().button_down.disconnect(_on_button_down)
	get_parent().remove_child(self)
	parent.add_child(self)
	parent.button_down.connect(_on_button_down)
