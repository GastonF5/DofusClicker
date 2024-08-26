class_name Loading extends TextureRect


var rotating := false

func _process(_delta):
	if visible and !rotating:
		rotate()


func rotate():
	rotating = true
	rotation = -360.0
	var tween = create_tween()
	tween.tween_property(self, "rotation", 360.0, 100).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	rotating = false
