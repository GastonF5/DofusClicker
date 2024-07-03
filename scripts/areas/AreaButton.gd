class_name AreaButton
extends PanelContainer


const area_btn_scene = preload("res://scenes/areas/area_button.tscn")

@export var _icon_txt: TextureRect
@export var _label: Label
@export var _btn: Button

var new := true
var area_id: int
var is_dungeon: bool

var clicked_callable: Callable

signal button_up


func init(area_res: AreaResource, icon_txt: Texture2D):
	area_id = area_res._id
	name = str(area_id)
	_label.text = area_res._name
	_icon_txt.texture = icon_txt


static func create(area_res: AreaResource, callable: Callable, icon_txt: Texture2D, is_dungeon := false) -> AreaButton:
	var area_btn = area_btn_scene.instantiate()
	area_btn.init(area_res, icon_txt)
	area_btn.is_dungeon = is_dungeon
	area_btn.clicked_callable = callable
	return area_btn


func _on_button_button_up():
	clicked_callable.call(area_id)
	if !is_dungeon and new:
		_icon_txt.texture = null
		new = false
