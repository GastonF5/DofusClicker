class_name SaveManager
extends Node


var mplayer: PlayerManager
var mrecipe: RecipeManager
var mstats: StatsManager


func _ready():
	mplayer = $%PlayerManager
	mrecipe = $%RecipeManager
	mstats = $%StatsManager


func save():
	var save = SaveResource.create()
	save.xp_amount = mplayer.xp_bar.get_total_xp()
	save.inventory = mplayer.inventory.get_items()\
		.map(func(i):
			var array = [i.resource.id, i.resource.count]
			return array)
	save.characteristics = save_characteristics()
	$%FileSaver.save_data(save.to_dict(), save.date.replace("T", "-").replace(":", "."), "user://saves/")


func save_characteristics() -> Dictionary:
	var dict := {}
	for carac: Caracteristique in mstats.caracteristiques:
		dict[carac.type] = carac.base_amount
	dict["points"] = mstats.points
	return dict



func load_save():
	var save_file = FileLoader.load_save()
	var save = SaveResource.to_save_res(save_file.data)
	load_inventory(save)
	load_xp(save)
	load_characteristics(save)
	if save:
		return save
	else:
		push_error("No save found")


func load_inventory(save: SaveResource):
	var inventory: Inventory = mplayer.inventory
	inventory.remove_items(inventory.get_items())
	for item in save.inventory:
		var resource = null
		if Datas._resources.has(item[0]):
			resource = Datas._resources[item[0]]
		if Datas._items.has(item[0]):
			resource = Datas._items[item[0]]
		if resource:
			inventory.add_item(Item.create(resource, inventory))


func load_xp(save: SaveResource):
	mrecipe.reset()
	mplayer.max_hp = 50
	mplayer.hp_bar.reset()
	var xp_bar: ExperienceBar = mplayer.xp_bar
	xp_bar.reset()
	xp_bar.gain_xp(save.xp_amount)


func load_characteristics(save: SaveResource):
	mstats.points = save.characteristics["points"]
	mstats.max_points = (mplayer.xp_bar.cur_lvl - 1) * 5
	mstats.update_points_label()
	for carac_type in Caracteristique.Type.values():
		var carac = mstats.get_caracteristique_for_type(carac_type)
		if carac:
			carac.base_amount = save.characteristics[carac_type]
