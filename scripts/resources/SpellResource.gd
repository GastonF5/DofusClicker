class_name SpellResource
extends Resource


@export var id: int
@export var name: String
@export var available := true
@export_multiline var description: String

@export_category("Texture")
@export var texture: Texture2D
@export var img_url: String

@export_category("")
@export var level: int
@export var pa_cost: int
@export var per_crit: float
@export var cooldown: float
@export var priority: int

@export_category("Effects")
@export var effects: Array[EffectResource]


func load_texture():
	if texture:
		return texture
	if !img_url:
		img_url = "https://api.dofusdb.fr/img/spells/sort_%d.png" % id
	await API.await_for_request_completed(await API.request(img_url))
	texture = API.get_texture(img_url)
	return texture


func get_zone() -> EffectResource.Zone:
	if effects.all(func(e): return e.effective_zone == EffectResource.Zone.MELEE):
		return EffectResource.Zone.MELEE
	if effects.all(func(e): return e.effective_zone == EffectResource.Zone.DISTANCE):
		return EffectResource.Zone.DISTANCE
	return EffectResource.Zone.ALL
