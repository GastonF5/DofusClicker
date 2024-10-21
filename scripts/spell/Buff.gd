class_name Buff
extends PanelContainer

const EffectType = EffectResource.Type

static func instantiate(spell_res: SpellResource, effects_amounts: Dictionary, parent: Entity, caster: Entity) -> Buff:
	var buff = FileLoader.get_packed_scene("spell/buff").instantiate()
	buff._parent = parent
	buff._caster = caster
	buff._effects = effects_amounts
	buff.init(spell_res)
	if parent.is_player:
		Globals.buffs_container.add_child(buff)
	elif Entity.is_monster(parent):
		parent.buffs_container.add_child(buff)
	parent.buffs.append(buff)
	return buff


static func get_poison_carac_effects(buff: Buff) -> Array:
	return buff._effects.values().filter(func(e): return e[0].is_poison_carac).map(func(e): return e + [buff._caster])


const POISON_TIME := 5

@export var spell_texture: TextureRect
@export var pb: ProgressBar

var _parent: Entity
var _caster: Entity
var _longer_timer: Timer

# Dictionnaire dont les values sont : timer
var _timers: Array[Timer] = []
# Dictionnaire dont les values sont : [effect, amount]
var _effects := {}

signal annuler


func init(spell_res: SpellResource):
	var effects = _effects.values().map(func(eff_am): return eff_am[0])
	
	spell_texture.texture = spell_res.texture
	name = spell_res.name
	var max_time = effects.reduce(func(accum, e): return max(accum, e.time), 0)
	pb.max_value = float(max_time)
	
	# Construction du dictionnaire des timers
	for effect in effects:
		if effect.resource_name == "":
			log.error("L'effet n'a pas de nom pour le sort %d" % spell_res.id)
		var timer = SpellsService.create_timer(effect.time, effect.resource_name, self)
		_timers.append(timer)
		if effect.time == max_time:
			_longer_timer = timer
	
	# Gestion de l'affichage de la description du buff
	mouse_entered.connect(PlayerManager.buff_description.init_buff.bindv([spell_res, _effects, _timers]))
	mouse_exited.connect(PlayerManager.buff_description.hide_description)
	
	# Gestion du timeout des timers
	for timer in _timers:
		timer.timeout.connect(annuler_bonus.bind(timer))
	GameManager.end_fight.connect(delete)
	annuler.connect(delete)


func _process(_delta):
	if is_instance_valid(_longer_timer):
		pb.value = _longer_timer.time_left
	for timer in _timers:
		if is_instance_valid(timer):
			do_poison_effect(_effects[timer.name], timer)


func do_poison_effect(effect_amount: Array, timer: Timer):
	var effect = effect_amount[0]
	var amount = effect_amount[1]
	if effect.type == EffectResource.Type.POISON and !effect.is_poison_carac:
		var time = effect.time - timer.time_left
		if (int(time) - time) == 0.0 and int(time) % POISON_TIME == 0:
			var degats = SpellsService.get_degats(_caster, amount, effect.element)
			_parent.take_damage(degats, effect.element)
			Globals.console.log_effects([[EffectResource.Type.DAMAGE, _parent, degats, effect.element, _parent.dying, true]])
			Globals.console.output.add_separator()


func annuler_bonus(timer: Timer):
	var effect = _effects[timer.name][0]
	var amount = _effects[timer.name][1]
	_timers.erase(timer)
	if effect.type in [EffectType.BONUS, EffectType.INVISIBILITE, EffectType.AVEUGLE]:
		SpellsService.annuler_bonus(self, _parent, effect, amount)
	if _timers.is_empty():
		delete()


func delete():
	if !_timers.is_empty():
		for timer in _timers:
			annuler_bonus(timer)
	else:
		if _parent:
			_parent.buffs.erase(self)
		if get_parent():
			get_parent().remove_child(self)
		queue_free()
