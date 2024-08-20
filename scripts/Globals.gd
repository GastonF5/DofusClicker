extends Node


const area_black_list = [10, 29, 32, 973, 974, 975, 976, 977, 978, 980, 982]
const debug := true

var quitting := false

var class_peeker: ClassPeeker
var area_peeker: AreaPeeker
var loading_screen: LoadingScreen
var loading_transition: LoadingTransition
var console: Console
var class_texture_rect: TextureRect
var timers: Node
var over_ui: CanvasLayer

var stats_container: Panel
var jobs_container: VBoxContainer

var spells_container: Panel
var spell_bar: SpellBar

var xp_bar: ExperienceBar
var inventory: Inventory
var equipment_container: EquipmentContainer
var selected_class: int
var player_bars: EntityBars


func _ready():
	initialize()


func initialize(root: Node = get_tree().current_scene):
	class_peeker = root.get_node("%ClassPeeker")
	area_peeker = root.get_node("%AreaPeeker")
	loading_screen = root.get_node("%LoadingScreen")
	loading_transition = root.get_node("%LoadingTransition")
	console = root.get_node("%Console")
	class_texture_rect = root.get_node("%ClassTexture")
	timers = root.get_node("%Timers")
	over_ui = root.get_node("%OverUI")
	stats_container = root.get_node("%Stats")
	jobs_container = root.get_node("%JobsContainer")
	spells_container = root.get_node("%Sorts")
	spell_bar = root.get_node("%SpellBar")
	xp_bar = root.get_node("%ExperienceBar")
	inventory = root.get_node("%InventoryContainer").get_node("%Inventory")
	equipment_container = root.get_node("%EquipmentContainer")
	player_bars = root.get_node("%EntityBars")
