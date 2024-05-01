extends ClickableControl
class_name Entity


var caracteristiques: Array[StatResource]


func init_caracteristiques(caracs: Array[StatResource]):
	for carac in caracs:
		var new_carac: StatResource = carac.duplicate()
		new_carac.init_amount()
		caracteristiques.append(new_carac)


func get_caracacteristique_for_type(type: Caracteristique.Type):
	var carac = caracteristiques.filter(func(c): return c.type == type)
	if carac.size() != 1:
		console.log_error("Aucune ou plus d'une caractéristique a été trouvée pour le type : " + Caracteristique.Type.find_key(type))
		return null
	return carac[0]
