extends Label
class_name TakenDamage


func init(amount: int):
	text = "-" + str(amount)
	do_tween()
	await create_timer(1).timeout
	queue_free()


func do_tween():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(0, 50), 1).as_relative()


func create_timer(time: float):
	var timer = Timer.new()
	timer.wait_time = time
	add_child(timer)
	timer.start()
	return timer
