class_name EffectResource
extends Resource


enum Type {
	DAMAGE,
	BONUS,
	RETRAIT,
	SPECIAL,
	RANDOM,
	POISON,
	INVOCATION,
	SOIN,
	BOUCLIER,
}

enum TargetType {
	CASTER,
	TARGET,
	TARGET_NEIGHBORS,
	NEIGHBORS,
	ALL_MONSTERS,
	ALL_ALLIES,
	RANDOM_MONSTER,
	RANDOM_ALLY,
	ALL,
}


@export var type: Type
@export var time: float
@export var target_type: TargetType
@export var show_time: bool
@export var has_grades: bool

@export_group("Damage & Soin")
@export var element: Caracteristique.Element
@export var lifesteal: bool

@export_group("Bouclier")
@export var level_pourcentage: bool

@export_group("Bonus & Retrait")
@export var caracteristic: Caracteristique.Type
@export var pourcentage: bool
var texture: Texture2D

@export_group("Special")
@export var method_name: StringName
@export_multiline var effect_label: String
@export var params: Array = []

@export_group("Random")
@export var nb_random_effects: int

@export_category("Amounts")
@export var amounts: Array[AmountResource]

@export var visible_in_description: bool = true


func duplicate_amounts() -> Array[AmountResource]:
	var new_amounts: Array[AmountResource] = []
	for amount in amounts:
		new_amounts.append(amount.duplicate())
	return new_amounts


func get_amount(crit: bool, grade: int) -> int:
	if has_grades:
		return amounts[grade - 1].get_random(crit)
	return amounts[0].get_random(crit)


func get_element_label() -> String:
	if element == Caracteristique.Element.BEST:
		return "Meilleur Élement"
	return Caracteristique.Element.find_key(element).to_pascal_case()


func get_caracteristic_label() -> String:
	if caracteristic == Caracteristique.Type.PV:
		return "PV"
	if caracteristic == Caracteristique.Type.DO_SORTS:
		return "Dommages aux sorts"
	if caracteristic == Caracteristique.Type.RES_DOMMAGES:
		return "de dommages subis"
	return StatResource.get_type_label(Caracteristique.Type.find_key(caracteristic))


func get_amount_label(grade: int) -> String:
	var pattern = "%d" if !(pourcentage or level_pourcentage) else "%d%%"
	var result: String
	if amounts.size() > grade:
		var m = amounts[grade]
		var parameters: Array[String] = []
		parameters.append(pattern % m._min)
		if m._min != m._max:
			parameters.append(pattern % m._max)
		if m._min_crit != m._min:
			parameters.append(pattern % m._min_crit)
		if m._min_crit != m._max_crit:
			parameters.append(pattern % m._max_crit)
		match parameters.size():
			1: result = str(parameters[0])
			2: result = "%s (%s)" % parameters
			3: result = "%s à %s (%s)" % parameters
			4: result = "%s à %s (%s à %s)" % parameters
			_: result = "ERREUR"
	if caracteristic == Caracteristique.Type.DO_SORTS:
		result += "%"
	return result


func get_effect_label(grade: int) -> String:
	var result: String
	if effect_label:
		return compute_special_label(grade)
	match type:
		Type.DAMAGE:
			if lifesteal:
				result = "%s vol %s"
			else:
				result = "%s dommages %s"
			result = result % [get_amount_label(grade), get_element_label()]
		Type.SOIN:
			result = "%s soins %s" % [get_amount_label(grade), get_element_label()]
		Type.BONUS:
			result = get_amount_label(grade) + ' ' + get_caracteristic_label()
		Type.RETRAIT:
			result = "-%s %s" % [get_amount_label(grade), get_caracteristic_label()]
		Type.BOUCLIER:
			if level_pourcentage:
				result = "%s du niveau en bouclier" % get_amount_label(grade)
			else:
				result = "%s en bouclier" % get_amount_label(grade)
		_:
			return "ERREUR"
	if show_time:
		if time == 0:
			result += " (infini)"
		else:
			result += " (%d secondes)" % time
	return result


func compute_special_label(grade: int) -> String:
	if !params.is_empty():
		var label = effect_label
		for i in range(params.size()):
			if params[i] is EffectResource:
				var eff_label = params[i].get_effect_label(grade)
				label = label.replace("{param%d}" % i, eff_label)
		return label
	if ["{min}", "{max}", "{min_crit}", "{max_crit}", "{time}"].any(func(e): return effect_label.contains(e)):
		var m = amounts[grade]
		var label = effect_label
		label = label.replace("{min}", str(m._min))
		label = label.replace("{max}", str(m._max))
		label = label.replace("{min_crit}", str(m._min_crit))
		label = label.replace("{max_crit}", str(m._max_crit))
		label = label.replace("{elem}", get_element_label())
		label = label.replace("{time}", "(%d secondes)" % time)
		return label
	return "ERREUR"


func get_label_color() -> Color:
	match type:
		Type.RETRAIT:
			return Color.CRIMSON
		_:
			return Color.LIME_GREEN
