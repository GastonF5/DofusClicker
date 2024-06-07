class_name SpellResource
extends Resource


@export var id: int
@export var name: String
@export_multiline var description: String

@export_category("Texture")
@export var texture: Texture2D
@export var img_url: String

@export_category("")
@export var pa_cost: int
@export var per_crit: float
@export var cooldown: float
@export var priority: int

@export_category("Effects")
@export var effects: Array[EffectResource]


func load_texture(api: API):
	if texture:
		return texture
	await api.await_for_request_completed(api.request(img_url))
	texture = api.get_texture(img_url)
	return texture
