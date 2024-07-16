extends ClickableControl
class_name Entity

const NO_CARAC_FOUND = "La caractéristique %s n'a pas été trouvée pour l'entité %s"
const CaracType = Caracteristique.Type
const Element = Caracteristique.Element

var caracteristiques: Array[StatResource] = []
var spells: Array[SpellResource] = []

var player_manager: PlayerManager
var player: bool
var inventory: Inventory

@export var name_label: Label
@export var texture_rect: TextureRect
@export var header_texture: TextureRect

@export var entity_bar: EntityBars
var hp_bar: CustomBar:
	get: return entity_bar.hp_bar
var pa_bar: CustomBar:
	get: return entity_bar.pa_bar
var pm_bar: CustomBar:
	get: return entity_bar.pm_bar

var dying = false
var attack_callable: Callable
signal dies

var erosion := 0.05
var taken_damage_rate: int = 100


#region Caractéristiques
func init(is_player := false):
	player_manager = get_tree().current_scene.get_node("%PlayerManager")
	pm_bar.cval_change.connect(func():
		pa_bar.speed = get_attack_speed())
	pa_bar.speed = get_attack_speed()
	player = is_player
	init_bars()


func init_caracteristiques(caracs: Array[StatResource]):
	for carac in caracs:
		var new_carac: StatResource = carac.duplicate()
		new_carac.init_amount()
		caracteristiques.append(new_carac)


func init_spells(spell_ids: Array):
	print(spell_ids)
	var dir = DirAccess.open("res://resources/spells/monster/")
	for id in spell_ids:
		if dir.file_exists("%d.tres" % id):
			var spell = FileLoader.load_file("res://resources/spells/monster/%d.tres" % id)
			spells.append(spell)


func get_caracacteristique_for_type(type: CaracType):
	var carac
	if player:
		return StatsManager.get_caracteristique_for_type(type)
	else:
		carac = caracteristiques.filter(func(c): return c.type == type)
	if carac.size() != 1:
		#push_error(NO_CARAC_FOUND % [CaracType.find_key(type), name])
		return null
	return carac[0]


func set_caracteristique_amount(type: CaracType, new_amount: int):
	var carac = get_caracacteristique_for_type(type)
	if carac:
		carac.amount = new_amount
	else:
		console.log_error("La caractéristique %s n'existe pas pour l'entité %s" % [CaracType.find_key(type).to_pascal_case(), name])


func connect_to_stat(type: CaracType, callable: Callable):
	var carac = get_caracacteristique_for_type(type)
	if carac:
		carac.amount_change.connect(callable)


func init_bars():
	connect_to_stat(Caracteristique.Type.VITALITE, func():
		hp_bar.mval = get_vitalite())
	connect_to_stat(Caracteristique.Type.PA, func():
		var curmval = pa_bar.mval
		pa_bar.mval = get_pa()
		pa_bar.cval += get_pa() - curmval)
	connect_to_stat(Caracteristique.Type.PM, func():
		var curmval = pm_bar.mval
		pm_bar.speed = 0.0
		pm_bar.mval = get_pm()
		pm_bar.cval = get_pm())


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
	if amount > 0:
		amount = amount * round(taken_damage_rate / 100.0)
		amount = apply_resistance(amount, element)
		apply_erosion(amount)
		if is_monster(self):
			create_taken_damage(amount)
	if hp_bar.cval - amount <= hp_bar.min_value:
		amount = hp_bar.cval
		hp_bar.cval = hp_bar.min_value
		dying = true
	elif hp_bar.cval - amount > hp_bar.mval:
		amount = -(hp_bar.mval - hp_bar.cval)
		hp_bar.cval -= amount
	else:
		hp_bar.cval -= amount
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


static func is_monster(value: Node):
	return is_instance_of(value, Monster)


func is_player():
	return !Entity.is_monster(self)


func die():
	print("%s died" % name)


func show_description():
	if !PlayerManager.dragged_item:
		PlayerManager.entity_description.init_entity(self)


func hide_description():
	if !PlayerManager.dragged_item:
		PlayerManager.entity_description.visible = false
