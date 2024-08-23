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
@export var show_time := true

@export_group("Damage & Soin")
@export var element: Caracteristique.Element
@export var lifesteal: bool

@export_group("Bonus & Retrait")
@export var caracteristic: Caracteristique.Type
@export var pourcentage: bool
var texture: Texture2D

@export_group("Special")
@export var method_name: StringName
@export_multiline var effect_label: String
@export var params: Array

@export_group("Random")
@export var nb_random_effects: int

@export_category("Amounts")
@export var amounts: Array[AmountResource]

@export var visible_in_description: bool = true


func get_amount(crit: bool, grade: int) -> int:
	return amounts[grade].get_random(crit)


func get_element_label() -> String:
	if element == Caracteristique.Element.BEST:
		return "Meilleur Élement"
	return Caracteristique.Element.find_key(element).to_pascal_case()


func get_caracteristic_label() -> String:
	if caracteristic == Caracteristique.Type.PV:
		return "PV"
	if caracteristic == Caracteristique.Type.DO_SORTS:
		return "Dommages aux sorts"
	return StatResource.get_type_label(Caracteristique.Type.find_key(caracteristic))


func get_amount_label(grade: int) -> String:
	var result: String
	if amounts.size() > grade:
		var m = amounts[grade]
		var parameters = []
		parameters.append(m._min)
		if m._min != m._max:
			parameters.append(m._max)
		if m._min_crit != m._min:
			parameters.append(m._min_crit)
		if m._min_crit != m._max_crit:
			parameters.append(m._max_crit)
		match parameters.size():
			1: result = str(parameters[0])
			2: result = "%d (%d)" % parameters
			3: result = "%d à %d (%d)" % parameters
			4: result = "%d à %d (%d à %d)" % parameters
			_: result = "ERREUR"
	if caracteristic == Caracteristique.Type.DO_SORTS:
		result += "%"
	return result


func get_effect_label(grade: int) -> String:
	var result: String
	if effect_label:
		return compute_special_label(grade)
	match type:
		Type.DAMAGE, Type.SOIN:
			result = "%s %s" % [get_amount_label(grade), get_element_label()]
		Type.BONUS:
			if !pourcentage:
				result = "%s %s" % [get_amount_label(grade), get_caracteristic_label()]
			else:
				result = get_amount_label(grade) + "% " + get_caracteristic_label()
		Type.RETRAIT:
			result = "- %s %s" % [get_amount_label(grade), get_caracteristic_label()]
		_:
			return "ERREUR"
	if show_time:
		if time == 0:
			result += " (infini)"
		else:
			result += " (%d secondes)" % time
	return result


func compute_special_label(grade: int) -> String:
	if ["{min}", "{max}", "{min_crit}", "{max_crit}"].any(func(e): return effect_label.contains(e)):
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
