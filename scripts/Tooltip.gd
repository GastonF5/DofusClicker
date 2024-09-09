extends PanelContainer
class_name Tooltip


@export var label: Label

var carac_parent: Node


func init(parent_control: Control):
	if parent_control:
		name = parent_control.name + "Tooltip"
	else:
		name = "Tooltip"
	visible = false
	z_index = 1
	if parent_control:
		init_connections(parent_control)
	carac_parent = parent_control


func init_connections(control: Control):
	control.mouse_entered.connect(_on_mouse_entered_control)
	control.mouse_exited.connect(_on_mouse_exited_control)


func update_text(text: String):
	label.text = text


func _on_mouse_entered_control():
	if carac_parent is Caracteristique:
		position = carac_parent.get_node("TooltipPosition").global_position
	if carac_parent is ExperienceBar:
		position = carac_parent.global_position + Vector2((carac_parent.size.x - size.x) / 2, -60)
	visible = true


func _on_mouse_exited_control():
	visible = false


static func create(text: String, parent: Node, control_to_connect: Control) -> Tooltip:
	var tooltip = FileLoader.get_packed_scene("tooltip").instantiate()
	tooltip.init(control_to_connect)
	tooltip.update_text(text)
	parent.add_child(tooltip)
	return tooltip
