extends Node


var tab_container: TabContainer
var current_tab: JobPanel

var recipes: Array[Recipe] = []

var console: Console
var inventory: Inventory

var recipe_filters: RecipeFilters
var prompt_has_focus := false


func initialize():
	console = Globals.console
	
	
	Datas.init_done.connect(init_recipes.bind(Globals.xp_bar.cur_lvl))
	Globals.xp_bar.lvl_up.connect(init_recipes)
	tab_container = Globals.jobs_container.get_node("TabContainer")
	inventory = Globals.inventory
	inventory.item_entered_tree.connect(check_recipes)
	inventory.item_exiting_tree.connect(check_recipes)
	
	recipe_filters = load("res://scenes/filters/recipe_filters.tscn").instantiate()
	recipe_filters.filter_toggle.connect(filter_recipes)
	on_job_tab_changed(tab_container.current_tab)
	for recipe in current_tab.recipe_container.get_children():
		recipes.append(recipe)
	tab_container.tab_changed.connect(on_job_tab_changed)


func _input(event):
	if current_tab:
		var search_prompt = current_tab.search_prompt
		if search_prompt.has_focus() and (event.is_action_pressed("esc") or event.is_action_pressed("LMB")):
			search_prompt.release_focus()


func on_job_tab_changed(tab):
	disconnect_inputs()
	var last_tab := current_tab
	current_tab = tab_container.get_child(tab) as JobPanel
	
	# Search prompt
	var text = "" if !last_tab else last_tab.search_prompt.text
	current_tab.search_prompt.text = text
	if last_tab: last_tab.search_prompt.clear()
	
	# Filters
	if recipe_filters.get_parent() != null:
		recipe_filters.get_parent().remove_child(recipe_filters)
	current_tab.filter_container.add_child(recipe_filters)
	var toggled = last_tab and last_tab.fitlers_toggled()
	current_tab.toggle_filters(toggled)
	if last_tab: last_tab.toggle_filters(false)
	
	connect_inputs()
	#filter_recipes()


func disconnect_inputs():
	if current_tab:
		var search_prompt = current_tab.search_prompt
		if search_prompt and search_prompt.text_changed.is_connected(filter_recipes):
			search_prompt.text_changed.disconnect(filter_recipes)


func connect_inputs():
	var search_prompt = current_tab.search_prompt
	search_prompt.text_changed.connect(filter_recipes)
	search_prompt.focus_entered.connect(func():
		prompt_has_focus = true)
	search_prompt.focus_exited.connect(func():
		prompt_has_focus = false)


func init_recipes(lvl := -1):
	if lvl == -1: lvl = Globals.xp_bar.cur_lvl
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


func filter_recipes(_params = null):
	var text_filter = current_tab.search_prompt.text
	for nrecipe in recipes:
		if text_filter and text_filter != "":
			nrecipe.visible = nrecipe.resource.get_result().name.to_lower().contains(text_filter.to_lower())
		else:
			nrecipe.visible = true
	if !recipe_filters.applied_filters.is_empty():
		for nrecipe: Recipe in recipes.filter(func(r): return r.visible):
			var is_filtered = false
			for result_stat_type in nrecipe.resource.get_result().equip_res.stats.map(func(s): return s.get_type()):
				is_filtered = recipe_filters.applied_filters.has(result_stat_type)
				if is_filtered: break
			nrecipe.visible = is_filtered


func filter_lvl(lvl_filter: String):
	pass
