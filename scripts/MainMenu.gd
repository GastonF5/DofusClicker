extends Control

@onready var file_saver: FileSaver = $FileSaver
@onready var datas: Datas = $Datas


func _ready():
	check_loaded_data()
	check_saves()


func check_loaded_data():
	file_saver.check_directory_path(file_saver.DATA_PATH)
	var dir = DirAccess.open(file_saver.DATA_PATH)
	var is_data_loaded = true
	for data_type in Datas.DataType.keys():
		data_type = data_type.split("_")[0].to_lower()
		is_data_loaded = is_data_loaded and\
			(dir.file_exists("%s.tres" % data_type) or dir.file_exists("%s.tres.remap" % data_type))
	if !is_data_loaded:
		datas.load_data()


func check_saves():
	var saves_path = "user://saves/"
	file_saver.check_directory_path(saves_path)
	var dir = DirAccess.open(saves_path)
	var saves = dir.get_files()
	$VBC/HBC/LoadBtn.disabled = saves.is_empty()
	for file in saves:
		create_save_button(file)


func load_save(save: String):
	print(save)


func create_save_button(file_name: String):
	var button = Button.new()
	file_name = file_name.trim_suffix(".tres")
	button.name = file_name
	button.text = format_date(file_name)
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 64)
	button.button_up.connect(load_save.bind(button.name))
	$Saves/SavesPanel/VBC.add_child(button)


func format_date(file_name: String):
	var tiret_split = file_name.split("-")
	var annee = tiret_split[0]
	var mois = tiret_split[1]
	var jour = tiret_split[2]
	var heure = tiret_split[3].split(".")[0]
	var minutes = tiret_split[3].split(".")[1]
	return "%s-%s-%s : %sh%s" % [annee, mois, jour, heure, minutes]


func _on_quit_btn_button_up():
	get_tree().quit()


func _on_play_btn_button_up():
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_load_data_btn_button_up():
	var dir = DirAccess.open(file_saver.DATA_PATH)
	for file in dir.get_files():
		dir.remove(file)
	datas.load_data()


func _on_close_btn_button_up():
	$Saves.visible = false


func _on_load_btn_button_up():
	$Saves.visible = true
