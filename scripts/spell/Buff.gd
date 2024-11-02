class_name Buff
extends PanelContainer

const EffectType = EffectResource.Type

static func instantiate(spell_res: SpellResource, effects_amounts: Dictionary, parent: Entity, caster: Entity, grade: int) -> Buff:
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


@export var spell_texture: TextureRect
@export var pb: ProgressBar

var _parent: Entity
var _caster: Entity
var _longer_timer: Timer
var _grade: int

# Dictionnaire dont les values sont : [effect, amount, timer, count]
var _effects := {}

signal annuler


# region Utilitaires
func get_effect(effect_name: String) -> EffectResource:
	return _effects[effect_name][0]

func get_amount(effect_name: String) -> int:
	return _effects[effect_name][1]

func get_timer(effect_name: String) -> Timer:
	return _effects[effect_name][2]

func set_timer(effect_name: String, timer: Timer) -> void:
	if _effects.has(effect_name):
		_effects[effect_name][2] = timer

func delete_timer(effect_name: String) -> void:
	var timer = get_timer(effect_name)
	if timer.get_parent():
		timer.get_parent().remove_child(timer)
	timer.queue_free()

func get_timers() -> Array[Timer]:
	var timers: Array[Timer] = []
	timers.assign(_effects.keys().map(get_timer))
	return timers

func get_count(effect_name: String) -> int:
	return _effects[effect_name][3]

func set_count(effect_name: String, count: int) -> void:
	if _effects.has(effect_name):
		_effects[effect_name][3] = count

func get_effects() -> Array[EffectResource]:
	var effects: Array[EffectResource] = []
	effects.assign(_effects.keys().map(get_effect))
	return effects
# endregion


func get_poison_carac_effects() -> Array[EffectResource]:
	var buffs: Array[EffectResource] = []
	buffs.assign(get_effects().filter(func(e): return e.is_poison_carac))
	return buffs


func init(spell_res: SpellResource):
	var effects = _effects.keys().map(get_effect)
	
	spell_texture.texture = spell_res.texture
	name = spell_res.name
	var max_time = effects.reduce(func(accum, e): return max(accum, e.time), 0)
	pb.max_value = float(max_time)
	
	# Pour chaque effet, on crée un timer et on lui donne le nombre de fois qu'il va être joué
	for effect in effects:
		if effect.resource_name == "":
			log.error("L'effet n'a pas de nom pour le sort %d" % spell_res.id)
		var effect_name = effect.resource_name
		var timer = SpellsService.create_timer(effect.time, effect_name, self)
		timer.timeout.connect(end_of_effect.bind(effect_name))
		_effects[effect_name] += [timer, effect.nb_hits]
	
	set_longer_timer()
	
	# Gestion de l'affichage de la description du buff
	mouse_entered.connect(PlayerManager.buff_description.init_buff.bindv([spell_res, self]))
	mouse_exited.connect(PlayerManager.buff_description.hide_description)
	
	GameManager.end_fight.connect(delete_all)
	annuler.connect(delete_all)



func set_longer_timer():
	var max_time = get_effects().reduce(func(accum, e): return max(accum, e.time), 0)
	pb.max_value = float(max_time)
	for effect_name in _effects:
		if get_effect(effect_name).time == max_time:
			_longer_timer = get_timer(effect_name)


func _process(_delta):
	if _longer_timer and is_instance_valid(_longer_timer):
		pb.value = _longer_timer.time_left
	else:
		pb.value = 0


func end_of_effect(effect_name: String, can_renouveler := true):
	cancel_effect(effect_name)
	var count = _effects[effect_name][3]
	if can_renouveler and count > 1:
		renouveler_effect(effect_name)
	else:
		delete_effect(effect_name)
	if _effects.is_empty():
		delete_buff()


func cancel_effect(effect_name: String):
	var effect = get_effect(effect_name)
	var amount = get_amount(effect_name)
	if effect.type in [EffectType.BONUS, EffectType.INVISIBILITE, EffectType.AVEUGLE]:
		SpellsService.annuler_bonus(self, _parent, effect, amount)
	elif effect.type == EffectType.POISON and is_instance_valid(_caster):
		SpellsService.do_poison_effect(_caster, _parent, effect, amount)


func delete_effect(effect_name: String):
	delete_timer(effect_name)
	_effects.erase(effect_name)
	set_longer_timer()


func renouveler_effect(effect_name: String):
	var new_timer = SpellsService.create_timer(get_effect(effect_name).time, effect_name, self)
	new_timer.timeout.connect(end_of_effect.bind(effect_name))
	set_timer(effect_name, new_timer)
	set_count(effect_name, get_count(effect_name) - 1)


func delete_all():
	for effect_name in _effects:
		cancel_effect(effect_name)
		delete_effect(effect_name)
	delete_buff()


func delete_buff():
	if _parent:
		_parent.buffs.erase(self)
	if get_parent():
		get_parent().remove_child(self)
	queue_free()
