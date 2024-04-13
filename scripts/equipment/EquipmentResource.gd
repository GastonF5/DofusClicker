class_name EquipmentResource
extends Resource

enum Type {
	COIFFE,
	CAPE,
	CEINTURE,
	BOTTES,
	AMULETTE,
	ANNEAU,
	ARME
}


@export var equip_type: Type

@export var stats: Array[StatResource]
