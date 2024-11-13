class_name SpellsService


const StatType = Caracteristique.Type
const Element = Caracteristique.Element
const EffectType = EffectResource.Type
const TargetType = EffectResource.TargetType
const Direction = EffectResource.Direction
const Zone = EffectResource.Zone

static var console: Console
static var tnode: Node


static var logs_before = []
static var effects_log = []
static var logs_after = []
static var effects_buff := {}
static func perform_spell(caster: Entity, plate: EntityContainer, resource: SpellResource, grade: int):
	var crit_amount = resource.per_crit + caster.get_critique() / 100.0
	var crit = randf_range(0, 1) <= crit_amount
	for effect: EffectResource in resource.effects:
		perform_effect(caster, plate, effect, crit, grade)
	# instantier buff
	if !effects_buff.is_empty():
		for target in effects_buff.keys():
			Buff.instantiate(resource, effects_buff[target], target, caster, grade)
	effects_buff.clear()
	# console log
	console.log_spell_cast(caster, resource, crit)
	console.log_effects(logs_before)
	console.log_effects(effects_log)
	console.log_effects(logs_after)
	console.output.add_separator()
	logs_before.clear()
	effects_log.clear()
	logs_after.clear()
	check_dying_entities([PlayerManager.player_entity] + MonsterManager.monsters + MonsterManager.invocs)


static func perform_weapon(caster: Entity, plate: EntityContainer, resource: WeaponResource, weapon_name: String):
	var crit_amount = (resource._crit_proba + caster.get_critique()) / 100.0
	var crit = randf_range(0, 1) <= crit_amount
	for effect: EffectResource in resource._hit_effects.map(func(he): return he.get_effect()):
		perform_effect(caster, plate, effect, crit, 0)
	# console log
	console.log_weapon_cast(caster, weapon_name, crit)
	console.log_effects(effects_log)
	console.output.add_separator()
	effects_log.clear()
	check_dying_entities([PlayerManager.player_entity] + MonsterManager.monsters)


static func perform_effect(caster: Entity, plate: EntityContainer, effect: EffectResource, crit: bool, grade: int):
	if !caster.is_player or is_effective_by_zone(effect.effective_zone):
		var method_name = "perform_%s" % EffectType.find_key(effect.type).to_lower()
		var callable = Callable(SpellsService, method_name)
		if caster.can_cast_spell_in_zone(effect.effective_zone, plate):
			if effect.type in [EffectType.SPECIAL, EffectType.INVOCATION, EffectType.RANDOM]:
				callable.bindv([caster, plate, effect, crit, grade]).call()
			else:
				for tar in get_targets(caster, plate, effect.target_type):
					if !(tar.is_invisible and caster != tar):
						callable.bindv([caster, tar, effect, crit, grade]).call()


static func perform_damage(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int, is_poison := false, do_log_before := false):
	# Exception pour la balise tactique
	if ClassExceptions.is_balise_tactique(target) and Globals.selected_class_is(Globals.Classe.CRA):
		return
	var element = effect.element
	var amount: int
	if element == Element.BEST:
		element = caster.get_best_element()
	else:
		if element == Element.RANDOM:
			element = randi_range(0, 4) as Element
	amount = get_degats(caster, effect.get_amount(crit, grade), element)
	if crit:
		amount += caster.get_do_crit()
	amount = target.take_damage(amount - target.returned_damage, element)
	add_log_effect(EffectType.DAMAGE, target, effect, amount, grade, is_poison, do_log_before)
	if effect.lifesteal:
		var soin = -round(amount / 2.0)
		caster.take_damage(soin, element)
		add_log_effect(EffectType.DAMAGE, caster, effect, soin, grade, false, do_log_before)
	if target.returned_damage > 0:
		amount = target.returned_damage
		caster.take_damage(amount, element)
		add_log_effect(EffectType.DAMAGE, caster, effect, amount, grade, false, do_log_before)


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
	add_log_effect(EffectType.DAMAGE, target, effect, -amount, grade)


