class_name EntityBars
extends Control


@export_category("TextureProgressBars")
@export var hp_bar: TextureProgressBar
@export var pa_bar: TextureProgressBar
@export var pm_bar: TextureProgressBar

@export var decoration: TextureRect

func _ready():
	if decoration:
		decoration.position.y += 10
