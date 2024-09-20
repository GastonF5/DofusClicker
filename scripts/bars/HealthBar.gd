class_name HealthBar extends CustomBar


@export var shield_full_texture: Texture2D
@export var shield_label: Label


var shield_val: int:
	set(val):
		shield_val = val
		if shield_val < 0:
			shield_val = 0
		else:
			$ArmorTexture.visible = val > 0
			update_texture()
			shield_label.text = str(val)


func update_texture():
	if $ArmorTexture.visible:
		texture_progress = shield_full_texture
	else:
		texture_progress = full_texture


# Renvoie le montant à éroder
func take_damage(amount: int, ignore_shield := false) -> int:
	if amount < 0:
		take_soin(-amount)
		return 0
	var reste := amount
	if !ignore_shield:
		reste = max(amount - shield_val, 0)
	shield_val -= amount - reste
	if reste > 0:
		if cval - reste <= min_value:
			reste = cval
			cval = min_value as int
		elif cval - reste > mval:
			reste = -(mval - cval)
			cval -= reste
		else:
			cval -= reste
	return reste


func take_soin(amount: int):
	cval += amount
