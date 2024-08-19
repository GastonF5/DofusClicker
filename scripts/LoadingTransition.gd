class_name LoadingTransition
extends CanvasLayer


@export var black: Panel


func _enter_tree():
	visible = true
	fade_out()


func fade_up():
	visible = true
	var tween = create_tween()
	tween.tween_property(black, "modulate", Color.WHITE, 0.5).set_trans(Tween.TRANS_LINEAR)
	await tween.finished


func fade_out():
	var tween = create_tween()
	tween.tween_property(black, "modulate", Color.TRANSPARENT, 0.5).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	visible = false
