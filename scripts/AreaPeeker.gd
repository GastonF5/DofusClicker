class_name AreaPeeker
extends PanelContainer


var monster_manager: MonsterManager
@export var back_button: Button
@export var area_label: Label

var selected_area_id := -1
var selected_subarea_id := -1
var cur_lvl := 1

var area_btns := {}
var subarea_btns := {}

var console: Console


func initialize():
	console = $%Console
	$%PlayerManager.xp_bar.lvl_up.connect(_on_level_up)
	cur_lvl = $%PlayerManager.xp_bar.cur_lvl
	init_areas()


func init_areas():
	var areas = Datas._areas.values()
	areas = areas.filter(func(a): return !a.black_listed(cur_lvl) and a.get_level() > 0 and a.get_level() <= cur_lvl and a.has_monsters(cur_lvl))
	areas.sort_custom(AreaResource.sort_by_level)
	for area in areas:
		create_area_button(area)
		#prints(area._name, area._id)


func init_subareas(area: AreaResource):
	selected_area_id = area._id
	for subarea in area.get_subareas(cur_lvl):
		if !subarea.black_listed() and subarea.has_monsters(cur_lvl):
			create_area_button(subarea, true)
			prints(subarea._name, subarea._id)


func _on_area_clicked(area_id: int):
	clear_buttons()
	back_button.disabled = false
	init_subareas(Datas._areas[area_id])


func _on_subarea_clicked(subarea_id: int):
	var subarea = Datas._subareas[subarea_id]
	selected_subarea_id = subarea_id
	if DungeonManager.is_dungeon(subarea_id):
		$%DungeonManager.enter_dungeon(subarea_id)
	else:
		enter_subarea(subarea)


func create_area_button(area: AreaResource, is_subarea := false):
	var button: AreaButton
	var callable = _on_subarea_clicked if is_subarea else _on_area_clicked
	if (!is_subarea and area_btns.has(area._id)) or (is_subarea and subarea_btns.has(area._id)):
		button = subarea_btns[area._id] if is_subarea else area_btns[area._id]
	else:
		var is_dungeon = DungeonManager.is_dungeon(area._id)
		var btn_icon = load("res://assets/icons/dungeon.png")\
			if is_dungeon\
			else load("res://assets/icons/quest.png")
		button = AreaButton.create(area, callable, btn_icon, is_dungeon)
		if is_subarea:
			subarea_btns[area._id] = button
		else:
			area_btns[area._id] = button
	$HBC/ScrollContainer/HBC.add_child(button)


func erase_button(area: AreaResource):
	var button = $HBC/ScrollContainer/HBC.get_node(str(area._id))
	$HBC/ScrollContainer/HBC.remove_child(button)


func clear_buttons():
	for button in $HBC/ScrollContainer/HBC.get_children().filter(func(b): return b is AreaButton):
		$HBC/ScrollContainer/HBC.remove_child(button)


func _enter_tree():
	monster_manager = get_tree().current_scene.get_node("%MonsterManager")


func _on_back_button_button_up():
	if selected_subarea_id != -1:
		leave_subarea()
	else:
		clear_buttons()
		back_button.disabled = true
		init_areas()


func _on_level_up():
	cur_lvl = $%PlayerManager.xp_bar.cur_lvl


func set_area_label(label: String, _visible: bool):
	area_label.text = label
	area_label.visible = _visible


func enter_subarea(subarea: AreaResource):
	clear_buttons()
	back_button.icon = load("res://assets/back_btn/btn_arrow_turn_character_normal.png")
	set_area_label(subarea._name, true)
	log_enter_subarea(subarea._name)
	load_monsters(subarea)


func leave_subarea():
	back_button.icon = load("res://assets/icons/zaap.png")
	log_leave_subarea()
	selected_subarea_id = -1
	set_area_label("", false)
	init_subareas(Datas._areas[selected_area_id])
	monster_manager.start_fight_button.disabled = true


func log_enter_subarea(subarea_name: String):
	console.log_info("Vous entrez dans la zone %s" % subarea_name)


func log_leave_subarea():
	if selected_subarea_id != -1:
		var subarea = Datas._subareas[selected_subarea_id]
		console.log_info("Vous sortez de la zone %s" % subarea._name)


func load_monsters(subarea: AreaResource):
	var monster_resources = subarea.get_monsters()
	var composite_signal
	var not_loaded_monsters = monster_resources.filter(func(r): return !r.texture)
	if !not_loaded_monsters.is_empty():
		composite_signal = API.CompositeSignal.new()
		for monster_res in not_loaded_monsters:
			if !monster_res.texture:
				composite_signal.add_method(monster_res.load_texture.bindv([$%API, $%Console]))
	monster_resources = monster_resources.filter(func(res): return !res.archimonstre)
	MonsterManager.monsters_res = monster_resources
	for mres in monster_resources:
		print("%s (%d) :" % [mres.name, mres.id])
		print(mres.spells)
	if composite_signal:
		await composite_signal.finished
		if selected_subarea_id == subarea._id:
			monster_manager.start_fight_button.disabled = false
	else:
		monster_manager.start_fight_button.disabled = false
