class_name ThreadedLoadingTexture
extends Resource


var thread: Thread
@export var texture: Texture2D


func _load(path: String, id: int):
	if is_instance_valid(thread) and thread.is_started():
		thread.wait_to_finish()
	thread = Thread.new()
	log.debug("Start loading texture : %d" % id)
	thread.start(_bg_load.bind(path, id))


func _bg_load(path: String, id: int) -> Texture2D:
	var tex: Texture2D = FileLoader.load_asset(path, id)
	_bg_load_done.call_deferred()
	return tex


func _bg_load_done() -> void:
	if thread:
		var tex: Texture2D = thread.wait_to_finish()
		thread = null
		texture = tex
