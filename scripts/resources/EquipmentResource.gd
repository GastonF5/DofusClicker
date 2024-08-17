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


@export var type: Type
@export var stats: Array[StatResource]
@export var weapon_resource: WeaponResource


func get_type() -> String:
	return Type.find_key(type)


func is_weapon() -> bool:
	return type == Type.ARME


static func map(data: Dictionary) -> EquipmentResource:
	var resource = EquipmentResource.new()
	resource.type = EquipmentResource.get_equip_type(Datas._types.get(data["typeId"] as int)._name)
	resource.stats = EquipmentResource.build_stats(data["effects"])
	if resource.is_weapon():
		resource.weapon_resource = WeaponResource.map(data)
	return resource


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


static func build_stats(effects: Array) -> Array[StatResource]:
	var result: Array[StatResource] = []
	for effect in effects:
		var charac_type = API.get_carach_type_from_id(effect["characteristic"] as int)
		if charac_type != -1:
			result.append(StatResource.create(charac_type, effect["from"], effect["to"]))
	return result


func load_save(data: Dictionary):
	for stat in stats:
		stat.amount = data[stat.type]
