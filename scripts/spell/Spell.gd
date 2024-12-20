class_name Spell
extends DraggableControl

@export var spell_texture: TextureRect
@export var cooldown_bar: ProgressBar

var resource: SpellResource
var timer: Timer


func _process(delta):
	if GameManager.in_fight:
		if timer and is_instance_valid(timer):
			cooldown_bar.value = timer.time_left * 100
		if draggable:
			if PlayerManager.pa_bar.cval < resource.pa_cost:
				spell_texture.modulate = Color.ORANGE_RED
			else:
				spell_texture.modulate = Color.WHITE
	else:
		super(delta)
	if draggable and get_parent().is_in_group("spell_slot") and size != get_parent().size:
		resize_spell()


func change_parent():
	super()
	drop_parent.add_child(self)


func resize_spell():
	size = get_parent().size
	position = Vector2.ZERO


func init(res: SpellResource, _draggable: bool):
	draggable = _draggable
	name = res.name
	resource = res
	spell_texture.texture = res.texture
	if _draggable:
		if res.cooldown != 0:
			cooldown_bar.max_value = res.cooldown * 100
		else:
			cooldown_bar.visible = false
	else:
		cooldown_bar.visible = false
	reset()


func do_action():
	var player_entity = PlayerManager.player_entity
	var selected_plate = PlayerManager.selected_plate
	if resource.pa_cost <= PlayerManager.pa_bar.cval and selected_plate and !timer:
		if resource.pa_cost != 0:
			PlayerManager.pa_bar.cval -= resource.pa_cost
		player_entity.apply_carac_poison(resource.pa_cost, Caracteristique.Type.PA)
		SpellsService.perform_spell(player_entity, selected_plate, resource, 0)
		if resource.cooldown != 0:
			timer = SpellsService.create_timer(resource.cooldown, "%sTimer" % resource.name.to_pascal_case(), self)
			timer.timeout.connect(delete_timer)


static func instantiate(spell_res: SpellResource, parent: Control, clickable = true) -> Spell:
	var spell = FileLoader.get_packed_scene("spell/spell").instantiate()
	spell.init(spell_res, clickable)
	parent.add_child(spell)
	return spell


func reset():
	cooldown_bar.value = 0
	spell_texture.modulate = Color.WHITE
	delete_timer()


func delete_timer():
	if timer and is_instance_valid(timer):
		timer.get_parent().remove_child(timer)
		timer.queue_free()
		timer = null
