class_name SpellsService


static func coup_de_poing(target: Monster):
	target.take_damage(5)


static func fleche_sanglante(target: Monster):
	deal_damage_to_surrounding_monsters(target, 10)


static func deal_damage_to_surrounding_monsters(target: Monster, amount: int):
	var monsters = MonsterManager.monsters
	var index = monsters.find(target)
	if index - 1 >= 0:
		monsters[index - 1].take_damage(amount)
	if index + 1 < MonsterManager.monsters.size():
		monsters[index + 1].take_damage(amount)
