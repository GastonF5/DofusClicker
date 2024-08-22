class_name Buff
extends PanelContainer


@export var spell_texture: TextureRect
@export var pb: ProgressBar

var timer: Timer


func init(effect: EffectResource, amount: int):
	spell_texture.texture = effect.texture
	pb.max_value = float(effect.time)
	timer = SpellsService.create_timer(effect.time, "Buff")
	mouse_entered.connect(PlayerManager.buff_description.init_buff.bindv([effect, amount, timer]))
	mouse_exited.connect(PlayerManager.buff_description.hide_description)
	timer.timeout.connect(delete)
	GameManager.end_fight.connect(delete)


func _process(_delta):
	if is_instance_valid(timer):
		pb.value = timer.time_left


static func instantiate(effect: EffectResource, amount: int, parent: Node) -> Buff:
	var buff = FileLoader.get_packed_scene("spell/buff").instantiate()
	buff.init(effect, amount)
	parent.add_child(buff)
	return buff


func delete():
	get_parent().remove_child(self)
	queue_free()
