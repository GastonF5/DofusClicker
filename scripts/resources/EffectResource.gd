class_name EffectResource
extends Resource


enum Type {
	DAMAGE,
	BONUS,
	RETRAIT,
	SPECIAL,
	RANDOM,
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
@export var lifesteal: bool

@export_category("Bonus & Retrait")
@export var caracteristic: Caracteristique.Type

@export_category("Special")
@export var method_name: StringName
@export var params: Array

@export_category("Random")
@export var nb_random_effects: int

@export_category("Amounts")
@export var min_amounts: Array[int]
@export var max_amounts: Array[int]
@export var crit_min_amounts: Array[int]
@export var crit_max_amounts: Array[int]


func get_amount(crit: bool, grade: int) -> int:
	if crit:
		return randi_range(crit_min_amounts[grade], crit_max_amounts[grade])
	else:
		return randi_range(min_amounts[grade], max_amounts[grade])
