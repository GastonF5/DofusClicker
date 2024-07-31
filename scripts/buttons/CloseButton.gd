class_name CloseButton
extends Button


var callable_on_close: Callable


static func create(callable: Callable) -> CloseButton:
	var close_btn = load("res://scenes/buttons/close_button.tscn").instantiate()
	close_btn.callable_on_close = callable
	return close_btn


func _on_button_up():
	if callable_on_close:
		callable_on_close.call()
	else:
		push_error("Callable on close not set for CloseButton %s" % name)
