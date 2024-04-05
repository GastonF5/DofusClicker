class_name Monster
extends ClickableControl


@export var name_label: Label
@export var texture_rect: TextureRect
@export var health_bar: ProgressBar
@export var health_label: Label
@export var selected_arrow: TextureRect
@export var header_image: TextureRect

var resource: MonsterResource

signal dies


func init(res: MonsterResource):
	name = res.name
	name_label.text = res.name
	init_clickable($"VBC/VBC/MonsterContainer")
	selected_arrow.visible = false
	texture_rect.texture = res.texture
	health_bar.max_value = res.max_health
	health_bar.value = health_bar.max_value
	resource = res
	if res.boss:
		header_image.texture = load("res://assets/ui/icons/boss.png")
	elif res.archimonstre:
		header_image.texture = load("res://assets/ui/icons/archimonstre.png")
	else:
		header_image.texture = null
	update_health_label()


func take_damage(amount: int):
	health_bar.value -= amount
	update_health_label()
	if health_bar.value <= health_bar.min_value:
		die()


func update_health_label():
	health_label.text = "%d/%d" % [health_bar.value, health_bar.max_value]


func die():
	for item_res in resource.drop:
		get_tree().root.get_node("Main/GameManager").inventory.add_item(Item.create(item_res))
	health_bar.value = health_bar.min_value
	get_parent().remove_child(self)
	dies.emit(resource.xp_gain)
	queue_free()
