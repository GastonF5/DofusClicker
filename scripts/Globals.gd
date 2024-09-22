extends Node


const area_white_list = [
	# Incarnam
	450, 778, 445, 444, 443, 442, 449, 447,
	# Astrub
	95, 99
]

const debug := true
const check_version_for_reload_data := false

var has_focus: bool:
	set(val):
		has_focus = val
		if !val: focused_node = null
var focused_node: Node

var game: Node
var quitting := false

var main_menu: Control
var class_peeker: ClassPeeker
var area_peeker: AreaPeeker
var new_area_container: Container
var loading_screen: LoadingScreen
var loading_transition: LoadingTransition
var console: Console
var class_texture_rect: TextureRect
var timers: Node
var over_ui: CanvasLayer

var stats_container: Panel
var jobs_container: PanelContainer
var main_panel: PanelContainer

var spells_container: Panel
var spell_bar: SpellBar
var buffs_container: HBoxContainer

var xp_bar: ExperienceBar
var inventory: Inventory
var equipment_container: EquipmentContainer
var selected_class: int
var player_bars: EntityBars
var description_container: PanelContainer:
	set(new_container):
		if description_container:
			for child in description_container.get_children():
				description_container.remove_child(child)
				new_container.add_child(child)
		description_container = new_container


func _ready():
	get_viewport().gui_focus_changed.connect(
		func(n):
			focused_node = n
	)
	initialize()


func initialize(root: Node = get_tree().current_scene):
	game = root.get_node("%MainGame")
	class_peeker = root.get_node("%ClassPeeker")
	main_menu = root.get_node("%MainMenu")
	area_peeker = game.get_node("%AreaPeeker")
	new_area_container = game.get_node("%NewAreaContainer")
	loading_screen = root.get_node("%LoadingScreen")
	loading_transition = root.get_node("%LoadingTransition")
	console = game.get_node("%Console")
	class_texture_rect = game.get_node("%ClassTexture")
	timers = root.get_node("%Timers")
	over_ui = root.get_node("%OverUI")
	stats_container = game.get_node("%Stats")
	jobs_container = game.get_node("%JobsSuperContainer").get_child(0).get_child(0)
	main_panel = game.get_node("%MainPanel")
	spells_container = game.get_node("%Sorts")
	spell_bar = game.get_node("%SpellBar")
	xp_bar = game.get_node("%ExperienceBar")
	inventory = game.get_node("%InventoryContainer").get_node("%Inventory")
	equipment_container = game.get_node("%EquipmentContainer")
	player_bars = game.get_node("%EntityBars")
	buffs_container = game.get_node("%BuffsContainer")
	description_container = game.get_node("%DescriptionContainer")
	
	main_panel.visible = false
	game.get_node("%PlayerBarContainer").visible = false
	new_area_container.visible = false


func take_focus():
	has_focus = true


func leave_focus():
	has_focus = false
