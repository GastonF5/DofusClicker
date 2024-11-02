class_name EffectResource
extends Resource

const StatType = Caracteristique.Type
const _INF = 999999

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
	POUSSEE,
	INVISIBILITE,
	AVEUGLE,
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
	AROUND,
	TARGET_AROUND,
	COLUMN,
}

enum Direction { UP, DOWN, LEFT, RIGHT, NONE }
enum Zone { ALL, MELEE, DISTANCE }


@export var type: Type
@export var time: float
@export var target_type: TargetType
@export var show_time: bool
@export var effective_zone: Zone
@export var has_grades: bool
var caster: Entity

@export_group("Damage & Soin")
@export var element: Caracteristique.Element
@export var lifesteal: bool

@export_group("Bouclier")
@export var level_pourcentage: bool

@export_group("Bonus & Retrait")
@export var caracteristic: StatType
@export var pourcentage: bool
@export var retrait_vol: bool

@export_group("Special")
@export var method_name: StringName
@export_multiline var effect_label: String
@export var params: Array = []

@export_group("Random")
@export var nb_random_effects: int

@export_group("Poussée")
@export var direction: Direction
@export var is_attirance: bool

@export_group("Poison")
@export var nb_hits: int = 1
@export var is_poison_carac: bool

@export_group("Invocation")
@export var invoc_id: int

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
	if caracteristic == StatType.PV:
		return "PV"
	if caracteristic == StatType.DO_SORTS:
		return "Dommages aux sorts"
	if caracteristic == StatType.RES_DOMMAGES:
		return "Dommages subis"
	if caracteristic == StatType.RES_DOMMAGES_FIXE:
		return "Dommages réduits"
	if caracteristic == StatType.DOMMAGE_RETOURNE:
		return "Dommages retournés"
	return StatResource.get_type_label(StatType.find_key(caracteristic))


func get_amount_label(grade: int, amount: int = _INF) -> String:
	var is_pourcentage_charac = caracteristic in [StatType.DO_SORTS, StatType.RES_DOMMAGES, StatType.CRITIQUE]
	var formatter = func(d): return str(d)
	var pattern = "%s"
	if pourcentage or level_pourcentage or is_pourcentage_charac:
		pattern = "%s%%"
	if caracteristic == StatType.RES_DOMMAGES:
		formatter = func(d): return str(100 + d)
		pattern = "x%s%%"
	if amount != _INF:
		return pattern % formatter.call(amount)
	var result: String
	if amounts.size() > grade:
		var m = amounts[grade]
		var parameters: Array[String] = []
		parameters.append(pattern % formatter.call(m._min))
		if m._min != m._max:
			parameters.append(pattern % formatter.call(m._max))
		if m._min_crit != m._min:
			parameters.append(pattern % formatter.call(m._min_crit))
		if m._min_crit != m._max_crit:
			parameters.append(pattern % formatter.call(m._max_crit))
		match parameters.size():
			1: result = str(parameters[0])
			2: result = "%s (%s)" % parameters
			3: result = "%s à %s (%s)" % parameters
			4: result = "%s à %s (%s à %s)" % parameters
			_: result = "ERREUR"
	return result


func get_effect_label(grade: int, amount: int = _INF) -> String:
	var result: String = ""
	if effect_label and amount == _INF:
		return compute_special_label(grade)
	match type:
		Type.DAMAGE:
			if lifesteal:
				result += "%s vol %s"
			else:
				result += "%s dommages %s"
			result = result % [get_amount_label(grade, amount), get_element_label()]
		Type.POISON:
			result += "%s Poison %s" % [get_amount_label(grade, amount), get_element_label()]
		Type.SOIN:
			result += "%s soins %s" % [get_amount_label(grade, amount), get_element_label()]
		Type.BONUS:
			match caracteristic:
				StatType.RES_DOMMAGES:
					result += get_caracteristic_label() + ' ' + get_amount_label(grade, amount)
				StatType.RES_DOMMAGES_FIXE:
					result += get_caracteristic_label() + ' de ' + get_amount_label(grade, amount)
				StatType.DOMMAGE_RETOURNE:
					result += get_caracteristic_label() + ' : ' + get_amount_label(grade, amount)
				_:
					result += get_amount_label(grade, amount) + ' ' + get_caracteristic_label()
		Type.RETRAIT:
			if retrait_vol:
				result += "Vole "
			else:
				result += "-"
			result += "%s %s" % [get_amount_label(grade, amount), get_caracteristic_label()]
		Type.BOUCLIER:
			if level_pourcentage:
				result += "%s du niveau en bouclier" % get_amount_label(grade, amount)
			else:
				result += "%s en bouclier" % get_amount_label(grade, amount)
		Type.POUSSEE:
			var nb_cases = get_amount_label(grade, amount)
			if is_attirance:
				result += "Attire"
			else:
				result += "Repousse"
			result += " de %s case" % nb_cases
			if int(nb_cases) > 1:
				result += "s"
		Type.INVISIBILITE:
			result += "Rend invisible"
		Type.AVEUGLE:
			result += "Rend aveugle"
		Type.INVOCATION:
			result += "Invoque : %s" % Datas._monsters[invoc_id].name
		_:
			return "ERREUR"
	if show_time or amount != _INF:
		if time == 0:
			result += " (infini)"
		else:
			result += " (%d secondes)" % time
	if type == Type.POISON:
		result += " (%d fois)" % nb_hits
	if amount == _INF:
		match effective_zone:
			Zone.MELEE:
				result += " (Mêlée)"
			Zone.DISTANCE:
				result += " (Distance)"
	return result


func compute_special_label(grade: int) -> String:
	var label = effect_label
	if !params.is_empty():
		for i in range(params.size()):
			if params[i] is EffectResource:
				var eff_label = params[i].get_effect_label(grade)
				label = label.replace("{param%d}" % i, eff_label)
			if params[i] is int:
				label = label.replace("{param%d}" % i, str(params[i]))
	if ["{min}", "{max}", "{min_crit}", "{max_crit}", "{time}"].any(func(e): return effect_label.contains(e)):
		var m = amounts[grade]
		label = label.replace("{min}", str(m._min))
		label = label.replace("{max}", str(m._max))
		label = label.replace("{min_crit}", str(m._min_crit))
		label = label.replace("{max_crit}", str(m._max_crit))
		label = label.replace("{elem}", get_element_label())
		label = label.replace("{time}", "(%d secondes)" % time)
	if label != "":
		return label
	return "ERREUR"


func get_label_color() -> Color:
	if type == Type.RETRAIT and !retrait_vol:
		return Color.CRIMSON
	return Color.LIME_GREEN
