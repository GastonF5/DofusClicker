extends Node


func save():
	var save = SaveResource.create()
	save.xp_amount = Globals.xp_bar.get_total_xp()
	save.inventory = Globals.inventory.get_items().map(func(i): return i.get_save())
	save.equipment = EquipmentManager.equipment_container.get_save()
	save.characteristics = save_characteristics()
	save.class_id = Globals.selected_class
	save.discovered_areas = save_areas()
	FileSaver.save_data(save.to_dict(), save.date.replace("T", "-").replace(":", "."), "user://saves/")


func save_characteristics() -> Dictionary:
	var dict := {}
	for carac: Caracteristique in StatsManager.caracteristiques:
		if carac.modifiable:
			dict[carac.type] = carac.base_amount
	dict["points"] = StatsManager.points
	return dict


func save_areas() -> Array:
	var btns: Array[AreaButton]
	btns.assign(Globals.area_peeker.area_btns.values() + Globals.area_peeker.subarea_btns.values())
	return btns.filter(func(btn): return !btn.new)\
			.map(func(btn: AreaButton): return [btn.area_id, btn.is_subarea])


func load_save(save: SaveResource):
	load_inventory(save)
	EquipmentManager.equipment_container.load_save(save.equipment)
	load_xp(save)
	load_characteristics(save)
	load_areas(save)
	if save:
		return save
	else:
		push_error("No save found")


func load_inventory(save: SaveResource):
	var inventory: Inventory = Globals.inventory
	inventory.remove_items(inventory.get_items())
	for data in save.inventory:
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


func load_xp(save: SaveResource):
	RecipeManager.reset()
	PlayerManager.max_hp = 50
	PlayerManager.hp_bar.reset()
	Globals.xp_bar.reset()
	Globals.xp_bar.gain_xp(save.xp_amount)


func load_characteristics(save: SaveResource):
	StatsManager.points = save.characteristics["points"]
	StatsManager.max_points = (Globals.xp_bar.cur_lvl - 1) * 5
	StatsManager.update_points_label()
	for key in save.characteristics.keys():
		if key is int:
			var carac = StatsManager.get_caracteristique_for_type(key)
			if carac:
				carac.base_amount = save.characteristics[key]


func load_areas(save: SaveResource):
	var area_peeker = Globals.area_peeker
	for data in save.discovered_areas:
		var area_id = data[0]
		var is_subarea = data[1]
		# si c'est une subarea
		if area_peeker.button_exists(area_id, is_subarea):
			area_peeker.get_button(area_id, is_subarea).new = false
		else:
			area_peeker.create_area_button(area_id, is_subarea, false)
