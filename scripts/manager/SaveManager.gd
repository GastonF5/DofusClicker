extends Node


func initialize():
	Globals.game.get_node("%SaveButton").button_up.connect(save)


func save():
	var save_res = SaveResource.create()
	save_res.xp_amount = Globals.xp_bar.get_total_xp()
	save_res.inventory = Globals.inventory.get_items().map(func(i): return i.get_save())
	save_res.equipment = EquipmentManager.equipment_container.get_save()
	save_res.characteristics = save_characteristics()
	save_res.class_id = Globals.selected_class
	save_res.discovered_areas = save_areas()
	save_res.current_areas = [Globals.area_peeker.selected_area_id, Globals.area_peeker.selected_subarea_id]
	save_res.spells = Globals.spell_bar.get_save()
	FileSaver.save_data(save_res.to_dict(), save_res.date.replace("T", "-").replace(":", "_"), "user://saves/")
	Globals.console.log_info("Sauvegarde effectuée avec succès")


func save_characteristics() -> Dictionary:
	var dict := {}
	for carac: Caracteristique in StatsManager.caracteristiques:
		if carac.modifiable:
			dict[carac.type] = carac.base_amount
	dict["points"] = StatsManager.points
	return dict


func save_areas() -> Array:
	var btns: Array[AreaButton] = []
	btns.assign(Globals.area_peeker.area_btns.values() + Globals.area_peeker.subarea_btns.values())
	return btns.filter(func(btn): return !btn._new and !btn._is_dungeon)\
			.map(func(btn: AreaButton): return [btn._area_id, btn.is_subarea()])


func load_save(save_res: SaveResource):
	log.info("Chargement de la sauvegarde")
	load_inventory(save_res)
	load_xp(save_res)
	EquipmentManager.equipment_container.load_save(save_res.equipment)
	load_characteristics(save_res)
	load_areas(save_res)
	load_spells(save_res)
	if save_res:
		log.info("Chargement de la sauvegarde effectué avec succès")
		return save_res
	else:
		log.error("No save found")


func load_inventory(save_res: SaveResource):
	var inventory: Inventory = Globals.inventory
	inventory.remove_items(inventory.get_items())
	for data in save_res.inventory:
		var resource = get_item_or_resource(data["id"])
		if resource:
			resource.load_save(data)
			inventory.add_item(Item.create(resource))


func get_item_or_resource(id: int):
	if Datas._resources.has(id):
		return Datas._resources[id]._duplicate()
	if Datas._items.has(id):
		return Datas._items[id]._duplicate()
	if Datas._keys.has(id):
		return Datas._keys[id]._duplicate()
	return null


func load_xp(save_res: SaveResource):
	PlayerManager.max_hp = 50
	PlayerManager.hp_bar.reset()
	Globals.xp_bar.reset()
	Globals.xp_bar.gain_xp(save_res.xp_amount)


func load_characteristics(save_res: SaveResource):
	StatsManager.points = save_res.characteristics["points"]
	StatsManager.max_points = (Globals.xp_bar.cur_lvl - 1) * 5
	StatsManager.update_points_label()
	for key in save_res.characteristics.keys():
		if key is int:
			var carac = StatsManager.get_caracteristique_for_type(key)
			if carac:
				carac.base_amount = save_res.characteristics[key]


func load_areas(save_res: SaveResource):
	var area_peeker: AreaPeeker = Globals.area_peeker
	# discovered areas
	for data in save_res.discovered_areas:
		var area_id = data[0]
		var is_subarea = data[1]
		var button: AreaButton
		if is_subarea:
			button = area_peeker.subarea_btns[area_id]
		else:
			button = area_peeker.area_btns[area_id]
		button._new = false
	# current area
	if save_res.current_areas[0] != -1:
		area_peeker._on_area_clicked(save_res.current_areas[0])
	if save_res.current_areas[1] != -1:
		area_peeker._on_subarea_clicked(save_res.current_areas[1])


func load_spells(save_res: SaveResource):
	for spell_button: SpellButton in Globals.spells_container.get_node("%SpellContainer").get_children():
		var spell_id = spell_button.get_spell_id()
		if save_res.spells.values().has(spell_id):
			spell_button._on_button_up()
	Globals.spell_bar.load_save(save_res.spells)


func delete_save(save_btn: SaveButton):
	var dir = DirAccess.open(FileSaver.SAVE_PATH)
	var file_name = save_btn.file_name
	if dir.file_exists(file_name):
		dir.remove(file_name)
		save_btn.get_parent().remove_child(save_btn)
		save_btn.queue_free()
	else:
		push_error("Save file not found")


func format_date(date: String):
	var date_split = date.split("T")
	return "%s : %s" % [date_split[0], date_split[1]]
