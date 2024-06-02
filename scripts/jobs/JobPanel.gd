class_name JobPanel
extends Panel

@export_category("Containers")
@export var recipe_container: VBoxContainer
@export var filter_container: ScrollContainer

@export_category("Inputs")
@export var search_prompt: LineEdit
@export var filter_button: Button


func _on_filter_button_toggled(toggled_on):
	recipe_container.get_parent().visible = !toggled_on
	filter_container.visible = toggled_on


func fitlers_toggled() -> bool:
	return filter_button.button_pressed


func toggle_filters(toggled: bool):
	filter_button.button_pressed = toggled
