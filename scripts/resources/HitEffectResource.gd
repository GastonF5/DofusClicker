class_name HitEffectResource
extends Resource

const Element = Caracteristique.Element
const CaracType = Caracteristique.Type

enum HitEffectType {
	NONE,
}

@export var _id: int
@export var _type: HitEffectType
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


func get_characteristic(for_effect: bool):
	var element = get_element()
	if element != Element.NONE:
		return CaracType.get("DO_%s" % Element.find_key(element))
	else:
		if get_description().contains("PA"):
			return CaracType.RET_PA if for_effect else CaracType.PA
		else:
			return CaracType.RET_PM if for_effect else CaracType.PM


func get_type():
	return _type
