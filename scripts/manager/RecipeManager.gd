extends AbstractManager


var tab_container: TabContainer
var current_tab: JobPanel

var recipe_containers: Array[RecipeContainer] = []

var recipe_filters: RecipeFilters

signal recipes_initialized


func reset():
	tab_container = null
	current_tab = null
	recipe_containers.clear()
	recipe_filters = null
	super()


func initialize():
	if !Datas.init_done.is_connected(init_recipes):
		Datas.init_done.connect(init_recipes.bind(Globals.xp_bar.cur_lvl))
	Globals.xp_bar.lvl_up.connect(init_recipes)
	tab_container = Globals.jobs_container.get_node("VBC/TabContainer")
	
	recipe_filters = RecipeFilters.scene.instantiate()
	recipe_filters.filter_toggle.connect(filter_recipes)
	on_job_tab_changed(tab_container.current_tab)
	tab_container.tab_changed.connect(on_job_tab_changed)
	super()


func _input(event):
	if !Globals.quitting:
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


func disconnect_inputs():
	if current_tab:
		var search_prompt = current_tab.search_prompt
		if search_prompt and search_prompt.text_changed.is_connected(filter_recipes):
			search_prompt.text_changed.disconnect(filter_recipes)
		if search_prompt and search_prompt.focus_entered.is_connected(Globals.take_focus):
			search_prompt.focus_entered.disconnect(Globals.take_focus)
		if search_prompt and search_prompt.focus_exited.is_connected(Globals.leave_focus):
			search_prompt.focus_exited.disconnect(Globals.leave_focus)


func connect_inputs():
	var search_prompt = current_tab.search_prompt
	search_prompt.text_changed.connect(filter_recipes.unbind(1))
	search_prompt.focus_entered.connect(Globals.take_focus)
	search_prompt.focus_exited.connect(Globals.leave_focus)


func init_recipes(lvl := -1):
	if lvl == -1: lvl = Globals.xp_bar.cur_lvl
	var recipes_to_init = Datas._recipes.values().filter(is_recipe_to_init.bind(lvl))
	for recipe in recipes_to_init:
		var parent
		if recipe.get_result().is_key():
			parent = tab_container.get_node("BricoleurPanel")
		elif recipe.get_result().is_consommable():
			parent = tab_container.get_node("ConsommablesPanel")
		else:
			parent = get_parent_by_type(recipe.get_result().type_id)
		if parent:
			create_recipe(recipe, parent)
		if recipe.get_result().is_equipment():
			create_recipe(recipe, tab_container.get_node("ToutPanel"))


func create_recipe(recipe_res: RecipeResource, parent: JobPanel):
	var recipe_container = RecipeContainer.create(recipe_res, parent.recipe_container)
	recipe_container.crafted.connect(_on_recipe_craft)
	recipe_containers.append(recipe_container)
	filter_recipe(recipe_container)


func is_recipe_to_init(recipe: RecipeResource, lvl: int):
	var can_be_crafted = true
	if recipe.get_result().get_id() == 1182:
		pass
	if !Globals.debug:
		for ingredient: ItemResource in recipe.get_ingredients():
			can_be_crafted = can_be_crafted and ingredient.get_drop_areas() != ""
	if recipe.get_result() and can_be_crafted:
		return recipe.get_result().level == lvl
	return false


func _on_recipe_craft(recipe: RecipeResource):
	Globals.inventory.remove_items(recipe.get_ingredients())
	var item = Item.create(recipe.get_result())
	Globals.inventory.add_item(item)
	if Globals.debug and item.resource.is_equipment():
		Globals.console.log_equip(item)


func get_parent_by_type(type_id: int) -> JobPanel:
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
	return tab_container.get_node(node_name + "Panel")


func filter_recipes():
	for recipe_container in recipe_containers:
		filter_recipe(recipe_container)


var filter_methods = [is_filtered_by_research, is_filtered_by_level, is_filtered_by_introuvable, is_filtered_by_craftable, is_filtered_by_characteristics]
func filter_recipe(recipe_container: RecipeContainer):
	var is_filtered = true
	for filter_method in filter_methods:
		is_filtered = is_filtered and filter_method.call(recipe_container)
		if !is_filtered:
			break
	recipe_container.visible = is_filtered


func is_filtered_by_research(recipe_container: RecipeContainer) -> bool:
	var text_filter = current_tab.search_prompt.text
	if text_filter and text_filter != "":
		return recipe_container._resource.get_result().name.to_lower().contains(text_filter.to_lower())
	return true


func is_filtered_by_craftable(recipe_container: RecipeContainer) -> bool:
	return !recipe_filters.craftable or recipe_container.is_craftable()


func is_filtered_by_characteristics(recipe_container: RecipeContainer) -> bool:
	if recipe_filters.applied_filters.is_empty():
		return true
	var count := 0
	if !recipe_container._resource.get_result().is_equipment():
		return true
	var result_stat_types = recipe_container._resource.get_result().equip_res.stats.map(func(s): return s.get_type())
	var is_filtered = false
	for applied_filter in recipe_filters.applied_filters:
		if result_stat_types.has(applied_filter):
			count += 1
	if count == recipe_filters.applied_filters.size():
		is_filtered = true
	return is_filtered


func is_filtered_by_level(recipe_container: RecipeContainer) -> bool:
	return range(recipe_filters._min, recipe_filters._max + 1)\
		.has(recipe_container._resource.get_result().level)


func is_filtered_by_introuvable(recipe_container: RecipeContainer) -> bool:
	if recipe_filters.introuvable:
		return !recipe_container.is_trouvable()
	return recipe_container.is_trouvable()
