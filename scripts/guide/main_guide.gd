class_name GuideMenu extends Control

const GUIDE_PATH := "res://scenes/guide/"


func _ready():
	for button: Button in $VBC.get_children():
		button.button_up.connect(open_guide.bind(button.name))


func open_guide(guide_name: StringName):
	guide_name = guide_name.to_snake_case()
	var guide_scene = load(GUIDE_PATH + guide_name + ".tscn").instantiate()
	guide_scene.get_node("BackButton").button_up.connect(guide_scene.queue_free)
	get_parent().add_child(guide_scene)


func _on_back_button_button_up():
	visible = false
