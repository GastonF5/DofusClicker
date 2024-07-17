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


@export var class_texture_rect: TextureRect

func _ready():
	class_peeker.visible = true
	class_peeker.bselect.button_up.connect(_on_class_selected)


func _on_class_selected():
	class_texture_rect.texture = class_peeker.get_logo_transparent()
	mstats.initialize()
	mplayer.initialize(class_peeker.classes[class_peeker.selected_class])
	mmonster.initialize()
	mequipment.initialize()
	mrecipe.initialize()
	datas.load_data()
	area_peeker.initialize()
	console.initialize()
	class_peeker.visible = false


static func in_fight() -> bool:
	return !MonsterManager.monsters.is_empty()


func lose_fight():
	mmonster.clear_monsters()
	console.log_info("Vous avez perdu le combat")
	mmonster.end_fight()
