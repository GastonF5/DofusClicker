class_name ClickableControl
extends Control


var mouse_on = false
var clickable_control: Control
var is_clickable = true

signal clicked


func init_clickable(control: Control):
	clickable_control = control
	clickable_control.mouse_entered.connect(_on_mouse_entered_control)
	clickable_control.mouse_exited.connect(_on_mouse_exited_control)


func _input(event):
	if is_clickable and mouse_on and event.is_action_pressed("LMB"):
		clicked.emit(self)


func _on_mouse_entered_control():
	mouse_on = true


func _on_mouse_exited_control():
	mouse_on = false
