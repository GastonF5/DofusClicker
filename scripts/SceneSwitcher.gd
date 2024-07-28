extends Node

var _params = null


func change_scene(next_scene, params = null):
	_params = params
	get_tree().change_scene_to_packed(next_scene)


func get_param(pname):
	if _params and _params.has(pname):
		return _params[pname]
	return null
