extends ClickableControl
class_name Entity

const NO_CARAC_FOUND = "La caractéristique %s n'a pas été trouvée pour l'entité %s"

var caracteristiques: Array[StatResource]
var player_manager: PlayerManager
var inventory: Inventory

@export var hp_bar: HPBar
@export var pa_bar: PABar
@export var pm_bar: PMBar

@export var attack_bar: TextureProgressBar

var dying = false
var attack_callable: Callable
signal dies

var attack_timer: Timer


#region Caractéristiques
func init_caracteristiques(caracs: Array[StatResource]):
	for carac in caracs:
		var new_carac: StatResource = carac.duplicate()
		new_carac.init_amount()
		caracteristiques.append(new_carac)


func get_caracacteristique_for_type(type: Caracteristique.Type) -> StatResource:
	var carac = caracteristiques.filter(func(c): return c.type == type)
	if carac.size() != 1:
		console.log_error(NO_CARAC_FOUND % [Caracteristique.Type.find_key(type), name])
		return null
	return carac[0]


func set_caracteristique_amount(type: Caracteristique.Type, new_amount: int):
	var carac = get_caracacteristique_for_type(type)
	if carac:
		carac.amount = new_amount


func connect_to_stat(type: Caracteristique.Type, callable: Callable, params: Array):
	var carac = get_caracacteristique_for_type(type)
	if carac:
		carac.amount_change.connect(callable.bindv(params))


func get_vitalite() -> int:
	var hp = get_caracacteristique_for_type(Caracteristique.Type.VITALITE)
	return 0 if !hp else hp.amount


func get_pm() -> int:
	var pm = get_caracacteristique_for_type(Caracteristique.Type.PM)
	return 0 if !pm else pm.amount


func get_pa() -> int:
	var pa = get_caracacteristique_for_type(Caracteristique.Type.PA)
	return 0 if !pa else pa.amount
#endregion


func take_damage(amount: int):
	create_taken_damage(amount)
	hp_bar.current_hp -= amount
	if hp_bar.current_hp <= hp_bar.min_value:
		dying = true
	return amount


func create_taken_damage(amount: int):
	var taken_damage: TakenDamage = FileLoader.get_packed_scene("taken_damage").instantiate()
	get_parent().add_child(taken_damage)
	taken_damage.init(amount)


func new_attack_timer(time = 0.0):
	var attack_time = get_attack_time() if time == 0.0 else time
	if attack_timer != null:
		attack_timer.timeout.disconnect(attack_callable)
		attack_timer.queue_free()
	attack_timer = Timer.new()
	attack_timer.wait_time = abs(attack_time)
	attack_timer.timeout.connect(attack_callable)
	add_child(attack_timer)
	attack_timer.start()


func update_timer():
	if pm_bar.get_amount() == 0:
		attack_timer.paused = true
	else:
		attack_timer.paused = false
		update_attack_bar()


func get_attack_time():
	var pm = pm_bar.get_amount()
	return null if pm == 0 or pm > 10 else 10 / pm


func update_attack_bar():
	var last_max_value = attack_bar.max_value
	var last_value = attack_bar.value
	attack_bar.max_value = get_attack_time()
	attack_bar.value = (last_value * attack_bar.max_value) / last_max_value
	if float(abs(attack_bar.max_value - attack_bar.value)) > 0:
		new_attack_timer(float(abs(attack_bar.max_value - attack_bar.value)))
