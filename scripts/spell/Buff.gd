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
var _longer_timer: Timer:
	set(val):
		if _longer_timer:
			_longer_timer.timeout.disconnect(delete_all)
		_longer_timer = val
		if _longer_timer:
			_longer_timer.timeout.connect(delete_all)

# Dictionnaire dont les values sont : [timer, count]
var _timers := {}
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
		timer.timeout.connect(annuler_bonus.bind(timer.name))
		_timers[timer.name] = [timer, effect.nb_hits]
		if effect.time == max_time:
			_longer_timer = timer
	
	# Gestion de l'affichage de la description du buff
	mouse_entered.connect(PlayerManager.buff_description.init_buff.bindv([spell_res, self]))
	mouse_exited.connect(PlayerManager.buff_description.hide_description)
	
	GameManager.end_fight.connect(delete_all)
	annuler.connect(delete_all)


func _process(_delta):
	if is_instance_valid(_longer_timer):
		pb.value = _longer_timer.time_left


func do_poison_effect(effect_amount: Array, count: int):
	var effect = effect_amount[0]
	var amount = effect_amount[1]
	if !effect.is_poison_carac and !_caster.dying:
		var degats = SpellsService.get_degats(_caster, amount, effect.element)
		_parent.take_damage(degats, effect.element)
		Globals.console.log_effects([[EffectResource.Type.DAMAGE, _parent, degats, effect.element, _parent.dying, true]])
		Globals.console.output.add_separator()
	if count - 1 >= 1 and !_caster.dying:
		var timer = SpellsService.create_timer(effect.time, effect.resource_name, self)
		timer.timeout.connect(annuler_bonus.bind(timer.name))
		if _longer_timer == null:
			pb.max_value = float(effect.time)
			_longer_timer = timer
		_timers[timer.name] = [timer, count - 1]


func annuler_bonus(timer_name: String, check_empty := true):
	var effect = _effects[timer_name][0]
	var amount = _effects[timer_name][1]
	var timer = _timers[timer_name][0]
	var count = _timers[timer_name][1]
	if _longer_timer == timer:
		_longer_timer = null
	remove_child(timer)
	timer.queue_free()
	if effect.type in [EffectType.BONUS, EffectType.INVISIBILITE, EffectType.AVEUGLE]:
		SpellsService.annuler_bonus(self, _parent, effect, amount)
	if effect.type == EffectType.POISON:
		do_poison_effect(_effects[timer_name], count)
	if check_empty and _timers.is_empty():
		delete_all(false)


func delete_all(annule_bonus := true):
	if annule_bonus:
		for timer_name in _timers:
			annuler_bonus(timer_name, false)
	if _parent:
		_parent.buffs.erase(self)
	if get_parent():
		get_parent().remove_child(self)
	queue_free()
