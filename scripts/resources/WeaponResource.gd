class_name WeaponResource
extends Resource

enum WeaponType {
	NONE,
	MARTEAU,
	BATON,
	ARC,
	EPEE,
	DAGUES,
	PELLE,
	BAGUETTE,
}

@export var _type: WeaponType
@export var _pa_cost: int
@export var _hit_effects: Array[HitEffectResource]:
	get:
		if Datas._hit_effects.is_empty():
			return _hit_effects
		return _hit_effects.filter(func(he): return Datas._hit_effects.has(he._id))
@export var _crit_proba: int


static func map(data: Dictionary) -> WeaponResource:
	var resource = WeaponResource.new()
	resource._type = WeaponResource.get_weapon_type(data)
	resource._pa_cost = data["apCost"] as int
	resource._hit_effects.assign([])
	for effect_data in data["possibleEffects"]:
		resource._hit_effects.append(HitEffectResource.map(effect_data, data["criticalHitBonus"] as int))
	resource._crit_proba = data["criticalHitProbability"] as int
	return resource


static func get_weapon_type(data: Dictionary) -> WeaponType:
	var type = WeaponType.get(data["type"]["name"]["fr"].to_upper())
	if type:
		return type as WeaponType
	else:
		return WeaponType.NONE


func get_type():
	return _type

func get_pa_cost():
	return _pa_cost

func get_crit_proba():
	return _crit_proba

func get_bonus_crit() -> int:
	if _hit_effects and !_hit_effects.is_empty():
		var amounts = _hit_effects[0]._amounts
		return amounts._min_crit - amounts._min
	return 0
