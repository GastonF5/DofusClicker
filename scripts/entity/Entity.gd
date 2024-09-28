extends ClickableControl
class_name Entity

const NO_CARAC_FOUND = "La caractéristique %s n'a pas été trouvée pour l'entité %s"
const CaracType = Caracteristique.Type
const Element = Caracteristique.Element

const INIT_POSITION = Vector2(4, -182)
const PLATE_SEPARATION = Vector2(223, 314)

var caracteristiques: Array[StatResource] = []
var spells: Array[SpellResource] = []
var buffs: Array[Buff] = []

var inventory: Inventory

@export var name_label: Label
@export var texture_rect: TextureRect
@export var header_texture: TextureRect

@export var hp_bar: HealthBar
@export var pa_bar: CustomBar
@export var pm_bar: CustomBar

@export var buffs_container: HBoxContainer

var dying = false
var attack_callable: Callable
signal dies

var erosion := 0.05
var taken_damage_rate: float = 100

var console: Console
var is_player := false


#region Caractéristiques
func init():
	inventory = Globals.inventory
	console = SpellsService.console
	if is_player:
		hp_bar = PlayerManager.hp_bar
		pa_bar = PlayerManager.pa_bar
		pm_bar = PlayerManager.pm_bar
	pm_bar.cval_change.connect(func():
		pa_bar.speed = get_attack_speed())
	pa_bar.speed = get_attack_speed()
	init_bars()


func init_caracteristiques(caracs: Array[StatResource]):
	for carac in caracs:
		var new_carac: StatResource = carac.duplicate()
		new_carac.init_amount()
		var existing_carac = get_caracteristique_for_type(new_carac.type)
		if existing_carac:
			caracteristiques.erase(existing_carac)
		caracteristiques.append(new_carac)


func init_spells(spell_ids: Array):
	print(spell_ids)
	var dir = DirAccess.open("res://resources/spells/monster/")
	for id in spell_ids:
		if dir.file_exists("%d.tres" % id) or dir.file_exists("%d.tres.remap" % id):
			var spell = FileLoader.load_file("res://resources/spells/monster/%d.tres" % id)
			if spell.available:
				spells.append(spell)


func get_caracteristique_for_type(type: CaracType):
	if type == CaracType.PV:
		push_error("No characteristic available for type PV")
		return null
	var carac
	if is_player:
		return StatsManager.get_caracteristique_for_type(type)
	else:
		carac = caracteristiques.filter(func(c): return c.type == type)
	if carac.size() == 0:
		carac = StatResource.create(type, 0, 0)
		carac.init_amount()
		caracteristiques.append(carac)
		return carac
	if carac.size() > 1:
		push_error("More than one characteristic has been found for type %s for entity %s" % [CaracType.find_key(type), name])
		return null
	return carac[0]


func get_carac_amount_for_type(type: CaracType) -> int:
	if type == CaracType.PV:
		if is_player:
			return PlayerManager.max_hp
		return hp_bar.mval
	else:
		return get_caracteristique_for_type(type).amount


func get_caracteristique_for_element(element: Element, dommages := false):
	return get_caracteristique_for_type(StatsManager.get_type_for_element(element, dommages))


func get_best_element() -> Element:
	var amount := int(-INF)
	var best
	for type in [CaracType.AGILITE, CaracType.CHANCE, CaracType.INTELLIGENCE, CaracType.FORCE]:
		var carac = get_caracteristique_for_type(type)
		if carac.amount > amount:
			amount = carac.amount
			best = type
	return Caracteristique.type_to_element(best)


func set_caracteristique_amount(type: CaracType, new_amount: int):
	var carac = get_caracteristique_for_type(type)
	if carac:
		carac.amount = new_amount
	else:
		console.log_error("La caractéristique %s n'existe pas pour l'entité %s" % [CaracType.find_key(type).to_pascal_case(), name])


func connect_to_stat(type: CaracType, callable: Callable):
	var carac = get_caracteristique_for_type(type)
	if carac:
		carac.amount_change.connect(callable)


func init_bars():
	connect_to_stat(Caracteristique.Type.VITALITE, func():
		if is_player:
			PlayerManager.max_hp = get_vitalite()
		else:
			hp_bar.mval = get_vitalite())
	connect_to_stat(Caracteristique.Type.PA, func():
		var curmval = pa_bar.mval
		pa_bar.mval = get_pa()
		pa_bar.cval += get_pa() - curmval)
	connect_to_stat(Caracteristique.Type.PM, func():
		#var curmval = pm_bar.mval
		pm_bar.speed = 0.0
		pm_bar.mval = get_pm()
		pm_bar.cval = get_pm())


