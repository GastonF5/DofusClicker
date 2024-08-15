class_name HitEffectResource
extends Resource

enum HitEffectType {
	NONE,
}

@export var _id: int
@export var _description: String
@export var _type: HitEffectType
@export var _amounts: AmountResource


static func map(data: Dictionary, crit_bonus: int) -> HitEffectResource:
	var resource = HitEffectResource.new()
	resource._id = data["effectId"]
	var min = data["diceNum"]
	var max = data["diceSide"]
	resource._amounts = AmountResource.create(min, max, min + crit_bonus, max + crit_bonus)
	return resource


static func get_hit_effect_type_from_api(data) -> HitEffectType:
	return HitEffectType.NONE
