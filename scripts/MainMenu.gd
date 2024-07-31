extends Control


func _ready():
	check_loaded_data()
	check_saves()


func check_loaded_data():
	FileSaver.check_directory_path(FileSaver.DATA_PATH)
	var dir = DirAccess.open(FileSaver.DATA_PATH)
	var is_data_loaded = true
	for data_type in Datas.DataType.keys():
		data_type = data_type.split("_")[0].to_lower()
		is_data_loaded = is_data_loaded and\
			(dir.file_exists("%s.tres" % data_type) or dir.file_exists("%s.tres.remap" % data_type))
	if !is_data_loaded:
		Datas.load_data()


func check_saves():
	var saves_path = "user://saves/"
	FileSaver.check_directory_path(saves_path)
	var dir = DirAccess.open(saves_path)
	var saves = dir.get_files()
	$VBC/HBC/LoadBtn.disabled = saves.is_empty()
	for file in saves:
		var save_res = SaveResource.to_save_res(FileLoader.load_save(file).data)
		create_save_button(save_res)


func load_save(save_res: SaveResource):
	Globals.selected_class = save_res.class_id
	GameManager._on_class_selected(save_res.class_id)
	if SaveManager.load_save(save_res):
		resume_game()
	else:
		push_error("Une erreur est survenue lors du chargement de la sauvegarde")


func resume_game():
	visible = false


func create_save_button(save_res: SaveResource):
	var button = Button.new()
	button.name = save_res.date.replace("T", "-").replace(":", "_")
	button.text = format_date(save_res.date)
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 64)
	button.button_up.connect(load_save.bind(save_res))
	button.add_child(CloseButton.create(delete_save.bind(button)))
	$Saves/SavesPanel/VBC.add_child(button)


func delete_save(save_btn: Button):
	var dir = DirAccess.open(FileSaver.SAVE_PATH)
	var file_name = save_btn.name + ".tres"
	print(file_name	)
	if dir.file_exists(file_name):
		dir.remove(file_name)
		save_btn.get_parent().remove_child(save_btn)
		save_btn.queue_free()
	else:
		push_error("Save file not found")


func format_date(date: String):
	var date_split = date.split("T")
	return "%s : %s" % [date_split[0], date_split[1]]


func _on_quit_btn_button_up():
	get_tree().quit()


func _on_play_btn_button_up():
	resume_game()


func _on_load_data_btn_button_up():
	var dir = DirAccess.open(FileSaver.DATA_PATH)
	for file in dir.get_files():
		dir.remove(file)
	Datas.load_data()


func _on_close_btn_button_up():
	$Saves.visible = false


func _on_load_btn_button_up():
	$Saves.visible = true
