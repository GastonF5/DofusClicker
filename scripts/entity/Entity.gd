extends ClickableControl
class_name Entity


const NO_CARAC_FOUND = "La caractéristique %s n'a pas été trouvée pour l'entité %s"

var caracteristiques: Array[StatResource]


func init_caracteristiques(caracs: Array[StatResource]):
	for carac in caracs:
		var new_carac: StatResource = carac.duplicate()
		new_carac.init_amount()
		caracteristiques.append(new_carac)


func get_caracacteristique_for_type(type: Caracteristique.Type):
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
