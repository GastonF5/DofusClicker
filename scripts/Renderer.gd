class_name Renderer


const RENDERER_URL = "https://renderer.dofusdb.fr/look/%s/full/1/%d_%d.png"


static func stringToHex(s: String):
	return s.to_utf8_buffer().hex_encode()


static func get_url(monster_data, resolution: int = 200) -> String:
	return RENDERER_URL % [stringToHex(monster_data["look"]), resolution, resolution]
