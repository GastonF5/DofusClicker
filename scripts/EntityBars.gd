class_name EntityBars
extends Control


@export_category("TextureProgressBars")
@export var hp_bar: TextureProgressBar
@export var pa_bar: TextureProgressBar
@export var pm_bar: TextureProgressBar


func _ready():
	$Decoration.position.y += 10
