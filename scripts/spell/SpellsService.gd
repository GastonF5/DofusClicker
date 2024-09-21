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
	var crit_amount = resource.per_crit + caster.get_critique() / 100.0
	var crit = randf_range(0, 1) <= crit_amount
	console.log_spell_cast(caster, resource, crit)
	for effect: EffectResource in resource.effects:
		effect.texture = resource.texture
		if count > max_count:
			perform_effect(caster, target, effect, crit, grade)
		else:
			# Un effet de type "random" a été appliqué
			if count == rand_count:
				perform_effect(caster, target, effect, crit, grade)
			count += 1
	console.output.add_separator()
	check_dying_entities([PlayerManager.player_entity] + MonsterManager.monsters)


static func perform_weapon(caster: Entity, target: Entity, resource: WeaponResource, weapon_name: String):
	var crit_amount = (resource._crit_proba + caster.get_critique()) / 100.0
	var crit = randf_range(0, 1) <= crit_amount
	console.log_weapon_cast(caster, weapon_name, crit)
	for effect: EffectResource in resource._hit_effects.map(func(he): return he.get_effect()):
		perform_effect(caster, target, effect, crit, 0)
	check_dying_entities([PlayerManager.player_entity] + MonsterManager.monsters)


static func perform_effect(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var method_name = "perform_%s" % EffectType.find_key(effect.type).to_lower()
	var callable = Callable(SpellsService, method_name)
	if effect.type == EffectResource.Type.SPECIAL:
		callable.bindv([caster, target, effect, crit, grade]).call()
	else:
		for tar in get_targets(caster, target, effect.target_type):
			callable.bindv([caster, tar, effect, crit, grade]).call()


static func perform_damage(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var element = effect.element
	var amount: int
	if element == Element.BEST:
		var amounts := {}
		for _elem in [Element.AIR, Element.EAU, Element.FEU, Element.TERRE]:
			amounts[_elem] = get_degats(caster, effect.get_amount(crit, grade), _elem)
		amount = amounts.values().max()
		element = amounts.find_key(amount)
	else:
		if element == Element.RANDOM:
			element = randi_range(0, 4) as Element
		amount = get_degats(caster, effect.get_amount(crit, grade), element)
	if crit:
		amount += caster.get_do_crit()
	amount = target.take_damage(amount, element)
	if effect.lifesteal:
		caster.take_damage(-round(amount / 2.0), element)


static func perform_soin(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var element = effect.element
	var amount := 0
	if effect.pourcentage or effect.level_pourcentage:
		amount = SpellsService.get_amount_or_pourcentage(caster, effect, crit, grade)
	else:
		if element == Element.BEST:
			element = caster.get_best_element()
		amount = get_soin(caster, effect.get_amount(crit, grade), element)
	target.take_damage(-amount, element)


static func perform_bonus(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var amount = effect.get_amount(crit, grade)
	if effect.pourcentage and effect.caracteristic != StatType.EROSION:
		amount = int(caster.get_carac_amount_for_type(effect.caracteristic) * (amount / 100.0))
	var carac
	match effect.caracteristic:
		StatType.EROSION:
			amount = amount / 100.0
			target.erosion += amount
		StatType.RES_DOMMAGES:
			target.taken_damage_rate -= amount
		StatType.PV:
			add_pv_to_entity(target, amount)
		_:
			carac = target.get_caracteristique_for_type(effect.caracteristic)
			carac.amount += amount
	console.log_bonus(target, amount, effect.get_caracteristic_label(), effect.time)
	if effect.time != 0:
		if target.is_player:
			Buff.instantiate(effect, amount, PlayerManager.player_entity)
		else:
			Buff.instantiate(effect, amount, target)
		var timer = create_timer(effect.time, "BonusTimer")
		await timer.timeout
		timer.queue_free()
		if is_instance_valid(timer) and GameManager.in_fight and is_instance_valid(target):
			match effect.caracteristic:
				StatType.EROSION:
					target.erosion -= amount
				StatType.RES_DOMMAGES:
					target.taken_damage_rate += amount
				StatType.PV:
					add_pv_to_entity(target, -amount)
				_:
					carac.amount -= amount


static func perform_retrait(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var amount = effect.get_amount(crit, grade)
	var carac_label = StatType.find_key(effect.caracteristic)
	var bar: CustomBar = target.get("%s_bar" % carac_label.to_lower())
	var ret_amount = caster.get_retrait(effect.caracteristic)
	var res_amount = target.get_resistance_retrait(effect.caracteristic)
	var ret_ratio = (ret_amount / float(res_amount)) if res_amount != 0 else 100.0
	var retrait_amount := 0
	for i in range(amount):
		var proba = 50 * ret_ratio * (bar.cval / float(bar.mval))
		proba = clamp(proba, 10, 90)
		if randf_range(0, 1) <= proba / 100.0:
			bar.cval -= 1
			retrait_amount += 1
	console.log_retrait(target, retrait_amount, effect.get_caracteristic_label())


static func perform_special(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var callable = Callable(SpellsService, effect.method_name)
	if callable:
		var params = [caster, target, effect, crit, grade] + effect.params
		callable.bindv(params).call()
	else:
		console.log_error("%s not found in SpellsService" % callable.get_method())


static func perform_bouclier(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var amount = SpellsService.get_amount_or_pourcentage(caster, effect, crit, grade)
	target.hp_bar.shield_val += amount
	console.log_shield(target, amount, effect.time)
	if effect.time != 0:
		var timer = create_timer(effect.time, "BonusTimer")
		await timer.timeout
		timer.queue_free()
		if is_instance_valid(timer) and GameManager.in_fight and is_instance_valid(target):
			target.hp_bar.shield_val -= amount


static func perform_random(_caster: Entity, _target: Entity, effect: EffectResource, _crit: bool, _grade: int):
	count = 1
	rand_count = randi_range(1, effect.nb_random_effects)
	max_count = effect.nb_random_effects

#region Spécial
static func dommages_pourcentage_pv_caster(caster: Entity, target: Entity, effect: EffectResource, _crit: bool, grade: int):
	var amount = caster.get_vitalite() * (effect.amounts[grade]._min / 100.0)
	for targ in get_targets(caster, target, effect.target_type):
		targ.take_damage(amount, effect.element)


static func sacrifice_pourcentage_pv(caster: Entity, _target: Entity, effect: EffectResource, _crit: bool, grade: int):
	var amount = caster.get_vitalite() * (effect.amounts[grade]._min / 100.0)
	if caster.is_player:
		PlayerManager.max_hp -= int(amount)
		await GameManager.end_fight
		PlayerManager.max_hp += int(amount)
	else:
		console.log_error("Target not supported")
#endregion


#region Sacrieur
static func punition(caster: Entity, target: Entity, effect: EffectResource, _crit: bool, _grade: int, _params: Array):
	var amount = int((PlayerManager.static_max_hp - PlayerManager.max_hp) * 0.3)
	var targets = get_targets(caster, target, effect.target_type)
	for tar in targets:
		tar.take_damage(amount, Element.NEUTRE)


static func furie(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int, _params: Array = []):
	var bonus_pm: int = get_targets(caster, target, EffectResource.TargetType.TARGET_NEIGHBORS).size()
	var new_effect = effect.duplicate(true)
	new_effect.amounts = effect.duplicate_amounts()
	new_effect.amounts[grade].add(bonus_pm)
	new_effect.texture = effect.texture
	perform_bonus(caster, caster, new_effect, crit, grade)
#endregion


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
	var targets = get_targets(caster, target, effect.target_type)
	for tar in targets:
		tar.take_damage(amount, effect.element)
#endregion


#region Iop
static var pugilat_adder := 0
static func pugilat(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var new_effect = effect.duplicate(true)
	new_effect.amounts = effect.duplicate_amounts()
	new_effect.amounts[grade].add(pugilat_adder)
	new_effect.type = EffectResource.Type.DAMAGE
	perform_effect(caster, target, new_effect, crit, grade)
	pugilat_adder += 18


static var fureur_adder := 0
static func fureur(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var new_effect = effect.duplicate(true)
	new_effect.amounts = effect.duplicate_amounts()
	new_effect.amounts[grade].add(fureur_adder)
	new_effect.type = EffectResource.Type.DAMAGE
	perform_effect(caster, target, new_effect, crit, grade)
	fureur_adder += 20


static var tempete_de_puissance_last_target: Entity = null
static func tempete_de_puissance(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	perform_damage(caster, target, effect, crit, grade)
	if tempete_de_puissance_last_target:
		perform_damage(caster, tempete_de_puissance_last_target, effect, crit, grade)


static var tumulte_adder := 0
static func tumulte(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var new_effect = effect.duplicate(true)
	new_effect.amounts = effect.duplicate_amounts()
	new_effect.amounts[grade].add(tumulte_adder)
	new_effect.type = EffectResource.Type.DAMAGE
	perform_effect(caster, target, new_effect, crit, grade)
	tumulte_adder += 20 * get_targets(caster, target, effect.target_type).size()


static func vertu(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	if target:
		perform_bonus(caster, caster, effect, crit, grade)
#endregion


#region Utilitaires
static func get_amount_or_pourcentage(caster: Entity, effect: EffectResource, crit: bool, grade: int):
	var amount = effect.get_amount(crit, grade)
	if effect.pourcentage:
		amount = int(caster.get_carac_amount_for_type(effect.caracteristic) * (effect.get_amount(crit, grade) / 100.0))
	if effect.level_pourcentage:
		amount = int(Globals.xp_bar.cur_lvl * (effect.get_amount(crit, grade) / 100.0))
	return amount


static func get_multiplicateur(caster: Entity, element: Element, soin: bool) -> float:
	var carac = caster.get_caracteristique_for_element(element)
	var caracteristique = StatsManager.get_carac_amount(carac)
	var puissance = caster.get_puissance() if !soin else 0
	return (puissance + caracteristique + 100) / 100.0


static func get_fixe(caster: Entity, element: Element) -> int:
	var dommages = caster.get_dommages()
	var do_elem_carac = caster.get_caracteristique_for_element(element, true)
	var dommages_elem = StatsManager.get_carac_amount(do_elem_carac)
	return dommages + dommages_elem


static func get_degats(caster: Entity, amount: int, element: Element) -> int:
	var multiplicateur = get_multiplicateur(caster, element, false)
	var fixe = get_fixe(caster, element)
	return max(multiplicateur * amount + fixe, 0)


static func get_soin(caster: Entity, amount: int, element: Element) -> int:
	var multiplicateur = get_multiplicateur(caster, element, true)
	var fixe = caster.get_soin()
	return max(multiplicateur * amount + fixe, 0)


static func get_neighbor_entities() -> Array[Entity]:
	var neighbor_entities: Array[Entity] = []
	for plate in PlayerManager.selected_plate.get_neighbor_plates():
		if plate._entity and is_instance_valid(plate._entity):
			neighbor_entities.append(plate._entity)
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
	GameManager.end_fight.connect(timer.queue_free)
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


static func add_pv_to_entity(entity: Entity, amount: int):
	if entity.is_player:
		PlayerManager.max_hp += amount
	else:
		entity.hp_bar.mval += amount


static func on_fight_end():
	SpellsService.pugilat_adder = 0
	SpellsService.fureur_adder = 0
	SpellsService.tempete_de_puissance_last_target = null
#endregion
