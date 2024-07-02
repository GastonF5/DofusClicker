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

@export_group("Damage & Soin")
@export var element: Caracteristique.Element
@export var lifesteal: bool

@export_group("Bonus & Retrait")
@export var caracteristic: Caracteristique.Type

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
	return Caracteristique.Element.find_key(element).to_pascal_case()


func get_caracteristic_label() -> String:
	return StatResource.get_type_label(Caracteristique.Type.find_key(caracteristic))


func get_amount_label(grade: int) -> String:
	if amounts.size() > grade:
		var m = amounts[grade]
		var params = []
		params.append(m.min)
		if m.min != m.max:
			params.append(m.max)
		if m.min_crit != m.min:
			params.append(m.min_crit)
		if m.min_crit != m.max_crit:
			params.append(m.max_crit)
		match params.size():
			1: return str(params[0])
			2: return "%d (%d)" % params
			3: return "%d à %d (%d)" % params
			4: return "%d à %d (%d à %d)" % params
	return "ERREUR"


func get_effect_label(grade: int) -> String:
	match type:
		Type.DAMAGE, Type.SOIN:
			return "%s %s" % [get_amount_label(grade), get_element_label()]
		Type.BONUS:
			return "%s %s" % [get_amount_label(grade), get_caracteristic_label()]
		Type.RETRAIT:
			return "- %s %s" % [get_amount_label(grade), get_caracteristic_label()]
		Type.SPECIAL:
			return compute_special_label(grade)
		_:
			return "ERREUR"


func compute_special_label(grade: int) -> String:
	if ["{min}", "{max}", "{min_crit}", "{max_crit}"].any(func(e): return effect_label.contains(e)):
		var m = amounts[grade]
		var label = effect_label
		label = label.replace("{min}", str(m.min))
		label = label.replace("{max}", str(m.max))
		label = label.replace("{min_crit}", str(m.min_crit))
		label = label.replace("{max_crit}", str(m.max_crit))
		label = label.replace("{elem}", get_element_label())
		return label
	return "ERREUR"


func get_label_color() -> Color:
	match type:
		Type.RETRAIT:
			return Color.CRIMSON
		_:
			return Color.LIME_GREEN
