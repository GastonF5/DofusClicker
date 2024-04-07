class_name DraggableControl
extends Control

@onready var OverUI = $"/root/Main/OverUI"

var old_parent: Button
var drop_parent: Button
var draggable = false
var dragged = false:
	set(value):
		dragged = value
		if value:
			z_index = 10
			PlayerManager.dragged_item = self
		else:
			z_index = 0
			PlayerManager.dragged_item = null

var inventory: Inventory


func init_draggable():
	get_parent().button_down.connect(_on_button_down)
	draggable = true
	drop_parent = get_parent()


func _process(_delta):
	if dragged:
		global_position = get_global_mouse_position() - size / 2


func _input(event):
	if dragged and event.is_action_released("LMB"):
		drop()


func _on_button_down():
	if draggable:
		drag()


func drag():
	dragged = true
	old_parent = get_parent()
	if get_parent() != null:
		get_parent().remove_child(self)
		OverUI.add_child(self)


func drop():
	dragged = false
	change_parent()
	position = Vector2.ZERO


func change_parent():
	if old_parent.button_down.is_connected(_on_button_down):
		old_parent.button_down.disconnect(_on_button_down)
	get_parent().remove_child(self)
	inventory.add_item(self, drop_parent)
	old_parent = null
	drop_parent.button_down.connect(_on_button_down)
