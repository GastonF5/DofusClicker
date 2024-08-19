extends Node


func save():
	var save_res = SaveResource.create()
	save_res.xp_amount = Globals.xp_bar.get_total_xp()
	save_res.inventory = Globals.inventory.get_items().map(func(i): return i.get_save())
	save_res.equipment = EquipmentManager.equipment_container.get_save()
	save_res.characteristics = save_characteristics()
	save_res.class_id = Globals.selected_class
	save_res.discovered_areas = save_areas()
	save_res.current_areas = [Globals.area_peeker.selected_area_id, Globals.area_peeker.selected_subarea_id]
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
	return btns.filter(func(btn): return !btn._new)\
			.map(func(btn: AreaButton): return [btn._area_id, btn.is_subarea()])


func load_save(save_res: SaveResource):
	load_inventory(save_res)
	EquipmentManager.equipment_container.load_save(save_res.equipment)
	load_xp(save_res)
	load_characteristics(save_res)
	load_areas(save_res)
	if save_res:
		return save_res
	else:
		push_error("No save found")


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
		return Datas._resources[id].duplicate(true)
	if Datas._items.has(id):
		return Datas._items[id].duplicate(true)
	return null


func load_xp(save_res: SaveResource):
	RecipeManager.reset()
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
	var area_peeker = Globals.area_peeker
	# discovered areas
	for data in save_res.discovered_areas:
		var area_id = data[0]
		var is_subarea = data[1]
		if area_peeker.button_exists(area_id, is_subarea):
			area_peeker.get_button(area_id, is_subarea)._new = false
		else:
			area_peeker.create_area_button(area_id, is_subarea, false)
	# current area
	if save_res.current_areas[0] != -1:
		area_peeker._on_area_clicked(save_res.current_areas[0])
	if save_res.current_areas[1] != -1:
		area_peeker._on_subarea_clicked(save_res.current_areas[1])


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
