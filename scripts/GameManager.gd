extends Node

var class_peeker: ClassPeeker
var area_peeker: AreaPeeker
var loading_screen: LoadingScreen
var console: Console
var class_texture_rect: TextureRect

static var in_fight := false

func _ready():
	class_peeker = Globals.class_peeker
	area_peeker = Globals.area_peeker
	loading_screen = Globals.loading_screen
	console = Globals.console
	class_texture_rect = Globals.class_texture_rect
	
	SpellsService.console = Globals.console
	SpellsService.tnode = Globals.timers
	
	class_peeker.visible = true
	class_peeker.bselect.pressed.connect(_on_class_selected)


func _on_class_selected():
	class_texture_rect.texture = class_peeker.get_logo_transparent()
	StatsManager.initialize()
	PlayerManager.initialize(class_peeker.classes[class_peeker.selected_class])
	MonsterManager.initialize()
	EquipmentManager.initialize()
	RecipeManager.initialize()
	Datas.load_data()
	area_peeker.initialize()
	console.initialize()
	class_peeker.visible = false


func lose_fight():
	MonsterManager.clear_monsters()
	console.log_info("Vous avez perdu le combat")
	MonsterManager.end_fight()
