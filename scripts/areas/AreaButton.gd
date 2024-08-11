class_name AreaButton
extends PanelContainer


const area_btn_scene = preload("res://scenes/areas/area_button.tscn")

@export var _icon_txt: TextureRect
@export var _area_name_lbl: Label
@export var _level_lbl: Label

var _new := true:
	set(value):
		_new = value
		_icon_txt.visible = value
var _area_id: int
var _is_dungeon: bool

var clicked_callable: Callable

signal button_up


func init(area_res: AreaResource, icon_txt: Texture2D):
	_area_id = area_res._id
	name = str(_area_id)
	_area_name_lbl.text = area_res._name
	if area_res._level > 0:
		_level_lbl.text = "Niveau %d" % area_res._level
	else:
		_level_lbl.visible = false
	_icon_txt.texture = icon_txt


static func create(area_id: int, callable: Callable, icon_txt: Texture2D, subarea: bool, is_dungeon := false) -> AreaButton:
	var area_btn = area_btn_scene.instantiate()
	var area_res = Datas._subareas[area_id] if subarea else Datas._areas[area_id]
	area_btn.init(area_res, icon_txt)
	area_btn._is_dungeon = is_dungeon
	area_btn.clicked_callable = callable
	return area_btn


func is_subarea():
	return Datas._subareas.has(_area_id)


func _on_button_button_up():
	clicked_callable.call(_area_id)
	if !_is_dungeon and _new:
		_new = false
