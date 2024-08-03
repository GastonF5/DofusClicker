extends Node

var class_peeker: ClassPeeker

static var in_fight := false


var managers = [StatsManager, PlayerManager, MonsterManager, EquipmentManager, RecipeManager]
func _ready():
	class_peeker = Globals.class_peeker
	
	SpellsService.console = Globals.console
	SpellsService.tnode = Globals.timers
	
	class_peeker.visible = true
	class_peeker.bselect.pressed.connect(_on_class_selected)


func _on_class_selected():
	await Globals.loading_transition.fade_up()
	await init_game()
	await Globals.loading_transition.fade_out()


func init_game(selected_class: int = Globals.selected_class):
	class_peeker.bselect.disabled = true
	Globals.class_texture_rect.texture = class_peeker.get_logo_transparent(selected_class)
	for manager: AbstractManager in managers:
		manager.initialize()
	Datas.load_data()
	Globals.area_peeker.initialize()
	Globals.console.initialize()
	await RecipeManager.recipes_initialized
	class_peeker.visible = false


func lose_fight():
	MonsterManager.clear_monsters()
	Globals.console.log_info("Vous avez perdu le combat")
	MonsterManager.end_fight()
