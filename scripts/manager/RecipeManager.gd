class_name RecipeManager
extends Node


@export var jobs_container: VBoxContainer
var tab_container: TabContainer

var recipe_container: VBoxContainer
var search_prompt: LineEdit
var recipes: Array[Recipe] = []

const recipe_container_path = "MarginContainer/VBC/ScrollContainer/RecipeContainer"
const search_prompt_path = "MarginContainer/VBC/Search"
const equip_type = EquipmentResource.Type
const weapon_type = EquipmentResource.WeaponType

var mouse_on_search = false

@onready var console: Console = $%Console
var inventory: Inventory


func _ready():
	$%Dicts.init_done.connect(init_recipes)
	tab_container = jobs_container.get_node("TabContainer")
	inventory = $%PlayerManager.inventory
	
	on_job_tab_changed(tab_container.current_tab)
	for recipe in recipe_container.get_children():
		recipes.append(recipe)
	tab_container.tab_changed.connect(on_job_tab_changed)


func _input(event):
	if search_prompt.has_focus() and (event.is_action_pressed("esc") or event.is_action_pressed("LMB")):
		search_prompt.release_focus()


func on_job_tab_changed(tab):
	disconnect_search_prompt()
	recipe_container = tab_container.get_child(tab).get_node(recipe_container_path)
	search_prompt = tab_container.get_child(tab).get_node(search_prompt_path)
	connect_search_prompt()


func disconnect_search_prompt():
	if search_prompt and search_prompt.mouse_entered.is_connected(on_mouse_enter_search):
		search_prompt.mouse_entered.disconnect(on_mouse_enter_search)
	if search_prompt and search_prompt.mouse_exited.is_connected(on_mouse_exit_search):
		search_prompt.mouse_exited.disconnect(on_mouse_exit_search)
	if search_prompt and search_prompt.text_changed.is_connected(filter_recipes):
		search_prompt.text_changed.disconnect(filter_recipes)


func connect_search_prompt():
	search_prompt.mouse_entered.connect(on_mouse_enter_search)
	search_prompt.mouse_exited.connect(on_mouse_exit_search)
	search_prompt.text_changed.connect(filter_recipes)


func init_recipes():
	for recipe in Dicts._recipes.values():
		var parent = get_parent_by_type(recipe.get_item().type_id)
		if parent:
			var nrecipe = Recipe.create(recipe, parent)
			nrecipe.craft.connect(on_recipe_craft)


func on_recipe_craft(result: ItemResource):
	inventory.remove_items(result.recipe.items)
	var item = Item.create(result, inventory)
	inventory.add_item(item)
	console.log_equip(item)


func on_mouse_enter_search():
	mouse_on_search = true


func on_mouse_exit_search():
	mouse_on_search = false


func get_parent_by_type(type_id: int):
	var type: Dicts.ItemType = Dicts._types[type_id]
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
	return tab_container.get_node(node_name + "Panel").get_node(recipe_container_path)


func filter_recipes(text_filter: String):
		for recipe in recipes:
			if text_filter and text_filter != "":
				recipe.visible = recipe.result.name.to_lower().contains(text_filter.to_lower())
			else:
				recipe.visible = true
