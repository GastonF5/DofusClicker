class_name ToggleControl extends Control


@export var button: Button
@export var content: Control


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
		content.visible = true
		tween.tween_property(content, "custom_minimum_size", child.size, 0.4).set_trans(Tween.TRANS_CIRC)
	else:
		tween.tween_property(content, "custom_minimum_size", Vector2(child.size.x, 0), 0.4).set_trans(Tween.TRANS_CIRC)
		await tween.finished
		content.visible = true
