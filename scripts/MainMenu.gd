extends Control


@export var close_btn: CloseButton


func _ready():
	$ReloadDataBtn.visible = Globals.debug
	check_loaded_data()
	check_saves()
	close_btn.callable_on_close = _on_close_btn_button_up


func check_loaded_data():
	FileSaver.check_directory_path(FileSaver.DATA_PATH)
	var dir = DirAccess.open(FileSaver.DATA_PATH)
	var is_data_loaded = true
	for data_type in Datas.DataType.keys():
		#data_type = data_type.split("_")[0].to_lower()
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
		if save_res:
			create_save_button(save_res)


func load_save(save_res: SaveResource):
	Globals.selected_class = save_res.class_id
	await Globals.loading_transition.fade_up()
	if await GameManager.init_game(save_res):
		resume_game()
		await Globals.loading_transition.fade_out()
	else:
		push_error("Une erreur est survenue lors du chargement de la sauvegarde")


func resume_game():
	visible = false


func create_save_button(save_res: SaveResource):
	var save_btn = SaveButton.create(save_res)
	save_btn.save_callable = load_save.bind(save_res)
	save_btn.deleted.connect(check_save_buttons)
	$Saves/SavesPanel/VBC.add_child(save_btn)


func check_save_buttons():
	if $Saves/SavesPanel/VBC.get_child_count() == 1:
		_on_close_btn_button_up()
		$VBC/HBC/LoadBtn.disabled = true


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
	$PopupBackground.visible = false
	$Saves.visible = false


func _on_load_btn_button_up():
	$PopupBackground.visible = true
	$Saves.visible = true


func _on_save_button_button_up():
	SaveManager.save()


func _on_quit_button_button_up():
	GameManager.reload_game()


func _on_change_class_button_button_up():
	GameManager.change_class()
