class_name EquipmentResource
extends Resource

enum Type {
	COIFFE,
	CAPE,
	CEINTURE,
	BOTTES,
	AMULETTE,
	ANNEAU,
	ARME,
	BOUCLIER,
	NONE
}

enum SuperType {
	AMULETTE,
	ARME,
	ANNEAU,
	CEINTURE,
	BOTTES,
	CONSOMMABLE,
	BOUCLIER,
	CAPTURE,
	RESSOURCE,
	COIFFE,
	CAPE,
	FAMILIER,
	DOFUS_TROPHEE,
}

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


@export var type: Type
@export var weapon_type: WeaponType

@export var stats: Array[StatResource]
@export var per_crit: float
@export var effects: Array[EffectResource]


func get_type() -> String:
	return Type.find_key(type)


static func get_equip_type(type_label: String) -> Type:
	match type_label:
		"Chapeau":
			return EquipmentResource.Type.COIFFE
		"Bâton", "Baguette", "Arc", "Épée", "Marteau", "Pelle", "Hache", "Pioche", "Faux":
			return EquipmentResource.Type.ARME
		_:
			var keys = EquipmentResource.Type.keys()
			keys = keys.filter(func(k): return k.to_lower() == type_label.to_lower())
			if keys.size() == 1:
				return EquipmentResource.Type.get(keys[0])
			return EquipmentResource.Type.NONE
