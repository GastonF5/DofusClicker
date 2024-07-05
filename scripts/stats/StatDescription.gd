class_name StatDescription
extends Control


@export var txt: TextureRect
@export var lbl: Label


func update(texture: Texture2D, label: String):
	txt.texture = texture
	lbl.text = label if label != "" else "0"
