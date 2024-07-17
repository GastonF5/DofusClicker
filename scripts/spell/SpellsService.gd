class_name SpellsService


const StatType = Caracteristique.Type
const Element = Caracteristique.Element
const EffectType = EffectResource.Type
const TargetType = EffectResource.TargetType

static var console: Console
static var tnode: Node


static var count := 1
static var max_count := 0
static var rand_count := 0
static func perform_spell(caster: Entity, target: Entity, resource: SpellResource, grade: int):
	var crit_amount = resource.per_crit
	var caster_crit = caster.get_caracacteristique_for_type(StatType.CRITIQUE)
	if caster_crit: crit_amount += caster_crit.amount / 100.0
	var crit = randf_range(0, 1) <= crit_amount
	console.log_spell_cast(caster, resource, crit)
	for effect: EffectResource in resource.effects:
		if count > max_count:
			perform_effect(caster, get_targets(caster, target, effect.target_type), effect, crit, grade)
		else:
			# Un effet de type "random" a été appliqué
			if count == rand_count:
				perform_effect(caster, get_targets(caster, target, effect.target_type), effect, crit, grade)
			count += 1
	check_dying_entities([PlayerManager.player_entity] + MonsterManager.monsters)


static func perform_weapon_effects(caster: Entity, target: Entity, resource: EquipmentResource, grade: int):
	if resource.weapon_type == EquipmentResource.WeaponType.NONE:
		push_error("La ressource n'est pas une arme")
		return
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
		caster.take_damage(-round(amount / 2.0), effect.element)


static func perform_soin(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var amount = effect.get_amount(crit, grade)
	target.take_damage(-amount, effect.element)


static func perform_bonus(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var amount = effect.get_amount(crit, grade)
	var carac
	match effect.caracteristic:
		StatType.EROSION:
			amount = amount / 100.0
			target.erosion += amount
		StatType.RES_DOMMAGES:
			target.taken_damage_rate -= amount
		_:
			carac = target.get_caracacteristique_for_type(effect.caracteristic)
			carac.amount += amount
	console.log_bonus(target, amount, effect.get_caracteristic_label(), effect.time)
	if effect.time != 0:
		var timer = create_timer(effect.time, "BonusTimer")
		await timer.timeout
		timer.queue_free()
		if is_instance_valid(timer) and GameManager.in_fight and is_instance_valid(target):
			match effect.caracteristic:
				StatType.EROSION:
					target.erosion -= amount
				StatType.RES_DOMMAGES:
					target.taken_damage_rate += amount
				_:
					carac.amount -= amount



static func perform_retrait(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var amount = effect.get_amount(crit, grade)
	var carac_label = StatType.find_key(effect.caracteristic)
	var bar: CustomBar = target.get("%s_bar" % carac_label.to_lower())
	var ret_carac = caster.get_caracacteristique_for_type(StatType.get("RET_%s" % carac_label))
	var res_carac = target.get_caracacteristique_for_type(StatType.get("RES_%s" % carac_label))
	var ret_ratio = (ret_carac.amount / res_carac.amount) if res_carac.amount != 0 else 100
	var retrait_amount := 0
	for i in range(amount):
		var proba = 50 * ret_ratio * (bar.cval / bar.mval)
		proba = clamp(proba, 10, 90)
		if randf_range(0, 1) <= proba / 100.0:
			bar.cval -= 1
			retrait_amount += 1
	console.log_retrait(target, retrait_amount, effect.get_caracteristic_label())


static func perform_special(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var callable = Callable(SpellsService, effect.method_name)
	if callable:
		callable.callv([caster, target, effect, crit, grade, effect.params])
	else:
		console.log_error("%s not found in SpellsService")


static func perform_random(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	count = 1
	rand_count = randi_range(1, effect.nb_random_effects)
	max_count = effect.nb_random_effects


#region Ecaflip
static func chance_ecaflip(caster: Entity, _target: Entity, _effect: EffectResource, _crit: bool, _grade: int, _params: Array):
	caster.taken_damage_rate = 50
	var timer = create_timer(5, "ChanceEcaflipTimer")
	await timer.timeout
	timer.queue_free()
	caster.taken_damage_rate = 200
	timer = create_timer(3, "ChanceEcaflipTimer")
	await timer.timeout
	timer.queue_free()
	caster.taken_damage_rate = 100

static var face = false
static func pile_face(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int, _params: Array):
	var amount = effect.get_amount(crit, grade)
	if !crit and face:
		amount -= 5
	face = !face
	target.take_damage(amount, effect.element)
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


static func get_neighbor_entities() -> Array[Entity]:
	var neighbor_entities: Array[Entity] = []
	for plate in PlayerManager.selected_plate.get_neighbor_plates():
		if plate.entity and is_instance_valid(plate.entity):
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
	var monsters = MonsterManager.monsters
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
			targets += monsters
		TargetType.RANDOM_MONSTER:
			randomize()
			targets.append(monsters[randi_range(0, monsters.size() - 1)])
	return targets
#endregion
