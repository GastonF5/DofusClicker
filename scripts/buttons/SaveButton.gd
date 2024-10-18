class_name SaveButton
extends Control

static var scene = preload("res://scenes/buttons/save_button.tscn")

static func create(save_res: SaveResource) -> SaveButton:
	var save_btn = SaveButton.scene.instantiate()
	save_btn.file_name = save_res.date.replace("T", "-").replace(":", "_") + ".tres"
	save_btn.date = SaveManager.format_date(save_res.date)
	save_btn.name = save_res.date
	save_btn.button.text = "Niveau %d - %s" % [Globals.xp_bar.get_lvl(save_res.xp_amount), save_btn.date]
	save_btn.class_texture.texture = Globals.class_peeker.get_logo(save_res.class_id)
	save_btn.close_button.callable_on_close = save_btn.open_confirmation_popup
	return save_btn


@export var class_texture: TextureRect
@export var close_button: CloseButton
@export var button: Button

var file_name: String
var date: String

var save_callable: Callable:
	set(value):
		save_callable = value
		button.button_up.connect(save_callable)


signal deleted


func open_confirmation_popup():
	var confirm_popup = ConfirmationPopup.scene.instantiate()
	confirm_popup.popup_label = "Vous êtes sur le point de supprimer la sauvegarde du %s\nÊtes-vous sûr ?" % date
	confirm_popup.cancel_label = "Non"
	confirm_popup.confirm_label = "Oui"
	get_tree().current_scene.add_child(confirm_popup)
	confirm_popup.confirm.connect(func():
		SaveManager.delete_save(self)
		deleted.emit())
