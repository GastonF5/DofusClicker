class_name LoadingScreen
extends CanvasLayer


@export var loading_pb: ProgressBar
@export var progress_text: TextureRect
@export var loading_label: Label

var loading = false:
	set(value):
		loading = value
		update_visibility()
		if loading:
			reset()

var vec: Vector2


func _ready():
	vec = Vector2(progress_text.size.x / 2, progress_text.size.y / 4)
	progress_text.position = loading_pb.position
	reset()


func update_visibility():
	self.visible = loading


func set_max_value(mv: float):
	loading_pb.max_value = mv


func set_loading_label(text: String):
	loading_label.text = text


func increment_loading(times := 1):
	set_value(loading_pb.value + times)


func reset():
	set_value(0)


func set_value(v: int):
	loading_pb.value = v
	var x_pos = (loading_pb.value * loading_pb.size.x) / loading_pb.max_value
	progress_text.position = loading_pb.position + Vector2(x_pos, 0) - vec


func print_loading_pb():
	print("%d / %d" % [loading_pb.value as int, loading_pb.max_value as int])
