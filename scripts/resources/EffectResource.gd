class_name EffectResource
extends Resource


enum Type {
	DAMAGE,
	BONUS,
	RETRAIT,
	SPECIAL,
	RANDOM,
	POISON,
	INVOCATION,
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

@export_group("Damage")
@export var element: Caracteristique.Element
@export var lifesteal: bool

@export_group("Bonus & Retrait")
@export var caracteristic: Caracteristique.Type

@export_group("Special")
@export var method_name: StringName
@export var params: Array

@export_group("Random")
@export var nb_random_effects: int

@export_category("Amounts")
@export var amounts: Array[AmountResource]


func get_amount(crit: bool, grade: int) -> int:
	return amounts[grade].get_random(crit)
