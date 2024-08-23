extends AbstractManager

var class_peeker: ClassPeeker

var in_fight := false

signal end_fight


var managers = [StatsManager, PlayerManager, MonsterManager, EquipmentManager, RecipeManager]

func _ready():
	Globals.game.get_node("%ChangeClassButton").button_up.connect(change_class)
	Globals.game.get_node("%QuitButton").button_up.connect(reload_game)
	initialize()


func _input(event):
	if event.is_action_pressed("space") and !MonsterManager.start_fight_button.disabled:
		MonsterManager.start_fight()


func initialize():
	class_peeker = Globals.class_peeker
	
	SpellsService.console = Globals.console
	SpellsService.tnode = Globals.timers
	
	class_peeker.visible = true
	class_peeker.bselect.pressed.connect(_on_class_selected)
	super()


func reset():
	in_fight = false
	class_peeker = null
	SpellsService.console = null
	SpellsService.tnode = null
	super()


func _on_class_selected():
	await Globals.loading_transition.fade_up()
	Globals.class_texture_rect.texture = class_peeker.get_logo_transparent(Globals.selected_class)
	if !managers.all(func(m): return m.is_initialized):
		await init_game()
	else:
		PlayerManager.init_spells()
		class_peeker.visible = false
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


func change_class():
	await Globals.loading_transition.fade_up()
	for slot in Globals.spell_bar.slots:
		if slot.get_child_count() == 1:
			Globals.spell_bar.delete_spell(slot.get_child(0))
	class_peeker.visible = true
	for button: Button in class_peeker.buttons:
		button.set_pressed_no_signal(false)
	class_peeker.select_class(0)
	await Globals.loading_transition.fade_out()


func reload_game():
	Globals.quitting = true
	await Globals.loading_transition.fade_up()
	for manager in GameManager.managers:
		manager.reset()
	var main = get_tree().root.get_node("Main")
	get_tree().root.remove_child(main)
	main.queue_free()
	main = load("res://scenes/main.tscn").instantiate()
	main.name = "Main"
	get_tree().root.add_child(main)
	get_tree().current_scene = main
	Globals.initialize(main)
	GameManager.initialize()
	Globals.quitting = false
