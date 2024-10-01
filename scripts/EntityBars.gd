class_name EntityBars
extends Control


@export_category("TextureProgressBars")
@export var hp_bar: CustomBar
@export var pa_bar: CustomBar
@export var pm_bar: CustomBar

@export var decoration: TextureRect

func _ready():
	if decoration:
		decoration.position.y += 10
