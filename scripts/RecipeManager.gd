class_name RecipeManager
extends Node


@export var job_tab: TabBar

var recipe_container: VBoxContainer
var search_prompt: TextEdit

var recipes: Array[Recipe] = []


func _ready():
	for recipe in recipe_container.get_children():
		recipes.append(recipe)
	job_tab.tab_changed.connect(on_job_tab_changed)


func on_job_tab_changed(_tab):
	var search_prompts = get_tree().get_nodes_in_group("search_prompt")
	search_prompts.filter(func(a): return a.visible)
	search_prompt = search_prompts.get(0)
