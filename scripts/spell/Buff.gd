class_name Buff
extends PanelContainer

static func instantiate(effect: EffectResource, amount: int, parent: Entity, caster: Entity) -> Buff:
	var buff = FileLoader.get_packed_scene("spell/buff").instantiate()
	buff._parent = parent
	buff._caster = caster
	buff._effect = effect
	buff._amount = amount
	buff.init()
	if parent.is_player:
		Globals.buffs_container.add_child(buff)
	elif Entity.is_monster(parent):
		parent.buffs_container.add_child(buff)
	parent.buffs.append(buff)
	return buff


static func is_poison_carac(buff: Buff) -> bool:
	return buff._effect.is_poison_carac


const POISON_TIME := 5

@export var spell_texture: TextureRect
@export var pb: ProgressBar

var _parent: Entity
var _caster: Entity
var _timer: Timer
var _effect: EffectResource
var _amount: int

signal annuler


func init():
	spell_texture.texture = _effect.texture
	if _effect.resource_name.is_empty():
		Globals.console.log_error("L'effet n'a pas de nom")
	else:
		name = _effect.resource_name
	pb.max_value = float(_effect.time)
	_timer = SpellsService.create_timer(_effect.time, "Buff")
	mouse_entered.connect(PlayerManager.buff_description.init_buff.bindv([_effect, _amount, _timer]))
	mouse_exited.connect(PlayerManager.buff_description.hide_description)
	_timer.timeout.connect(delete.bind(_effect, _amount))
	GameManager.end_fight.connect(delete.bind(_effect, _amount))
	annuler.connect(delete.bind(_effect, _amount))


func _process(_delta):
	if is_instance_valid(_timer):
		pb.value = _timer.time_left
		do_poison_effect()


func do_poison_effect():
	if _effect.type == EffectResource.Type.POISON and !_effect.is_poison_carac:
		var time = _effect.time - _timer.time_left
		if (int(time) - time) == 0.0 and int(time) % POISON_TIME == 0:
			var amount = SpellsService.get_degats(_caster, _amount, _effect.element)
			_parent.take_damage(amount, _effect.element)
			Globals.console.log_effects([[EffectResource.Type.DAMAGE, _parent, amount, _effect.element, _parent.dying]])
			Globals.console.output.add_separator()


func delete(effect: EffectResource, amount: int):
	if effect.type == EffectResource.Type.BONUS:
		SpellsService.annuler_bonus(self, _parent, effect, amount)
	if _parent:
		_parent.buffs.erase(self)
	if get_parent():
		get_parent().remove_child(self)
	queue_free()
