extends Label
class_name TakenDamage

enum Type { DAMAGE, RET_PA, RET_PM }


func init(amount: int, type: Type):
	if amount >= 0:
		text = "-" + str(amount)
	if amount < 0:
		text = "+" + str(-amount)
	label_settings = label_settings.duplicate()
	position = Vector2(0, 130)
	apply_position(type)
	apply_colors(type)
	do_tween()
	await SpellsService.create_timer(1.0, "TakenDamageTimer").timeout
	queue_free()


func do_tween():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(0, 50), 1).as_relative().set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, 1).set_trans(Tween.TRANS_BACK)


func apply_position(type: Type):
	position.x += get_parent().size.x / 2 - size.x / 2
	match type:
		Type.RET_PA:
			position += Vector2.LEFT * 80
		Type.RET_PM:
			position += Vector2.RIGHT * 80
		_:
			pass


func apply_colors(type: Type):
	var colors = get_colors_by_type(type)
	label_settings.font_color = colors[0]
	label_settings.shadow_color = colors[1]


func get_colors_by_type(type: Type) -> Array[Color]:
	var colors: Array[Color] = []
	match type:
		Type.DAMAGE:
			colors.assign([Color("ff6d5b"), Color("3c0000")])
		Type.RET_PA:
			colors.assign([Color("5cb3ff"), Color("001b33")])
		Type.RET_PM:
			colors.assign([Color("7cff5c"), Color("0a3300")])
	return colors
