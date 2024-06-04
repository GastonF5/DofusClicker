class_name SpellsService


const StatType = Caracteristique.Type
const Element = Caracteristique.Element

static var console: Console
static var tnode: Node
static var player_entity: Entity


static func coup_de_poing(target: Monster):
	target.take_damage(5, Element.NEUTRE)
	check_dying_targets([target])


#region Ecaflip
static func chance_ecaflip(_target: Monster):
	PlayerManager.taken_damage_rate = 50
	var timer = create_timer(5)
	await timer.timeout
	PlayerManager.taken_damage_rate = 200
	timer = create_timer(3)
	await timer.timeout
	timer.queue_free()
	PlayerManager.taken_damage_rate = 100

static func roue_fortune(_target: Monster):
	pass

static func trefle(_target: Monster):
	pass

static var pile = true
static var pile_min = 15
static var pile_max = 17
static var face_min = 10
static var face_max = 12
static func pile_face(target: Monster):
	# les dommages sont plus faibles au tour suivant
	var taken_damage = 0
	if target:
		if pile:
			taken_damage = target.take_damage(get_degats(pile_min, pile_max, StatType.FORCE), Element.TERRE)
			pile = false
		else:
			taken_damage = target.take_damage(get_degats(face_min, face_max, StatType.FORCE), Element.TERRE)
			pile = true
		check_dying_targets([target])
		console.log_info("Pile ou Face lancé sur %s :\n - %d dégâts" % [target.resource.name, taken_damage])

static var destin_min = 31
static var destin_max = 34
static func destin_ecaflip(target: Monster):
	# dommages + retrait PM
	var taken_damage = 0
	if target:
		taken_damage = target.take_damage(get_degats(destin_min, destin_max, StatType.FORCE), Element.TERRE)
		check_dying_targets([target])
		console.log_info("Destin d'Ecaflip lancé sur %s : \n - %d dégâts" % [target.resource.name, taken_damage])

static func pelotage(_target: Monster):
	pass

static func griffe_ceangal(_target: Monster):
	pass

static func tout_rien(_target: Monster):
	pass

static func felintion(_target: Monster):
	pass

#endregion


#region Monstres
# id 5866
static func brulure_legere():
	var amount := randi_range(6, 10)
	var element: Element = randi_range(1, 4)
	player_entity.take_damage(amount, element)

#id 202
static func morsure_du_bouftou(crit: bool):
	var min := 23 if !crit else 34
	var max := 33 if !crit else 50
	player_entity.take_damage(randi_range(min, max), Element.NEUTRE)


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


static func deal_damage(target: Entity, min_amout: int, max_amount: int, element: Element):
	target.take_damage(randi_range(min_amout, max_amount), element)


static func create_timer(time: float, name: String = "Timer"):
	var timer = Timer.new()
	timer.name = name
	timer.wait_time = time
	timer.autostart = true
	tnode.add_child(timer)
	return timer
#endregion
