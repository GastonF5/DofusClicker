class_name ConfirmationPopup
extends CanvasLayer


@export var label: Label
@export var cancel_btn: Button
@export var confirm_btn: Button


var popup_label:
	set(value):
		label.text = value
	get:
		return label.text

var cancel_label:
	set(value):
		cancel_btn.text = value
	get:
		return cancel_btn.text

var confirm_label:
	set(value):
		confirm_btn.text = value
	get:
		return confirm_btn.text


signal cancel
signal confirm


static func create() -> ConfirmationPopup:
	var conf_popup = load("res://scenes/confirmation_popup.tscn").instantiate()
	return conf_popup


func _on_cancel_button_button_up():
	cancel.emit()
	self_destroy()


func _on_confirm_button_button_up():
	confirm.emit()
	self_destroy()


func self_destroy():
	visible = false
	queue_free()
