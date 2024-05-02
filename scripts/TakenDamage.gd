extends Label
class_name TakenDamage


func init(amount: int):
	text = "-" + str(amount)
	position = Vector2(62.5, 150)
	do_tween()
	await create_timer(1).timeout
	queue_free()


func do_tween():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(0, 50), 1).as_relative().set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, 1).set_trans(Tween.TRANS_BACK)


func create_timer(time: float):
	var timer = Timer.new()
	timer.wait_time = time
	add_child(timer)
	timer.start()
	return timer
