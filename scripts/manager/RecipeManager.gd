class_name RecipeManager
extends Node


@export var tab_container: TabContainer

var recipe_container: VBoxContainer
var search_prompt: TextEdit
var recipes: Array[Recipe] = []
var inventory: Inventory

const recipe_container_path = "MarginContainer/VBC/ScrollContainer/RecipeContainer"
const search_prompt_path = "MarginContainer/VBC/Search"
const equip_type = EquipmentResource.Type

var mouse_on_search = false


func _ready():
	inventory = $"/root/Main/PlayerManager".inventory
	on_job_tab_changed(tab_container.current_tab)
	init_recipes()
	for recipe in recipe_container.get_children():
		recipes.append(recipe)
	tab_container.tab_changed.connect(on_job_tab_changed)


func _input(event):
	if !mouse_on_search and event.is_action_pressed("LMB"):
		search_prompt.release_focus()
	if search_prompt.has_focus() and event.is_action_pressed("esc"):
		search_prompt.release_focus()


func on_job_tab_changed(tab):
	recipe_container = tab_container.get_child(tab).get_node(recipe_container_path)
	search_prompt = tab_container.get_child(tab).get_node(search_prompt_path)
	search_prompt.mouse_entered.connect(on_mouse_enter_search)
	search_prompt.mouse_exited.connect(on_mouse_exit_search)


func init_recipes():
	var equip_types = equip_type.keys()
	for type in equip_types:
		var equips_res = FileLoader.get_equipment_resources(type)
		for res in equips_res:
			if res.recipe != null:
				var recipe = Recipe.create(res, get_parent_by_type(equip_type.get(type)), inventory)
				recipe.craft.connect(on_recipe_craft)


func on_recipe_craft(result: ItemResource):
	inventory.remove_items(result.recipe.items)
	inventory.add_item(Item.create(result, inventory))


func on_mouse_enter_search():
	mouse_on_search = true


func on_mouse_exit_search():
	mouse_on_search = false


func get_parent_by_type(type: equip_type):
	var index: int
	match type:
		equip_type.COIFFE, equip_type.CAPE:
			index = 0
		equip_type.BOTTES, equip_type.CEINTURE:
			index = 1
		equip_type.AMULETTE, equip_type.ANNEAU:
			index = 2
	return tab_container.get_child(index).get_node(recipe_container_path)
	
