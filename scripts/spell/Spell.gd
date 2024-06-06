class_name Spell
extends ClickableControl

var player_manager: PlayerManager

@export var spell_texture: TextureRect
@export var cooldown_bar: TextureProgressBar

var resource: SpellResource
var timer: Timer


func _process(_delta):
	if timer != null:
		cooldown_bar.value = timer.time_left * 100
	if is_clickable and player_manager:
		if player_manager.pa_bar.cval < resource.pa_cost:
			spell_texture.modulate = Color.ORANGE_RED
		else:
			spell_texture.modulate = Color.WHITE


func init(res: SpellResource, clickable: bool):
	player_manager = get_tree().current_scene.get_node("%PlayerManager")
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
	if resource.pa_cost <= player_manager.pa_bar.cval and PlayerManager.selected_plate and is_clickable:
		if resource.pa_cost != 0:
			player_manager.pa_bar.cval -= resource.pa_cost
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
	SpellsService.perform_spell(player_manager.player_entity, PlayerManager.selected_plate.get_entity(), resource, 0)


static func instantiate(spell_res: SpellResource, parent: Control, clickable = true) -> Spell:
	var spell = FileLoader.get_packed_scene("spell/spell").instantiate()
	parent.add_child(spell)
	spell.init(spell_res, clickable)
	return spell
