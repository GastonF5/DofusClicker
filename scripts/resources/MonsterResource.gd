class_name MonsterResource
extends Resource


@export var name: String
@export var monster_id: int
@export var race_id: int
@export var race: String

@export var texture: Texture2D
@export var image_url: String

@export var boss: bool
@export var archimonstre: bool
@export var corresponding_archimonstre_id: int
@export var corresponding_non_archimonstre_id: int

@export var grades: Array[GradeResource]

@export var spells: Array
@export var drops: Array[DropResource]

@export var favorite_area: int
@export var areas: Array
