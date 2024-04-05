class_name Spell
extends ClickableControl

@export var spell_texture: TextureRect
@export var cooldown_bar: TextureProgressBar

var resource: SpellResource
var timer: Timer

signal cast


func _process(_delta):
	if timer != null:
		cooldown_bar.value = timer.time_left * 100


func init(res: SpellResource):
	name = res.name
	resource = res
	spell_texture.texture = res.texture
	cooldown_bar.max_value = res.cooldown * 100
	cooldown_bar.value = 0
	init_clickable(spell_texture)
	clicked.connect(do_action)


func do_action(_self):
	if GameManager.selected_monster != null and is_clickable:
		cast.emit(resource)
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