func get_vitalite() -> int:
	if is_player:
		return PlayerManager.max_hp
	var hp = get_caracteristique_for_type(CaracType.VITALITE)
	return 0 if !hp else hp.amount

func get_pm() -> int:
	var pm = get_caracteristique_for_type(CaracType.PM)
	return 0 if !pm else pm.amount

func get_pa() -> int:
	var pa = get_caracteristique_for_type(CaracType.PA)
	return 0 if !pa else pa.amount

func get_critique() -> int:
	var carac = get_caracteristique_for_type(CaracType.CRITIQUE)
	return StatsManager.get_carac_amount(carac)

func get_do_crit() -> int:
	var carac = get_caracteristique_for_type(CaracType.DO_CRITIQUES)
	return StatsManager.get_carac_amount(carac)

func get_puissance() -> int:
	var carac = get_caracteristique_for_type(CaracType.PUISSANCE)
	return StatsManager.get_carac_amount(carac)

func get_dommages() -> int:
	var carac = get_caracteristique_for_type(CaracType.DOMMAGES)
	return StatsManager.get_carac_amount(carac)

func get_do_pou() -> int:
	var carac = get_caracteristique_for_type(CaracType.DO_POU)
	return StatsManager.get_carac_amount(carac)

func get_re_pou() -> int:
	var carac = get_caracteristique_for_type(CaracType.RES_POU)
	return StatsManager.get_carac_amount(carac)

func get_soin() -> int:
	var carac = get_caracteristique_for_type(CaracType.SOIN)
	return StatsManager.get_carac_amount(carac)

func get_sagesse() -> int:
	var carac = get_caracteristique_for_type(CaracType.SAGESSE)
	return StatsManager.get_carac_amount(carac)

func get_ret_pa() -> int:
	var carac = get_caracteristique_for_type(CaracType.RET_PA)
	return StatsManager.get_carac_amount(carac)

func get_res_pa() -> int:
	var carac = get_caracteristique_for_type(CaracType.RES_PA)
	return StatsManager.get_carac_amount(carac)

func get_ret_pm() -> int:
	var carac = get_caracteristique_for_type(CaracType.RET_PM)
	return StatsManager.get_carac_amount(carac)

func get_res_pm() -> int:
	var carac = get_caracteristique_for_type(CaracType.RES_PM)
	return StatsManager.get_carac_amount(carac)

func get_retrait(type: CaracType) -> int:
	var carac_amount = get_ret_pa() if type == CaracType.PA else get_ret_pm()
	return int(floor(carac_amount + (get_sagesse() / 10.0)))

func get_resistance_retrait(type: CaracType) -> int:
	return get_res_pa() if type == CaracType.PA else get_res_pm()

func get_prospection() -> float:
	var prospection = StatsManager.get_carac_amount(get_caracteristique_for_type(CaracType.PROSPECTION))
	var chance = StatsManager.get_carac_amount(get_caracteristique_for_type(CaracType.CHANCE))
	return 100 + (chance / 100.0) + prospection
#endregion


#region Animation
func animate_poussee(direction: Vector2, distance: int):
	var tween = create_tween()
	var init_position = position
	if distance > 0:
		position = init_position - Vector2(0, -32) - PLATE_SEPARATION * direction * distance
		tween.tween_property(self, "position", init_position - Vector2(0, -32), 0.3).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(self, "position", init_position + direction * 30, 0.1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position", init_position, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
#endregion


func take_damage(amount: int, element: Element):
	if amount > 0:
		amount = amount * round(taken_damage_rate / 100.0)
		if element != Element.POUSSEE:
			amount = apply_resistance(amount, element)
		if Entity.is_monster(self):
			create_taken_damage(amount)
	apply_erosion(hp_bar.take_damage(amount))
	if hp_bar.cval == int(hp_bar.min_value):
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
		res = get_caracteristique_for_type(type).amount
	return amount - (amount * res / 100.0)


func apply_erosion(amount: int):
	var ero = (amount * erosion) as int
	if is_player:
		PlayerManager.max_hp -= ero
	else:
		hp_bar.mval -= ero


static func is_monster(value: Node):
	return is_instance_of(value, Monster)


func die():
	print("%s died" % name)
	if is_player:
		hp_bar.value = hp_bar.min_value
		GameManager.lose_fight()


func show_description():
	if !PlayerManager.dragged_item:
		PlayerManager.entity_description.init_entity(self)


func hide_description():
	if !PlayerManager.dragged_item:
		PlayerManager.entity_description.visible = false