static func perform_bonus(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var amount = effect.get_amount(crit, grade)
	if effect.pourcentage and effect.caracteristic != StatType.EROSION:
		amount = int(caster.get_carac_amount_for_type(effect.caracteristic) * (amount / 100.0))
	var carac
	match effect.caracteristic:
		StatType.EROSION:
			amount = amount / 100.0
			target.erosion += amount
			amount = amount * 100.0
		StatType.RES_DOMMAGES:
			target.taken_damage_rate += amount
		StatType.RES_DOMMAGES_FIXE:
			target.reduced_damage += amount
		StatType.PV:
			add_pv_to_entity(target, amount)
		StatType.DOMMAGE_RETOURNE:
			target.returned_damage += amount
		_:
			carac = target.get_caracteristique_for_type(effect.caracteristic)
			carac.amount += amount
	add_log_effect(EffectType.BONUS, target, effect, amount, grade)
	if effect.time != 0:
		add_buff_effect(target, effect, amount)


static func annuler_bonus(buff: Buff, target: Entity, effect: EffectResource, amount: int):
	if is_instance_valid(buff) and is_instance_valid(target):
		if effect.type == EffectType.INVISIBILITE:
			target.set_invisible(false)
			return
		if effect.type == EffectType.AVEUGLE:
			target.is_aveugle = false
			return
		match effect.caracteristic:
			StatType.EROSION:
				target.erosion -= amount
			StatType.RES_DOMMAGES:
				target.taken_damage_rate -= amount
			StatType.RES_DOMMAGES_FIXE:
				target.reduced_damage -= amount
			StatType.PV:
				add_pv_to_entity(target, -amount)
			StatType.DOMMAGE_RETOURNE:
				target.returned_damage -= amount
			_:
				var carac = target.get_caracteristique_for_type(effect.caracteristic)
				carac.amount -= amount


static func perform_poison(_caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var amount = effect.get_amount(crit, grade)
	add_buff_effect(target, effect, amount)
	add_log_effect(EffectType.POISON, target, effect, amount, grade)


static func perform_retrait(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var amount = effect.get_amount(crit, grade)
	var carac_label = StatType.find_key(effect.caracteristic)
	var bar: CustomBar = target.get("%s_bar" % carac_label.to_lower())
	var ret_amount = caster.get_retrait(effect.caracteristic)
	var res_amount = target.get_resistance_retrait(effect.caracteristic)
	var ret_ratio = (ret_amount / float(res_amount)) if res_amount != 0 else 100.0
	var retrait_amount := 0
	if amount > 0:
		for i in range(amount):
			var proba = 50 * ret_ratio * (bar.cval / float(bar.mval))
			proba = clamp(proba, 10, 90)
			if randf_range(0, 1) <= proba / 100.0:
				bar.cval -= 1
				retrait_amount += 1
	else:
		bar.cval -= amount
		retrait_amount = amount
	add_log_effect(EffectType.RETRAIT, target, effect, retrait_amount, grade)
	if !target.is_player:
		target.create_taken_damage(retrait_amount, TakenDamage.Type.RET_PA if effect.caracteristic == StatType.PA else TakenDamage.Type.RET_PM)
	if effect.retrait_vol and retrait_amount > 0:
		var new_effect = effect.duplicate(true)
		new_effect.amounts = effect.duplicate_amounts()
		new_effect.amounts[grade] = AmountResource.create(retrait_amount, retrait_amount, retrait_amount, retrait_amount)
		new_effect.type = EffectResource.Type.BONUS
		perform_bonus(caster, caster, new_effect, crit, grade)


static func perform_special(caster: Entity, plate: EntityContainer, effect: EffectResource, crit: bool, grade: int):
	var callable = Callable(SpellsService, effect.method_name)
	if callable:
		var params = [caster, plate, effect, crit, grade]
		callable = callable.bind(effect.params)
		callable = callable.bindv(params)
		callable.call()
	else:
		console.log_error("%s not found in SpellsService" % callable.get_method())


static func perform_bouclier(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	var amount = SpellsService.get_amount_or_pourcentage(caster, effect, crit, grade)
	target.hp_bar.shield_val += amount
	add_log_effect(EffectType.BOUCLIER, target, effect, amount, grade)
	if effect.time != 0:
		var timer = create_timer(effect.time, "BonusTimer")
		await timer.timeout
		timer.queue_free()
		if is_instance_valid(timer) and GameManager.in_fight and is_instance_valid(target):
			target.hp_bar.shield_val -= amount


@warning_ignore("integer_division")
static func perform_poussee(caster: Entity, target: Entity, effect: EffectResource, crit: bool, grade: int):
	if target.is_player:
		var amount = get_degats_poussee(caster, target, effect.get_amount(crit, grade))
		target.take_damage(amount, Element.POUSSEE)
		add_log_effect(EffectType.DAMAGE, target, effect, amount, grade)
		return
	var direction = effect.direction
	var plate: EntityContainer = target.get_parent()
	if effect.target_type in [TargetType.AROUND, TargetType.TARGET_AROUND]:
		direction = PlayerManager.selected_plate.direction_to(plate)
	var direction_callable_name = "get_%s_plate" % Direction.find_key(direction).to_lower()
	var distance = effect.get_amount(crit, grade)
	var destination_plate: EntityContainer = plate.call(direction_callable_name, distance)
	var second_target = plate.get_first_entity(plate.get(direction_callable_name), distance)
	var dist_between_plates: int
	# si on trouve une entité sur le chemin, on calcule la distance entre cette entité et la cible
	# sinon on calcule la distance entre la dernière case disponible et la cible
	if second_target and second_target != target:
		dist_between_plates = plate.distance_to(second_target.get_parent()) - 1
	else:
		dist_between_plates = plate.distance_to(destination_plate)
	# dommages
	if !effect.is_attirance and dist_between_plates < distance:
		var amount = get_degats_poussee(caster, target, distance - dist_between_plates)
		target.take_damage(amount, Element.POUSSEE)
		effect.element = Element.POUSSEE
		add_log_effect(EffectType.POUSSEE, target, effect, amount, grade)
		if second_target and second_target != target:
			second_target.take_damage(amount / 2, Element.POUSSEE)
			add_log_effect(EffectType.POUSSEE, second_target, effect, amount / 2, grade)
	# animation
	if dist_between_plates > 0:
		destination_plate = plate.call(direction_callable_name, dist_between_plates)
		target.reparent(destination_plate, false)
		if destination_plate != plate:
			target.unselect()
	target.animate_poussee(get_direction(direction), dist_between_plates)


static func perform_invisibilite(_caster: Entity, target: Entity, effect: EffectResource, _crit: bool, grade: int):
	target.set_invisible()
	add_buff_effect(target, effect, 0)
	add_log_effect(EffectType.INVISIBILITE, target, effect, 0, grade)


static func perform_aveugle(_caster: Entity, target: Entity, effect: EffectResource, _crit: bool, grade: int):
	target.is_aveugle = true
	add_buff_effect(target, effect, 0)
	add_log_effect(EffectType.AVEUGLE, target, effect, 0, grade)


static func perform_invocation(caster: Entity, plate: EntityContainer, effect: EffectResource, _crit: bool, _grade: int):
	# Balise tactique
	if effect.invoc_id == 5908:
		for balise_tactique in MonsterManager.invocs.filter(func(m): return ClassExceptions.is_balise_tactique(m)):
			balise_tactique.die()
	var invoc_res = Datas._monsters[effect.invoc_id]
	if !caster.is_player and !plate:
		var caster_plate: EntityContainer = caster.get_parent()
		var empty_plates = []
		for surrouding_plate in caster_plate.get_surrounding_plates():
			if surrouding_plate.is_empty():
				empty_plates.append(surrouding_plate)
		plate = empty_plates[randi_range(0, empty_plates.size() - 1)]
	if !plate:
		log.error("No empty plate available")
		return
	MonsterManager.instantiate_invoc(invoc_res, plate, caster.is_player)


static func perform_random(caster: Entity, plate: EntityContainer, effect: EffectResource, crit: bool, grade: int):
	var rand_index = randi_range(0, effect.params.size() - 1)
	if effect.params.any(func(e): return !(e is EffectResource)):
		log.error("Un des paramètres de l'effet %s n'est pas un EffectResource" % effect.name)
	else:
		perform_effect(caster, plate, effect.params[rand_index], crit, grade)


#region Spécial
static func dommages_pourcentage_pv_caster(caster: Entity, plate: EntityContainer, effect: EffectResource, _crit: bool, grade: int):
	var amount = caster.get_vitalite() * (effect.amounts[grade]._min / 100.0)
	for targ in get_targets(caster, plate, effect.target_type):
		targ.take_damage(amount, effect.element)


static func sacrifice_pourcentage_pv(caster: Entity, _plate: EntityContainer, effect: EffectResource, _crit: bool, grade: int):
	var amount = caster.get_vitalite() * (effect.amounts[grade]._min / 100.0)
	if caster.is_player:
		PlayerManager.max_hp -= int(amount)
		await GameManager.end_fight
		PlayerManager.max_hp += int(amount)
	else:
		console.log_error("Target not supported")
#endregion


#region Sacrieur
static func punition(caster: Entity, plate: EntityContainer, effect: EffectResource, _crit: bool, _grade: int, _params: Array):
	var amount = int((PlayerManager.static_max_hp - PlayerManager.max_hp) * 0.3)
	var targets = get_targets(caster, plate, effect.target_type)
	for tar in targets:
		tar.take_damage(amount, Element.NEUTRE)


static func furie(caster: Entity, plate: EntityContainer, effect: EffectResource, crit: bool, grade: int, _params: Array):
	var bonus_pm: int = get_targets(caster, plate, EffectResource.TargetType.TARGET_NEIGHBORS).size()
	var new_effect = effect.duplicate(true)
	new_effect.amounts = effect.duplicate_amounts()
	new_effect.amounts[grade].add(bonus_pm)
	new_effect.type = EffectType.BONUS
	perform_effect(caster, plate, new_effect, crit, grade)


static func douleur_cuisante(caster: Entity, plate: EntityContainer, effect: EffectResource, crit: bool, grade: int, _params: Array):
	var bonus_puissance: int = get_targets(caster, plate, EffectResource.TargetType.TARGET_AROUND).size()
	var new_effect = effect.duplicate(true)
	new_effect.amounts = effect.duplicate_amounts()
	new_effect.amounts[grade].mult(bonus_puissance)
	new_effect.type = EffectType.BONUS
	perform_effect(caster, plate, new_effect, crit, grade)


static func mutilation(caster: Entity, plate: EntityContainer, _effect: EffectResource, crit: bool, grade: int, params: Array):
	var mutilation_buff = caster.buffs.filter(func(b): return b.name == "Mutilation")
	if mutilation_buff.is_empty():
		for i in range(2):
			perform_effect(caster, plate, params[i], crit, grade)
	else:
		mutilation_buff[0].annuler.emit()
		perform_effect(caster, plate, params[2], crit, grade)
		perform_effect(caster, plate, params[3], crit, grade)
#endregion


#region Ecaflip
static func chance_ecaflip(caster: Entity, _plate: EntityContainer, _effect: EffectResource, _crit: bool, _grade: int, _params: Array):
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
static func pile_face(caster: Entity, plate: EntityContainer, effect: EffectResource, crit: bool, grade: int, _params: Array):
	var amount = effect.get_amount(crit, grade)
	if !crit and face:
		amount -= 5
	face = !face
	var targets = get_targets(caster, plate, effect.target_type)
	for tar in targets:
		tar.take_damage(amount, effect.element)
#endregion


#region Iop
static var pugilat_adder := 0
static func pugilat(caster: Entity, plate: EntityContainer, effect: EffectResource, crit: bool, grade: int, params: Array):
	var new_effect = effect.duplicate(true)
	new_effect.amounts = effect.duplicate_amounts()
	new_effect.amounts[grade].add(pugilat_adder)
	new_effect.type = EffectResource.Type.DAMAGE
	perform_effect(caster, plate, new_effect, crit, grade)
	pugilat_adder += params[0]


static var fureur_adder := 0
static func fureur(caster: Entity, plate: EntityContainer, effect: EffectResource, crit: bool, grade: int):
	var new_effect = effect.duplicate(true)
	new_effect.amounts = effect.duplicate_amounts()
	new_effect.amounts[grade].add(fureur_adder)
	new_effect.type = EffectResource.Type.DAMAGE
	perform_effect(caster, plate, new_effect, crit, grade)
	fureur_adder += 20


static var tempete_de_puissance_last_target: Entity = null
static func tempete_de_puissance(caster: Entity, plate: EntityContainer, effect: EffectResource, crit: bool, grade: int, _params: Array):
	if plate.get_entity():
		perform_damage(caster, plate.get_entity(), effect, crit, grade)
	if tempete_de_puissance_last_target and is_instance_valid(tempete_de_puissance_last_target):
		perform_damage(caster, tempete_de_puissance_last_target, effect, crit, grade)
	tempete_de_puissance_last_target = plate.get_entity()


static var tumulte_adder := 0
static func tumulte(caster: Entity, plate: EntityContainer, effect: EffectResource, crit: bool, grade: int, params: Array):
	var new_effect = effect.duplicate(true)
	new_effect.amounts = effect.duplicate_amounts()
	new_effect.amounts[grade].add(tumulte_adder)
	new_effect.type = EffectResource.Type.DAMAGE
	perform_effect(caster, plate, new_effect, crit, grade)
	tumulte_adder += params[0] * get_targets(caster, plate, effect.target_type).size()


static func vertu(caster: Entity, plate: EntityContainer, effect: EffectResource, crit: bool, grade: int, _params: Array):
	if plate.get_entity():
		perform_bonus(caster, caster, effect, crit, grade)
#endregion


#region Cra
static func fleche_assaillante(caster: Entity, plate: EntityContainer, effect: EffectResource, crit: bool, grade: int, _params: Array):
	var bonus_puissance: int = get_targets(caster, plate, EffectResource.TargetType.TARGET_NEIGHBORS).size()
	var new_effect = effect.duplicate(true)
	new_effect.amounts = effect.duplicate_amounts()
	new_effect.amounts[grade].mult(bonus_puissance)
	perform_bonus(caster, caster, new_effect, crit, grade)


static func fleche_explosive(caster: Entity, plate: EntityContainer, effect: EffectResource, crit: bool, grade: int, _params: Array):
	if plate.get_entity():
		var new_effect = effect.duplicate(true)
		new_effect.type = EffectType.DAMAGE
		perform_effect(caster, plate, new_effect, crit, grade)


static var fleche_punitive_adder := 0
static func fleche_punitive(caster: Entity, plate: EntityContainer, effect: EffectResource, crit: bool, grade: int, params: Array):
	var new_effect = effect.duplicate(true)
	new_effect.amounts = effect.duplicate_amounts()
	new_effect.amounts[grade].add(fleche_punitive_adder)
	new_effect.type = EffectResource.Type.DAMAGE
	perform_effect(caster, plate, new_effect, crit, grade)
	fleche_punitive_adder += params[0]
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
	if Entity.is_monster(caster):
		return amount
	var multiplicateur = get_multiplicateur(caster, element, false)
	var fixe = get_fixe(caster, element)
	return max(multiplicateur * amount + fixe, 0)


static func get_degats_poussee(caster: Entity, target: Entity, distance: int) -> int:
	var level = Globals.xp_bar.cur_lvl
	var do_pou = caster.get_do_pou()
	var re_pou = target.get_re_pou()
	@warning_ignore("integer_division")
	return (level / 2) + (do_pou - re_pou + 32) * distance / 4


static func get_soin(caster: Entity, amount: int, element: Element) -> int:
	var multiplicateur = get_multiplicateur(caster, element, true)
	var fixe = caster.get_soin()
	return max(multiplicateur * amount + fixe, 0)


static func get_neighbor_entities(plate: EntityContainer) -> Array[Entity]:
	var neighbor_entities: Array[Entity] = []
	for nplate in plate.get_neighbor_plates():
		var target = nplate.get_entity()
		if target and is_instance_valid(target):
			neighbor_entities.append(target)
	return neighbor_entities


static func check_dying_entities(entities: Array):
	for entity in entities:
		if is_instance_valid(entity) and entity.dying:
			entity.die()
			entity.dying = false


static func create_timer(time: float, name: String = "Timer", parent: Node = tnode):
	var timer = Timer.new()
	timer.name = name
	timer.wait_time = time
	timer.autostart = true
	parent.add_child(timer)
	GameManager.end_fight.connect(timer.queue_free)
	return timer


static func get_targets(caster: Entity, plate: EntityContainer, type: EffectResource.TargetType) -> Array[Entity]:
	var targets: Array[Entity] = []
	var monsters = MonsterManager.get_valid_monsters()
	var target = plate.get_entity() if plate else PlayerManager.player_entity
	match type:
		TargetType.CASTER:
			targets.append(caster)
		TargetType.TARGET:
			targets.append(target)
		TargetType.TARGET_NEIGHBORS:
			targets.append(target)
			targets += get_neighbor_entities(plate)
		TargetType.NEIGHBORS:
			targets += get_neighbor_entities(plate)
		TargetType.ALL_MONSTERS:
			targets.assign(monsters)
		TargetType.COLUMN:
			targets.append(target)
			targets.append(plate.get_line(true)[plate.id - 1].get_entity())
		TargetType.ALL:
			targets += monsters
			targets.append(PlayerManager.player_entity)
		TargetType.RANDOM_MONSTER:
			randomize()
			targets.append(monsters[randi_range(0, monsters.size() - 1)])
		TargetType.AROUND, TargetType.TARGET_AROUND:
			targets += get_neighbor_entities(plate)
			if plate:
				var updown_target = plate.get_line(true)[plate.id - 1].get_entity()
				if is_instance_valid(updown_target):
					targets.append(updown_target)
			if type == TargetType.TARGET_AROUND:
				targets.append(target)
	return targets.filter(func(t): return t != null)


static func add_pv_to_entity(entity: Entity, amount: int):
	if entity.is_player:
		PlayerManager.max_hp += amount
	else:
		entity.hp_bar.mval += amount


static func get_direction(direction: Direction) -> Vector2:
	match direction:
		Direction.UP:
			return Vector2.UP
		Direction.DOWN:
			return Vector2.DOWN
		Direction.RIGHT:
			return Vector2.RIGHT
		Direction.LEFT:
			return Vector2.LEFT
		_:
			return Vector2.ZERO


static func is_effective_by_zone(zone: Zone):
	var cur_plate = PlayerManager.selected_plate
	match zone:
		Zone.ALL:
			return true
		Zone.MELEE:
			return MonsterManager.get_melee_plates().has(cur_plate)
		Zone.DISTANCE:
			return MonsterManager.get_distance_plates().has(cur_plate)


static func on_fight_end():
	SpellsService.pugilat_adder = 0
	SpellsService.fureur_adder = 0
	SpellsService.fleche_punitive_adder = 0
	SpellsService.tempete_de_puissance_last_target = null


static func add_buff_effect(target: Entity, effect: EffectResource, amount: int):
	if !effects_buff.has(target):
		effects_buff[target] = {}
	if effects_buff[target].has(effect.resource_name):
		log.debug("Attention ! Le sort lancé contient deux effets avec le même nom : %s" % effect.resource_name)
	effects_buff[target][effect.resource_name] = [effect, amount]


static func add_log_effect(type: EffectType, target: Entity, effect: EffectResource, amount: int, grade: int, is_poison: bool = false, before := false, after := false):
	var effect_log: Array = []
	match type:
		EffectType.DAMAGE:
			effect_log.assign([type, target, amount, effect.element, target.dying, is_poison])
		EffectType.BONUS:
			effect_log.assign([type, target, effect.get_effect_label(grade, amount)])
		EffectType.RETRAIT:
			effect_log.assign([type, target, amount, effect.get_caracteristic_label()])
		EffectType.BOUCLIER:
			effect_log.assign([type, target, amount, effect.time])
		EffectType.POUSSEE:
			effect_log.assign([EffectType.DAMAGE, target, amount, Element.POUSSEE, target.dying, false])
		EffectType.INVISIBILITE, EffectType.AVEUGLE:
			effect_log.assign([type, target, effect.time])
		EffectType.POISON:
			var carac_label = ""
			if effect.is_poison_carac:
				carac_label = effect.get_caracteristic_label()
			effect_log.assign([type, target, amount, effect.element, effect.time, carac_label, effect.nb_hits])
	if before:
		logs_before.append(effect_log)
	elif after:
		logs_after.append(effect_log)
	else:
		effects_log.append(effect_log)


static func do_poison_effect(caster: Entity, target: Entity, effect: EffectResource, amount: int, carac_amount: int = 0):
	if is_instance_valid(target) and is_instance_valid(caster):
		var new_effect = effect.duplicate(true)
		new_effect.amounts.assign([])
		new_effect.amounts.append(AmountResource.new())
		# calcul des dégâts de poison
		var poison_amount = get_degats(caster, amount, effect.element)
		if effect.is_poison_carac:
			poison_amount *= carac_amount
		new_effect.amounts[0].add(poison_amount)
		# perform poison damage
		perform_damage(caster, target, new_effect, false, 0, true, effect.is_poison_carac)
		SpellsService.check_dying_entities([target])
		# log effects in console
		if !effect.is_poison_carac:
			console.log_effects(effects_log)
			console.output.add_separator()
			effects_log.clear()
#endregion
