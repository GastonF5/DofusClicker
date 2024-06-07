class_name SpellsService


const StatType = Caracteristique.Type
const Element = Caracteristique.Element
const EffectType = EffectResource.Type
const TargetType = EffectResource.TargetType

static var console: Console
static var tnode: Node
static var player_entity: Entity


static var count := 1
static var max_count := 0
static var rand_count := 0
static func perform_spell(caster: Entity, target: Entity, resource: SpellResource, grade: int):
	var crit_amount = resource.per_crit
	var caster_crit = caster.get_caracacteristique_for_type(StatType.CRITIQUE)
	if caster_crit: crit_amount += caster_crit.amount / 100.0
	var crit = randf_range(0, 1) <= crit_amount
	for effect: EffectResource in resource.effects:
		if count > max_count:
			perform_effect(caster, get_targets(caster, target, effect.target_type), effect, crit, grade)
		else:
			# Un effet de type "random" a été appliqué
			if count == rand_count:
				perform_effect(caster, get_targets(caster, target, effect.target_type), effect, crit, grade)
			count += 1
	check_dying_entities([caster] + MonsterManager.monsters)


static func perform_effect(caster: Entity, targets: Array[Entity], effect: EffectResource, crit: bool, grade: int):
	var method_name = "perform_%s" % EffectType.find_key(effect.type).to_lower()
	var callable = Callable(SpellsService, method_name)
	for target in targets:
		callable.callv([caster, target, effect, crit, grade])


static func perform_damage(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var amount = effect.get_amount(crit, grade)
	if crit:
		var do_crit = caster.get_caracacteristique_for_type(StatType.DO_CRITIQUES)
		if do_crit:
			amount += do_crit.amount
	amount = target.take_damage(amount, effect.element)
	if effect.lifesteal:
		caster.take_damage(-amount, effect.element)


static func perform_bonus(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var amount = effect.get_amount(crit, grade)
	match effect.caracteristic:
		StatType.EROSION:
			amount = amount / 100.0
			target.erosion += amount
			if effect.time != 0:
				var timer = create_timer(effect.time)
				await timer.timeout
				timer.queue_free()
				if is_instance_valid(target):
					target.erosion -= amount
		_:
			var carac = target.get_caracacteristique_for_type(effect.caracteristic)
			carac.amount += amount
			if effect.time != 0:
				var timer = create_timer(effect.time)
				await timer.timeout
				timer.queue_free()
				if is_instance_valid(target):
					carac.amount -= amount


static func perform_retrait(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var amount = effect.get_amount(crit, grade)
	var carac_label = StatType.find_key(effect.caracteristic)
	var bar: CustomBar = target.get("%s_bar" % carac_label.to_lower())
	var ret_carac = caster.get_caracacteristique_for_type(StatType.get("RET_%s" % carac_label))
	var res_carac = target.get_caracacteristique_for_type(StatType.get("RES_%s" % carac_label))
	var ret_ratio = (ret_carac.amount / res_carac.amount) if res_carac.amount != 0 else 100
	for i in range(amount):
		var proba = 50 * ret_ratio * (bar.cval / bar.mval)
		proba = clamp(proba, 10, 90)
		if randf_range(0, 1) <= proba / 100.0:
			bar.cval -= 1


static func perform_special(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var callable = Callable(SpellsService, effect.method_name)
	print(callable.get_method())
	if callable:
		callable.callv([caster, target, effect, crit, grade, effect.params])
	else:
		console.log_error("%s not found in SpellsService")


static func perform_random(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	count = 1
	rand_count = randi_range(1, effect.nb_random_effects)
	max_count = effect.nb_random_effects


#region Ecaflip
static func chance_ecaflip(_caster: Entity, _target: Entity, _effect: EffectResource, _crit: bool, _grade: int, _params: Array):
	PlayerManager.taken_damage_rate = 50
	var timer = create_timer(5)
	await timer.timeout
	timer.queue_free()
	PlayerManager.taken_damage_rate = 200
	timer = create_timer(3)
	await timer.timeout
	timer.queue_free()
	PlayerManager.taken_damage_rate = 100

static var face = false
static func pile_face(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int, _params: Array):
	var _min = effect.crit_min_amounts[grade] if crit else effect.min_amounts[grade]
	var _max = effect.crit_max_amounts[grade] if crit else effect.max_amounts[grade]
	if face:
		_min -= 6 if crit else 5
		_max -= 6 if crit else 5
	face = !face
	target.take_damage(randi_range(_min, _max), effect.element)
#endregion


#region Monstres
#id 202
static func morsure_du_bouftou(crit: bool):
	var _min := 23 if !crit else 34
	var _max := 33 if !crit else 50
	player_entity.take_damage(randi_range(_min, _max), Element.NEUTRE)


static func fureur_du_bouftou(grade: int):
	var monsters = MonsterManager.monsters
	var random_monster: Entity = monsters[randi_range(0, monsters.size() - 1)]
	var dommages = random_monster.get_caracacteristique_for_type(StatType.DOMMAGES)
	var value: int
	match grade:
		1: value = randi_range(6, 15)
		2: value = randi_range(8, 17)
		3: value = randi_range(10, 19)
		4: value = randi_range(12, 21)
		5: value = randi_range(14, 25)
	random_monster.set_caracteristique_amount(StatType.DOMMAGES, dommages + value)
	var timer = create_timer(10)
	await timer.timeout
	timer.queue_free()
	random_monster.set_caracteristique_amount(StatType.DOMMAGES, dommages)
#endregion


#region Utilitaires
static func get_multiplicateur(type: StatType) -> float:
	var carac = StatsManager.get_caracteristique_for_type(type)
	var caracteristique = 0 if !carac else carac.amount
	var pui_carac = StatsManager.get_caracteristique_for_type(StatType.PUISSANCE)
	var puissance = 0 if !pui_carac else pui_carac.amount
	return (puissance + caracteristique + 100) / 100.0


static func get_fixe(_type: StatType) -> int:
	return 0


static func get_degats(min_damage: int, max_damage: int, type: StatType) -> int:
	var multiplicateur = get_multiplicateur(type)
	var fixe = get_fixe(type)
	return multiplicateur * randi_range(min_damage, max_damage) + fixe


static func get_neighbor_entities():
	var neighbor_entities = []
	for plate in PlayerManager.selected_plate.get_neighbors():
		if plate.entity:
			neighbor_entities.append(plate.entity)
	return neighbor_entities


static func check_dying_entities(entities: Array):
	for entity in entities:
		if entity.dying:
			entity.die()
			entity.dying = false


static func create_timer(time: float, name: String = "Timer"):
	var timer = Timer.new()
	timer.name = name
	timer.wait_time = time
	timer.autostart = true
	tnode.add_child(timer)
	return timer


static func get_targets(caster: Entity, target: Entity, type: EffectResource.TargetType) -> Array[Entity]:
	var targets: Array[Entity] = []
	match type:
		TargetType.CASTER: targets.append(caster)
		TargetType.TARGET:
			if target: targets.append(target)
		TargetType.TARGET_NEIGHBORS:
			if target: targets.append(target)
			targets += get_neighbor_entities()
		TargetType.NEIGHBORS:
			targets += get_neighbor_entities()
		TargetType.ALL_MONSTERS:
			targets += MonsterManager.monsters
	return targets
#endregion
