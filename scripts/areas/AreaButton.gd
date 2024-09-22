class_name AreaButton
extends PanelContainer


const area_btn_scene = preload("res://scenes/areas/area_button.tscn")

@export var _icon_txt: TextureRect
@export var _area_name_lbl: Label
@export var _level_lbl: Label

var _new: bool:
	set(value):
		_new = value
		if !_is_dungeon:
			_icon_txt.visible = value

var _area_id: int
var super_area_id: int
var _subarea: bool:
	get: return super_area_id != -1

var _is_dungeon: bool
var level: int

var clicked_callable: Callable

var disabled: bool:
	get:
		return $Button.disabled
	set(val):
		$Button.disabled = val
		if !val:
			modulate = Color.WHITE
		else:
			modulate = Color.DIM_GRAY

signal button_up


func init(area_res: AreaResource, icon_txt: Texture2D, is_dungeon: bool):
	_area_id = area_res._id
	super_area_id = area_res._super_area_id
	_is_dungeon = is_dungeon
	if _subarea:
		disabled = true
		_new = false
	name = str(_area_id)
	_area_name_lbl.text = area_res._name
	level = area_res._level
	if level > 0:
		_level_lbl.text = "Niveau %d" % level
	else:
		_level_lbl.visible = false
	_icon_txt.texture = icon_txt


static func create(area_id: int, callable: Callable, icon_txt: Texture2D, subarea: bool, is_dungeon := false) -> AreaButton:
	var area_btn = area_btn_scene.instantiate()
	var area_res = Datas._subareas[area_id] if subarea else Datas._areas[area_id]
	area_btn.init(area_res, icon_txt, is_dungeon)
	area_btn.clicked_callable = callable
	return area_btn


func is_subarea():
	return Datas._subareas.has(_area_id)


func _on_button_button_up():
	clicked_callable.call(_area_id)
	if (!_is_dungeon and _new) or !_subarea:
		_new = false


func is_available(lvl: int):
	if _is_dungeon:
		return level <= lvl
	return level <= lvl + 3
