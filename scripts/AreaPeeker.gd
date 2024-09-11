class_name AreaPeeker
extends PanelContainer


@export var back_button: Button
@export var area_label: Label

var selected_area_id := -1
var selected_subarea_id := -1
var cur_lvl := 1

var area_btns := {}
var subarea_btns := {}

var console: Console


func initialize():
	console = Globals.console
	Globals.xp_bar.lvl_up.connect(_on_level_up)
	cur_lvl = Globals.xp_bar.cur_lvl
	init_areas()


func init_areas():
	var areas = Datas._areas.values()
	areas = areas.filter(func(a): return !a.black_listed(cur_lvl) and a.get_level() > 0 and a.get_level() <= cur_lvl and a.has_monsters())
	areas.sort_custom(AreaResource.sort_by_level)
	for area in areas:
		create_area_button(area._id)
		#prints(area._name, area._id)


func init_subareas(area: AreaResource):
	selected_area_id = area._id
	for subarea in area.get_subareas(cur_lvl):
		if !subarea.black_listed() and subarea.has_monsters():
			create_area_button(subarea._id, true)
			prints(subarea._name, subarea._id)


func _on_area_clicked(area_id: int):
	clear_buttons()
	back_button.disabled = false
	init_subareas(Datas._areas[area_id])


func _on_subarea_clicked(subarea_id: int):
	var subarea = Datas._subareas[subarea_id]
	selected_subarea_id = subarea_id
	if DungeonManager.is_dungeon(subarea_id):
		DungeonManager.enter_dungeon(subarea_id)
	else:
		enter_subarea(subarea)


func create_area_button(area_id: int, is_subarea := false, do_add_child := true):
	var button: AreaButton
	var callable = _on_subarea_clicked if is_subarea else _on_area_clicked
	if button_exists(area_id, is_subarea):
		button = subarea_btns[area_id] if is_subarea else area_btns[area_id]
	else:
		var is_dungeon = DungeonManager.is_dungeon(area_id)
		var btn_icon = load("res://assets/icons/dungeon.png")\
			if is_dungeon\
			else load("res://assets/icons/quest.png")
		button = AreaButton.create(area_id, callable, btn_icon, is_subarea, is_dungeon)
		if is_subarea:
			subarea_btns[area_id] = button
		else:
			area_btns[area_id] = button
	if do_add_child:
		$HBC/ScrollContainer/HBC.add_child(button)
	else:
		button._new = false


func erase_button(area: AreaResource):
	var button = $HBC/ScrollContainer/HBC.get_node(str(area._id))
	$HBC/ScrollContainer/HBC.remove_child(button)


func clear_buttons():
	for button in $HBC/ScrollContainer/HBC.get_children().filter(func(b): return b is AreaButton):
		$HBC/ScrollContainer/HBC.remove_child(button)


func _on_back_button_button_up():
	if selected_subarea_id != -1:
		leave_subarea()
	else:
		clear_buttons()
		back_button.disabled = true
		init_areas()


func _on_level_up():
	cur_lvl = Globals.xp_bar.cur_lvl


func set_area_label(label: String, _visible: bool):
	area_label.text = label
	area_label.visible = _visible


func enter_subarea(subarea: AreaResource, subarea_name: String = ""):
	clear_buttons()
	back_button.icon = load("res://assets/back_btn/btn_arrow_turn_character_normal.png")
	if subarea_name == "":
		set_area_label(subarea._name, true)
		log_enter_subarea(subarea._name)
	else:
		set_area_label(subarea_name, true)
		log_enter_subarea(subarea_name)
	load_monsters(subarea)
	_show_fight_side()
	Globals.game.get_node("%SubareaBackground").texture = FileLoader.get_subarea_asset(subarea._id)


func leave_subarea():
	back_button.icon = load("res://assets/icons/zaap.png")
	log_leave_subarea()
	selected_subarea_id = -1
	set_area_label("", false)
	init_subareas(Datas._areas[selected_area_id])
	MonsterManager.start_fight_button.disabled = true
	_show_havre_sac_side()


func log_enter_subarea(subarea_name: String):
	console.log_info("Vous entrez dans la zone %s" % subarea_name)


func log_leave_subarea():
	if selected_subarea_id != -1:
		var subarea = Datas._subareas[selected_subarea_id]
		console.log_info("Vous sortez de la zone %s" % subarea._name)


func load_monsters(subarea: AreaResource):
	MonsterManager.set_start_fight_button_loading(true)
	var monster_resources = subarea.get_monsters()
	var composite_signal
	var not_loaded_monsters = monster_resources.filter(func(r): return !r.texture)
	if !not_loaded_monsters.is_empty():
		composite_signal = API.CompositeSignal.new()
		for monster_res in not_loaded_monsters:
			if !monster_res.texture:
				composite_signal.add_method(monster_res.load_texture)
	monster_resources = monster_resources.filter(func(res): return !res.archimonstre)
	MonsterManager.monsters_res = monster_resources
	for mres in monster_resources:
		print("%s (%d) :" % [mres.name, mres.id])
		print(mres.spells)
	if composite_signal:
		await composite_signal.finished
		if selected_subarea_id == subarea._id:
			MonsterManager.start_fight_button.disabled = false
			MonsterManager.set_start_fight_button_loading(false)
	else:
		MonsterManager.start_fight_button.disabled = false
		MonsterManager.set_start_fight_button_loading(false)


func button_exists(id: int, is_subarea: bool):
	if is_subarea:
		return subarea_btns.keys().has(id)
	else:
		return area_btns.keys().has(id)


func get_button(id: int, is_subarea: bool):
	if !button_exists(id, is_subarea):
		return null
	return subarea_btns[id] if is_subarea else area_btns[id]


func _show_fight_side():
	Globals.game.get_node("%JobsSuperContainer").visible = false
	Globals.main_panel.visible = true
	Globals.game.get_node("%PlayerBarContainer").visible = true
	Globals.description_container = Globals.game.get_node("%DescriptionContainer2")
	var spell_bar = Globals.spell_bar
	spell_bar.get_parent().remove_child(spell_bar)
	Globals.game.get_node("%SpellBarContainer1").add_child(spell_bar)


func _show_havre_sac_side():
	Globals.game.get_node("%JobsSuperContainer").visible = true
	Globals.main_panel.visible = false
	Globals.game.get_node("%PlayerBarContainer").visible = false
	Globals.description_container = Globals.game.get_node("%DescriptionContainer")
	var spell_bar = Globals.spell_bar
	spell_bar.get_parent().remove_child(spell_bar)
	Globals.game.get_node("%SpellBarContainer2").add_child(spell_bar)
