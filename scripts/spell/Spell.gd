class_name Spell
extends DraggableControl

var player_manager: PlayerManager

@export var spell_texture: TextureRect
@export var cooldown_bar: ProgressBar

var resource: SpellResource
var timer: Timer


func init_player_manager():
	if !player_manager:
		player_manager = get_tree().current_scene.get_node("%PlayerManager")


func _process(delta):
	super(delta)
	if timer and is_instance_valid(timer):
		cooldown_bar.value = timer.time_left * 100
	if player_manager and draggable:
		if player_manager.pa_bar.cval < resource.pa_cost:
			spell_texture.modulate = Color.ORANGE_RED
		else:
			spell_texture.modulate = Color.WHITE


func _enter_tree():
	super()
	init_player_manager()


func change_parent():
	super()
	drop_parent.add_child(self)


func init(res: SpellResource, _draggable: bool):
	draggable = _draggable
	name = res.name
	resource = res
	spell_texture.texture = res.texture
	if _draggable:
		if res.cooldown != 0:
			cooldown_bar.max_value = res.cooldown * 100
			cooldown_bar.value = 0
		else:
			cooldown_bar.visible = false
	else:
		cooldown_bar.visible = false


func do_action():
	if resource.pa_cost <= player_manager.pa_bar.cval and PlayerManager.selected_plate and !timer:
		if resource.pa_cost != 0:
			player_manager.pa_bar.cval -= resource.pa_cost
		cast()
		if resource.cooldown != 0:
			timer = SpellsService.create_timer(resource.cooldown, "%sTimer" % resource.name.to_pascal_case())
			timer.timeout.connect(on_timeout)


func on_timeout():
	timer.get_parent().remove_child(timer)
	timer.queue_free()
	timer = null
	cooldown_bar.value = 0


func cast():
	SpellsService.perform_spell(PlayerManager.player_entity, PlayerManager.selected_plate.get_entity(), resource, 0)


static func instantiate(spell_res: SpellResource, parent: Control, clickable = true) -> Spell:
	var spell = FileLoader.get_packed_scene("spell/spell").instantiate()
	spell.init(spell_res, clickable)
	parent.add_child(spell)
	return spell


func reset():
	cooldown_bar.value = cooldown_bar.min_value
