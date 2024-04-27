class_name Spell
extends ClickableControl

@onready var player_manager: PlayerManager = $"/root/Main/PlayerManager"
@onready var console: Console = player_manager.console

@export var spell_texture: TextureRect
@export var cooldown_bar: TextureProgressBar

var resource: SpellResource
var timer: Timer


func _process(_delta):
	if timer != null:
		cooldown_bar.value = timer.time_left * 100
	if is_clickable:
		if PlayerManager.current_pa < resource.pa_cost:
			spell_texture.modulate = Color.ORANGE_RED
		else:
			spell_texture.modulate = Color.WHITE


func init(res: SpellResource, clickable: bool):
	global_position -= size/2
	name = res.name
	resource = res
	spell_texture.texture = res.texture
	if clickable:
		init_clickable(spell_texture)
		clicked.connect(do_action)
		if res.cooldown != 0:
			cooldown_bar.max_value = res.cooldown * 100
			cooldown_bar.value = 0
		else:
			cooldown_bar.visible = false
	else:
		is_clickable = false
		cooldown_bar.visible = false


func do_action(_self = null):
	if resource.pa_cost <= PlayerManager.current_pa and MonsterManager.selected_monster != null and is_clickable:
		if resource.pa_cost != 0:
			PlayerManager.current_pa = PlayerManager.current_pa - resource.pa_cost
			player_manager.pa_bar.update(PlayerManager.current_pa)
		cast()
		if resource.cooldown != 0:
			is_clickable = false
			timer = Timer.new()
			add_child(timer)
			timer.wait_time = resource.cooldown
			timer.timeout.connect(on_timeout)
			timer.start()


func on_timeout():
	remove_child(timer)
	timer.queue_free()
	timer = null
	is_clickable = true
	cooldown_bar.value = 0


func cast():
	var taken_damage = Callable(SpellsService, resource.spell_name).bind(MonsterManager.selected_monster).call()
	if taken_damage != null:
		console.log_info("%s lancé : %d dégât%s" % [resource.name, taken_damage, "" if taken_damage <= 1 else "s"])
	else:
		console.log_info("%s lancé" % resource.name)


static func instantiate(spell_res: SpellResource, parent: Control, clickable = true) -> Spell:
	var spell = FileLoader.get_packed_scene("spell/spell").instantiate()
	spell.init(spell_res, clickable)
	parent.add_child(spell)
	return spell
