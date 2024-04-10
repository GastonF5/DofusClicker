class_name MonsterResource
extends Resource


@export var name: String
@export var texture: Texture2D
@export var max_health: int
@export var xp_gain: int

@export var hit_time: float
@export var damage: int

@export var boss: bool
@export var archimonstre: bool

@export var drop: Array[ItemResource]
