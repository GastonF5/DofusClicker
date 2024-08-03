extends Node

var class_peeker: ClassPeeker

var in_fight := false


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


func init_game(save_res: SaveResource = null):
	class_peeker.bselect.disabled = true
	var selected_class = save_res.class_id if save_res else Globals.selected_class
	Globals.class_texture_rect.texture = class_peeker.get_logo_transparent(selected_class)
	for manager: AbstractManager in managers:
		manager.initialize()
	Datas.load_data()
	Globals.area_peeker.initialize()
	Globals.console.initialize()
	if save_res:
		if !SaveManager.load_save(save_res):
			return false
	await RecipeManager.composite.finished
	class_peeker.visible = false
	return true


func lose_fight():
	MonsterManager.clear_monsters()
	Globals.console.log_info("Vous avez perdu le combat")
	MonsterManager.end_fight()
