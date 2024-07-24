extends Control


func _on_quit_btn_button_up():
	get_tree().quit()


func _on_play_btn_button_up():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
