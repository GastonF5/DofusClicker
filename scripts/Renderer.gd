class_name Renderer
extends Node


const RENDERER_URL = "https://renderer.dofusdb.fr/look/%s/full/1/%d_%d.png"

@onready var api: API = $"%API"


func stringToHex(s: String):
	return s.to_utf8_buffer().hex_encode()


func get_url(monster_data, resolution: int) -> String:
	return RENDERER_URL % [stringToHex(monster_data["look"]), resolution, resolution]


func get_monster_texture(monster_data, resolution: int):
	var url = get_url(monster_data, resolution)
	await api.await_for_request_completed(api.request(url))
	#return api.get_texture(url)
