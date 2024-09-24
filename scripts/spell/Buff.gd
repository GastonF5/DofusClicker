class_name Buff
extends PanelContainer


@export var spell_texture: TextureRect
@export var pb: ProgressBar

var _parent: Entity
var _timer: Timer


func init(effect: EffectResource, amount: int):
	spell_texture.texture = effect.texture
	if effect.resource_name.is_empty():
		Globals.console.log_error("L'effet n'a pas de nom")
	else:
		name = effect.resource_name
	pb.max_value = float(effect.time)
	_timer = SpellsService.create_timer(effect.time, "Buff")
	mouse_entered.connect(PlayerManager.buff_description.init_buff.bindv([effect, amount, _timer]))
	mouse_exited.connect(PlayerManager.buff_description.hide_description)
	_timer.timeout.connect(delete)
	GameManager.end_fight.connect(delete)


func _process(_delta):
	if is_instance_valid(_timer):
		pb.value = _timer.time_left


static func instantiate(effect: EffectResource, amount: int, parent: Entity) -> Buff:
	var buff = FileLoader.get_packed_scene("spell/buff").instantiate()
	buff._parent = parent
	buff.init(effect, amount)
	if parent.is_player:
		Globals.buffs_container.add_child(buff)
	elif Entity.is_monster(parent):
		parent.buffs_container.add_child(buff)
	parent.buffs.append(buff)
	return buff


func delete():
	if _parent:
		_parent.buffs.erase(self)
	if get_parent():
		get_parent().remove_child(self)
	queue_free()
