class_name GameManager
extends Node

@onready var class_peeker: ClassPeeker = $%ClassPeeker

@onready var mstats: StatsManager = $%StatsManager
@onready var mplayer: PlayerManager = $%PlayerManager
@onready var mmonster: MonsterManager = $%MonsterManager
@onready var mequipment: EquipmentManager = $%EquipmentManager
@onready var mrecipe: RecipeManager = $%RecipeManager
@onready var area_peeker: AreaPeeker = $%AreaPeeker
@onready var loading_screen: LoadingScreen = $%LoadingScreen
@onready var datas: Datas = $%Datas
@onready var console: Console = $%Console


func _ready():
	class_peeker.visible = true
	class_peeker.bselect.button_up.connect(_on_class_selected)


func _on_class_selected():
	mstats.initialize()
	mplayer.initialize(class_peeker.classes[class_peeker.selected_class])
	mmonster.initialize()
	mequipment.initialize()
	mrecipe.initialize()
	datas.load_data()
	area_peeker.initialize()
	console.initialize()
	class_peeker.visible = false
