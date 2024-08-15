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
@export var _hit_effects: Array[HitEffectResource]
@export var _crit_proba: float


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
	var type = WeaponType.find_key(data["type"]["name"]["fr"].to_upper())
	if type:
		return WeaponType.get(type)
	else:
		return WeaponType.NONE
