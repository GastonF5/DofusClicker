class_name EquipmentResource
extends Resource

enum Type {
	COIFFE,
	CAPE,
	CEINTURE,
	BOTTES,
	AMULETTE,
	ANNEAU
}


@export var type: Type

@export var stats: Array[StatResource]


func get_type() -> String:
	return Type.find_key(type)
