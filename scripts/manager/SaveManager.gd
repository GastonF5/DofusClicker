class_name SaveManager
extends Node


func save():
	var save = SaveResource.create()
	var player_manager: PlayerManager = $%PlayerManager
	save.xp_amount = player_manager.xp_bar.get_total_xp()
	save.inventory = player_manager.inventory.get_items()\
		.map(func(i):
			var array = [i.resource.id, i.resource.count]
			return array)
	$%FileSaver.save_data(save.to_dict(), save.date.replace("T", "-").replace(":", "."), "user://saves/")


func load_save():
	var save_file = FileLoader.load_save()
	var save = SaveResource.to_save_res(save_file.data)
	load_inventory(save)
	if save:
		return save
	else:
		push_error("No save found")


func load_inventory(save: SaveResource):
	var inventory: Inventory = $%PlayerManager.inventory
	for item in save.inventory:
		var resource = null
		if Datas._resources.has(item[0]):
			resource = Datas._resources[item[0]]
		if Datas._items.has(item[0]):
			resource = Datas._items[item[0]]
		if resource:
			inventory.add_item(Item.create(resource, inventory))
