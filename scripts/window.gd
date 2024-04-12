extends PanelContainer


@export var bg_text: Texture2D


func _ready():
	$"Content/Background".texture = bg_text
