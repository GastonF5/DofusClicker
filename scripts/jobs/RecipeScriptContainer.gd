class_name RecipeScriptContainer
extends PanelContainer


@export var search_prompt: LineEdit
@export var filter_button: Button
@export var scripting_button: Button

@export var tab_container: CustomTabContainer
@export var filter_container: ScrollContainer
@export var scripting_panel: Panel

@export var recipe_filters: RecipeFilters


func _on_filter_button_toggled(toggled_on):
	filter_container.visible = toggled_on
	tab_container.visible = !toggled_on
	scripting_panel.visible = false
	scripting_button.set_pressed_no_signal(false)


func _on_scripting_button_toggled(toggled_on):
	scripting_panel.visible = toggled_on
	tab_container.visible = !toggled_on
	filter_container.visible = false
	filter_button.set_pressed_no_signal(false)
