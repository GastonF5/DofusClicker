class_name ConsommableResource
extends Resource


const EffectType = EffectResource.Type

const ID_NO_MATCH_ERROR := "L'id du consommable %s n'est pas en accord avec l'id de l'item"
const ID_NOT_EXISTS_ERROR := "L'id du consommable %s n'existe pas."
const EFFECT_ERROR := "Le consommable %s contient un effet de type %s (non pris en charge)"


@export var item_id: int
@export var effects: Array[ConsommableEffect]


func get_item_res() -> ItemResource:
	if Datas._consommables.has(item_id):
		var item_res: ItemResource = Datas._consommables[item_id]
		if item_res.consommable != self:
			log.error(ID_NO_MATCH_ERROR % resource_name)
			return null
		return item_res
	else:
		log.error(ID_NOT_EXISTS_ERROR % resource_name)
		return null


func consume():
	for effect: ConsommableEffect in effects:
		if effect.nb_fight == 0:
			var carac: Caracteristique = PlayerManager.player_entity.get_caracteristique_for_type(effect.characteristic)
			carac.amount += effect.amount
