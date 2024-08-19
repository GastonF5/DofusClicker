class_name HitEffectResource
extends Resource

const Element = Caracteristique.Element
const CaracType = Caracteristique.Type

@export var _id: int
@export var _element: Element
@export var _description: String
@export var _amounts: AmountResource


## Mapping pour les armes
static func map(data: Dictionary, crit_bonus: int) -> HitEffectResource:
	var resource = HitEffectResource.new()
	resource._id = data["effectId"]
	var minimum = data["diceNum"]
	var maximum = data["diceSide"]
	resource._amounts = AmountResource.create(minimum, maximum, minimum + crit_bonus, maximum + crit_bonus)
	return resource


## Mapping pour les datas
static func map_data(data: Dictionary) -> HitEffectResource:
	var resource = HitEffectResource.new()
	resource._id = data["id"]
	var description = data["description"]["fr"]
	resource._description = description.replace("#1{~1~2", "{0}").replace("}#2", "{1}")
	var element_id := data["elementId"] as int
	if element_id == -1:
		resource._element = Element.NONE
	else:
		resource._element = element_id
	return resource


func get_description() -> String:
	if _description:
		return _description
	if Datas._hit_effects.has(_id):
		var description: String = Datas._hit_effects[_id]._description
		description = description.replace("{0}", str(_amounts._min))
		description = description.replace("{1}", str(_amounts._max))
		return description
	push_error("Hit effect not found for id %s" % _id)
	return "NO HIT EFFECT FOUND"


func get_element() -> Element:
	if _element:
		return _element
	if Datas._hit_effects.has(_id):
		return Datas._hit_effects[_id]._element
	push_error("Hit effect not found for id %s" % _id)
	return Caracteristique.Element.NONE


func get_characteristic() -> CaracType:
	var element = get_element()
	if element != Element.NONE:
		if get_description().contains("soins"):
			return CaracType.SOIN
		return CaracType.get("DO_%s" % Element.find_key(element))
	else:
		if get_description().contains("PA"):
			return CaracType.PA
		else:
			return CaracType.PM


func get_effect_label() -> String:
	var label: String
	var element = Element.find_key(get_element()).to_pascal_case()
	var vol = get_description().contains("vol")
	var characteristic = get_characteristic()
	match characteristic:
		CaracType.SOIN:
			label = "soins %s" % element
		CaracType.DO_AIR, CaracType.DO_EAU, CaracType.DO_FEU, CaracType.DO_NEUTRE, CaracType.DO_TERRE:
			label = "%s %s" % ["vol" if vol else "dommages", element]
		CaracType.PA, CaracType.PM:
			label = CaracType.find_key(characteristic)
		_:
			label = "NOT SUPPORTED"
			push_error("Not supported characteristic for hit effect : %s" % CaracType.find_key(characteristic))
	var result: String
	if _amounts._min >= _amounts._max:
		result = "%d %s" % [_amounts._min, label]
	else:
		result = "%d à %d %s" % [_amounts._min, _amounts._max, label]
	if [CaracType.RET_PA, CaracType.RET_PM].has(characteristic):
		result = result.insert(0, "-")
	return result


func get_effect() -> EffectResource:
	var effect = EffectResource.new()
	var description = get_description()
	var effects_label = ["dommages", "vol", "soins"]
	if effects_label.any(func(e): return description.contains(e)):
		if description.contains("dommages") or description.contains("vol"):
			effect.type = EffectResource.Type.DAMAGE
			effect.target_type = EffectResource.TargetType.TARGET
			if description.contains("vol"):
				effect.lifesteal = true
		if description.contains("soins"):
			effect.type = EffectResource.Type.SOIN
			effect.target_type = EffectResource.TargetType.CASTER
		effect.element = get_element()
	else:
		effect.type = EffectResource.Type.RETRAIT
		effect.caracteristic = get_characteristic()
		effect.target_type = EffectResource.TargetType.TARGET
	effect.amounts.assign([_amounts])
	return effect
