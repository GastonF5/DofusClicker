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
	BOUCLIER
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

@export var attack_type: Caracteristique.Element
@export var min_attack: int
@export var max_attack: int


func get_type() -> String:
	return Type.find_key(type)
