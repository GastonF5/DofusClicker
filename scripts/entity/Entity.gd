extends ClickableControl
class_name Entity

const NO_CARAC_FOUND = "La caractéristique %s n'a pas été trouvée pour l'entité %s"
const CaracType = Caracteristique.Type
const Element = Caracteristique.Element

var caracteristiques: Array[StatResource] = []
var spells: Array[SpellResource] = []

var player_manager: PlayerManager
var inventory: Inventory

@export var entity_bar: EntityBars
var hp_bar: CustomBar
var pa_bar: CustomBar
var pm_bar: CustomBar

var dying = false
var attack_callable: Callable
signal dies

var erosion := 0.05


#region Caractéristiques
func init():
	hp_bar = entity_bar.hp_bar
	pa_bar = entity_bar.pa_bar
	pm_bar = entity_bar.pm_bar
	pa_bar.speed = get_attack_speed()


func init_caracteristiques(caracs: Array[StatResource]):
	for carac in caracs:
		var new_carac: StatResource = carac.duplicate()
		new_carac.init_amount()
		caracteristiques.append(new_carac)


func init_spells(spell_ids: Array):
	for id in spell_ids:
		spells.append(FileLoader.load_file("res://resources/spells/monster/%d.tres" % id))


func get_caracacteristique_for_type(type: CaracType) -> StatResource:
	var carac = caracteristiques.filter(func(c): return c.type == type)
	if carac.size() != 1:
		console.log_error(NO_CARAC_FOUND % [CaracType.find_key(type), name])
		return null
	return carac[0]


func set_caracteristique_amount(type: CaracType, new_amount: int):
	var carac = get_caracacteristique_for_type(type)
	if carac:
		carac.amount = new_amount


func connect_to_stat(type: CaracType, callable: Callable, params: Array):
	var carac = get_caracacteristique_for_type(type)
	if carac:
		carac.amount_change.connect(callable.bindv(params))


func get_vitalite() -> int:
	var hp = get_caracacteristique_for_type(CaracType.VITALITE)
	return 0 if !hp else hp.amount


func get_pm() -> int:
	var pm = get_caracacteristique_for_type(CaracType.PM)
	return 0 if !pm else pm.amount


func get_pa() -> int:
	var pa = get_caracacteristique_for_type(CaracType.PA)
	return 0 if !pa else pa.amount
#endregion


func take_damage(amount: int, element: Element):
	amount = apply_resistance(amount, element)
	apply_erosion(amount)
	if is_monster(self):
		create_taken_damage(amount)
	hp_bar.cval -= amount
	if hp_bar.cval <= hp_bar.min_value:
		dying = true
	return amount


func create_taken_damage(amount: int):
	var taken_damage: TakenDamage = FileLoader.get_packed_scene("taken_damage").instantiate()
	get_parent().add_child(taken_damage)
	taken_damage.init(amount)


func get_attack_speed() -> float:
	var pm = pm_bar.cval
	return 0.0 if pm == 0 or pm > 10 else 20.0 * pm


func apply_resistance(amount: int, element: Element) -> int:
	var type = CaracType.get("RES_" + Element.keys()[element])
	var res = 0
	if caracteristiques.is_empty():
		res = StatsManager.get_caracteristique_for_type(type).amount
	else:
		res = get_caracacteristique_for_type(type).amount
	return amount - (amount * res / 100.0)


func apply_erosion(amount: int):
	var ero = (amount * erosion) as int
	hp_bar.cval -= ero
	hp_bar.mval -= ero
	hp_bar.update()


static func is_monster(value: Node):
	return is_instance_of(value, Monster)
