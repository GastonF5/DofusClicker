extends Node


var class_peeker: ClassPeeker
var area_peeker: AreaPeeker
var loading_screen: LoadingScreen
var console: Console
var class_texture_rect: TextureRect
var timers: Node

var stats_container: Panel
var jobs_container: VBoxContainer

var spells_container: Panel
var spell_bar: SpellBar

var xp_bar: ExperienceBar
var inventory: Inventory
var selected_class: int


func _ready():
	class_peeker = get_tree().current_scene.get_node("%ClassPeeker")
	area_peeker = get_tree().current_scene.get_node("%AreaPeeker")
	loading_screen = get_tree().current_scene.get_node("%LoadingScreen")
	console = get_tree().current_scene.get_node("%Console")
	class_texture_rect = get_tree().current_scene.get_node("%ClassTexture")
	timers = get_tree().current_scene.get_node("%Timers")
	stats_container = get_tree().current_scene.get_node("%Stats")
	jobs_container = get_tree().current_scene.get_node("%JobsContainer")
	spells_container = get_tree().current_scene.get_node("%Sorts")
	spell_bar = get_tree().current_scene.get_node("%SpellBar")
	xp_bar = get_tree().current_scene.get_node("%ExperienceBar")
	inventory = get_tree().current_scene.get_node("%InventoryContainer").get_node("%Inventory")
