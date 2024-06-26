class_name DraggableControl
extends Control

@onready var OverUI = $"/root/Main/OverUI"

var old_parent: Button
var drop_parent: Button
var draggable := false
var dragged := false:
	set(value):
		dragged = value
		if value:
			z_index = 10
			if is_item(): PlayerManager.dragged_item = self
			if is_spell(): PlayerManager.dragged_spell = self
		else:
			z_index = 0
			if is_item(): PlayerManager.dragged_item = null
			if is_spell(): PlayerManager.dragged_spell = null

var inventory: Inventory
var initialized := false


func _enter_tree():
	if old_parent is Button:
		old_parent.button_pressed = false
	if !initialized and draggable:
		init_draggable()
		initialized = true


func init_draggable():
	if get_parent() != null:
		get_parent().button_down.connect(_on_button_down)
	drop_parent = get_parent()


func _process(_delta):
	if dragged:
		global_position = get_global_mouse_position() - size / 2


func _input(event):
	if dragged:
		if event.is_action_released("LMB"):# and (!is_spell() or !GameManager.in_fight()):
			drop()


func _on_button_down():
	if draggable:
		if !is_spell() or !GameManager.in_fight():
			drag()


func drag():
	dragged = true
	old_parent = get_parent()
	#old_parent.set_pressed_no_signal(false)
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
	old_parent = null
	drop_parent.button_down.connect(_on_button_down)


func is_item():
	return self is Item


func is_spell():
	return self is Spell
