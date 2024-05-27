class_name RecipeManager
extends Node


@export var jobs_container: VBoxContainer
var tab_container: TabContainer

var recipe_container: VBoxContainer
var search_prompt: LineEdit
var lvl_input: LineEdit
var recipes: Array[Recipe] = []

@onready var console: Console = $%Console
var inventory: Inventory


func _ready():
	$%Datas.init_done.connect(init_recipes.bind(1))
	tab_container = jobs_container.get_node("TabContainer")
	inventory = $%PlayerManager.inventory
	inventory.item_entered_tree.connect(check_recipes)
	inventory.item_exiting_tree.connect(check_recipes)
	
	on_job_tab_changed(tab_container.current_tab)
	for recipe in recipe_container.get_children():
		recipes.append(recipe)
	tab_container.tab_changed.connect(on_job_tab_changed)


func _input(event):
	if search_prompt.has_focus() and (event.is_action_pressed("esc") or event.is_action_pressed("LMB")):
		search_prompt.release_focus()
	if lvl_input.has_focus() and (event.is_action_pressed("esc") or event.is_action_pressed("LMB")):
		lvl_input.release_focus()


func on_job_tab_changed(tab):
	disconnect_inputs()
	recipe_container = tab_container.get_child(tab).recipe_container
	search_prompt = tab_container.get_child(tab).search_prompt
	lvl_input = tab_container.get_child(tab).lvl_input
	connect_inputs()


func disconnect_inputs():
	if search_prompt and search_prompt.text_changed.is_connected(filter_recipes):
		search_prompt.text_changed.disconnect(filter_recipes)
	if lvl_input and lvl_input.text_changed.is_connected(filter_lvl):
		lvl_input.text_changed.disconnect(filter_lvl)


func connect_inputs():
	search_prompt.text_changed.connect(filter_recipes)
	lvl_input.text_changed.connect(filter_lvl)


func init_recipes(lvl: int):
	var recipes_to_init = Datas._recipes.values().filter(func(r): return r.get_result().level == lvl)
	for recipe in recipes_to_init:
		var parent = get_parent_by_type(recipe.get_result().type_id)
		if parent:
			var nrecipe = Recipe.create(recipe, parent)
			recipes.append(nrecipe)
			nrecipe.craft.connect(on_recipe_craft)


func on_recipe_craft(recipe: RecipeResource):
	inventory.remove_items(recipe.get_ingredients())
	var item = Item.create(recipe.get_result(), inventory)
	inventory.add_item(item)
	console.log_equip(item)


func check_recipes(items):
	for recipe in recipes:
		recipe.check(items)


func get_parent_by_type(type_id: int):
	var type: ItemTypeResource = Datas._types[type_id]
	var node_name: String
	match type._name.to_upper():
		"CHAPEAU", "CAPE":
			node_name = "Tailleur"
		"BOTTES", "CEINTURE":
			node_name = "Cordonnier"
		"AMULETTE", "ANNEAU":
			node_name = "Bijoutier"
		"BOUCLIER":
			node_name = "Faconneur"
		"ARC", "BAGUETTE", "BÂTON":
			node_name = "Sculpteur"
		"DAGUE", "EPEE", "MARTEAU", "PELLE":
			node_name = "Forgeron"
		_:
			return null
	var job_panel: JobPanel = tab_container.get_node(node_name + "Panel")
	return job_panel.recipe_container


func filter_recipes(text_filter: String):
		for nrecipe in recipes:
			if text_filter and text_filter != "":
				nrecipe.visible = nrecipe.recipe.get_result().name.to_lower().contains(text_filter.to_lower())
			else:
				nrecipe.visible = true


func filter_lvl(lvl_filter: String):
	pass
