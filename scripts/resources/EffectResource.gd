class_name EffectResource
extends Resource


enum Type {
	DAMAGE,
	BONUS,
	SPECIAL,
}

enum TargetType {
	CASTER,
	TARGET,
	TARGET_NEIGHBORS,
	NEIGHBORS,
	ALL_MONSTERS,
	ALL_ALLIES,
	RANDOM_MONSTER,
	RANDOM_ALLY,
	ALL,
}


@export var type: Type
@export var time: float
@export var target_type: TargetType

@export_category("Damage")
@export var element: Caracteristique.Element

@export_category("Bonus")
@export var caracteristic: Caracteristique.Type

@export_category("Special")
@export var method_name: String
@export var params: Array

@export_category("Amounts")
@export var min_amounts: Array[int]
@export var max_amounts: Array[int]
@export var crit_min_amounts: Array[int]
@export var crit_max_amounts: Array[int]
