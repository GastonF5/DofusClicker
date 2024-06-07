class_name CustomBar
extends TextureProgressBar


@export var auto_fill: bool
@export var speed: float

@export_category("Texture")
@export var full_texture: Texture2D
@export var empty_texture: Texture2D

@export_category("Labels")
@export var value_label: Label
@export var max_value_label: Label

@export_category("Values")
@export var cval: int:
	get:
		return cval if auto_fill else value
	set(val):
		if auto_fill and val < cval:
			value = 0
		cval = val
		if !auto_fill: value = val
		if cval > mval: cval = mval
		update_value_label()
		cval_change.emit()

@export var mval: int:
	get:
		return mval if auto_fill else max_value
	set(val):
		mval = val
		if !auto_fill: max_value = val
		if cval > mval: cval = mval
		update_max_value_label()

signal cval_change

func _ready():
	texture_under = empty_texture
	texture_progress = full_texture
	setup_labels()
	global_position -= size / 2.0
	if auto_fill:
		value = max_value
		cval = mval


func setup_labels():
	update_value_label()
	update_max_value_label()
	if auto_fill:
		max_value_label.visible = false
		max_value_label.queue_free()
		max_value_label = null
		value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func _process(delta):
	if auto_fill:
		if cval < mval or value <= max_value:
			value += float(delta * speed)
			# si la barre est complète, on gagne 1 PA et on reset la barre
			if value >= max_value:
				cval += 1
				value = min_value if cval < mval else max_value


func update_value_label():
	if value_label:
		value_label.text = str(cval)


func update_max_value_label():
	if max_value_label:
		max_value_label.text = str(mval)


func reset():
	cval = mval
	if auto_fill:
		value = max_value
