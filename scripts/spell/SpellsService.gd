class_name SpellsService


static func coup_de_poing(target: Monster):
	target.take_damage(5)
	check_dying_targets([target])


static func fleche_sanglante(target: Monster):
	var targets = deal_damage_to_surrounding_monsters(target, 10)
	check_dying_targets(targets)


static func create_timer(time: float):
	var timer = Timer.new()
	timer.wait_time = time
	timer.autostart = true
	return timer


#region Ecaflip
static func chance_ecaflip(target: Monster):
	PlayerManager.taken_damage_rate = 50
	var timer = create_timer(5)
	target.add_child(timer)
	await timer.timeout
	PlayerManager.taken_damage_rate = 200
	timer = create_timer(3)
	target.add_child(timer)
	await timer.timeout
	PlayerManager.taken_damage_rate = 100

static func roue_fortune(_target: Monster):
	pass

static func trefle(_target: Monster):
	pass

static var pile = true
static var pile_face_damage: int = 50
static func pile_face(target: Monster):
	var taken_damage = 0
	if target:
		if pile:
			#pile_face_damage = randi_range(3, 6)
			taken_damage = target.take_damage(pile_face_damage)
			pile = false
		else:
			taken_damage = target.take_damage(pile_face_damage * 2)
			pile = true
		check_dying_targets([target])
	return taken_damage

static func destin_ecaflip(_target: Monster):
	pass

static func pelotage(_target: Monster):
	pass

static func griffe_ceangal(_target: Monster):
	pass

static func tout_rien(_target: Monster):
	pass

static func felintion(_target: Monster):
	pass

#endregion


static func deal_damage_to_surrounding_monsters(target: Monster, amount: int):
	var monsters = MonsterManager.monsters
	var index = monsters.find(target)
	var targets: Array[Monster] = []
	if index - 1 >= 0:
		targets.append(monsters[index - 1])
		monsters[index - 1].take_damage(amount)
	if index + 1 < MonsterManager.monsters.size():
		targets.append(monsters[index + 1])
		monsters[index + 1].take_damage(amount)
	return targets


static func check_dying_targets(targets: Array[Monster]):
	for monster in targets:
		if monster.dying:
			monster.die()
			monster.dying = false
