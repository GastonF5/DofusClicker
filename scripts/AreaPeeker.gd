class_name AreaPeeker
extends PanelContainer


var monster_manager: MonsterManager
@export var back_button: Button

var selected_area_id := -1

signal subarea_selected


func _ready():
	$%Datas.init_done.connect(init_areas)


func init_areas():
	var cur_lvl = $%PlayerManager.xp_bar.cur_lvl
	var areas = Datas._areas.values()
	for area in areas:
		if area.get_level() > 0 and area.get_level() <= cur_lvl and area.has_monsters(cur_lvl):
			create_area_button(area)


func _on_area_clicked(button: Button):
	var cur_lvl = $%PlayerManager.xp_bar.cur_lvl
	clear_buttons()
	back_button.disabled = false
	var area: AreaResource = Datas._areas[button.name.to_float()]
	selected_area_id = area._id
	for subarea in area.get_subareas(cur_lvl):
		if subarea.has_monsters(cur_lvl):
			create_subarea_button(subarea)


func _on_subarea_clicked(button: Button):
	var subarea = Datas._subareas[button.name.to_float()]
	monster_manager.start_fight_button.disabled = true
	var monster_resources = subarea.get_monsters()
	for monster_res in monster_resources:
		if !monster_res.texture:
			monster_res.load_texture($%API, $%Console)
	monster_resources = monster_resources.filter(func(res): return !res.archimonstre)
	MonsterManager.monsters_res = monster_resources
	monster_manager.start_fight_button.disabled = false


func create_area_button(area: AreaResource):
	var button = Button.new()
	button.text = "%s (lvl %d)" % [area._name, area.get_level()]
	button.name = str(area._id)
	button.button_up.connect(_on_area_clicked.bind(button))
	button.focus_mode = Control.FOCUS_NONE
	$HBC/ScrollContainer/HBC.add_child(button)


func create_subarea_button(subarea: AreaResource):
	var button = Button.new()
	button.text = "%s (lvl %d)" % [subarea._name, subarea.get_level()]
	button.name = str(subarea._id)
	button.button_up.connect(_on_subarea_clicked.bind(button))
	button.focus_mode = Control.FOCUS_NONE
	$HBC/ScrollContainer/HBC.add_child(button)


func erase_button(area: AreaResource):
	var button = $HBC/ScrollContainer/HBC.get_node(str(area._id))
	$HBC/ScrollContainer/HBC.remove_child(button)
	button.queue_free()


func clear_buttons():
	for button in $HBC/ScrollContainer/HBC.get_children():
		$HBC/ScrollContainer/HBC.remove_child(button)
		button.queue_free()


func _enter_tree():
	monster_manager = get_tree().current_scene.get_node("%MonsterManager")


func _on_back_button_button_up():
	clear_buttons()
	selected_area_id = -1
	back_button.disabled = true
	init_areas()
