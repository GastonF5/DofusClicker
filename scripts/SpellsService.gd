class_name SpellsService


static func coup_de_poing(target: Monster):
	target.take_damage(5)
	check_dying_targets([target])


static func fleche_sanglante(target: Monster):
	var targets = deal_damage_to_surrounding_monsters(target, 10)
	check_dying_targets(targets)


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
