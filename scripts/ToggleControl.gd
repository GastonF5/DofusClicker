class_name ToggleControl extends Control

const arrow_down = preload("res://assets/icons/green_arrow_down.png")
const arrow_right = preload("res://assets/icons/green_arrow_right.png")

@export var button: Button
@export var content: Control

@export var stats_container: VBoxContainer


func _ready():
	if button:
		button.toggled.connect(toggle_content)
	else:
		push_error("Button not set for %s" % name)
	if !content:
		push_error("Content not set for %s" % name)
	toggle_content(false)


func toggle_content(toggled: bool):
	var tween = create_tween()
	var child = content.get_child(0)
	if toggled:
		button.icon = arrow_down
		content.visible = true
		tween.tween_property(content, "custom_minimum_size", child.size, 0.4).set_trans(Tween.TRANS_CIRC)
	else:
		button.icon = arrow_right
		tween.tween_property(content, "custom_minimum_size", Vector2(child.size.x, 0), 0.4).set_trans(Tween.TRANS_CIRC)
		await tween.finished
		content.visible = true
